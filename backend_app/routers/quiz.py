from datetime import datetime , timezone
import re

from fastapi import APIRouter, Depends, HTTPException
from google import genai
from requests import Session
import schemas
import models

from routers.user import get_db
from schemas import QuizResult
import config
import json

router = APIRouter()
client = genai.Client(api_key=config.GOOGLE_API_KEY)

@router.get("/generate_placement_test")
def generate_placement_test(
    target_language: str = "English",
    native_language: str = "Turkish",
    db: Session = Depends(get_db)
):
    try:
        system_prompt = f"""
Sen uzman bir {target_language} seviye tespit sınavı hazırlayıcısısın.

Amaç:
Öğrencinin seviyesini gerçekçi şekilde A1, A2, B1, B2 veya C1 olarak belirlemek.
Test kolay olmamalı; özellikle A2 ve üstünde güçlü çeldiriciler kullanılmalı.

TEST YAPISI:
- Toplam 15 soru üret.
- 1-3: A1
- 4-6: A2
- 7-9: B1
- 10-12: B2
- 13-15: C1
- Her seviyeden tam 3 soru olmalı.

DİL KURALLARI:
1. "question" alanı öğrencinin ana dili olan {native_language} dilinde olmalı.
2. "context_text", "options" ve "answer" kesinlikle {target_language} dilinde olmalı.
3. "answer" alanı options içindeki değerlerden biriyle birebir aynı olmalı.
4. Sadece geçerli JSON döndür. Markdown, açıklama, ```json kullanma.

ÇOK KRİTİK SORU KALİTESİ KURALLARI:
- Görsel, resim veya ekranda gösterilmeyen nesne gerektiren soru üretme.
- "Bu nesnenin adını seç." gibi bağlamsız soru yazma.
- "Boşluğu dolduran uygun kelimeyi seç." gibi eksik soru yazma.
- Her question tek başına okununca anlaşılır olmalı.
- Vocabulary sorularında çevirilecek kelime mutlaka question içinde yer almalı.
  Örnek: "'istasyon' kelimesinin {target_language} karşılığını seç."
- Grammar sorularında boşluklu cümle mutlaka question içinde yer almalı.
  Örnek: "Cümleyi tamamla: She ___ to school every day."
- A1 ve A2 sorularında context_text kullanma; tüm gerekli bilgi question içinde olmalı.
- B1 dialogue sorularında kısa diyalog gerekiyorsa diyalogu question içine yaz.
- B2 reading sorularında context_text zorunlu olmalı.
- C1 reading/listening sorularında context_text zorunlu olmalı.
- options listesi tam 4 seçenekten oluşmalı.
- Yanlış seçenekler bariz saçma olmamalı.
- Çeldiriciler aynı kelime türünden ve aynı konu alanından olmalı.

ZORLUK AYARI KURALLARI:
A1:
- Çok temel kelime ve basit gramer.
- be, have, simple present, temel nesneler, temel günlük ifadeler.
- Kolay olmalı ama tamamen tahmin edilebilir olmamalı.
- Yanlış seçenekler aynı türden olmalı.
- Örnek yapı: "Cümleyi tamamla: She ___ a teacher."

A2:
- Günlük durumlar, geçmiş zaman, karşılaştırmalar, miktar ifadeleri, ulaşım, alışveriş, yönler.
- A2 soruları A1 kadar kolay olmamalı.
- Collocation ve günlük kullanım ölçülebilir.
- Örnek yapı: "Cümleyi tamamla: I was late, so I had to ___ a taxi."
- Kötü örnek üretme: "The elephant is very ___." gibi çok bariz sorular sorma.

B1:
- Diyalog tamamlama, bağlama uygun kelime, neden-sonuç ve öneri anlamı ölçülmeli.
- Öğrenci sadece kelime ezberiyle değil, bağlamı anlayarak cevap vermeli.
- Şıklar anlamca yakın ama sadece biri bağlama uygun olmalı.

B2:
- Kısa okuma metni üzerinden çıkarım yapılmalı.
- Cevap metinde birebir yazmamalı; öğrenci anlamdan çıkarmalı.
- Şıkların hepsi metinle ilişkili görünebilir, ama sadece biri doğru çıkarım olmalı.
- Ana fikir, yazarın tutumu veya sonuç çıkarma sorulabilir.

C1:
- Akademik, soyut veya nüanslı anlam farkı içermeli.
- Basit kelime anlamı sorma.
- Yazarın amacı, ima edilen anlam, ton, varsayım veya karmaşık çıkarım sorulmalı.
- Listening sorusunda context_text bir anons, kısa akademik konuşma veya resmi açıklama olabilir.

Soru tipleri:
- A1: grammar veya vocabulary
- A2: grammar veya vocabulary
- B1: grammar, vocabulary veya dialogue
- B2: reading
- C1: reading veya listening

JSON formatı tam olarak şöyle olmalı:

{{
  "test_title": "{target_language} Placement Test",
  "questions": [
    {{
      "id": 1,
      "level": "A1",
      "type": "grammar",
      "context_text": null,
      "question": "Cümleyi tamamla: She ___ a student.",
      "options": ["is", "are", "am", "be"],
      "answer": "is"
    }},
    {{
      "id": 4,
      "level": "A2",
      "type": "grammar",
      "context_text": null,
      "question": "Cümleyi tamamla: I was late, so I had to ___ a taxi.",
      "options": ["take", "make", "do", "have"],
      "answer": "take"
    }},
    {{
      "id": 7,
      "level": "B1",
      "type": "dialogue",
      "context_text": null,
      "question": "Diyaloğu tamamla: A: I missed the bus. B: You should have ___ earlier.",
      "options": ["left", "arrived", "travelled", "caught"],
      "answer": "left"
    }},
    {{
      "id": 10,
      "level": "B2",
      "type": "reading",
      "context_text": "Many people choose public transport not only because it is cheaper, but also because it reduces traffic and pollution. However, delays and crowded vehicles can make daily travel stressful.",
      "question": "Metne göre toplu taşıma hakkında en doğru çıkarım hangisidir?",
      "options": [
        "It has both advantages and disadvantages",
        "It is always faster than driving",
        "People use it only because it is free",
        "It completely solves traffic problems"
      ],
      "answer": "It has both advantages and disadvantages"
    }},
    {{
      "id": 14,
      "level": "C1",
      "type": "listening",
      "context_text": "The speaker argues that remote work has improved flexibility, yet warns that long-term productivity depends on clearer communication and stronger boundaries between work and private life.",
      "question": "Dinlediğin metne göre konuşmacının temel tutumu nedir?",
      "options": [
        "Cautiously optimistic",
        "Completely negative",
        "Uninterested in the topic",
        "Strongly opposed to flexibility"
      ],
      "answer": "Cautiously optimistic"
    }}
  ]
}}

SON KONTROL:
- questions listesi tam 15 elemanlı olmalı.
- Her level için tam 3 soru olmalı.
- A1, A2, B1 sorularında context_text null olmalı.
- B2 ve C1 reading/listening sorularında context_text boş olmamalı.
- Hiçbir soru görsel gerektirmemeli.
- Her question ekranda tek başına anlaşılır olmalı.
- options içinde 4 seçenek olmalı.
- answer options içindeki seçeneklerden biriyle birebir aynı olmalı.
- Sorular özellikle A2 ve üstünde çok kolay olmamalı.
"""

        models_to_try = [
            "gemini-2.5-flash-lite",
            
        ]

        response = None
        last_error = None

        for model_name in models_to_try:
            try:
                response = client.models.generate_content(
                    model=model_name,
                    contents=system_prompt,
                )
                break
            except Exception as e:
                last_error = e
                print(f"{model_name} modeli hata verdi: {e}")

        if response is None:
            raise HTTPException(
                status_code=503,
                detail=f"Yapay zeka modeli şu anda yoğun. Lütfen biraz sonra tekrar deneyin. Detay: {last_error}"
            )

        raw_text = (response.text or "").strip()
        raw_text = raw_text.replace("```json", "").replace("```", "").strip()

        # AI bazen JSON dışına metin eklerse ilk JSON objesini yakala.
        match = re.search(r"\{.*\}", raw_text, re.DOTALL)
        if match:
            raw_text = match.group(0)

        test_data = json.loads(raw_text)

        if "questions" not in test_data or not isinstance(test_data["questions"], list):
            raise Exception("JSON içinde geçerli bir questions listesi yok.")

        questions = test_data["questions"]

        if len(questions) != 15:
            raise Exception(f"Soru sayısı 15 değil. Gelen soru sayısı: {len(questions)}")

        expected_levels = ["A1", "A2", "B1", "B2", "C1"]
        for level in expected_levels:
            count = sum(1 for q in questions if q.get("level") == level)
            if count != 3:
                raise Exception(f"{level} soru sayısı 3 değil. Gelen: {count}")

        for q in questions:
            options = q.get("options")
            answer = q.get("answer")
            q_type = q.get("type")
            context_text = q.get("context_text")

            if not isinstance(options, list) or len(options) != 4:
                raise Exception(f"{q.get('id')} numaralı soruda options 4 seçenekli değil.")

            if answer not in options:
                raise Exception(f"{q.get('id')} numaralı soruda answer options içinde değil.")

            if q_type in ["reading", "listening"]:
                if context_text is None or str(context_text).strip() == "":
                    raise Exception(f"{q.get('id')} numaralı {q_type} sorusunda context_text boş.")
            else:
                q["context_text"] = None

        return test_data

    except HTTPException:
        raise

    except Exception as e:
        print(f"--- SINAV ÜRETİM HATASI --- \n{str(e)}")
        raise HTTPException(
            status_code=500,
            detail="Sınav şu an oluşturulamıyor, lütfen tekrar deneyin."
        )


