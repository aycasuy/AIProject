from http import client

from fastapi import APIRouter, Depends, HTTPException, types
from requests import Session
import models
from models import Flashcard, SentencePuzzle
from routers.user import get_db
import schemas
from google import genai
from google.genai import types
import json
import config
import random
from typing import List
import random

router = APIRouter()

@router.post("/analyze_text")
def analyze_text(request: schemas.TextAnalyzeRequest):
    prompt = f"""
    You are an expert {request.target_language} teacher and linguist. Analyze the following {request.target_language} text. 
    Your response MUST BE ONLY a valid JSON object. Do not include any markdown formatting like ```json, code blocks, or conversational text. Just output the raw JSON.
    
    The JSON structure must exactly match this format:
    {{
      "overall_level": "B2",
      "words": [
        {{"word": "word_in_text", "translation": "translation_in_native_language", "cefr_level": "C1"}}
      ]
    }}
    
    Instructions:
    1. Determine the overall CEFR level of the text (A1, A2, B1, B2, C1, or C2).
    2. Extract 5 to 8 of the most difficult or important vocabulary words from the text that a language learner might struggle with.
    3. Provide accurate {request.native_language} translations for those specific words based on their context in the text.
    4. Provide the CEFR level for each extracted word.

    Text to analyze:
    "{request.text}"
    """

    try:
        client = genai.Client()
        response = client.models.generate_content(
            model="gemini-2.5-flash-lite",
            contents=prompt
        )
        
        clean_text = response.text.strip()
        if clean_text.startswith("```json"):
            clean_text = clean_text[7:]
        if clean_text.endswith("```"):
            clean_text = clean_text[:-3]
            
        
        ai_data = json.loads(clean_text.strip())
        return ai_data

    except json.JSONDecodeError:
        raise HTTPException(status_code=500, detail="Yapay zeka geçerli bir JSON formatı döndürmedi.")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Yapay Zeka Analiz Hatası: {str(e)}")


import json
import re
from fastapi import HTTPException
from google import genai
from google.genai import types

@router.post("/generate_quiz")
def generate_quiz(request: schemas.TextAnalyzeRequest):
    prompt = f"""
You are an expert language teacher.

Read the following text carefully and create EXACTLY 3 questions based on it.
Mix the question types:
- At least one multiple_choice
- At least one fill_in_the_blank

TEXT TO ANALYZE:
---
{request.text}
---

CRITICAL RULES:
1. For "multiple_choice", provide a question and 4 options.
2. For "fill_in_the_blank", provide a sentence with EXACTLY three underscores: ___
3. The "question", "options", "word_bank", and "correct_answer" MUST be in {request.target_language}.
4. The "question_translation" and "explanation" MUST be in {request.native_language}.
5. For multiple_choice, "correct_answer" MUST exactly match one of the options.
6. For fill_in_the_blank, "correct_answer" MUST exactly match one of the words in "word_bank".
7. ONLY output a valid JSON object. No markdown. No explanation outside JSON.

The JSON structure MUST exactly match this format:

{{
  "questions": [
    {{
      "type": "multiple_choice",
      "question": "What is the main topic?",
      "question_translation": "Ana konu nedir?",
      "options": ["A) option one", "B) option two", "C) option three", "D) option four"],
      "correct_answer": "A) option one",
      "explanation": "Metne göre doğru cevap budur."
    }},
    {{
      "type": "fill_in_the_blank",
      "question": "The technology is growing very ___ today.",
      "question_translation": "Teknoloji bugün çok hızlı büyüyor.",
      "word_bank": ["fast", "slow", "apple", "car"],
      "correct_answer": "fast",
      "explanation": "Metinde büyümenin hızlı olduğu anlatılıyor."
    }}
  ]
}}
"""

    try:
        client = genai.Client()

        response = client.models.generate_content(
            model="gemini-2.5-flash-lite",
            contents=prompt,
            config=types.GenerateContentConfig(
                response_mime_type="application/json"
            ),
        )

        raw_text = response.text or ""

        clean_text = raw_text.strip()
        clean_text = clean_text.replace("```json", "").replace("```", "").strip()

        # Gemini bazen JSON dışına metin eklerse ilk JSON objesini yakala
        match = re.search(r"\{.*\}", clean_text, re.DOTALL)
        if match:
            clean_text = match.group(0)

        quiz_data = json.loads(clean_text)

        if "questions" not in quiz_data or not isinstance(quiz_data["questions"], list):
            raise ValueError("AI response does not contain a valid questions list.")

        return quiz_data

    except json.JSONDecodeError as e:
        raise HTTPException(
            status_code=500,
            detail=f"JSON parse hatası: {str(e)}"
        )

    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Sınav Üretim Hatası: {str(e)}"
        )
