from datetime import date
import hashlib
import json
import os
from fastapi import APIRouter, Depends, HTTPException, types
from google import genai
from google.genai import types as gemini_types
from sqlalchemy.orm import Session
import schemas
from routers.analyze import ask_ai_for_grammar_check
import models
from routers.user import get_db
from models import AICache, UserDB, UserProgressDB, VocabularyDB 
import config
from database import SessionLocal
from schemas import CorrectionRequest, HintRequest, SentenceCheckRequest, SentenceCheckResponse, TranslateRequest

router = APIRouter()
# 1. Yeni nesil Gemini Client'ını başlat
# (API anahtarını bilgisayarındaki veya .env dosyasındaki GEMINI_API_KEY ortam değişkeninden otomatik alır)
client = genai.Client()
client = genai.Client(api_key=config.GOOGLE_API_KEY)

async def get_smart_ai_response(db: Session, feature_type: str, user_input: str, system_prompt: str):
    """
    feature_type: İstek nereden geldi? (Örn: 'roleplay_cafe')
    user_input: Kullanıcının yazdığı İngilizce metin (Örn: 'I want a coffee')
    system_prompt: Senin o sayfada kullandığın yapay zeka kuralı/promptu
    """
    
    # 1. GÜVENLİK GÖREVLİSİ (ÖN BELLEK KONTROLÜ)
    cleaned_input = user_input.lower().strip()
    
    cached_data = db.query(AICache).filter(
        AICache.feature_type == feature_type,
        AICache.input_text == cleaned_input
    ).first()

    if cached_data:
        print(f"⚡ BEDAVA CEVAP! [{feature_type}] için veritabanından çekildi.")
        return cached_data.ai_response

    # 2. VERİTABANINDA YOKSA GEMINI'YE GİDİYORUZ (TOKEN HARCANIR)
    print(f"🤖 YENİ SORU! [{feature_type}] için Gemini'ye gidiliyor...")
    
    # System prompt'u ve kullanıcı mesajını temiz bir şekilde birleştiriyoruz
    full_prompt = f"SİSTEM KURALI:\n{system_prompt}\n\nKULLANICI MESAJI:\n{user_input}"
    
    try:
        # YENİ NESİL İSTEK YAPISI (client.models.generate_content)
        response = client.models.generate_content(
            model='gemini-2.5-flash-lite', # Kendi kullandığın modeli yazabilirsin
            contents=full_prompt,
        )
        api_response = response.text
        
        # 3. YATIRIM ZAMANI: Gelecekte bedava kullanmak için kaydet!
        new_cache = AICache(
            feature_type=feature_type,
            input_text=cleaned_input,
            ai_response=api_response
        )
        db.add(new_cache)
        db.commit()

        return api_response
        
    except Exception as e:
        print(f"Gemini API Hatası: {e}")
        return "Üzgünüm, şu an bağlantı kuramıyorum. Lütfen tekrar dene."
    


    # --- YARDIMCI FONKSİYON: Şifre (Hash) Üretici ---

