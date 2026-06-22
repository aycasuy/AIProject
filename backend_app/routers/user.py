import random

from fastapi import APIRouter, Depends, HTTPException
from requests import request
from sqlalchemy import func
from sqlalchemy.orm import Session
import bcrypt 
import models
from database import SessionLocal
from models import DailyXPLog, UserDB, UserProgressDB
import schemas

router = APIRouter()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# --- ŞİFRELEME YARDIMCI FONKSİYONLARI ---
def hash_password(password: str) -> str:
    # Şifreyi byte'a çevirip 72 karakter sınırını koruyoruz
    pwd_bytes = password[:72].encode('utf-8')
    salt = bcrypt.gensalt()
    hashed_password = bcrypt.hashpw(pwd_bytes, salt)
    return hashed_password.decode('utf-8')

def verify_password(plain_password: str, hashed_password: str) -> bool:
    password_byte_enc = plain_password[:72].encode('utf-8')
    hashed_password_byte_enc = hashed_password.encode('utf-8')
    return bcrypt.checkpw(password_byte_enc, hashed_password_byte_enc)

# --- 1. KAYIT OL (REGISTER) ---
@router.post("/register")
def register(request: schemas.UserRegister, db: Session = Depends(get_db)):
    existing_user = db.query(models.UserDB).filter(
        (models.UserDB.username == request.username) | (models.UserDB.email == request.email)
    ).first()
    
    if existing_user:
        raise HTTPException(status_code=400, detail="Bu kullanıcı adı veya e-posta zaten kullanımda!")

    # Yeni nesil kendi şifreleme fonksiyonumuzu kullanıyoruz
    hashed_pwd = hash_password(request.password)

    new_user =models.UserDB(
        username=request.username, 
        email=request.email, 
        hashed_password=hashed_pwd, 
        native_language=""
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)

    # 3. İLİŞKİLİ TABLOYA (user_progress) İLK DİL DOSYASINI AÇMA
    

    return {"mesaj": "Kayıt başarıyla oluşturuldu ve dil dosyası açıldı!"}

    

# --- 2. GİRİŞ YAP (LOGIN) ---
@router.post("/login")
def login(user: schemas.UserLogin, db: Session = Depends(get_db)):
    db_user = db.query(UserDB).filter(UserDB.username == user.username).first()
    if not db_user:
        raise HTTPException(status_code=404, detail="Kullanıcı bulunamadı!")
    
    # Yeni nesil kendi doğrulama fonksiyonumuzu kullanıyoruz
    if not verify_password(user.password, db_user.hashed_password):
        raise HTTPException(status_code=401, detail="Şifre hatalı!")

    # 🌟 1. Kullanıcının seviyesini öğrenmek için ilerleme tablosuna bakıyoruz
    user_prog = db.query(UserProgressDB).filter(UserProgressDB.user_id == db_user.id).first()
    
    # 🌟 2. Eğer kayıtlı bir seviyesi yoksa çökmemsi için varsayılan değer atıyoruz
    # (Senin veritabanında sütun adın current_level veya level olabilir, ona göre düzeltirsin)
    level_value = user_prog.current_level if user_prog and hasattr(user_prog, 'current_level') else "Belirlenmedi"

    # 🌟 3. FLUTTER'A GİDECEK OLAN DOLU DOLU KARGO PAKETİ
    return {
        "message": "Giriş Başarılı", 
        "username": db_user.username,
        # db_user içindeki sütun adlarına göre eşleştir (native_language ve target_language):
        "native_language": getattr(db_user, 'native_language', ""),
        "target_language": getattr(db_user, 'target_language', ""),
        "level": level_value
    }