# En üste typing'den List eklemeyi unutma (varsa sorun yok)
# schemas.py'den RoleplayRequest ve ChatMessage'ı import ettiğinden emin ol.


@router.post("/chat_roleplay")
async def chat_roleplay(request: schemas.RoleplayRequest):
    try:
        # 1. GEÇMİŞİ DÜZENLE (Gemini'nin anlayacağı bir metne çeviriyoruz)
        history_text = ""
        for msg in request.chat_history:
            sender = "Öğrenci" if msg.role == "user" else "Sen (Garson/Karakter)"
            history_text += f"{sender}: {msg.text}\n"

        # 2. EFSANEVİ ROLEPLAY PROMPTU
        prompt = f"""
        Sen bir dil pratiği uygulaması için yaratılmış, çok gerçekçi bir karaktersin.
        Karşındaki kişi {request.user_level} seviyesinde {request.target_language} öğrenen bir öğrenci.
        
        SENARYO BİLGİSİ:
        Eğer '{request.scenario}' değeri "AUTO" ise: Öğrencinin seviyesine ({request.user_level}) uygun, RASTGELE, yaratıcı ve eğlenceli bir günlük hayat senaryosu yarat (Örn: Kayıp Eşya Bürosu, Pasaport Kontrolü, Evcil Hayvan Dükkanı).
        Eğer "AUTO" değilse: Doğrudan '{request.scenario}' senaryosunu oyna.

        Görevlerin ve Kuralların:
        1. SADECE {request.target_language} dilinde konuş. Asla çeviri yapma.
        2. Karakterinden ASLA çıkma. Karşındakine gerçekten o mekandaymış gibi davran.
        3. Öğrencinin seviyesine uygun karmaşıklıkta cümleler kur.
        4. SOHBETİ SONLANDIRMA: Eğer olay çözüldüyse (hesap ödendiyse, bilet alındıysa) 'is_conversation_over' değerini true yap.

        Öğrencinin Son Mesajı: "{request.user_message}"
        Geçmiş Sohbet:
        {history_text}

        ÇIKTI FORMATI:
        Sadece aşağıdaki JSON formatında çıktı ver:
        {{
            "scenario_name": "Seçtiğin veya uydurduğun senaryonun kısa ve havalı adı (Örn: Paris'te Bir Fırın)",
            "ai_response": "Bonjour! Que puis-je faire pour vous aujourd'hui?",
            "correction_for_user": "Varsa kendi dilinde gramer düzeltmesi, yoksa boş bırak",
            "is_conversation_over": false
        }}
        """
      
        # Yeni Google GenAI SDK ile çağrı (JSON formatına zorluyoruz)
        client = genai.Client()
        response = client.models.generate_content(
            model='gemini-2.5-flash-lite',
            contents=prompt,
            config=types.GenerateContentConfig(
                response_mime_type="application/json",
            ),
        )
        #  1. GEMINI'DEN GELEN HAM METNİ AL
        raw_text = response.text.strip()
        print(" Gemini'den Gelen Ham Cevap:", raw_text) # Hatayı görmek için terminale yazdırıyoruz!

        # 
        if raw_text.startswith("```json"):
            raw_text = raw_text[7:] # Baştaki ```json kısmını kes
        if raw_text.startswith("```"):
            raw_text = raw_text[3:] 
        if raw_text.endswith("```"):
            raw_text = raw_text[:-3] 
            
        raw_text = raw_text.strip() # Boşlukları temizle
        
        #  3. TEMİZLENMİŞ METNİ JSON'A ÇEVİR
        analysis_data = json.loads(raw_text)

        return {
            "status": "success",
            "data": analysis_data
        }

    except Exception as e:
        # HATANIN NE OLDUĞUNU TERMİNALDE GÖRMEK İÇİN:
        print("  ROLEPLAY HATASI:", str(e))
        raise HTTPException(status_code=500, detail=f"Sohbet hatası: {str(e)}")
    