@router.post("/api/ai-teacher/correct")
async def correct_user_text(request: schemas.CorrectionRequest, db: Session = Depends(get_db)):
    
    user_text_lower = request.user_text.lower().strip()
    words_in_sentence = user_text_lower.split()
    target_words_list = [w.strip().lower() for w in request.target_words.split(",") if w.strip()]
    used_words = [w for w in target_words_list if w in user_text_lower]

    # 🛡️ DEMİR KUBBE KURAL 1: HİÇ HEDEF KELİME KULLANMAMIŞ!
    if len(target_words_list) > 0 and len(used_words) == 0:
        return {
            "ai_message": "Cümlen fena değil ama asıl amacımızı unuttuk! 😊",
            "corrections": [{
                "wrong": request.user_text,
                "correct": "Hedef kelime eksik.",
                "explanation": f"Puan kazanmak için şu kelimelerden en az birini kullanmalısın: {', '.join(target_words_list)}"
            }],
            "next_step": "Yukarıdaki kelimeleri kullanarak yeni bir cümle kurmayı dener misin?"
        }

    # 🛡️ DEMİR KUBBE KURAL 2: ÇOK KISA YAZIP KAÇMAK YOK!
    if len(words_in_sentence) < 3:
        return {
            "ai_message": "Biraz daha çabalamanı istiyorum! 🚀",
            "corrections": [{
                "wrong": request.user_text,
                "correct": "Daha uzun bir cümle kurmalısın.",
                "explanation": "Sadece 1-2 kelime yazıp geçemezsin. En az 3 kelimelik tam bir cümle kurmaya çalış."
            }],
            "next_step": "Bu ifadeyi tam bir cümle içinde nasıl kullanırsın?"
        }

    # 🛡️ DEMİR KUBBE KURAL 3: HİLE KONTROLÜ (WORD DUMPING)
    if len(target_words_list) > 0 and len(used_words) >= 2 and len(words_in_sentence) <= len(used_words) + 2:
        return {
            "ai_message": "Kurnazca bir hamle ama bunu kabul edemem! 😊",
            "corrections": [{
                "wrong": request.user_text,
                "correct": "Lütfen kurallı bir cümle kurun.",
                "explanation": "Kelimeleri sadece boşlukla ayırarak arka arkaya dizemezsin."
            }],
            "next_step": "Hadi bu kelimelerle gerçek bir cümle kurmayı tekrar deneyelim!"
        }

    # --- EĞER KULLANICI BU 3 KURALI AŞABİLDİYSE GEMİNİ'YE GİTSİN ---
    
    # 🌟 GÜNCELLEME 1: Cache Logları Terminale Yazdırılıyor
    history_str = str(request.history).lower()
    search_text = f"lang: {request.target_language} | topic: {request.topic.strip()} | history: {history_str} | text: {user_text_lower}"
    
    cached_data = db.query(models.AICache).filter(
        models.AICache.feature_type == "writing_correction", 
        models.AICache.input_text == search_text            
    ).first()
    
    if cached_data:
        print(f"🟢 CACHE HIT: Yanıt Veritabanından Çekildi! (Soru: {request.user_text})")
        return json.loads(cached_data.ai_response)

    print(f"🟡 CACHE MISS: Yeni İstek, Gemini'ye Gidiliyor... (Soru: {request.user_text})")

    conversation_context = ""
    if request.history:
        for msg in request.history:
            role = "Öğrenci" if msg.get("role") == "user" else "Sen (AI)"
            conversation_context += f"{role}: {msg.get('content')}\n"

   # 🤖 GÜNCELLEME: GEMİNİ İÇİN KESİN SINIRLAR (Papağan ve Zoraki Satıcı Engellendi)
    system_instruction = f"""You are acting in a roleplay scenario to teach the {request.target_language} language.
    The user is at level: {request.level}.
    
    YOUR PERSONA / SCENARIO: {request.topic}
    
    Your jobs:
    1. STAY IN CHARACTER! Respond to the user's message as the character described in the scenario.
    2. REACTION ONLY: Write your character's reaction/statement in {request.target_language} in the "ai_message" field. DO NOT write any questions in this field. Leave the question for the next step.
    3. FORGIVING CORRECTIONS: Check the user's text ONLY for MAJOR grammatical or vocabulary mistakes. IGNORE minor punctuation or capitalization. If there are major mistakes, you MUST add them to "corrections" STRICTLY as JSON objects with "wrong", "correct", and "explanation" keys. NEVER put plain strings in the array!
    4. FOLLOW-UP QUESTION: In the "next_step" field, ask ONE natural follow-up question to keep the roleplay going in {request.target_language}.
       - CRITICAL RULE 1: NEVER repeat a question you already asked in the previous turns.
       - CRITICAL RULE 2: If the user indicates they are finished, saying goodbye, or saying "no thank you", DO NOT force a question. Leave "next_step" completely EMPTY ("").
    
    EXPECTED JSON FORMAT:
    {{
      "ai_message": "Only your statement/reaction here (e.g., 'Hello! Yes, of course.' or 'Okay, one coffee with milk.')",
      "corrections": [
        {{"wrong": "incorrect word", "correct": "fixed word", "explanation": "Turkish explanation"}}
      ],
      "next_step": "Only your question here (e.g., 'What would you like to drink?') OR an empty string '' if the conversation is naturally ending."
    }}"""

    prompt = f"Previous Conversation:\n{conversation_context}\n\nUser's New Message: {request.user_text}"

    try:
        response = client.models.generate_content(
            model='gemini-2.5-flash-lite',
            contents=prompt,
            config=gemini_types.GenerateContentConfig(
                system_instruction=system_instruction,
                response_mime_type="application/json", 
                temperature=0.4 
            )
        )
        
        json_data = json.loads(response.text)
        
        # 🌟 GÜNCELLEME 3: Kayıt logu
        new_cache = models.AICache(feature_type="writing_correction", input_text=search_text, ai_response=response.text)
        db.add(new_cache)
        db.commit()
        print(f"💾 CACHE SAVED: Gemini yanıtı veritabanına kaydedildi.")
        
        return json_data
        
    except Exception as e:
        print(f"🚨 AI Hatası: {str(e)}")
        
        return {
            "ai_message": "Şu an sistemimde ufak bir yoğunluk var ama seni çok iyi anladım. Harika gidiyorsun! 🚀",
            "corrections": [], # Hata yokmuş gibi boş liste dönüyoruz
            "next_step": "Şimdi bana başka ne söylemek istersin?" # Sohbet kopmasın diye topu ona atıyoruz
        }
    
