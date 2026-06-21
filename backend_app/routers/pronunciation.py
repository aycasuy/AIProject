import re

from fastapi import APIRouter, Depends, HTTPException
import json
from google import genai
from google.genai import types
from requests import Session # JSON formatına zorlamak için gerekli
from routers.user import get_db
import models
import schemas
from schemas import PronunciationCorrectionRequest, PronunciationRequest 
import config
from schemas import GeneratePronunciationRequest
from schemas import DictationRequest
from sqlalchemy.sql.expression import func

router = APIRouter()

# Yeni SDK'da Client oluşturuyoruz (GEMINI_API_KEY ortam değişkeninden otomatik alınır)
client = genai.Client()
client = genai.Client(api_key=config.GOOGLE_API_KEY)

from sqlalchemy.sql.expression import func

from sqlalchemy import func


def clean_pronunciation_text(text: str) -> str:
    if not text:
        return ""

    text = text.replace("```json", "").replace("```", "")
    text = text.replace("**", "").replace("*", "")
    text = text.replace("\n", " ")
    text = re.sub(r"\s+", " ", text)
    return text.strip()


@router.post("/generate_pronunciation_text")
async def generate_pronunciation_text(
    request: schemas.GeneratePronunciationRequest,
    db: Session = Depends(get_db)
):
    exclude_texts = request.exclude_texts or []

    # 1. ÖNCE VERİTABANINDAN DENE
    # A1, A2, B1... fark etmez. Eğer pronunciation_texts tablosunda bu ders için hazır metin varsa onu kullan.
    query = db.query(models.PronunciationText).filter(
        models.PronunciationText.level == request.level,
        models.PronunciationText.target_language == request.target_language
    )

    if request.lesson_id is not None:
        query = query.filter(models.PronunciationText.lesson_id == request.lesson_id)

    if exclude_texts:
        query = query.filter(~models.PronunciationText.text.in_(exclude_texts))

    random_record = query.order_by(func.random()).first()

    if random_record:
        selected_text = clean_pronunciation_text(random_record.text)
        return {
            "status": "success",
            "source": "database",
            "text": selected_text
        }

    # Eğer exclude yüzünden kayıt kalmadıysa aynı dersin kayıtlarından tekrar seç.
    fallback_query = db.query(models.PronunciationText).filter(
        models.PronunciationText.level == request.level,
        models.PronunciationText.target_language == request.target_language
    )

    if request.lesson_id is not None:
        fallback_query = fallback_query.filter(
            models.PronunciationText.lesson_id == request.lesson_id
        )

    fallback_record = fallback_query.order_by(func.random()).first()

    if fallback_record:
        selected_text = clean_pronunciation_text(fallback_record.text)
        return {
            "status": "success",
            "source": "database_fallback",
            "text": selected_text
        }

    # 2. VERİTABANINDA HİÇ METİN YOKSA AI ÜRETSİN
    # Eski hatanın sebebi: cache key sadece level + words idi.
    # Bu yüzden 1. ve 2. adımda aynı cache metni dönüyordu.
    # Artık lesson_id ve round da cache key'e dahil.
    cache_key = (
        f"lang:{request.target_language}|"
        f"level:{request.level}|"
        f"lesson:{request.lesson_id}|"
        f"round:{request.round}|"
        f"words:{request.target_words}"
    ).lower()

    cached_data = db.query(models.AICache).filter(
        models.AICache.feature_type == "pronunciation_text",
        models.AICache.input_text == cache_key
    ).first()

    if cached_data:
        print("⚡ [CACHE BULDUM - METİN] Aynı round için cache döndürüldü.")
        cached_json = json.loads(cached_data.ai_response)
        cached_json["text"] = clean_pronunciation_text(cached_json.get("text", ""))
        return cached_json

    try:
        print("🤖 [GEMİNİ DEVREDE - METİN] Cache yok. Yeni telaffuz metni üretiliyor...")

        prompt = f"""
Sen uzman bir {request.target_language} dil öğretmenisin.

Öğrencinin seviyesi: {request.level}
Bu görev: Telaffuz pratiği
Bu kaçıncı metin: {request.round}

Zorunlu kelimeler:
{request.target_words}

Kurallar:
- {request.target_language} dilinde yaz.
- Öğrencinin seviyesine uygun yaz.
- 2 kısa cümle veya en fazla 3 kısa cümle üret.
- Metin doğal ve sesli okunabilir olmalı.
- Zorunlu kelimeleri doğal şekilde kullan.
- Daha önceki metinlere benzemeyen farklı bir metin üret.
- Markdown kullanma.
- Kelimeleri **kalın** yapma.
- Tırnak işareti, madde işareti veya açıklama ekleme.
- Sadece paragrafı döndür.
"""

        response = client.models.generate_content(
            model="gemini-2.5-flash-lite",
            contents=prompt,
            config=types.GenerateContentConfig(
                temperature=0.9,
                top_p=0.95
            )
        )

        generated_text = clean_pronunciation_text(response.text or "")

        if not generated_text:
            generated_text = "Please read this sentence clearly and slowly."

        result_json = {
            "status": "success",
            "source": "ai",
            "text": generated_text
        }

        new_cache = models.AICache(
            feature_type="pronunciation_text",
            input_text=cache_key,
            ai_response=json.dumps(result_json, ensure_ascii=False)
        )
        db.add(new_cache)
        db.commit()

        print("✅ [KAYDEDİLDİ] Yeni telaffuz metni cache tablosuna yazıldı.")
        return result_json

    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Metin Üretme Hatası: {str(e)}"
        )