def ask_ai_for_grammar_check(
    target_language: str,
    native_language: str,
    original: str,
    correct: str,
    submitted: list
) -> dict:

    prompt = f"""
You are an expert {target_language} grammar teacher. The student's native language is {native_language}.
Analyze the student's sentence building attempt using academic grammar terminology.

Your response MUST BE ONLY a valid JSON object. Do not include any markdown formatting like ```json, code blocks, or conversational text. Just output the raw JSON.

Original sentence ({native_language}): '{original}'
Correct {target_language} sentence: '{correct}'
Student's attempt: '{ " ".join(submitted) if isinstance(submitted, list) else submitted }'

The JSON structure must exactly match this format:
{{
    "score": "80/100",
    "word_breakdown": {{
        "She": "dişil özne (he/she/it)",
        "is": "'to be' fiilinin 3. tekil hali",
        "a teacher": "meslek için 'a' artikeli kullanılır"
    }},
    "ai_tip": "💡 'He is a doctor' / 'She is a nurse' kalıbını hatırla!"
}}

Instructions:
1. Compare the student's attempt '{' '.join(submitted)}' to the correct sentence '{correct}'.
2. Score out of 100:
   - 100/100 → perfect match
   - 70-99   → correct meaning but minor word order issue
   - 40-69   → partially correct
   - 0-39    → mostly incorrect
3. In "word_breakdown":
   - Use the CORRECT sentence words/phrases as keys (not the student's wrong words).
   - Group words that belong together as a phrase (e.g. "a teacher", "go to school").
   - Explain WHY each word/phrase is grammatically correct using academic terms.
   - If the student made an error on that word, briefly explain the mistake.
   - STRICTLY write ALL explanations in {native_language}.
4. In "ai_tip":
   - Always start with 💡
   - Give a memorable grammar rule related to this sentence.
   - Write the rule explanation in {native_language}.
   - Provide 2 short example sentences in {target_language}.
   - Keep it under 2 sentences total.
5. NEVER add extra fields. Only return: score, word_breakdown, ai_tip.
"""

    try:
        client = genai.Client()
        response = client.models.generate_content(
            model="gemini-2.5-flash-lite",
            contents=prompt
        )

        clean_text = response.text.strip()

        # Olası Markdown kalıntılarını temizle
        if clean_text.startswith("```json"):
            clean_text = clean_text[7:]
        elif clean_text.startswith("```"):
            clean_text = clean_text[3:]

        if clean_text.endswith("```"):
            clean_text = clean_text[:-3]

        ai_data = json.loads(clean_text.strip())
        return ai_data

    except Exception as e:
        print(f"🤖 AI API Hatası: {e}")
        return {
            "score": "0/100",
            "word_breakdown": {
                "Sistem Hatası": "Şu an AI öğretmenine ulaşılamıyor, ancak cümlende hatalar mevcut."
            },
            "ai_tip": f"💡 Lütfen {target_language} dilbilgisi kurallarını gözden geçirip tekrar dene."
        }