# --- 3. İLERLEME KAYDET ---
#@router.post("/save_progress")
#def save_progress(request: schemas.ProgressUpdateRequest, db: Session = Depends(get_db)):
   # user = db.query(models.UserDB).filter(models.UserDB.username == request.username).first()
   # if not user:
    #    raise HTTPException(status_code=404, detail="Kullanıcı bulunamadı")
    

  #  progress = db.query(models.UserProgressDB).filter(
  #      models.UserProgressDB.user_id == user.id,
  #      models.UserProgressDB.target_language == "English"
   # ).first()
  #  if not progress:
   #     progress = models.UserProgressDB(user_id=user.id, target_language="English")
   #     db.add(progress)
    
   
   # progress.level = request.new_level
  #  progress.xp_score += request.added_xp
  #  db.commit()
    
   # return {"mesaj": f"Tebrikler! Yeni seviye: {progress.level}, Toplam XP: {progress.xp_score}"}



@router.post("/update_languages")
def update_languages(request: schemas.LanguageUpdateRequest, db: Session = Depends(get_db)):
    # 1. Kullanıcıyı ana tabloda bul
    user = db.query(models.UserDB).filter(models.UserDB.username == request.username).first()
    
    if not user:
        raise HTTPException(status_code=404, detail="Kullanıcı bulunamadı!")

    # 2. Ana dilini güncelle (users tablosu)
    user.native_language = request.native_language
    
    # 3. Öğrenmek istediği dili user_progress tablosunda ara
    progress = db.query(models.UserProgressDB).filter(
        models.UserProgressDB.user_id == user.id,
        models.UserProgressDB.target_language == request.target_language
    ).first()

    # 4. Eğer bu dili ilk defa seçiyorsa ona yeni bir gelişim dosyası (satır) aç
    if not progress:
        new_progress = models.UserProgressDB(
            user_id=user.id,
            target_language=request.target_language,
            level="Belirlenmedi",
            xp_score=0
        )
        db.add(new_progress)
    
    # Tüm işlemleri kaydet
    db.commit()
    
    return {
        "mesaj": "Diller başarıyla güncellendi ve dosya açıldı!", 
        "native_language": user.native_language, 
        "target_language": request.target_language
    }


# 🌟 DİKKAT: Artık sadece username değil, target_language de alıyor!
@router.get("/get_user_stats/{username}")
def get_user_stats(username: str, target_language: str = "English", db: Session = Depends(get_db)):
    # 1. Kullanıcıyı bul
    user = db.query(models.UserDB).filter(models.UserDB.username == username).first()
    if not user:
        raise HTTPException(status_code=404, detail="Kullanıcı bulunamadı!")

    # 2. Kullanıcının SEÇTİĞİ DİLDEKİ gelişimini bul
    progress = db.query(models.UserProgressDB).filter(
        models.UserProgressDB.user_id == user.id,
        models.UserProgressDB.target_language == target_language
    ).first()

    level = progress.level if progress else "Belirlenmedi"
    xp = progress.xp_score if progress else 0

    # 🌟 İŞTE MÜKEMMEL UX'İ KURTARACAK O PAKET:
    return {
        "username": user.username,
        "target_language": target_language,
        "level": level,
        "xp_score": xp,
        "native_language": user.native_language if user.native_language else "" # 🌟 EKSİK OLAN SATIR EKLENDİ!
    }

# 1. Kelimeyi Veritabanına Kaydetme Kapısı
@router.post("/add_vocabulary")
def add_vocabulary(request: schemas.AddVocabularyRequest, db: Session = Depends(get_db)):
    user = db.query(models.UserDB).filter(models.UserDB.username == request.username).first()
    if not user:
        raise HTTPException(status_code=404, detail="Kullanıcı bulunamadı")
        
    # Kelime zaten eklenmiş mi kontrol et
    existing_word = db.query(models.VocabularyDB).filter(
        models.VocabularyDB.user_id == user.id, 
        models.VocabularyDB.word == request.word,
        models.VocabularyDB.target_language == request.target_language

    ).first()
    
    if not existing_word:
        new_word = models.VocabularyDB(
            user_id=user.id, word=request.word, 
            translation=request.translation, cefr_level=request.cefr_level, target_language=request.target_language
        )
        db.add(new_word)
        db.commit()
        
    return {"message": "Kelime kumbaraya eklendi!"}