@router.post("/analyze_pronunciation")
async def analyze_pronunciation(request: schemas.PronunciationRequest, db: Session = Depends(get_db)):

    native_language_key = request.native_language.strip().lower()

    native_language_map = {
        "english": "English",
        "ingilizce": "English",
        "spanish": "Spanish",
        "ispanyolca": "Spanish",
        "turkish": "Turkish",
        "türkçe": "Turkish",
        "german": "German",
        "almanca": "German",
        "french": "French",
        "fransızca": "French",
    }

    feedback_language = native_language_map.get(
        native_language_key,
        request.native_language.strip(),
    )

    print(
        "🌍 PRONUNCIATION ANALYSIS:",
        {
            "target_language": request.target_language,
            "native_language": request.native_language,
            "feedback_language": feedback_language,
        },
    )
    
    # =================================================================
    # 🌟 SÜPER GENİŞLETİLMİŞ YAZILIMSAL TOLERANS SÖZLÜĞÜ (MVP KATİLİ) 🌟
    # =================================================================
    stt_corrections = {
        "a": ["i", "ah", "uh", "hey", "eight", "ay", "ei", "an", "e", "a."],
        "the": ["da", "de", "di", "zee", "v", "they"],
        "an": ["and", "in", "un", "on", "a"],
        "it": ["eat", "at"],
        "is": ["ease", "yes", "his"],
        "yell": ["yeah", "yellow", "yal", "yale", "jail", "gel", "young", "you", "yo", "ill", "el", "yel", "yes"],
        "buy": ["by", "bye", "boy", "my", "why", "ba", "bay", "pie", "guy"],
        "hi": ["he", "high", "hay", "i", "bye"],
        "he": ["hi", "see", "the", "who", "hay"],
        "bye": ["buy", "by", "my", "pie", "bay"],
        "yes": ["yell", "less", "guess", "is"],
        "no": ["know", "now", "not", "oh", "knows"],
        "know": ["no", "now", "new", "known"],
        "please": ["place", "plays", "police", "pleas"],
        "place": ["please", "plays", "pace", "plate"],
        "thank": ["tank", "think", "sank", "thanks"],
        "tank": ["thank", "think", "bank"],
        "sorry": ["story", "sari", "starry"],
        "story": ["sorry", "store"],
        "good": ["food", "wood", "could", "hood", "god"],
        "food": ["good", "foot", "fluid"],
        "meet": ["meat", "met", "mit", "it"],
        "meat": ["meet", "met", "mit"],
        "met": ["meet", "meat", "mat"],
        "night": ["knight", "not", "light", "right", "nine"],
        "knight": ["night", "not"],
        "how": ["hoe", "who", "now", "ha"],
        "hoe": ["how", "who"],
        "live": ["leave", "life", "love", "liv"],
        "leave": ["live", "leaf", "let"],
        "age": ["edge", "h", "each", "itch"],
        "edge": ["age", "egg", "each"],
        "name": ["same", "main", "nim", "game"],
        "same": ["name", "some", "shame"],
        "year": ["ear", "here", "hear", "your"],
        "ear": ["year", "air", "are"],
        "old": ["cold", "hold", "gold", "all"],
        "cold": ["old", "gold", "hold"],
        "like": ["lake", "lock", "luck", "light"],
        "lake": ["like", "look", "late"],
        "job": ["jog", "chop", "top", "hop"],
        "jog": ["job", "dog", "jug"],
        "speak": ["peak", "week", "speech", "big"],
        "peak": ["speak", "beak", "pick"],
        "learn": ["turn", "earn", "line", "burnt"],
        "turn": ["learn", "tern", "time"],
        "one": ["won", "on", "van", "when", "want","run"],
        "won": ["one", "on", "win", "gone","ron"],
        "two": ["too", "to", "do", "through", "who"],
        "too": ["two", "to", "do"],
        "four": ["for", "fore", "or", "door", "far"],
        "for": ["four", "fore", "or","far"],
        "three": ["tree", "free", "the", "try", "they"],
        "tree": ["three", "free", "try"],
        "five": ["fine", "fire", "live", "find"],
        "fine": ["five", "find", "line"],
        "six": ["sick", "seek", "sex", "sicks", "since"],
        "sick": ["six", "seek", "thick"],
        "eight": ["ate", "it", "hate", "a", "hey"],
        "ate": ["eight", "eat", "at"],
        "nine": ["line", "mine", "night", "fine", "none"],
        "line": ["nine", "mine", "lane"],
        "ten": ["pen", "pan", "then", "tan", "time","on"],
        "pen": ["ten", "pan", "pin"],
        "thirteen": ["thirty", "13", "third in"],
        "thirty": ["thirteen", "dirty"],
        "fourteen": ["forty", "14", "four in"],
        "forty": ["fourteen", "party"],
        "fifteen": ["fifty", "15", "fifth in"],
        "fifty": ["fifteen", "nifty","50","elli"],
        "sixteen": ["sixty", "16", "six in"],
        "sixty": ["sixteen"]
    }
    
    orig_clean = request.original_text.strip().lower()
    spoken_clean = request.spoken_text.strip().lower()
    
    # =================================================================
    # 🌟 YENİ: SÜPER AKILLI EŞLEŞTİRME (SMART MATCHING) 🌟
    # Hedef kelime veya tolerans kelimelerinden HERHANGİ BİRİ okunan cümlenin İÇİNDE geçiyorsa doğru say!
    # =================================================================
    is_smart_match = False
    
    # Metni kelimelere bölüyoruz ki "a" harfi "banana" kelimesinin içinde geçiyor diye doğru saymasın
    spoken_words = spoken_clean.split()

    # 1. İhtimal: Orijinal kelime cümlenin içinde ayrı bir kelime olarak geçiyor mu?
    if orig_clean in spoken_words:
        is_smart_match = True
        
    # 2. İhtimal: Tolerans sözlüğündeki kelimelerden biri geçiyor mu? 
    elif orig_clean in stt_corrections:
        for correction_word in stt_corrections[orig_clean]:
            if correction_word in spoken_words:
                is_smart_match = True
                print(f"🔧 [STT HİLESİ] Mikrofon '{spoken_clean}' duydu, içinde '{correction_word}' yakalandı!")
                break

    # Eğer akıllı eşleşme başarılıysa, metni arka planda zorla "doğru" yapıyoruz
    if is_smart_match:
        request.spoken_text = request.original_text 
        spoken_clean = orig_clean

    # =================================================================
    # 🌟 MÜKEMMEL EŞLEŞME BYPASS'I (SÜPER HIZ) 🌟
    # =================================================================
    
    if orig_clean == spoken_clean:
        perfect_feedbacks = {
            "English": (
                "Perfect! You read it just like a native speaker. 🎯"
            ),
            "Spanish": (
                "¡Perfecto! Leíste como un hablante nativo. 🎯"
            ),
            "Turkish": (
                "Mükemmel! Tıpkı bir anadil konuşuru gibi okudun. 🎯"
            ),
            "German": (
                "Perfekt! Du hast es wie ein Muttersprachler gelesen. 🎯"
            ),
            "French": (
                "Parfait ! Tu as lu comme un locuteur natif. 🎯"
            ),
        }

        perfect_feedback = perfect_feedbacks.get(
            feedback_language,
            "Perfect pronunciation! 🎯",
        )

        print(
            "⚡ [KESTİRME] Birebir eşleşme. "
            f"Feedback language: {feedback_language}"
        )

        return {
            "status": "success",
            "analysis": {
                "score": 100,
                "mispronounced_words": [],
                "feedback": perfect_feedback,
            },
            "added_xp": 50,
        }



    # =================================================================
    # CACHE KONTROLÜ
    # =================================================================
    search_text = (
    f"v2 | "
    f"target_language: {request.target_language.strip().lower()} | "
    f"native_language: {feedback_language.lower()} | "
    f"original: {request.original_text.strip().lower()} | "
    f"spoken: {request.spoken_text.strip().lower()}"
)
    
    cached_data = db.query(models.AICache).filter(
        models.AICache.feature_type == "pronunciation_analysis_v2", 
        models.AICache.input_text == search_text            
    ).first()
    
    if cached_data:
        print("⚡ Analiz Sonucu Cache'ten geldi (Maliyet: 0)")
        return json.loads(cached_data.ai_response)

    # =================================================================
    # CACHE'TE YOKSA GEMİNİ'YE ANALİZ ETTİR
    # =================================================================
    try:
        print("🤖 [GEMİNİ DEVREDE - ANALİZ] Yeni bir ses geldi! Telaffuz değerlendirmesi için API'ye gidiliyor...")
        prompt = f"""
        You are an expert {request.target_language} pronunciation teacher.

        Target language: {request.target_language}
        Student's native language: {feedback_language}

        Original text:
        "{request.original_text}"

        Speech recognition result:
        "{request.spoken_text}"

        Tasks:
        1. Compare the original text with the recognized text.
        2. Give a score between 0 and 100.
        3. Identify missing or incorrectly pronounced words.
        4. Write a short, supportive pronunciation assessment.

        STRICT LANGUAGE RULE:
        - The "feedback" field must be written entirely in {feedback_language}.
        - Do not use Turkish unless the feedback language is Turkish.
        - Do not mix languages.
        - The values in "mispronounced_words" must remain in
        {request.target_language}.

        Return only valid JSON in this exact structure:
        {{
            "score": 85,
            "mispronounced_words": ["word1", "word2"],
            "feedback": "Feedback written entirely in {feedback_language}."
        }}
        """
        
        response = client.models.generate_content(
            model='gemini-2.5-flash-lite',
            contents=prompt,
            config=types.GenerateContentConfig(
                response_mime_type="application/json", 
                temperature=0.1
            ),
        )
        
        analysis_data = json.loads(response.text)
        added_xp = 50 if analysis_data.get("score", 0) >= 70 else 10

        result_json = {
            "status": "success",
            "analysis": analysis_data,
            "added_xp": added_xp
        }

        # ANALİZ SONUCUNU VERİTABANINA KAYDET
        new_cache = models.AICache(
            feature_type="pronunciation_analysis_v2", 
            input_text=search_text, 
            ai_response=json.dumps(result_json, ensure_ascii=False)
        )
        db.add(new_cache)
        db.commit()

        print("✅ [KAYDEDİLDİ] Gemini analizi tamamladı, sonuçlar gelecekteki denemeler için Cache'e kaydedildi!")
        return result_json

    except Exception as e:
        print("AI Hatası:", str(e))
        raise HTTPException(status_code=500, detail="Analiz sırasında hata oluştu.")
    