@router.post(
    "/fetch_sentence_puzzle",
    response_model=List[schemas.SentenceFetchResponse],
)
async def fetch_sentence_puzzle(
    request: schemas.SentenceFetchRequest,
    db: Session = Depends(get_db),
):
    native_language_map = {
        "tr": "Turkish",
        "turkish": "Turkish",
        "türkçe": "Turkish",

        "en": "English",
        "english": "English",
        "ingilizce": "English",

        "es": "Spanish",
        "spanish": "Spanish",
        "ispanyolca": "Spanish",

        "de": "German",
        "german": "German",
        "almanca": "German",

        "fr": "French",
        "french": "French",
        "fransızca": "French",
    }

    normalized_native_language = native_language_map.get(
        request.native_language.strip().lower(),
        request.native_language.strip(),
    )

    print(
        "🧩 SENTENCE PUZZLE REQUEST:",
        {
            "target_language": request.target_language,
            "native_language": request.native_language,
            "normalized_native_language": normalized_native_language,
            "lesson_id": request.lesson_id,
        },
    )

    # Hedef dile göre soruları getir.
    query = db.query(models.SentencePuzzle).filter(
        models.SentencePuzzle.target_language
        == request.target_language
    )

    if request.lesson_id is not None:
        query = query.filter(
            models.SentencePuzzle.lesson_id
            == request.lesson_id
        )

    puzzles = query.all()

    # Veritabanında soru yoksa uygulama çökmesin.
    if not puzzles:
        fallback_words = ["home", "I", "am", "going"]
        random.shuffle(fallback_words)

        fallback_sentence = (
            "No questions were found for this lesson."
            if normalized_native_language == "English"
            else "Veritabanında bu derse ait soru yok! (YEDEK)"
        )

        return [
            schemas.SentenceFetchResponse(
                id=0,
                original_sentence=fallback_sentence,
                correct_sentence="I am going home",
                scrambled_words=fallback_words,
            )
        ]

    selected_puzzles = random.sample(
        puzzles,
        min(5, len(puzzles)),
    )

    # Seçilen soruların istenen ana dildeki çevirilerini
    # tek sorguda getiriyoruz.
    translations_by_puzzle_id = {}

    if normalized_native_language != "Turkish":
        selected_ids = [
            puzzle.id
            for puzzle in selected_puzzles
        ]

        translation_records = (
            db.query(models.SentencePuzzleTranslation)
            .filter(
                models.SentencePuzzleTranslation.puzzle_id.in_(
                    selected_ids
                ),
                models.SentencePuzzleTranslation.native_language
                == normalized_native_language,
            )
            .all()
        )

        translations_by_puzzle_id = {
            translation.puzzle_id: translation
            for translation in translation_records
        }

    response_list = []

    for puzzle in selected_puzzles:
        localized_original_sentence = (
            puzzle.original_sentence
        )

        translation_record = translations_by_puzzle_id.get(
            puzzle.id
        )

        # İstenen dilde çeviri varsa onu kullan.
        # Yoksa mevcut Türkçe cümleye geri dön.
        if translation_record is not None:
            localized_original_sentence = (
                translation_record.original_sentence
            )

        words_list = puzzle.correct_sentence.split()
        random.shuffle(words_list)

        response_list.append(
            schemas.SentenceFetchResponse(
                id=puzzle.id,
                original_sentence=localized_original_sentence,
                correct_sentence=puzzle.correct_sentence,
                scrambled_words=words_list,
            )
        )

    return response_list



@router.get("/fetch_flashcards/{lesson_id}")
async def fetch_flashcards(lesson_id: int,target_language: str, db: Session = Depends(get_db)):
    cards = db.query(Flashcard).filter(Flashcard.lesson_id == lesson_id , Flashcard.target_language == target_language).all()
    
    # Eğer o derse ait kart yoksa boş liste dönmesin, uygulama çökmesin
    if not cards:
        return []
        
    return [{"word": c.word, "translation": c.translation, "image": c.image} for c in cards]


@router.post("/log_mistake")
def log_mistake(request: schemas.AddMistakeRequest, db: Session = Depends(get_db)):
    # 1. Kullanıcıyı bul (Senin kodun aynısı)
    user = db.query(models.UserDB).filter(models.UserDB.username == request.username).first()
    if not user:
        raise HTTPException(status_code=404, detail="Kullanıcı bulunamadı")
        
    # 2. Bu soruyu daha önce de yanlış yapmış mı kontrol et
    existing_mistake = db.query(models.MistakeDB).filter(
        models.MistakeDB.user_id == user.id, 
        models.MistakeDB.puzzle_id == request.puzzle_id,
        models.MistakeDB.puzzle_type == request.puzzle_type,
        models.MistakeDB.target_language == request.target_language
    ).first()
    
    if existing_mistake:
        # Daha önce de bilememişse hata sayısını artır (Senior Dokunuşu!)
        existing_mistake.mistake_count += 1
    else:
        # İlk defa bilemediyse yeni kayıt oluştur
        new_mistake = models.MistakeDB(
            user_id=user.id, 
            puzzle_id=request.puzzle_id,
            mistake_count=1,
            puzzle_type=request.puzzle_type,
            target_language=request.target_language
        )
        db.add(new_mistake)
        
    db.commit()
    return {"message": "Hata veritabanına kaydedildi!"}


#boşluk doldurma için kullanılacak endpoint