# --- BOSS SAVAŞI (HIZLI OKUMA) SONUÇ KAPISI ---
@router.post("/quiz_boss_result")
def quiz_boss_result(result: schemas.QuizResult, db: Session = Depends(get_db)):
    # 1. Kullanıcı ve İlerlemeyi Bul
    user = db.query(models.UserDB).filter(models.UserDB.username == result.username).first()
    prog = db.query(models.UserProgressDB).filter(
        models.UserProgressDB.user_id == user.id,
        models.UserProgressDB.target_language == result.target_language
    ).first()

    # 🌟 YENİ: DERS KONTROLÜ
    # Kullanıcı şu an hangi dersin quiziyle (Speed Reading) uğraşıyor? 
    # Flutter'dan gelen 'lesson_id' ile kontrol edelim.
    current_lesson = db.query(models.Lesson).filter(models.Lesson.id == result.lesson_id).first()
    
    # KURAL: Eğer kullanıcının bulunduğu dersin sırası (order), 
    # çözdüğü bu lesson_id'nin sırasından küçükse bu bir "İlk Çözüş"tür.
    # Eğer eşit veya büyükse, bu bir "Tekrar Pratiği"dir.
    is_replay = False
    if current_lesson and prog:
        if prog.current_section > current_lesson.order:
            is_replay = True
        elif prog.current_section == current_lesson.order and prog.current_lesson > 4: # 4 = Quiz adımı
            is_replay = True

    # 2. XP Hesaplama
    if is_replay:
        earned_xp = 0 # 🛑 Tekrar pratiğinde XP yok!
    else:
        earned_xp = (result.correct_count * 10) + 5
        prog.xp_score += earned_xp
    
    # 5. Günlük Log Güncelleme (Sadece XP kazanıldıysa)
    if earned_xp > 0:
        today = datetime.now(timezone.utc).date()
        daily_log = db.query(models.DailyXPLog).filter(
            models.DailyXPLog.user_id == user.id,
            models.DailyXPLog.date == today
        ).first()

        if daily_log:
            daily_log.xp_earned += earned_xp
        else:
            new_log = models.DailyXPLog(user_id=user.id, date=today, xp_earned=earned_xp)
            db.add(new_log)

    # 6. Kelimeleri Güncelle (MİMARİNİN KALBİ)
    # SADECE ilk kez çözüyorsa ve başarı %70 üzerindeyse kelimeleri YOKSA EKLE, VARSA GÜNCELLE!
    if not is_replay and result.total_questions > 0 and (result.correct_count / result.total_questions) >= 0.7:
        if result.learned_words:
            for word in result.learned_words:
                word = word.strip()
                existing_word = db.query(models.VocabularyDB).filter(
                    models.VocabularyDB.user_id == user.id,
                    models.VocabularyDB.word == word,
                    models.VocabularyDB.target_language == result.target_language
                ).first()
                
                if existing_word:
                    existing_word.is_learned = True
                else:
                    new_vocab = models.VocabularyDB(
                        user_id=user.id,
                        word=word,
                        target_language=result.target_language,
                        is_learned=True
                    )
                    db.add(new_vocab)

    db.commit()
    
    return {
        "message": "Tekrar pratiği yapıldı, XP verilmedi." if is_replay else "Boss Savaşı tamamlandı, ganimetler eklendi!",
        "earned_xp": earned_xp,
        "new_total_xp": prog.xp_score,
        "level_up": False
    }