import json
import re

from fastapi import HTTPException


@router.post("/analyze_listening")
async def analyze_listening(request: DictationRequest):
    native_language_key = request.native_language.strip().lower()

    native_language_map = {
        "english": "English",
        "ingilizce": "English",
        "spanish": "Spanish",
        "ispanyolca": "Spanish",
        "turkish": "Turkish",
        "türkçe": "Turkish",
        "german": "German",
        "almanca": "German",
        "french": "French",
        "fransızca": "French",
        "italian": "Italian",
        "italyanca": "Italian",
    }

    feedback_language = native_language_map.get(
        native_language_key,
        request.native_language.strip(),
    )

    print(
        "🎧 LISTENING ANALYSIS REQUEST:",
        {
            "target_language": request.target_language,
            "native_language": request.native_language,
            "feedback_language": feedback_language,
        },
    )

    def normalize_text(value: str) -> str:
        value = value.casefold().strip()
        value = re.sub(r"[^\w\s']", " ", value, flags=re.UNICODE)
        value = re.sub(r"\s+", " ", value)
        return value.strip()

    original_clean = normalize_text(request.original_text)
    user_clean = normalize_text(request.user_text)

    # Birebir eşleşmede Gemini'ye gitmeye gerek yok.
    if original_clean == user_clean:
        perfect_feedbacks = {
            "English": "Perfect! You heard and wrote the sentence correctly. 🎯",
            "Spanish": "¡Perfecto! Escuchaste y escribiste la frase correctamente. 🎯",
            "Turkish": "Mükemmel! Cümleyi doğru dinledin ve yazdın. 🎯",
            "German": "Perfekt! Du hast den Satz richtig gehört und geschrieben. 🎯",
            "French": "Parfait ! Tu as correctement entendu et écrit la phrase. 🎯",
            "Italian": "Perfetto! Hai ascoltato e scritto correttamente la frase. 🎯",
        }

        return {
            "status": "success",
            "analysis": {
                "score": 100,
                "feedback": perfect_feedbacks.get(
                    feedback_language,
                    "Perfect! You heard and wrote the sentence correctly. 🎯",
                ),
                "missed_words": [],
            },
            "added_xp": 50,
        }

    try:
        prompt = f"""
        You are an expert {request.target_language} language teacher
        specialized in listening and dictation assessment.

        Target language:
        {request.target_language}

        Student's native language:
        {feedback_language}

        Original sentence spoken by the application:
        "{request.original_text}"

        Sentence written by the student:
        "{request.user_text}"

        Tasks:
        1. Compare the two sentences.
        2. Ignore capitalization and minor punctuation differences.
        3. Penalize small spelling mistakes only slightly.
        4. Give a score from 0 to 100.
        5. Identify missing or incorrectly written target-language words.
        6. Write a short, supportive feedback message.

        STRICT LANGUAGE RULES:
        - The "feedback" field must be written entirely in {feedback_language}.
        - Do not use Turkish unless the feedback language is Turkish.
        - Do not mix languages.
        - The words in "missed_words" must remain in {request.target_language}.
        - Return only valid JSON.
        - Do not add Markdown or explanations outside the JSON.

        Return exactly this structure:
        {{
        "score": 85,
        "feedback": "Feedback written entirely in {feedback_language}.",
        "missed_words": ["word1", "word2"]
        }}
        """

        response = client.models.generate_content(
            model="gemini-2.5-flash-lite",
            contents=prompt,
            config=types.GenerateContentConfig(
                response_mime_type="application/json",
                temperature=0.1,
            ),
        )

        analysis_data = json.loads(response.text or "{}")

        raw_score = analysis_data.get("score", 0)

        try:
            score = int(raw_score)
        except (TypeError, ValueError):
            score = 0

        score = max(0, min(100, score))

        missed_words = analysis_data.get("missed_words", [])
        if not isinstance(missed_words, list):
            missed_words = []

        feedback = str(
            analysis_data.get("feedback", "")
        ).strip()

        fallback_feedbacks = {
            "English": "The evaluation is complete. Review the missed words and try again.",
            "Spanish": "La evaluación ha terminado. Revisa las palabras omitidas e inténtalo de nuevo.",
            "Turkish": "Değerlendirme tamamlandı. Kaçırdığın kelimeleri inceleyip tekrar dene.",
            "German": "Die Auswertung ist abgeschlossen. Überprüfe die fehlenden Wörter und versuche es erneut.",
            "French": "L'évaluation est terminée. Vérifie les mots manqués et réessaie.",
            "Italian": "La valutazione è completata. Controlla le parole mancanti e riprova.",
        }

        if not feedback:
            feedback = fallback_feedbacks.get(
                feedback_language,
                "The evaluation is complete. Please try again.",
            )

        analysis_data = {
            "score": score,
            "feedback": feedback,
            "missed_words": [
                str(word) for word in missed_words
            ],
        }

        # Flutter tarafındaki başarı eşiği 60 olduğu için burada da 60 kullandım.
        added_xp = 50 if score >= 60 else 10

        return {
            "status": "success",
            "analysis": analysis_data,
            "added_xp": added_xp,
        }

    except Exception as e:
        print("Dinleme Analizi Hatası:", str(e))

        raise HTTPException(
            status_code=500,
            detail="Listening analysis could not be completed.",
        )