@router.post(
    "/fetch_blank_puzzles",
    response_model=List[schemas.BlankFetchResponse],
)
async def fetch_blank_puzzles(
    request: schemas.BlankPuzzleFetchRequest,
    db: Session = Depends(get_db),
):
    # Ana dil adını veritabanındaki değerlerle eşleştiriyoruz.
    native_language_map = {
        "tr": "Turkish",
        "turkish": "Turkish",
        "türkçe": "Turkish",

        "en": "English",
        "english": "English",
        "ingilizce": "English",

        "es": "Spanish",
        "spanish": "Spanish",
        "ispanyolca": "Spanish",

        "de": "German",
        "german": "German",
        "almanca": "German",

        "fr": "French",
        "french": "French",
        "fransızca": "French",
    }

    requested_native_language = request.native_language.strip().lower()

    normalized_native_language = native_language_map.get(
        requested_native_language,
        request.native_language.strip(),
    )

    print(
        "🌍 BLANK PUZZLE REQUEST:",
        {
            "target_language": request.target_language,
            "native_language": request.native_language,
            "normalized_native_language": normalized_native_language,
            "lesson_id": request.lesson_id,
        },
    )

    # Ana tablodaki soruları getiriyoruz.
    puzzles = (
        db.query(models.BlankPuzzle)
        .filter(
            models.BlankPuzzle.lesson_id == request.lesson_id,
            models.BlankPuzzle.target_language
            == request.target_language,
        )
        .all()
    )

    if not puzzles:
        return []

    selected_puzzles = random.sample(
        puzzles,
        min(5, len(puzzles)),
    )

    response_data = []

    for puzzle in selected_puzzles:
        # Varsayılan olarak mevcut Türkçe çeviri kullanılır.
        localized_translation = puzzle.translation or ""

        # Kullanıcının ana dili Türkçe değilse yeni tabloya bakılır.
        if normalized_native_language != "Turkish":
            translation_record = (
                db.query(models.BlankPuzzleTranslation)
                .filter(
                    models.BlankPuzzleTranslation.puzzle_id
                    == puzzle.id,
                    models.BlankPuzzleTranslation.native_language
                    == normalized_native_language,
                )
                .first()
            )

            # İstenen dilde çeviri varsa onu kullan.
            # Yoksa eski Türkçe çeviri kullanılmaya devam eder.
            if translation_record is not None:
                localized_translation = (
                    translation_record.translation
                )

        response_data.append(
            {
                "id": puzzle.id,
                "before_text": puzzle.before_text or "",
                "after_text": puzzle.after_text or "",
                "correct_answer": puzzle.correct_answer or "",
                "translation": localized_translation,
            }
        )

    return response_data



@router.post("/evaluate_answer")
def evaluate_answer(request: schemas.PuzzleAnswerRequest, db: Session = Depends(get_db)):
    # 1. Kullanıcıyı bul
    user = db.query(models.UserDB).filter(models.UserDB.username == request.username).first()
    if not user:
        raise HTTPException(status_code=404, detail="Kullanıcı bulunamadı")

    # 2. Bu soruya ait 'mistakes' kaydı var mı kontrol et
    mistake_log = db.query(models.MistakeDB).filter(
        models.MistakeDB.user_id == user.id,
        models.MistakeDB.puzzle_id == request.puzzle_id,
        models.MistakeDB.puzzle_type == request.puzzle_type
    ).first()

    # --- ❌ KULLANICI YANLIŞ CEVAP VERDİYSE ---
    if not request.is_correct:
        if mistake_log:
            mistake_log.mistake_count += 1 # Hata sayısını artır
        else:
            # İlk defa yanlış yaptıysa yeni kayıt aç
            new_mistake = models.MistakeDB(
                user_id=user.id,
                puzzle_id=request.puzzle_id,
                puzzle_type=request.puzzle_type,
                mistake_count=1
            )
            db.add(new_mistake)
        
        db.commit()
        return {"status": "wrong", "message": "Hata kaydedildi. Daha çok çalışmalı!"}

    # --- ✅ KULLANICI DOĞRU CEVAP VERDİYSE ---
    else:
        is_learned_now = False

        # Kelimeyi kullanıcının sözlüğünde (user_vocabulary) bul
        vocab_entry = db.query(models.VocabularyDB).filter(
            models.VocabularyDB.user_id == user.id,
            models.VocabularyDB.word == request.tested_word
        ).first()

        # Algoritma: Eğer hata kaydı yoksa veya hata sayısı 2'den azsa, ÖĞRENDİ say!
        if mistake_log is None or mistake_log.mistake_count <= 2:
            if vocab_entry and not vocab_entry.is_learned:
                vocab_entry.is_learned = True
                is_learned_now = True
                
            # Öğrendiği için mistake tablosundan silebiliriz (Veritabanı temiz kalır)
            if mistake_log:
                db.delete(mistake_log)
        else:
            # Çok hatası varsa, doğru bildiği için cezasını 1 düşür (Hemen öğrenildi sayma)
            mistake_log.mistake_count -= 1

        db.commit()

        if is_learned_now:
            return {"status": "correct", "message": f"Tebrikler! '{request.tested_word}' kelimesi ÖĞRENİLDİ olarak işaretlendi! 🏆"}
        else:
            return {"status": "correct", "message": "Doğru! Ama tam öğrenmek için biraz daha pratik yapmalısın."}
        