import random

from sqlalchemy.sql.expression import func
import random

@router.post("/generate_final_test")
async def generate_final_test(request: schemas.TestRequest, db: Session = Depends(get_db)):
    exam_questions = []

    # 1. BOŞLUK DOLDURMA (BlankPuzzle tablosundan)
    blank_records = db.query(models.BlankPuzzle).filter(
        models.BlankPuzzle.lesson_id == request.lesson_id,
        models.BlankPuzzle.target_language == request.target_language # 🌟 DİL FİLTRESİ EKLENDİ
    ).order_by(func.random()).limit(3).all()
    
    for b in blank_records:
        full_question = f"{b.before_text} ____ {b.after_text}".strip()
        exam_questions.append({
            "type": "blank", 
            "question": full_question, 
            "answer": b.correct_answer, 
            "translation": b.translation
        })

    # 2. CÜMLE KURMA (SentencePuzzle tablosundan)
    order_records = db.query(models.SentencePuzzle).filter(
        models.SentencePuzzle.lesson_id == request.lesson_id,
        models.SentencePuzzle.target_language == request.target_language # 🌟 DİL FİLTRESİ EKLENDİ
    ).order_by(func.random()).limit(3).all()
    
    for o in order_records:
        words = o.correct_sentence.split()
        scrambled_words = random.sample(words, len(words))
        
        exam_questions.append({
            "type": "order", 
            "original": o.original_sentence, 
            "scrambled": scrambled_words, 
            "correct": o.correct_sentence
        })

    # 3. DİNLEME VE TELAFFUZ (PronunciationText tablosundan)
    text_records = db.query(models.PronunciationText).filter(
        models.PronunciationText.level == request.level,
        models.PronunciationText.lesson_id == request.lesson_id, # 🌟 DERS FİLTRESİ EKLENDİ (Sadece bu dersin metni gelsin)
        models.PronunciationText.target_language == request.target_language # 🌟 DİL FİLTRESİ EKLENDİ
    ).order_by(func.random()).limit(4).all()
    
    for i, t in enumerate(text_records):
        q_type = "listen" if i < 2 else "speak"
        exam_questions.append({
            "type": q_type,
            "text": t.text
        })

    # Soruları karıştır (Her girdiğinde farklı sırada gelsin)
    random.shuffle(exam_questions)
    
    return {
        "status": "success",
        "total_questions": len(exam_questions),
        "questions": exam_questions
    }