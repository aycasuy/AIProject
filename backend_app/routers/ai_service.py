from datetime import date
import hashlib
import json
import os
import re
import unicodedata
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
    


def normalize_language_name(language: str) -> str:
    """Dil adlarını veritabanında ve promptlarda kullanılan standart ada çevirir."""
    if not language:
        return "Turkish"

    normalized = language.strip().casefold()
    normalized = unicodedata.normalize("NFKD", normalized)
    normalized = "".join(
        character
        for character in normalized
        if not unicodedata.combining(character)
    )
    normalized = normalized.translate(
        str.maketrans(
            {
                "ı": "i",
                "ş": "s",
                "ğ": "g",
                "ü": "u",
                "ö": "o",
                "ç": "c",
            }
        )
    )

    language_map = {
        "tr": "Turkish",
        "turkish": "Turkish",
        "turkce": "Turkish",
        "en": "English",
        "english": "English",
        "ingilizce": "English",
        "es": "Spanish",
        "spanish": "Spanish",
        "espanol": "Spanish",
        "ispanyolca": "Spanish",
        "de": "German",
        "german": "German",
        "deutsch": "German",
        "almanca": "German",
        "fr": "French",
        "french": "French",
        "francais": "French",
        "fransizca": "French",
    }

    return language_map.get(normalized, language.strip())


def target_expression_is_used(
    user_text: str,
    target_expression: str,
) -> bool:
    """
    Bir hedef kelimenin başka bir kelimenin içinde geçmesini eşleşme saymaz.
    Örnek: "he", "the" kelimesinin içinde geçtiği için kabul edilmez.
    """
    if not user_text or not target_expression:
        return False

    pattern = (
        r"(?<!\w)"
        + re.escape(target_expression.strip().casefold())
        + r"(?!\w)"
    )

    return (
        re.search(
            pattern,
            user_text.casefold(),
            flags=re.UNICODE,
        )
        is not None
    )


def normalize_minor_writing_differences(text: str) -> str:
    """
    Büyük-küçük harf, noktalama ve fazla boşlukları yok sayarak
    içerik karşılaştırması için sade bir metin döndürür.
    """
    if not text:
        return ""

    normalized = text.casefold().strip()
    normalized = re.sub(
        r"[^\w\s]",
        "",
        normalized,
        flags=re.UNICODE,
    )
    normalized = re.sub(r"\s+", " ", normalized)

    return normalized.strip()


def is_only_minor_writing_difference(
    wrong_text: str,
    correct_text: str,
) -> bool:
    """
    İki ifade yalnızca büyük harf, virgül, nokta, kesme işareti veya
    benzeri küçük yazım farklılıkları taşıyorsa True döndürür.
    """
    return (
        normalize_minor_writing_differences(wrong_text)
        == normalize_minor_writing_differences(correct_text)
    )


def sanitize_roleplay_corrections(
    raw_corrections,
) -> list[dict[str, str]]:
    """
    Gemini'den gelen düzeltmeleri doğrular ve yalnızca noktalama/büyük harf
    farkı içeren gereksiz düzeltmeleri kaldırır.
    """
    validated_corrections: list[dict[str, str]] = []

    if not isinstance(raw_corrections, list):
        return validated_corrections

    for correction in raw_corrections:
        if not isinstance(correction, dict):
            continue

        wrong_text = str(
            correction.get("wrong", "")
        ).strip()

        correct_text = str(
            correction.get("correct", "")
        ).strip()

        explanation = str(
            correction.get("explanation", "")
        ).strip()

        if not wrong_text or not correct_text:
            continue

        if is_only_minor_writing_difference(
            wrong_text,
            correct_text,
        ):
            print(
                "🧹 ÖNEMSİZ DÜZELTME FİLTRELENDİ:",
                {
                    "wrong": wrong_text,
                    "correct": correct_text,
                },
            )
            continue

        validated_corrections.append(
            {
                "wrong": wrong_text,
                "correct": correct_text,
                "explanation": explanation,
            }
        )

    return validated_corrections