# 🌟 DİKKAT: URL'ye ve fonksiyona target_language parametresini ekledik!
@router.get("/get_learning_stats/{username}")
def get_learning_stats(username: str, target_language: str, db: Session = Depends(get_db)):
    
    user = db.query(models.UserDB).filter(models.UserDB.username == username ).first()
    if not user:
        raise HTTPException(status_code=404, detail="Kullanıcı bulunamadı")

    # 🌟 KELİME KUMBARASI (Sadece o dilin kelimelerini sayıyoruz)
    total_words = db.query(models.VocabularyDB).filter(
        models.VocabularyDB.user_id == user.id,
        models.VocabularyDB.target_language == target_language # YENİ EKLENDİ
    ).count()
    
    learned_words = db.query(models.VocabularyDB).filter(
        models.VocabularyDB.user_id == user.id,
        models.VocabularyDB.target_language == target_language, # YENİ EKLENDİ
        models.VocabularyDB.is_learned == True
    ).count()

    # 1. BEKLEYEN HATALAR (Sadece kemik sorular ve o dildeki hatalar)
    allowed_types = ["blank_puzzle", "sentence_puzzle", "minimal_pair"] # YENİ EKLENDİ
    
    mistake_count = db.query(models.MistakeDB).filter(
        models.MistakeDB.user_id == user.id, 
        models.MistakeDB.target_language == target_language,
        models.MistakeDB.puzzle_type.in_(allowed_types)
    ).count() # PARANTEZ HATASI DÜZELTİLDİ
    
    # 2. Bekleyen Kelimeler (Sadece Flashcard)
    unlearned_words = total_words - learned_words

    return {
        "total_words": total_words,
        "learned_words": learned_words,
        "mistake_count": mistake_count,
        "unlearned_words": unlearned_words
    }
import random