from sqlalchemy.sql.expression import func # 🌟 Eğer sayfanın en üstünde yoksa bu kütüphaneyi eklemeyi unutma!

@router.get("/fetch_minimal_pairs/{lesson_id}")
async def fetch_minimal_pairs(
    lesson_id: int,
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

    print(
        "⚖️ MINIMAL PAIRS REQUEST:",
        {
            "lesson_id": lesson_id,
            "target_language": target_language,
            "native_language": native_language,
            "normalized_native_language": normalized_native_language,
        },
    )

    # İlgili ders ve hedef dil için rastgele kelime çiftlerini getir.
    pairs = (
        db.query(models.MinimalPair)
        .filter(
            models.MinimalPair.lesson_id == lesson_id,
            models.MinimalPair.target_language == target_language,
        )
        .order_by(func.random())
        .limit(7)
        .all()
    )

    if not pairs:
        return []

    translations_by_pair_id = {}

    # Türkçe dışındaki ana diller için ayrı çeviri tablosuna bak.
    if normalized_native_language != "Turkish":
        selected_pair_ids = [pair.id for pair in pairs]

        translation_records = (
            db.query(models.MinimalPairTranslation)
            .filter(
                models.MinimalPairTranslation.minimal_pair_id.in_(
                    selected_pair_ids
                ),
                models.MinimalPairTranslation.native_language
                == normalized_native_language,
            )
            .all()
        )

        translations_by_pair_id = {
            record.minimal_pair_id: record
            for record in translation_records
        }

    response_data = []

    for pair in pairs:
        # Varsayılan olarak ana tablodaki Türkçe çevirileri kullan.
        localized_translation_1 = pair.translation_1 or ""
        localized_translation_2 = pair.translation_2 or ""

        translation_record = translations_by_pair_id.get(pair.id)

        # İstenen dilde kayıt varsa onu kullan.
        if translation_record is not None:
            localized_translation_1 = (
                translation_record.translation_1
                or pair.translation_1
                or ""
            )

            localized_translation_2 = (
                translation_record.translation_2
                or pair.translation_2
                or ""
            )

        response_data.append(
            {
                "id": pair.id,
                "word_1": pair.word_1,
                "ipa_1": pair.ipa_1 or "",
                "translation_1": localized_translation_1,
                "word_2": pair.word_2,
                "ipa_2": pair.ipa_2 or "",
                "translation_2": localized_translation_2,
            }
        )

    return response_data


@router.post("/get_pronunciation_feedback")
async def get_pronunciation_feedback(
    request: PronunciationCorrectionRequest, 
    db: Session = Depends(get_db)
):
    target = request.target_word.strip().lower()
    spoken = request.spoken_word.strip().lower()
    
    # =================================================================
    # 🌟 SÜPER GENİŞLETİLMİŞ YAZILIMSAL TOLERANS SÖZLÜĞÜ (MVP KATİLİ) 🌟
    # =================================================================
    stt_corrections = {
        "a": ["i", "ah", "uh", "hey", "eight", "ay", "ei", "an", "e", "a."],
        "the": ["da", "de", "di", "zee", "v", "they"],
        "an": ["and", "in", "un", "on", "a"],
        "it": ["eat", "at"],
        "is": ["ease", "yes", "his"],
        "yell": ["yeah", "yellow", "yal", "yale", "jail", "gel", "young", "you", "yo", "ill", "el", "yel", "yes"],
        "buy": ["by", "bye", "boy", "my", "why", "ba", "bay", "pie", "guy"],
        "hi": ["he", "high", "hay", "i", "bye"],
        "he": ["hi", "see", "the", "who", "hay"],
        "bye": ["buy", "by", "my", "pie", "bay"],
        "yes": ["yell", "less", "guess", "is"],
        "no": ["know", "now", "not", "oh", "knows"],
        "know": ["no", "now", "new", "known"],
        "please": ["place", "plays", "police", "pleas"],
        "place": ["please", "plays", "pace", "plate"],
        "thank": ["tank", "think", "sank", "thanks"],
        "tank": ["thank", "think", "bank"],
        "sorry": ["story", "sari", "starry"],
        "story": ["sorry", "store"],
        "good": ["food", "wood", "could", "hood", "god"],
        "food": ["good", "foot", "fluid"],
        "meet": ["meat", "met", "mit", "it"],
        "meat": ["meet", "met", "mit"],
        "met": ["meet", "meat", "mat"],
        "night": ["knight", "not", "light", "right", "nine"],
        "knight": ["night", "not"],
        "how": ["hoe", "who", "now", "ha"],
        "hoe": ["how", "who"],
        "live": ["leave", "life", "love", "liv"],
        "leave": ["live", "leaf", "let"],
        "age": ["edge", "h", "each", "itch"],
        "edge": ["age", "egg", "each"],
        "name": ["same", "main", "nim", "game"],
        "same": ["name", "some", "shame"],
        "year": ["ear", "here", "hear", "your"],
        "ear": ["year", "air", "are"],
        "old": ["cold", "hold", "gold", "all"],
        "cold": ["old", "gold", "hold"],
        "like": ["lake", "lock", "luck", "light"],
        "lake": ["like", "look", "late"],
        "job": ["jog", "chop", "top", "hop"],
        "jog": ["job", "dog", "jug"],
        "speak": ["peak", "week", "speech", "big"],
        "peak": ["speak", "beak", "pick"],
        "learn": ["turn", "earn", "line", "burnt"],
        "turn": ["learn", "tern", "time"],
        "one": ["won", "on", "van", "when", "want","run"],
        "won": ["one", "on", "win","gone","ron"],
        "two": ["too", "to", "do", "through", "who"],
        "too": ["two", "to", "do"],
        "four": ["for", "fore", "or", "door", "far"],
        "for": ["four", "fore", "or","far"],
        "three": ["tree", "free", "the", "try", "they"],
        "tree": ["three", "free", "try"],
        "five": ["fine", "fire", "live", "find","hi"],
        "fine": ["five", "find", "line"],
        "six": ["sick", "seek", "sex", "sicks", "since"],
        "sick": ["six", "seek", "thick"],
        "eight": ["ate", "it", "hate", "a", "hey"],
        "ate": ["eight", "eat", "at"],
        "nine": ["line", "mine", "night", "fine", "none"],
        "line": ["nine", "mine", "lane"],
        "ten": ["pen", "pan", "then", "tan", "time","on"],
        "pen": ["ten", "pan", "pin","10"],
        "thirteen": ["thirty", "13", "third in"],
        "thirty": ["thirteen", "dirty","turkey","30"],
        "fourteen": ["forty", "14", "four in"],
        "forty": ["fourteen", "party","kırk","40"],
        "fifteen": ["fifty", "15", "fifth in"],
        "fifty": ["fifteen", "nifty","50","elli"],
        "sixteen": ["sixty", "16", "six in"],
        "sixty": ["sixteen"],
        # 🌟 İSPANYOLCA A1 - LESSON 9
        "hola": ["ola", "holy", "holla", "hold", "hora", "cola"],
        "adiós": ["adios", "radios", "audio", "addios"],
        "buenos días": ["buenos dias", "buenas dias", "when is", "bonus dias", "buenos"],
        "buenas tardes": ["bonus tardes", "when is tardes", "buenas", "buenas tarde"],
        "buenas noches": ["bonus notice", "bonus noches", "buenas noche", "buenas"],
        "por favor": ["favor", "labor", "four favor", "poor favor", "por"],
        "gracias": ["grass", "grassy", "garcia", "gracia", "grosses"],
        "perdón": ["pardon", "perdon", "burden", "person", "gordon"],
        "mucho gusto": ["mucho", "gousto", "much gusto", "musho gusto"],
        "sí": ["see", "sea", "si", "she", "say", "c"],
        "lo siento": ["siento", "science", "silent", "silo", "lo siento"],
        "chao": ["chow", "ciao", "wow", "cow", "show", "cho"],
        "¿cómo estás?": ["como estas", "como esta", "coma estas"],
        "estoy bien": ["estoy", "stay bien", "being", "been", "a stay"],
        "ola": ["hola", "ola", "cola", "hora"],
        "nos": ["no", "not", "knows", "nous","NAS","nas"],
        "quien": ["bien", "queen", "keen", "when", "kien","gene"],
        "nuevas": ["buenas", "nueve", "nuevos", "nueva"],
        "dios": ["adiós", "adios", "dias", "ios"],
        "vor": ["por", "four", "more", "bore"],
        "labor": ["favor", "por favor", "labrador", "layer","la voz"],
        "macho": ["mucho", "matcho", "march", "much","nacho"],
        "bien": ["bean", "been", "bin", "ban", "when", "queen", "keen", "vien", "b"],
        "gracia": ["gracias", "garcia", "grass", "grassy","francia"],
        "nuevas": ["buenas", "nueve", "nueva", "nuevos"],
        "por": ["favor", "four", "bore", "more", "door"],
        "si": ["sí", "see", "sea", "she", "say"],
    }

    # =================================================================
    # 🌟 YENİ: SÜPER AKILLI EŞLEŞTİRME (SMART MATCHING) 🌟
    # =================================================================
    is_smart_match = False
    
    # Metni kelimelere bölüyoruz
    spoken_words = spoken.split()

    # 1. İhtimal: Hedef kelime cümlenin içinde ayrı bir kelime olarak geçiyor mu?
    if target in spoken_words:
        is_smart_match = True
        
    # 2. İhtimal: Tolerans sözlüğündeki kelimelerden biri geçiyor mu? 
    elif target in stt_corrections:
        for correction_word in stt_corrections[target]:
            if correction_word in spoken_words:
                is_smart_match = True
                print(f"🔧 [STT HİLESİ] Mikrofon '{spoken}' duydu, içinde '{correction_word}' yakalandı!")
                break

    # Eğer akıllı eşleşme başarılıysa, metni arka planda zorla "doğru" yapıyoruz
    if is_smart_match:
        spoken = target 

    # =================================================================
    # 🌟 2. BİREBİR EŞLEŞME (YAPAY ZEKAYI BYPASS ET) 🌟
    # =================================================================
    if target == spoken:
        return {"status": "success","is_correct": True, "feedback": "Mükemmel telaffuz! 🎯"}

    # =================================================================
    # 3. CACHE KONTROLÜ
    # =================================================================
    cache_input_key = f"{target}_{spoken}_{request.native_language.lower()}"
    
    cached_result = db.query(models.AICache).filter(
        models.AICache.feature_type == "pronunciation_words",
        models.AICache.input_text == cache_input_key
    ).first()
    
    if cached_result:
        print(f"⚡ [CACHE HIT] '{cache_input_key}' anahtarı için veri veritabanından çekildi.")
        return {
            "status": "success", 
            "is_correct": False,
            "feedback": cached_result.ai_response 
        }

    # =================================================================
    # 4. CACHE'DE YOKSA GEMINI'YE SOR
    # =================================================================
    try:
        print(f"🤖 [API CALL] '{cache_input_key}' için Gemini çağrılıyor...")

        prompt = f"""
        Sen uzman bir {request.target_language} telaffuz öğretmenisin.
        Öğrencinin ana dili: {request.native_language}.
        
        Öğrenci "{request.target_word}" kelimesini söylemeye çalıştı, 
        ancak mikrofon onu "{request.spoken_word}" olarak anladı.
        
        Görevlerin:
        1. Öğrenciye '{request.native_language}' dilinde, samimi ve motive edici bir şekilde hatasını açıkla.
        2. Bu iki kelime arasındaki ses/fonetik farkını basitçe anlat ve nasıl düzeltmesi gerektiğini 1-2 cümleyle söyle.
        3. Asla gereksiz uzatma, doğrudan hedefe (sese) odaklan.

        ÇIKTI FORMATI:
        Sadece aşağıdaki JSON formatında çıktı ver:
        {{
            "feedback": "Seni '{request.spoken_word}' olarak duydum. '{request.target_word}' derken i harfini daha kısa ve kesik çıkarmaya dikkat et!"
        }}
        """
        
        response = client.models.generate_content(
            model='gemini-2.5-flash-lite',
            contents=prompt,
            config=types.GenerateContentConfig(
                response_mime_type="application/json",
            ),
        )
        
        analysis_data = json.loads(response.text)
        final_feedback = analysis_data.get("feedback", "Harika deneme, bir kez daha üstünden geçelim!")

        # YENİ CEVABI CACHE'E KAYDET
        new_cache_entry = models.AICache(
            feature_type="pronunciation_words",
            input_text=cache_input_key,
            ai_response=final_feedback
        )
        db.add(new_cache_entry)
        db.commit()
        print(f"🤖 [LOG] Koçun analizi hafızaya eklendi! (Key: {cache_input_key})")
        return {"status": "success","is_correct": False, "feedback": final_feedback}

    except Exception as e:
        print("Telaffuz Analizi Hatası:", str(e))
        return {"status": "error","is_correct": False, "feedback": "Şu an sesini tam alamadım, tekrar dener misin?"}
    



    

@router.get("/api/get_single_minimal_pair/{puzzle_id}")
async def get_single_minimal_pair(
    puzzle_id: int,
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
        "⚖️ SINGLE MINIMAL PAIR REQUEST:",
        {
            "puzzle_id": puzzle_id,
            "native_language": native_language,
            "normalized_native_language": normalized_native_language,
        },
    )

    # İstenen minimal pair kaydını bul.
    pair = (
        db.query(models.MinimalPair)
        .filter(models.MinimalPair.id == puzzle_id)
        .first()
    )

    if not pair:
        return []

    # Varsayılan olarak ana tablodaki Türkçe çevirileri kullan.
    localized_translation_1 = pair.translation_1 or ""
    localized_translation_2 = pair.translation_2 or ""

    # Ana dil Türkçe değilse çeviri tablosunda kayıt ara.
    if normalized_native_language != "Turkish":
        translation_record = (
            db.query(models.MinimalPairTranslation)
            .filter(
                models.MinimalPairTranslation.minimal_pair_id == pair.id,
                models.MinimalPairTranslation.native_language
                == normalized_native_language,
            )
            .first()
        )

        if translation_record is not None:
            localized_translation_1 = (
                translation_record.translation_1
                or pair.translation_1
                or ""
            )

            localized_translation_2 = (
                translation_record.translation_2
                or pair.translation_2
                or ""
            )

    # Flutter tek elemanlı liste bekliyor.
    return [
        {
            "id": pair.id,
            "word_1": pair.word_1,
            "ipa_1": pair.ipa_1 or "",
            "translation_1": localized_translation_1,
            "word_2": pair.word_2,
            "ipa_2": pair.ipa_2 or "",
            "translation_2": localized_translation_2,
        }
    ]