@router.get("/api/lessons")
def get_lessons(db: Session = Depends(get_db)):
    return db.query(models.Lesson).order_by(models.Lesson.order).all()




@router.post("/evaluate_sentence", response_model=SentenceCheckResponse)
def evaluate_sentence(request: SentenceCheckRequest, db: Session = Depends(get_db)):
    
    # 1. Kelimeleri birleştir ve Cache (Önbellek) Anahtarını oluştur
    submitted_sentence = " ".join(request.submitted_words).strip()
    correct_sentence = request.correct_sentence.strip()
    
    # 🌟 SENİN TABLONA ÖZEL: Aramayı tek bir metinde (input_text) yapabilmek için benzersiz bir şifre üretiyoruz:
    # Örn: "English | Ben eve gidiyorum | I going am home"
    cache_key = f"{request.target_language} | {request.original_sentence} | {submitted_sentence}"

    # ---------------------------------------------------------
    # 🚀 1. AŞAMA: KUSURSUZ DOĞRU
    # ---------------------------------------------------------
    if submitted_sentence.lower() == correct_sentence.lower():
        # TODO: İstediğin bir XP ekleme fonksiyonunu burada çağırabilirsin
        return {
            "is_correct": True,
            "xp_earned": 15,
            "ai_feedback": {
                "score": "100/100",
                "word_breakdown": {
                    "Mükemmel": "Tüm kelimeler doğru yerleştirildi!"
                },
                "ai_tip": f"💡 Harika iş çıkardın, bu {request.target_language} kalıbını unutma!"
            }
        }

    # ---------------------------------------------------------
    # 🗄️ 2. AŞAMA: CACHE (ÖNBELLEK) KONTROLÜ
    # ---------------------------------------------------------
    # 🌟 SENİN TABLON: AICache tablosunu kullanıyoruz
    cached_feedback = db.query(models.AICache).filter(
        models.AICache.feature_type == "sentence_check",
        models.AICache.input_text == cache_key
    ).first()

    if cached_feedback:
        print("⚡ CACHE'DEN OKUNDU! API Parası Cepte Kaldı!")
        # Senin ai_response sütunun Text (String) olduğu için onu tekrar JSON'a (Sözlüğe) çeviriyoruz:
        ai_data = json.loads(cached_feedback.ai_response) 
        
        return {
            "is_correct": False,
            "xp_earned": 0,
            "ai_feedback": ai_data
        }

    # ---------------------------------------------------------
    # 🧠 3. AŞAMA: YAPAY ZEKA (AI) İLE CANLI ANALİZ
    # ---------------------------------------------------------
    print(f"🤖 YENİ HATA. {request.target_language} AI'ına Gidiliyor...")
    
    ai_raw_response = ask_ai_for_grammar_check(
        target_language=request.target_language,
        native_language=request.native_language,
        original=request.original_sentence,
        correct=correct_sentence,
        submitted=submitted_sentence
    )
    
    # ---------------------------------------------------------
    # 💾 4. AŞAMA: GELECEK İÇİN CACHE'E KAYDET
    # ---------------------------------------------------------
    # 🌟 SENİN TABLON: Modül adını "sentence_check" olarak belirtiyoruz.
    new_cache_entry = models.AICache(
        feature_type="sentence_check", 
        input_text=cache_key,
        ai_response=json.dumps(ai_raw_response, ensure_ascii=False) # Sözlüğü Text'e çevirip kaydediyoruz
    )
    db.add(new_cache_entry)
    db.commit()

    return {
        "is_correct": False,
        "xp_earned": 0,
        "ai_feedback": ai_raw_response
    }



# FastAPI Endpoint'imiz
import random # 🌟 En yukarıda yoksa bunu eklemeyi unutma!