@router.get("/get_mistake_details/{username}")
def get_mistake_details(
    username: str,
    target_language: str,
    native_language: str = "Turkish",
    db: Session = Depends(get_db),
):
    native_language_map = {
        "tr": "Turkish",
        "turkish": "Turkish",
        "türkçe": "Turkish",

        "en": "English",
        "english": "English",
        "ingilizce": "English",

        "es": "Spanish",
        "spanish": "Spanish",
        "ispanyolca": "Spanish",

        "de": "German",
        "german": "German",
        "almanca": "German",

        "fr": "French",
        "french": "French",
        "fransızca": "French",
    }

    normalized_native_language = native_language_map.get(
        native_language.strip().lower(),
        native_language.strip(),
    )

    user = (
        db.query(models.UserDB)
        .filter(models.UserDB.username == username)
        .first()
    )

    if not user:
        raise HTTPException(
            status_code=404,
            detail="Kullanıcı bulunamadı",
        )

    practice_list = []

    allowed_types = [
        "blank_puzzle",
        "sentence_puzzle",
        "minimal_pair",
    ]

    mistakes = (
        db.query(models.MistakeDB)
        .filter(
            models.MistakeDB.user_id == user.id,
            models.MistakeDB.target_language == target_language,
            models.MistakeDB.puzzle_type.in_(allowed_types),
        )
        .limit(10)
        .all()
    )

    for mistake in mistakes:
        question_text = (
            "Question content not found"
            if normalized_native_language == "English"
            else "Soru içeriği bulunamadı"
        )

        # -----------------------------------------------------
        # BOŞLUK DOLDURMA
        # Soru hedef dilde olduğu için çevrilmez.
        # -----------------------------------------------------
        if mistake.puzzle_type == "blank_puzzle":
            puzzle = (
                db.query(models.BlankPuzzle)
                .filter(
                    models.BlankPuzzle.id == mistake.puzzle_id
                )
                .first()
            )

            if puzzle:
                question_text = (
                    f"{puzzle.before_text} ___ "
                    f"{puzzle.after_text}"
                )

        # -----------------------------------------------------
        # MİNİMAL PAIR
        # Kelimeler hedef dilde olduğu için çevrilmez.
        # -----------------------------------------------------
        elif mistake.puzzle_type == "minimal_pair":
            puzzle = (
                db.query(models.MinimalPair)
                .filter(
                    models.MinimalPair.id == mistake.puzzle_id
                )
                .first()
            )

            if puzzle:
                question_text = (
                    f"{puzzle.word_1} vs {puzzle.word_2}"
                )

        # -----------------------------------------------------
        # CÜMLE KURMA
        # original_sentence kullanıcının ana diline çevrilir.
        # -----------------------------------------------------
        elif mistake.puzzle_type == "sentence_puzzle":
            puzzle = (
                db.query(models.SentencePuzzle)
                .filter(
                    models.SentencePuzzle.id == mistake.puzzle_id
                )
                .first()
            )

            if puzzle:
                question_text = puzzle.original_sentence

                if normalized_native_language != "Turkish":
                    translation_record = (
                        db.query(
                            models.SentencePuzzleTranslation
                        )
                        .filter(
                            models.SentencePuzzleTranslation.puzzle_id
                            == puzzle.id,
                            models.SentencePuzzleTranslation.native_language
                            == normalized_native_language,
                        )
                        .first()
                    )

                    if translation_record is not None:
                        question_text = (
                            translation_record.original_sentence
                            or puzzle.original_sentence
                        )

        practice_list.append(
            {
                "puzzle_id": mistake.puzzle_id,
                "puzzle_type": mistake.puzzle_type,
                "question_text": question_text,
                "mistake_count": mistake.mistake_count,
                "is_new_word": False,
            }
        )

    if practice_list:
        random.shuffle(practice_list)

    return practice_list



# 1. Sadece öğrenilmemiş kelimeleri çeken GET endpoint'i
@router.get("/get_flashcard_practice/{username}")
def get_flashcard_practice(username: str,
                           target_language: str = "English",
                            db: Session = Depends(get_db)):
    user = db.query(models.UserDB).filter(models.UserDB.username == username).first()
    if not user:
        raise HTTPException(status_code=404, detail="Kullanıcı bulunamadı")
        
    # Kullanıcıyı boğmamak için tek seferde en fazla 15 kelime getir
    unlearned_words = db.query(models.VocabularyDB).filter(
        models.VocabularyDB.user_id == user.id,
        models.VocabularyDB.is_learned == False,
        models.VocabularyDB.target_language == target_language
    ).limit(15).all()
    
    return unlearned_words


# 3. Kelimeyi "Öğrenildi" yapan POST endpoint'i
@router.post("/mark_word_learned")
def mark_word_learned(request: schemas.MarkLearnedRequest, db: Session = Depends(get_db)):
    user = db.query(models.UserDB).filter(models.UserDB.username == request.username).first()
    if not user:
        raise HTTPException(status_code=404)
        
    word = db.query(models.VocabularyDB).filter(
        models.VocabularyDB.id == request.word_id,
        models.VocabularyDB.user_id == user.id
    ).first()
    
    if word:
        word.is_learned = True
        db.commit()
        return {"success": True, "message": "Kelime öğrenildi!"}
    return {"success": False}