# 2. Kayıtlı Kelimeleri Getirme Kapısı (Kelime Kumbarası Ekranı İçin)
@router.get("/get_vocabulary/{username}")
def get_vocabulary(username: str, db: Session = Depends(get_db)):
    user = db.query(models.UserDB).filter(models.UserDB.username == username).first()
    if not user:
        raise HTTPException(status_code=404, detail="Kullanıcı bulunamadı")
        
    words = db.query(models.VocabularyDB).filter(models.VocabularyDB.user_id == user.id).all()
    return words

from datetime import date




# 3. Test Sonucu XP Ekleme Kapısı
#@router.post("/add_xp")
#def add_xp(request: schemas.AddXPRequest, db: Session = Depends(get_db)):
  #  user = db.query(models.UserDB).filter(models.UserDB.username == request.username).first()
  #  if not user:
   #     raise HTTPException(status_code=404)
        
   # progress = db.query(models.UserProgressDB).filter(
  #      models.UserProgressDB.user_id == user.id,
  #      models.UserProgressDB.target_language == request.target_language
  #  ).first()
    
   # if progress:
        # 🌟 XP FARMING ENGELLEME (GÜVENLİK GÖREVLİSİ BURADA)
        # Eğer oynadığı bölüm kullanıcının haritadaki seviyesinden küçükse
        # VEYA aynı bölümde ama oynadığı ders numarası küçükse -> BU BİR TEKRARDIR!
     #   is_replay = False
    #    if request.section < progress.current_section or \
     #      (request.section == progress.current_section and request.lesson < progress.current_lesson):
     #       is_replay = True
            
        # Eğer tekrarsa XP'yi 0 yap (İstersen sembolik 5 de yapabilirsin)
      #  actual_xp = 0 if is_replay else request.xp_amount

        # Eğer kazanılan XP 0'dan büyükse veritabanına işle
      #  if actual_xp > 0:
      #      progress.xp_score += actual_xp
      #      db.commit()
     #       return {
     #           "message": f"Başarılı! +{actual_xp} XP eklendi.", 
     #           "new_xp": progress.xp_score,
     #           "is_replay": False
     #       }
     #   else:
     #       return {
     #           "message": "Tekrar pratiği yapıldığı için XP eklenmedi.", 
      #          "new_xp": progress.xp_score,
      #          "is_replay": True
      #      }
            
   # return {"message": "İlerleme bulunamadı", "new_xp": 0}


@router.post("/add_xp")
def add_xp(request: schemas.AddXPRequest, db: Session = Depends(get_db)):
    user = db.query(models.UserDB).filter(models.UserDB.username == request.username).first()
    if not user:
        raise HTTPException(status_code=404)
        
    progress = db.query(models.UserProgressDB).filter(
        models.UserProgressDB.user_id == user.id,
        models.UserProgressDB.target_language == request.target_language
    ).first()
    
    if progress:
        # 🌟 YENİ: EĞER BÖLÜM 999 İSE (SERBEST PRATİK), HİLE KONTROLÜNE SOKMA!
        is_replay = False
        
        if request.section != 999: # 999 değilse, normal harita kurallarını işlet
            if request.section < progress.current_section or \
               (request.section == progress.current_section and request.lesson < progress.current_lesson):
                is_replay = True
            
        actual_xp = 0 if is_replay else request.xp_amount

        if actual_xp > 0:
            progress.xp_score += actual_xp
            
            # Günlük Log Tablosuna Ekle (Grafik dolsun diye)
            from datetime import datetime, timezone
            today = datetime.now(timezone.utc).date()
            daily_log = db.query(models.DailyXPLog).filter(
                models.DailyXPLog.user_id == user.id,
                models.DailyXPLog.date == today
            ).first()

            if daily_log:
                daily_log.xp_earned += actual_xp
            else:
                new_log = models.DailyXPLog(user_id=user.id, date=today, xp_earned=actual_xp)
                db.add(new_log)
                
            db.commit()
            return {
                "message": f"Başarılı! +{actual_xp} XP eklendi.", 
                "new_xp": progress.xp_score,
                "is_replay": False
            }
        else:
            return {
                "message": "Tekrar pratiği yapıldığı için XP eklenmedi.", 
                "new_xp": progress.xp_score,
                "is_replay": True
            }
            
    return {"message": "İlerleme bulunamadı", "new_xp": 0}