@router.post("/api/ai-teacher/correct")
async def correct_user_text(
    request: schemas.CorrectionRequest,
    db: Session = Depends(get_db),
):
    feedback_language = normalize_language_name(
        request.native_language
    )
    target_language = normalize_language_name(
        request.target_language
    )

    user_text = request.user_text.strip()
    user_text_lower = user_text.casefold()

    words_in_sentence = re.findall(
        r"\b[\w'-]+\b",
        user_text_lower,
        flags=re.UNICODE,
    )

    target_words_list = [
        word.strip()
        for word in request.target_words.split(",")
        if word.strip()
    ]

    used_words = [
        word
        for word in target_words_list
        if target_expression_is_used(
            user_text_lower,
            word,
        )
    ]

    messages = {
        "Turkish": {
            "missing_message":
                "Cümlen fena değil ama asıl amacımızı unuttuk! 😊",
            "missing_correct":
                "Hedef kelime eksik.",
            "missing_explanation":
                "Puan kazanmak için şu kelimelerden en az birini "
                "kullanmalısın: {words}",
            "missing_next":
                "Yukarıdaki kelimelerden birini kullanarak yeni bir "
                "cümle kurmayı dener misin?",
            "short_message":
                "Biraz daha çabalamanı istiyorum! 🚀",
            "short_correct":
                "Daha uzun bir cümle kurmalısın.",
            "short_explanation":
                "En az üç kelimeden oluşan tam bir cümle kurmaya çalış.",
            "short_next":
                "Bu ifadeyi tam bir cümle içinde nasıl kullanırsın?",
            "dump_message":
                "Kelimeleri fark ettim, ancak tam bir cümle kurmalısın. 😊",
            "dump_correct":
                "Lütfen anlamlı ve kurallı bir cümle kur.",
            "dump_explanation":
                "Hedef kelimeleri yalnızca arka arkaya sıralamak yerine "
                "doğal bir cümle içinde kullan.",
            "dump_next":
                "Bu kelimelerle gerçek bir cümle kurmayı tekrar dener misin?",
            "fallback_message":
                "Şu anda kısa bir teknik sorun yaşıyorum, ancak mesajını "
                "aldım. Harika gidiyorsun! 🚀",
            "fallback_next":
                "Roleplay senaryosuna uygun başka bir cümle kurabilir misin?",
        },
        "English": {
            "missing_message":
                "Your sentence is not bad, but we missed the main goal! 😊",
            "missing_correct":
                "A target word is missing.",
            "missing_explanation":
                "Use at least one of these words to earn progress: {words}",
            "missing_next":
                "Can you write a new sentence using one of the words above?",
            "short_message":
                "I would like you to make a little more effort! 🚀",
            "short_correct":
                "You need to write a longer sentence.",
            "short_explanation":
                "Try to write a complete sentence containing at least "
                "three words.",
            "short_next":
                "How would you use this expression in a complete sentence?",
            "dump_message":
                "I noticed the target words, but you need a complete "
                "sentence. 😊",
            "dump_correct":
                "Please write a meaningful, well-formed sentence.",
            "dump_explanation":
                "Do not list the target words one after another. Use them "
                "naturally in a sentence.",
            "dump_next":
                "Can you try again with a natural sentence?",
            "fallback_message":
                "I am having a brief technical issue, but I understood "
                "your message. You are doing great! 🚀",
            "fallback_next":
                "Can you write another sentence that fits the roleplay?",
        },
        "Spanish": {
            "missing_message":
                "Tu frase no está mal, pero olvidamos el objetivo "
                "principal. 😊",
            "missing_correct":
                "Falta una palabra objetivo.",
            "missing_explanation":
                "Usa al menos una de estas palabras para progresar: {words}",
            "missing_next":
                "¿Puedes escribir una frase nueva usando una de las "
                "palabras anteriores?",
            "short_message":
                "¡Quiero que te esfuerces un poco más! 🚀",
            "short_correct":
                "Debes escribir una frase más larga.",
            "short_explanation":
                "Intenta escribir una frase completa de al menos tres "
                "palabras.",
            "short_next":
                "¿Cómo usarías esta expresión en una frase completa?",
            "dump_message":
                "He visto las palabras objetivo, pero necesitas formar "
                "una frase completa. 😊",
            "dump_correct":
                "Escribe una frase correcta y con sentido.",
            "dump_explanation":
                "No enumeres las palabras objetivo. Úsalas de manera "
                "natural dentro de una frase.",
            "dump_next":
                "¿Puedes intentarlo otra vez con una frase natural?",
            "fallback_message":
                "Tengo un pequeño problema técnico, pero he entendido tu "
                "mensaje. ¡Vas muy bien! 🚀",
            "fallback_next":
                "¿Puedes escribir otra frase adecuada para este roleplay?",
        },
        "German": {
            "missing_message":
                "Dein Satz ist nicht schlecht, aber das Hauptziel fehlt. 😊",
            "missing_correct":
                "Ein Zielwort fehlt.",
            "missing_explanation":
                "Verwende mindestens eines dieser Wörter: {words}",
            "missing_next":
                "Kannst du mit einem dieser Wörter einen neuen Satz bilden?",
            "short_message":
                "Versuche bitte, einen etwas längeren Satz zu schreiben. 🚀",
            "short_correct":
                "Du solltest einen längeren Satz bilden.",
            "short_explanation":
                "Schreibe einen vollständigen Satz mit mindestens drei "
                "Wörtern.",
            "short_next":
                "Wie würdest du diesen Ausdruck in einem vollständigen "
                "Satz verwenden?",
            "dump_message":
                "Ich sehe die Zielwörter, aber du brauchst einen "
                "vollständigen Satz. 😊",
            "dump_correct":
                "Bitte bilde einen sinnvollen und korrekten Satz.",
            "dump_explanation":
                "Liste die Wörter nicht nur auf, sondern verwende sie "
                "natürlich in einem Satz.",
            "dump_next":
                "Kannst du es noch einmal mit einem natürlichen Satz "
                "versuchen?",
            "fallback_message":
                "Es gibt gerade ein kleines technisches Problem, aber ich "
                "habe deine Nachricht verstanden. 🚀",
            "fallback_next":
                "Kannst du einen weiteren passenden Satz schreiben?",
        },
        "French": {
            "missing_message":
                "Ta phrase n'est pas mauvaise, mais l'objectif principal "
                "a été oublié. 😊",
            "missing_correct":
                "Un mot cible manque.",
            "missing_explanation":
                "Utilise au moins un de ces mots : {words}",
            "missing_next":
                "Peux-tu écrire une nouvelle phrase avec l'un de ces mots ?",
            "short_message":
                "J'aimerais que tu fasses un petit effort supplémentaire. 🚀",
            "short_correct":
                "Tu dois écrire une phrase plus longue.",
            "short_explanation":
                "Essaie d'écrire une phrase complète d'au moins trois mots.",
            "short_next":
                "Comment utiliserais-tu cette expression dans une phrase "
                "complète ?",
            "dump_message":
                "J'ai vu les mots cibles, mais il faut former une phrase "
                "complète. 😊",
            "dump_correct":
                "Écris une phrase correcte et naturelle.",
            "dump_explanation":
                "Ne fais pas seulement une liste. Utilise les mots "
                "naturellement dans une phrase.",
            "dump_next":
                "Peux-tu réessayer avec une phrase naturelle ?",
            "fallback_message":
                "Je rencontre un petit problème technique, mais j'ai "
                "compris ton message. Tu progresses très bien ! 🚀",
            "fallback_next":
                "Peux-tu écrire une autre phrase adaptée au jeu de rôle ?",
        },
    }

    target_texts = messages.get(
        target_language,
        messages["English"],
    )
    feedback_texts = messages.get(
        feedback_language,
        messages["English"],
    )

    print(
        "🎭 ROLEPLAY REQUEST:",
        {
            "target_language": target_language,
            "native_language": request.native_language,
            "feedback_language": feedback_language,
            "topic": request.topic,
        },
    )

    # KURAL 1: Hedef kelimelerden hiçbiri kullanılmamış.
    if target_words_list and not used_words:
        return {
            "ai_message": target_texts["missing_message"],
            "corrections": [
                {
                    "wrong": user_text,
                    "correct": target_texts["missing_correct"],
                    "explanation": feedback_texts[
                        "missing_explanation"
                    ].format(
                        words=", ".join(target_words_list)
                    ),
                }
            ],
            "next_step": target_texts["missing_next"],
        }

    # KURAL 2: Cümle çok kısa.
    if len(words_in_sentence) < 3:
        return {
            "ai_message": target_texts["short_message"],
            "corrections": [
                {
                    "wrong": user_text,
                    "correct": target_texts["short_correct"],
                    "explanation": feedback_texts[
                        "short_explanation"
                    ],
                }
            ],
            "next_step": target_texts["short_next"],
        }

    # KURAL 3: Hedef kelimeleri yalnızca sıralama.
    if (
        target_words_list
        and len(used_words) >= 2
        and len(words_in_sentence) <= len(used_words) + 2
    ):
        return {
            "ai_message": target_texts["dump_message"],
            "corrections": [
                {
                    "wrong": user_text,
                    "correct": target_texts["dump_correct"],
                    "explanation": feedback_texts[
                        "dump_explanation"
                    ],
                }
            ],
            "next_step": target_texts["dump_next"],
        }

    history_str = json.dumps(
        request.history,
        ensure_ascii=False,
        sort_keys=True,
    ).casefold()

    # v4 ile eski, gereksiz noktalama düzeltmesi içeren cache kayıtları kullanılmaz.
    search_text = (
        "v5 | "
        f"target_language:{target_language.casefold()} | "
        f"native_language:{feedback_language.casefold()} | "
        f"level:{request.level.strip().casefold()} | "
        f"topic:{request.topic.strip().casefold()} | "
        f"target_words:{request.target_words.strip().casefold()} | "
        f"history:{history_str} | "
        f"text:{user_text_lower}"
    )

    cached_data = (
        db.query(models.AICache)
        .filter(
            models.AICache.feature_type
            == "writing_correction_v5",
            models.AICache.input_text == search_text,
        )
        .first()
    )

    if cached_data:
        print(
            "🟢 ROLEPLAY CACHE HIT:",
            request.user_text,
        )

        try:
            cached_json = json.loads(
                cached_data.ai_response
            )
            cached_json["corrections"] = (
                sanitize_roleplay_corrections(
                    cached_json.get(
                        "corrections",
                        [],
                    )
                )
            )
            return cached_json
        except (TypeError, ValueError, json.JSONDecodeError) as error:
            print(
                "⚠️ ROLEPLAY CACHE OKUNAMADI:",
                str(error),
            )

    print(
        "🟡 ROLEPLAY CACHE MISS: Gemini çağrılıyor.",
        request.user_text,
    )

    conversation_context = ""

    for message in request.history:
        role = (
            "Student"
            if message.get("role") == "user"
            else "AI character"
        )

        conversation_context += (
            f"{role}: {message.get('content', '')}\n"
        )

    system_instruction = f"""
You are acting in a roleplay scenario to teach
{target_language}.

Student proficiency level:
{request.level}

ROLEPLAY PERSONA AND SCENARIO:
{request.topic}

Student's native language:
{feedback_language}

Follow all rules strictly:

1. Stay in character throughout the conversation.

2. The "ai_message" field:
   - Write only the character's natural reaction or statement.
   - Write it entirely in {target_language}.
   - Do not include grammatical explanations.
   - Do not ask a question in this field.

3. The "corrections" field:
   - Correct only major grammar or vocabulary errors.
   - Ignore minor capitalization and punctuation issues.
   - NEVER create a correction if the only differences are capitalization,
     commas, apostrophes, spacing, or final punctuation.
   - A grammatically and semantically correct sentence MUST return an empty
     "corrections" array, even if its writing style could be improved.
   - Do not rewrite a correct sentence merely to make it more natural or formal.
   - Each correction must be a JSON object.
   - "wrong" must contain the student's incorrect
     {target_language} expression.
   - "correct" must contain the corrected
     {target_language} expression.
   - "explanation" must be written entirely in
     {feedback_language}.
   - Never mix languages in the explanation.

4. The "next_step" field:
   - Ask one natural follow-up question.
   - Write the question entirely in {target_language}.
   - Never repeat a previous question.
   - If the conversation is naturally ending, return an
     empty string.

5. Return only valid JSON in this exact structure:

{{
  "ai_message": "Natural response in {target_language}.",
  "corrections": [
    {{
      "wrong": "Incorrect target-language expression",
      "correct": "Correct target-language expression",
      "explanation": "Explanation in {feedback_language}"
    }}
  ],
  "next_step": "Question in {target_language}, or empty string"
}}

6. CONVERSATION MEMORY:
   - Treat the previous conversation as authoritative memory.
   - Remember facts already provided by the student, including their name,
     preferences, order, answer, and previous choices.
   - Never ask for information that the student has already provided.
   - Never repeat a question that already appears in the conversation history.
   - If the student's name is already known, do not ask for it again.

7. FORGIVING CORRECTION POLICY:
   - Accept grammatically understandable compound messages.
   - Do not remove a correct clause merely because the student also asks
     another valid question in the same message.
   - For example, "my name is Ayca what is your name" is understandable and
     must not be treated as a major grammar error.
   - Missing capitalization, commas, and final punctuation are not errors.

"""

    prompt = f"""
Previous conversation:
{conversation_context}

Student's new message:
{request.user_text}
"""

    try:
        response = client.models.generate_content(
            model="gemini-2.5-flash-lite",
            contents=prompt,
            config=gemini_types.GenerateContentConfig(
                system_instruction=system_instruction,
                response_mime_type="application/json",
                temperature=0.2,
            ),
        )

        raw_response = response.text or "{}"
        json_data = json.loads(raw_response)

        ai_message = str(
            json_data.get("ai_message", "")
        ).strip()

        next_step = str(
            json_data.get("next_step", "")
        ).strip()

        validated_corrections = sanitize_roleplay_corrections(
            json_data.get(
                "corrections",
                [],
            )
        )

        result_json = {
            "ai_message": ai_message,
            "corrections": validated_corrections,
            "next_step": next_step,
        }

        new_cache = models.AICache(
            feature_type="writing_correction_v5",
            input_text=search_text,
            ai_response=json.dumps(
                result_json,
                ensure_ascii=False,
            ),
        )

        db.add(new_cache)
        db.commit()

        print(
            "💾 ROLEPLAY CACHE SAVED:",
            request.user_text,
        )

        return result_json

    except Exception as error:
        db.rollback()

        print(
            "🚨 ROLEPLAY AI HATASI:",
            str(error),
        )

        return {
            "ai_message": target_texts["fallback_message"],
            "corrections": [],
            "next_step": target_texts["fallback_next"],
        }

    