@router.post("/generate_speed_reading")
async def generate_speed_reading(username: str, target_language: str,native_language: str, level: str, lesson_id: int, db: Session = Depends(get_db)):
     # 🌟 GÖZLERİMİZLE GÖRMEK İÇİN TERMİNALE YAZDIRIYORUZ:
    print(f"🎯 HIZLI QUİZ İSTEĞİ GELDİ -> Hedef Dil: {target_language} | Ana Dil: {native_language}")
    # 1. Kullanıcıyı Bul
    user = db.query(UserDB).filter(UserDB.username == username).first()
    if not user:
        raise HTTPException(status_code=404, detail="Kullanıcı bulunamadı")
        
    user_prog = db.query(UserProgressDB).filter(UserProgressDB.user_id == user.id).first()
    if not user_prog:
        raise HTTPException(status_code=404, detail="Kullanıcının ilerlemesi bulunamadı")
    
    user_id = user.id
    
    # 🌟 2. İŞTE BÜYÜK DEĞİŞİKLİK BURADA: DERSİN KENDİ KELİMELERİNİ ÇEKİYORUZ!
    current_lesson = db.query(models.Lesson).filter(models.Lesson.id == lesson_id).first()
    
    lesson_words = []
    if current_lesson and current_lesson.target_words:
        # Veritabanındaki "Kitchen, Bedroom, Furniture" stringini kelime kelime listeye ayırıyoruz
        lesson_words = [w.strip() for w in current_lesson.target_words.split(",")]
        
    # Eğer dersin kendine ait kelimeleri varsa onları kullan!
    if lesson_words:
        # Çok uzun olmasın diye dersteki kelimelerden rastgele maksimum 4 tanesini seçiyoruz
        words = random.sample(lesson_words, min(len(lesson_words), 4)) 
    else:
        # Eğer derse kelime girmeyi unutmuşsak sistem çökmesin diye eski kumbaraya (VocabularyDB) yedek plan
        words_query = db.query(VocabularyDB).filter(
            VocabularyDB.user_id == user_id, 
            VocabularyDB.is_learned == False,
            VocabularyDB.target_language == target_language
        ).limit(3).all()
        words = [w.word for w in words_query] if words_query else ["hello", "time", "friend"]
        
    words.sort() # Cache key hep aynı çıksın diye alfabetik sıralıyoruz
    
    # 3. Senin Fonksiyonun İçin Parametreleri Hazırla
    feature_type = "speed_reading"
# 🌟 1. ÖNBELLEĞİ (CACHE) SİLMEK İÇİN VERSİYONU v6 YAPTIK
    PROMPT_VERSION = "v6" 
    cache_key_input = f"{PROMPT_VERSION}-{target_language}-{native_language}-{level}-lesson{lesson_id}-{','.join(words)}"

    # 🌟 2. İÇİNDEKİ TÜRKÇE ÖRNEKLERDEN ARINDIRILMIŞ YENİ PROMPT
    system_prompt = f"""
    Sen profesyonel bir {target_language} öğretmenisin. Karşındaki öğrenci tam olarak {level} seviyesinde.

    ÖNEMLİ PEDAGOJİK KURALLAR:
    - Eğer seviye A1 veya A2 ise: KESİNLİKLE çok basit, gündelik kelimeler kullan.
    - Cümleleri çok kısa tut. Maksimum 5-7 kelime.
    - Karmaşık gramer yapılarından kaçın.
    - Sadece Present Simple kullan.
    - Metin, öğrencinin şu kelimelerini KESİNLİKLE içermelidir: {', '.join(words)}.

    Bana {target_language} dilinde, içinde bu kelimelerin geçtiği kısa, akıcı ve heyecanlı bir hikaye yaz.
    Hikaye en fazla 4-5 cümleden oluşsun.

    SORU KURALLARI:
    - question alanı {target_language} dilinde olsun.
    - question_translation alanı KESİNLİKLE öğrencinin ana dili olan {native_language} dilinde olsun!
    - options alanındaki şıklar {target_language} dilinde kalsın.
    - Şıkları {native_language} diline çevirme.
    - correct_answer kısmına şıkkın tamamını yaz. Sadece A, B, C yazma.

    ÇIKTIYI SADECE AŞAĞIDAKİ JSON FORMATINDA VER, BAŞKA AÇIKLAMA YAZMA:
    {{
        "story_text": "Story text goes here...",
        "comprehension_questions": [
            {{
                "question": "Example question in {target_language}?",
                "question_translation": "Translation of the question in {native_language}",
                "options": ["A) Option 1", "B) Option 2", "C) Option 3", "D) Option 4"],
                "correct_answer": "B) Option 2"
            }}
        ],
        "vocabulary_questions": [
            {{
                "question": "What does 'example' mean?",
                "question_translation": "Translation of the vocabulary question in {native_language}",
                "options": ["A) Option 1", "B) Option 2", "C) Option 3", "D) Option 4"],
                "correct_answer": "A) Option 1"
            }}
        ]
    }}
    
    """
    
    # 4. İŞTE SENİN EFSANE FONKSİYONUNU ÇAĞIRIYORUZ!
    raw_ai_response = await get_smart_ai_response(
        db=db,
        feature_type=feature_type,
        user_input=cache_key_input,
        system_prompt=system_prompt
    )
    
    # Gemini bazen JSON'ın başına ve sonuna ```json ve ``` ekler, onu temizleyelim
    cleaned_json_string = raw_ai_response.replace("```json", "").replace("```", "").strip()
    
    # String'i gerçek JSON/Sözlük nesnesine çevirip Flutter'a yolluyoruz
    try:
        final_data = json.loads(cleaned_json_string)
        final_data["target_words"] = words
        return final_data
    except json.JSONDecodeError:
        return {"error": "Yapay zeka geçerli bir format üretmedi.", "raw_text": raw_ai_response}