# Eğer router kullanıyorsan @router.get, app kullanıyorsan @app.get yap
@router.get("/api/users/{username}/progress")
def get_user_progress(username: str, language: str = "English", db: Session = Depends(get_db)):
    
    # 1. Önce Kullanıcıyı Bul
    user = db.query(models.UserDB).filter(models.UserDB.username == username).first()
    
    if not user:
        raise HTTPException(status_code=404, detail="Kullanıcı bulunamadı")
    

    # 2. Kullanıcının O DİLDEKİ ilerlemesini bul
    progress = db.query(models.UserProgressDB).filter(
        models.UserProgressDB.user_id == user.id,
        models.UserProgressDB.target_language == language
    ).first()

    # 3. YA O DİLDE DAHA ÖNCE HİÇ ÇALIŞMADIYSA? (Harika bir UX dokunuşu)
    if not progress:
        # Hata vermek yerine, ona yepyeni, sıfır kilometre bir ilerleme haritası açıyoruz!
        progress = models.UserProgressDB(
            user_id=user.id,
            target_language=language,
            level="A1",
            current_section=1,
            current_lesson=1,
            xp_score=0,
            streak_days=0,
            lives=5,
            last_active_date=date.today()
        )
        db.add(progress)
        db.commit()
        db.refresh(progress)

    # 4. EĞER KAYDI VARSA CANLARINI KONTROL ET VE YENİLE
    else:
        progress = refresh_hearts(progress)
        # 🌟🌟🌟 ALEV SÖNDÜRÜCÜ KONTROLÜ BURADA ÇALIŞIYOR 🌟🌟🌟
        today = date.today()
        if progress.last_active_date and progress.last_active_date < today - timedelta(days=1):
            if progress.streak_days > 0:
                progress.streak_days = 0 # Ateş acımasızca söndü!
                
        # (Eğer progress.last_active_date null ise diye bir güvenlik ağı da koyabiliriz)
        if not progress.last_active_date:
             progress.last_active_date = today
        db.commit()
    
    # 🌟 GERİ SAYIM İÇİN KALAN SANİYEYİ HESAPLAMA EKLENTİSİ
    remaining_seconds = 0
    if progress.lives < 5 and progress.last_heart_lost:
        from datetime import datetime
        now = datetime.now()
        diff = now - progress.last_heart_lost
        # Her can 30 dakika (1800 saniye). Kalan saniyeyi buluyoruz:
        cycle_seconds = diff.total_seconds() % 900  #cycle_seconds = diff.total_seconds() % 5
        remaining_seconds = int(900 - cycle_seconds)

    # 4. Veriyi Flutter'ın beklediği TAM formatta geri gönderiyoruz!
    return {
        "user_name": user.username,
        "level": progress.level,
        "current_section": progress.current_section,
        "current_lesson": progress.current_lesson,
        "xp_score": progress.xp_score,
        "streak_days": progress.streak_days,
        "lives": progress.lives,
        "remaining_seconds": remaining_seconds
    }

from datetime import date, timedelta
from fastapi import HTTPException, Depends
from sqlalchemy.orm import Session