@router.get("/api/lessons")
def get_lessons(
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

    requested_language = native_language.strip().lower()

    normalized_native_language = native_language_map.get(
        requested_language,
        native_language.strip(),
    )

    lessons = (
        db.query(models.Lesson)
        .order_by(models.Lesson.order)
        .all()
    )

    # İstenen dildeki bütün çevirileri tek sorguda alıyoruz.
    translations = (
        db.query(models.LessonTranslation)
        .filter(
            models.LessonTranslation.native_language
            == normalized_native_language
        )
        .all()
    )

    translations_by_lesson_id = {
        translation.lesson_id: translation
        for translation in translations
    }

    response_data = []

    for lesson in lessons:
        translation_record = translations_by_lesson_id.get(
            lesson.id
        )

        # Çeviri bulunamazsa lessons tablosundaki mevcut değerler kullanılır.
        localized_title = lesson.title
        localized_topic = lesson.topic

        if translation_record is not None:
            localized_title = (
                translation_record.title or lesson.title
            )
            localized_topic = (
                translation_record.topic or lesson.topic
            )

        response_data.append(
            {
                "id": lesson.id,
                "order": lesson.order,
                "title": localized_title,
                "topic": localized_topic,
                "min_level": lesson.min_level,
                "xp_reward": lesson.xp_reward,
                "target_words": lesson.target_words or "",
                "target_language": lesson.target_language,
            }
        )

    print(
        "📚 LESSON REQUEST:",
        {
            "native_language": native_language,
            "normalized_native_language":
                normalized_native_language,
            "lesson_count": len(response_data),
        },
    )

    return response_data



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
        formatted_history = "\n".join([f"{m['role']}: {m['content']}" for m in request.history])
        
        prompt = f"""
        Öğrenci '{request.topic}' konusunda '{request.target_language}' dilinde roleplay yapıyor.
        Bu senaryoda yapay zeka öğretmen rolündedir ve konuşmayı başlatan taraftır.
        Öğrenci (user) yapay zekanın mesajlarına cevap vermektedir.
        Öğrenci şu an tıkandı ve ne yazacağını bilemiyor.
        
        Aşağıdaki sohbet geçmişine bakarak, öğrencinin şu an yapay zekanın son mesajına verebileceği kısa, doğal ve konuya uygun tek bir cümle öner.
        SADECE önerdiğin cümleyi '{request.target_language}' dilinde yaz. Açıklama veya çeviri ekleme.
        Cümle öğrenci perspektifinden olmalı, yapay zeka perspektifinden değil.
        
        Geçmiş:
        {formatted_history}
        """
        response = client.models.generate_content(
            model='gemini-2.5-flash-lite',
            contents=prompt,
        )
        return {"hint": response.text.strip()}
    except Exception as e:
        return {"hint": "I think we should..."}

# 🌟 2. ÇEVİRİ API'Sİ
@router.post("/translate_text")
def translate_text(request: TranslateRequest, db: Session = Depends(get_db)):
    
    try:
        prompt = f"Şu metni profesyonelce {request.native_language} diline çevir. Sadece çeviriyi ver:\n\n{request.text}"
        response = client.models.generate_content(
            model='gemini-2.5-flash-lite',
            contents=prompt,
        )
        return {"translation": response.text.strip()}
    except Exception as e:
        return {"translation": "Çeviri şu an yapılamıyor."}