# 1. KAPI: KULLANICI BUGÜN OYNAMIŞ MI KONTROL ET
@router.get("/roleplay/check")
def check_roleplay_lock(username: str, target_language: str, db: Session = Depends(get_db)):
    user = db.query(models.UserDB).filter(models.UserDB.username == username).first()
    if not user:
        raise HTTPException(status_code=404)
        
    progress = db.query(models.UserProgressDB).filter(
        models.UserProgressDB.user_id == user.id,
        models.UserProgressDB.target_language == target_language
    ).first()
    
    # Eğer son oynama tarihi BUGÜN ise kilitli dön!
    if progress and progress.last_roleplay_date == date.today():
        return {"is_locked": True}
    
    return {"is_locked": False}

# 2. KAPI: OYUN BİTTİĞİNDE TARİHİ BUGÜN OLARAK GÜNCELLE
@router.post("/roleplay/mark_done")
def mark_roleplay_done(request: schemas.RoleplayDoneRequest, db: Session = Depends(get_db)):
    user = db.query(models.UserDB).filter(models.UserDB.username == request.username).first()
    progress = db.query(models.UserProgressDB).filter(
        models.UserProgressDB.user_id == user.id,
        models.UserProgressDB.target_language == request.target_language
    ).first()
    
    if progress:
        progress.last_roleplay_date = date.today()
        db.commit()
    return {"message": "Roleplay başarıyla kilitlendi!"}




# 🌟 1. İPUCU API'Sİ
@router.post("/get_chat_hint")
def get_chat_hint(request: HintRequest, db: Session = Depends(get_db)):
    try:
        # Geçmişi formatla
        formatted_history = "\n".join([f"{m['role']}: {m['content']}" for m in request.history])
        
        prompt = f"""
        Öğrenci '{request.topic}' konusunda '{request.target_language}' dilinde roleplay yapıyor ama tıkandı ve ne yazacağını bilemiyor.
        Aşağıdaki sohbet geçmişine bakarak, öğrencinin şu an söyleyebileceği kısa, doğal ve konuya uygun tek bir cümle öner.
        SADECE önerdiğin cümleyi '{request.target_language}' dilinde yaz. Açıklama veya çeviri ekleme.
        
        Geçmiş:
        {formatted_history}
        """
        response = client.models.generate_content(
            model='gemini-2.5-flash-lite',
            contents=prompt,
        )
        return {"hint": response.text.strip()}
    except Exception as e:
        return {"hint": "I think we should..."} # Hata olursa varsayılan bir ipucu

# 🌟 2. ÇEVİRİ API'Sİ
@router.post("/translate_text")
def translate_text(request: TranslateRequest, db: Session = Depends(get_db)):
    try:
        prompt = f"Şu metni profesyonelce Türkçeye çevir. Sadece çeviriyi ver:\n\n{request.text}"
        response = client.models.generate_content(
            model='gemini-2.5-flash-lite',
            contents=prompt,
        )
        return {"translation": response.text.strip()}
    except Exception as e:
        return {"translation": "Çeviri şu an yapılamıyor."}