@router.post("/update_progress") 
def update_progress(request: schemas.ProgressUpdateRequest, db: Session = Depends(get_db)):
    # 1. Kullanıcıyı bul
    user = db.query(models.UserDB).filter(models.UserDB.username == request.username).first()
    if not user:
        raise HTTPException(status_code=404, detail="Kullanıcı bulunamadı")
    
    # 2. İlerlemeyi bul
    progress = db.query(models.UserProgressDB).filter(
        models.UserProgressDB.user_id == user.id,
        models.UserProgressDB.target_language == request.target_language
    ).first()
    
    if not progress:
        progress = models.UserProgressDB(user_id=user.id, target_language=request.target_language)
        db.add(progress)

    is_replay = False
    
    # 🌟 GÜVENLİK FİLTRESİ: Flutter "Bana 500 XP ver" derse Backend izin vermez! Max sınır 50 XP
    requested_xp = request.added_xp if request.added_xp <= 50 else 50
    actual_xp = requested_xp 

    # 3. HARİTA KİLİTLERİNİ AÇMA VE TEKRAR KONTROLÜ
    # Kural: Oynanan Bölüm (Section) > Mevcut Bölüm İSE VEYA Bölümler aynı ama Ders (Lesson) > Mevcut Ders İSE
    if request.current_section > progress.current_section or \
       (request.current_section == progress.current_section and request.current_lesson > progress.current_lesson):
        
        # YENİ DERS! Haritayı ilerlet!
        progress.current_section = request.current_section
        progress.current_lesson = request.current_lesson
    else:
        # ESKİ DERS! Çiftçilik yapılmasına izin verme!
        is_replay = True
        actual_xp = 0  # 🛑 Tekrar için XP yok!
        print("🔄 [TEKRAR PRATİĞİ] Eski ders tekrarlandı. XP verilmeyecek.")

    # 4. XP EKLEME 
    progress.xp_score += actual_xp
    if getattr(request, "new_level", None): # Eğer new_level diye bir şey gelirse...
        progress.level = request.new_level

    # 5. GÜNLÜK XP GÜNCELLEMESİ (Sadece gerçek XP kazanıldıysa)
    today = date.today()
    if actual_xp > 0:
        daily_log = db.query(models.DailyXPLog).filter(
            models.DailyXPLog.user_id == user.id,
            models.DailyXPLog.date == today
        ).first()

        if daily_log:
            daily_log.xp_earned += actual_xp
        else:
            new_log = models.DailyXPLog(user_id=user.id, date=today, xp_earned=actual_xp)
            db.add(new_log)
    
    # 6. ALEV (STREAK) MANTIĞI
    if progress.last_active_date != today:
        if progress.last_active_date == today - timedelta(days=1):
            progress.streak_days += 1
        else:
            progress.streak_days = 1
            
        progress.last_active_date = today

    db.commit()
    
    mesaj = f"Harita güncellendi. +{actual_xp} XP kazanıldı!" if not is_replay else "Tekrar pratiği tamamlandı! (+0 XP)"
    
    return {
        "mesaj": mesaj,
        "new_section": progress.current_section,
        "new_lesson": progress.current_lesson,
        "streak_days": progress.streak_days, 
        "earned_xp": actual_xp,  
        "is_replay": is_replay   
    }

# main.py veya ilgili router
from datetime import datetime, timedelta