@router.get("/get_practice_puzzle")
def get_practice_puzzle(
    puzzle_id: int,
    puzzle_type: str,
    native_language: str = "Turkish",
    db: Session = Depends(get_db),
):
    native_language_map = {
        "tr": "Turkish",
        "turkish": "Turkish",
        "türkçe": "Turkish",

        "en": "English",
        "english": "English",
        "ingilizce": "English",

        "es": "Spanish",
        "spanish": "Spanish",
        "ispanyolca": "Spanish",

        "de": "German",
        "german": "German",
        "almanca": "German",

        "fr": "French",
        "french": "French",
        "fransızca": "French",
    }

    normalized_native_language = native_language_map.get(
        native_language.strip().lower(),
        native_language.strip(),
    )

    print(
        "🎯 PRACTICE PUZZLE REQUEST:",
        {
            "puzzle_id": puzzle_id,
            "puzzle_type": puzzle_type,
            "native_language": native_language,
            "normalized_native_language": normalized_native_language,
        },
    )

    # ---------------------------------------------------------
    # BOŞLUK DOLDURMA PRATİĞİ
    # ---------------------------------------------------------
    if puzzle_type == "blank_puzzle":
        puzzle = (
            db.query(models.BlankPuzzle)
            .filter(models.BlankPuzzle.id == puzzle_id)
            .first()
        )

        if not puzzle:
            return []

        # Varsayılan olarak ana tablodaki Türkçe çeviriyi kullan.
        localized_translation = puzzle.translation or ""

        # Kullanıcının ana dili Türkçe değilse çeviri tablosuna bak.
        if normalized_native_language != "Turkish":
            translation_record = (
                db.query(models.BlankPuzzleTranslation)
                .filter(
                    models.BlankPuzzleTranslation.puzzle_id == puzzle.id,
                    models.BlankPuzzleTranslation.native_language
                    == normalized_native_language,
                )
                .first()
            )

            if translation_record is not None:
                localized_translation = (
                    translation_record.translation
                    or puzzle.translation
                    or ""
                )

        return [
            {
                "id": puzzle.id,
                "before_text": puzzle.before_text,
                "after_text": puzzle.after_text,
                "correct_answer": puzzle.correct_answer,
                "translation": localized_translation,
            }
        ]

    # ---------------------------------------------------------
    # CÜMLE KURMA PRATİĞİ
    # ---------------------------------------------------------
    elif puzzle_type == "sentence_puzzle":
        puzzle = (
            db.query(models.SentencePuzzle)
            .filter(models.SentencePuzzle.id == puzzle_id)
            .first()
        )

        if not puzzle:
            return []

        # Varsayılan olarak ana tablodaki Türkçe cümleyi kullan.
        localized_original_sentence = puzzle.original_sentence or ""

        # Kullanıcının ana dili Türkçe değilse çeviri tablosuna bak.
        if normalized_native_language != "Turkish":
            translation_record = (
                db.query(models.SentencePuzzleTranslation)
                .filter(
                    models.SentencePuzzleTranslation.puzzle_id == puzzle.id,
                    models.SentencePuzzleTranslation.native_language
                    == normalized_native_language,
                )
                .first()
            )

            if translation_record is not None:
                localized_original_sentence = (
                    translation_record.original_sentence
                    or puzzle.original_sentence
                    or ""
                )

        # Doğru cümleyi kelimelere ayır ve karıştır.
        words = puzzle.correct_sentence.split()
        random.shuffle(words)

        return [
            {
                "id": puzzle.id,
                "original_sentence": localized_original_sentence,
                "correct_sentence": puzzle.correct_sentence,
                "scrambled_words": words,
            }
        ]

    return []



#zayıf noktalara çalış çözüldükten sonra gelen endpoint
@router.post("/resolve_mistake")
def resolve_mistake(req: schemas.ResolveMistakeRequest, db: Session = Depends(get_db)):
    user = db.query(models.UserDB).filter(models.UserDB.username == req.username).first()
    if not user:
        raise HTTPException(status_code=404, detail="Kullanıcı bulunamadı")
        
    # Veritabanında o hatayı bul
    mistake = db.query(models.MistakeDB).filter(
        models.MistakeDB.user_id == user.id,
        models.MistakeDB.puzzle_id == req.puzzle_id,
        models.MistakeDB.puzzle_type == req.puzzle_type
    ).first()
    
    # Bulursan acımadan sil!
    if mistake:
        db.delete(mistake)
        db.commit()
        return {"message": "Tebrikler, bu hata listenden silindi!"}
        
    return {"message": "Hata zaten silinmiş veya bulunamadı."}