def refresh_hearts(progress):
    # 1. Eğer can zaten full ise zamanlayıcıyı tamamen kapat
    if progress.lives >= 5:
        progress.last_heart_lost = None
        return progress

    # 2. Canı eksik ama zamanlayıcısı yoksa, hemen başlat
    if not progress.last_heart_lost:
        progress.last_heart_lost = datetime.now()
        return progress

    # 3. Zaman farkını hesapla
    now = datetime.now()
    diff = now - progress.last_heart_lost
    total_seconds = diff.total_seconds()

    # 🌟 GİZLİ HATA ÇÖZÜCÜ: Eğer zaman eksiye düştüyse (Zaman kayması), saati sıfırla!
    if total_seconds < 0:
        progress.last_heart_lost = now
        return progress

    # 4. Kaç can kazandığını bul (TEST İÇİN 10 SANİYE)
    recovered_hearts = int(total_seconds // 900) # recovered_hearts = int(total_seconds // 5)

    if recovered_hearts > 0:
        progress.lives += recovered_hearts
        
        # Eğer can fullendiyse saati durdur
        if progress.lives >= 5:
            progress.lives = 5
            progress.last_heart_lost = None
        else:
            # Fullenmediyse, kazanılan can kadar süreyi ileri sar
            progress.last_heart_lost = progress.last_heart_lost + timedelta(seconds=10 * recovered_hearts) #progress.last_heart_lost = progress.last_heart_lost + timedelta(seconds=10 * recovered_hearts)

    return progress

@router.get("/get_progress/{username}")
def get_progress(username: str, db: Session = Depends(get_db)):
    progress = db.query(UserProgressDB).join(UserDB).filter(UserDB.username == username).first()
    if progress:
        progress = refresh_hearts(progress) # 🌟 Canları kontrol et ve yenile
        db.commit()
        return {
            "user_name": username,
            "level": progress.level,
            "current_section": progress.current_section,
            "current_lesson": progress.current_lesson,
            "xp_score": progress.xp_score,
            "streak_days": getattr(progress, "streak_days", 0), # Hata vermesin diye güvenlikli çektik
            
            "lives": progress.lives # 🌟 VE İŞTE EKSİK OLAN CANLAR BURADA!
        }
        
    return {"error": "Kullanıcı bulunamadı"}
    

@router.post("/save_progress")
def save_progress(request: schemas.PlacementResult, db: Session = Depends(get_db)):
    # 1. Kullanıcıyı bul
    user = db.query(models.UserDB).filter(models.UserDB.username == request.username).first()
    if not user:
        raise HTTPException(status_code=404, detail="Kullanıcı bulunamadı")
    
    # 2. İlerleme dosyasını bul
    progress = db.query(models.UserProgressDB).filter(
        models.UserProgressDB.user_id == user.id,
        models.UserProgressDB.target_language == request.target_language
    ).first()
    
    # 3. Dosyası yoksa aç, varsa seviyesini güncelle
    if not progress:
        progress = models.UserProgressDB(
            user_id=user.id,
            target_language=request.target_language, 
            level=request.level,
            xp_score=0
        )
        db.add(progress)
    else:
        progress.level = request.level # Sadece seviyeyi güncelliyoruz!
        
    db.commit()
    
    return {"message": f"Seviye başarıyla {request.level} olarak kaydedildi!"}



# Kendi router veya app objeni kullan

@router.get("/users/{user_name}/weekly-xp")
def get_weekly_xp(user_name: str, db: Session = Depends(get_db)):
     
     # 🌟 HATA BURADAYDI: request.username yerine URL'den gelen user_name'i kullandık!
     user = db.query(models.UserDB).filter(models.UserDB.username == user_name).first()
     if not user:
        raise HTTPException(status_code=404, detail="Kullanıcı bulunamadı")

    # 1. Bugünün tarihini ve 7 gün öncesini bul
     today = date.today()
     start_of_week = today - timedelta(days=today.weekday()) # Bu haftanın Pazartesi günü

    # 2. Veritabanından sadece bu haftanın loglarını çek
     logs = db.query(DailyXPLog).filter(
        DailyXPLog.user_id == user.id,
        DailyXPLog.date >= start_of_week,
        DailyXPLog.date <= today
    ).all()

    # 3. Flutter'ın tam istediği 7 elemanlı listeyi hazırla (Pzt'den Pazar'a)
    # Başlangıçta haftanın her günü 0 XP
     weekly_data = [0, 0, 0, 0, 0, 0, 0] 

    # 4. Veritabanından gelen verileri doğru günlere yerleştir
    # Python'da weekday() -> 0: Pazartesi, 6: Pazar
     for log in logs:
        day_index = log.date.weekday() 
        weekly_data[day_index] = log.xp_earned

    # Çıktı Örneği: {"weekly_xp": [150, 300, 50, 450, 0, 0, 0]}
     return {"weekly_xp": weekly_data}




# --- AYARLARI KAYDET KAPISI ---

@router.post("/update_preferences")
def update_preferences(request: schemas.UpdatePreferencesRequest, db: Session = Depends(get_db)):
    # 1. Kullanıcıyı bul
    user = db.query(models.UserDB).filter(models.UserDB.username == request.username).first()
    
    if not user:
        raise HTTPException(status_code=404, detail="Kullanıcı bulunamadı!")

    # 2. Seçilen dilin dosyasını bul
    progress = db.query(models.UserProgressDB).filter(
        models.UserProgressDB.user_id == user.id,
        models.UserProgressDB.target_language == request.target_language
    ).first()

    # 3. Eğer o dilde daha önce hiç oynamadıysa, ona sıfırdan bir dosya aç
    if not progress:
        from datetime import date
        new_progress = models.UserProgressDB(
            user_id=user.id,
            target_language=request.target_language,
            level="A1",
            current_section=1,
            current_lesson=1,
            xp_score=0,
            lives=5,
            streak_days=0,
            last_active_date=date.today()
        )
        db.add(new_progress)
    
    # İleride bildirim ayarlarını kaydetmek istersen diye:
    # user.notifications_enabled = request.notifications_enabled
    
    db.commit()
    
    return {
        "mesaj": "Ayarlar başarıyla güncellendi!", 
        "target_language": request.target_language
    }



@router.get("/get_user_languages/{username}")
def get_user_languages(username: str, db: Session = Depends(get_db)):
    # 1. Kullanıcıyı bul
    user = db.query(models.UserDB).filter(models.UserDB.username == username).first()
    if not user:
        raise HTTPException(status_code=404, detail="Kullanıcı bulunamadı")

    # 2. Kullanıcının tüm gelişim dosyalarını çek
    progresses = db.query(models.UserProgressDB).filter(
        models.UserProgressDB.user_id == user.id
    ).all()

    # 3. Sadece dillerin isimlerini bir liste yap (Örn: ["English", "Spanish"])
    active_languages = [p.target_language for p in progresses]

    return {"languages": active_languages}


# 🌟 YENİ: Seviye Atlama API'si
@router.post("/upgrade_level")
def upgrade_level(request: schemas.UpgradeLevelRequest, db: Session = Depends(get_db)):
    user = db.query(models.UserDB).filter(models.UserDB.username == request.username).first()
    if not user:
        raise HTTPException(status_code=404, detail="Kullanıcı bulunamadı")

    progress = db.query(models.UserProgressDB).filter(
        models.UserProgressDB.user_id == user.id,
        models.UserProgressDB.target_language == request.target_language
    ).first()

    if progress:
        # Seviyeyi yükselt ve haritayı en başa (1. Bölüm, 1. Ders) sar!
        progress.level = request.new_level
        progress.current_section = 1
        progress.current_lesson = 1
        db.commit()
        
        return {"status": "success", "message": f"Tebrikler, {request.new_level} seviyesine geçtiniz!"}
        
    raise HTTPException(status_code=404, detail="İlerleme bulunamadı")



@router.post("/generate_level_up_test")
async def generate_level_up_test(
    request: schemas.TestRequest,
    db: Session = Depends(get_db),
):
    exam_questions = []

   
    valid_lessons = (
        db.query(models.Lesson.id)
        .filter(
            func.upper(
                func.trim(models.Lesson.min_level)
            ) == request.level.strip().upper()
        )
        .all()
    )

    valid_lesson_ids = [
        lesson_id
        for (lesson_id,) in valid_lessons
    ]

    print(
        "🎓 LEVEL UP TEST REQUEST:",
        {
            "level": request.level,
            "target_language": request.target_language,
            "native_language": request.native_language,
            "lesson_ids": valid_lesson_ids,
        },
    )

    if not valid_lesson_ids:
        raise HTTPException(
            status_code=404,
            detail="Bu seviyeye ait ders bulunamadı.",
        )



    blank_records = (
        db.query(models.BlankPuzzle)
        .filter(
            models.BlankPuzzle.target_language
            == request.target_language,
            models.BlankPuzzle.lesson_id.in_(
                valid_lesson_ids
            ),
        )
        .order_by(func.random())
        .limit(10)
        .all()
    )

    blank_translation_map = {}

    if blank_records:
        blank_ids = [
            record.id
            for record in blank_records
        ]

        blank_translations = (
            db.query(
                models.BlankPuzzleTranslation
            )
            .filter(
                models.BlankPuzzleTranslation
                .puzzle_id.in_(blank_ids),
                models.BlankPuzzleTranslation
                .native_language
                == request.native_language,
            )
            .all()
        )

        blank_translation_map = {
            translation.puzzle_id:
                translation.translation
            for translation in blank_translations
        }

    for record in blank_records:
        full_question = (
            f"{record.before_text} ____ "
            f"{record.after_text}"
        ).strip()

        localized_translation = (
            blank_translation_map.get(record.id)
            or record.translation
            or ""
        )

        exam_questions.append(
            {
                "type": "blank",
                "question": full_question,
                "answer": record.correct_answer,
                "translation":
                    localized_translation,
            }
        )

    order_records = (
        db.query(models.SentencePuzzle)
        .filter(
            models.SentencePuzzle.target_language
            == request.target_language,
            models.SentencePuzzle.lesson_id.in_(
                valid_lesson_ids
            ),
        )
        .order_by(func.random())
        .limit(10)
        .all()
    )

    sentence_translation_map = {}

    if order_records:
        sentence_ids = [
            record.id
            for record in order_records
        ]

        sentence_translations = (
            db.query(
                models.SentencePuzzleTranslation
            )
            .filter(
                models.SentencePuzzleTranslation
                .puzzle_id.in_(sentence_ids),
                models.SentencePuzzleTranslation
                .native_language
                == request.native_language,
            )
            .all()
        )

        sentence_translation_map = {
            translation.puzzle_id:
                translation.original_sentence
            for translation in sentence_translations
        }

    for record in order_records:
        words = record.correct_sentence.split()

        scrambled_words = random.sample(
            words,
            len(words),
        )

        localized_original = (
            sentence_translation_map.get(record.id)
            or record.original_sentence
            or ""
        )

        exam_questions.append(
            {
                "type": "order",
                "original": localized_original,
                "scrambled": scrambled_words,
                "correct": record.correct_sentence,
            }
        )

    text_records = (
        db.query(models.PronunciationText)
        .filter(
            models.PronunciationText.level
            == request.level,
            models.PronunciationText.target_language
            == request.target_language,
        )
        .order_by(func.random())
        .limit(10)
        .all()
    )

    for index, record in enumerate(text_records):
        question_type = (
            "listen"
            if index < 5
            else "speak"
        )

        exam_questions.append(
            {
                "type": question_type,
                "text": record.text,
            }
        )

    random.shuffle(exam_questions)

    if not exam_questions:
        return {
            "status": "error",
            "message":
                "No questions were found for this exam.",
            "questions": [],
        }

    return {
        "status": "success",
        "total_questions": len(exam_questions),
        "target_language":
            request.target_language,
        "native_language":
            request.native_language,
        "questions": exam_questions,
    }



# 🌟 YENİ: CAN SATIN ALMA APİ'Sİ
@router.post("/buy_lives")
def buy_lives(request: schemas.BuyLivesRequest, db: Session = Depends(get_db)):
    user = db.query(models.UserDB).filter(models.UserDB.username == request.username).first()
    if not user:
        raise HTTPException(status_code=404, detail="Kullanıcı bulunamadı")
        
    progress = db.query(models.UserProgressDB).filter(
        models.UserProgressDB.user_id == user.id,
        models.UserProgressDB.target_language == request.target_language
    ).first()
    
    if not progress:
        raise HTTPException(status_code=404, detail="İlerleme bulunamadı")
        
    price = 300 # 🌟 CAN FULLEME BEDELİ (Bunu istediğin gibi değiştirebilirsin)
    
    if progress.xp_score >= price:
        progress.xp_score -= price
        progress.lives = 5 # Canları fulle
        progress.last_heart_lost = None # Süreyi sıfırla
        db.commit()
        
        return {
            "success": True, 
            "message": "Canlar başarıyla fullendi!", 
            "new_xp": progress.xp_score
        }
    else:
        return {
            "success": False, 
            "message": f"Yetersiz XP! {price} XP gerekiyor."
        }