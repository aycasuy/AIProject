from pydantic import BaseModel, Field
from typing import Dict, List, Optional


# -----------------------------------------
# KULLANICI YÖNETİMİ
# -----------------------------------------
class UserRegister(BaseModel):
    username: str
    email: str
    password: str = Field(..., min_length=8, max_length=50)

# Giriş Yaparken Gelecek Veriler
class UserLogin(BaseModel):
    username: str
    password: str = Field(..., min_length=8, max_length=50)


class ScoreUpdate(BaseModel):
    username: str
    new_level: str
    added_xp: int

class ChatRequest(BaseModel):
    user_input: str
    target_language: str
    native_language: str = "Turkish"

class QuizRequest(BaseModel):
    topic: str
    difficulty: str
    question_count: int


class ProgressUpdateRequest(BaseModel):
    username: str    
    new_level: str = None
    added_xp: int
    current_section: int  # Haritadaki Ders numarası (Örn: 1)
    current_lesson: int   # Haritadaki Adım numarası (Örn: 2)
    target_language: str = "English"

class LanguageUpdateRequest(BaseModel):
    username: str
    native_language: str
    target_language: str

class TextAnalyzeRequest(BaseModel):
    text: str
    target_language: str   # Örn: "Spanish" veya "English"
    native_language: str   # Örn: "Turkish" (İleride Almanlar da uygulamayı kullanabilsin diye)


class AddVocabularyRequest(BaseModel):
    username: str
    word: str
    translation: str
    cefr_level: str
    target_language: str = "English"

class AddXPRequest(BaseModel):
    username: str
    xp_amount: int
    target_language: str 
    # 🌟 YENİ: XP'nin hangi dersten geldiğini kontrol etmek için
    section: int 
    lesson: int

class PronunciationRequest(BaseModel):
    username: str
    target_language: str
    original_text: str
    spoken_text: str
    native_language: str = "Turkish"

class GeneratePronunciationRequest(BaseModel):
    target_language: str
    level: str
    target_words: str
    lesson_id: Optional[int] = None  # 🌟 YENİ: Artık Flutter bize ders numarasını da atabilecek
    round: Optional[int] = 1
    exclude_texts: Optional[List[str]] = []

class DictationRequest(BaseModel):
    username: str
    target_language: str
    original_text: str
    user_text: str
    native_language: str = "Turkish"


# Günlük Roleplay Kilidi İçin
class RoleplayDoneRequest(BaseModel):
    username: str
    target_language: str

# Geçmiş mesajları tutacak ufak kalıp
class RoleplayMessage(BaseModel):
    role: str  # "user" veya "model" (yapay zeka) olacak
    text: str


class RoleplayRequest(BaseModel):
    username: str
    target_language: str
    user_level: str
    scenario: str            # Örn: "Café & Restoran"
    chat_history: List[RoleplayMessage] # Geçmiş sohbetin listesi (Hafıza)
    user_message: str        # Kullanıcının az önce mikrofona söylediği son cümle


class CorrectionRequest(BaseModel):
    topic: str
    user_text: str
    level: str = "A1"
    target_words: str # 🌟 Hangi kelimelerden sapmayacak?
    history: List[Dict[str, str]] = [] # 🌟 Sohbet geçmişi
    target_language: str


class DecreaseLifeRequest(BaseModel):
    username: str
    target_language: str 

# -----------------------------------------
# CÜMLE SIRALAMA (DRAG & DROP) MODÜLÜ
# -----------------------------------------

# Flutter'dan Python'a Gelecek Paket
class SentenceCheckRequest(BaseModel):
    username: str
    target_language: str
    original_sentence: str       # Örn: "Ben eve gidiyorum"
    correct_sentence: str        # Örn: "I am going home"
    submitted_words: List[str]   # Örn: ["I", "going", "am", "home"] (Kullanıcının dizilimi)
    native_language: str = "Turkish"

# Python'un Flutter'a Döneceği "AI Geri Bildirim" Alt Paketi
class AIFeedbackData(BaseModel):
    score: str                   # Örn: "80/100"
    word_breakdown: Dict[str, str] # Örn: {"am": "yardımcı fiil özneye göre değişir"}
    ai_tip: str                  # Örn: "💡 'to be' fiilinin kullanımına dikkat et."

# Python'dan Flutter'a Gidecek Ana Kargo
class SentenceCheckResponse(BaseModel):
    is_correct: bool             # Tamamen doğru mu? (True/False)
    xp_earned: int               # Kazanılan XP
    ai_feedback: AIFeedbackData  # Yukarıdaki detaylı geri bildirim


# -----------------------------------------
# CÜMLE SIRALAMA - SORU GETİRME ŞEMALARI
# -----------------------------------------

# Flutter'dan Python'a: "Bana şu dilde ve seviyede soru ver"
class SentenceFetchRequest(BaseModel):
    target_language: str
    level: str = "A1"  # Örn: "A1", "A2"
    topic: str = "General" 
    # İleride "Cafe", "Seyahat" gibi konulara göre filtrelemek için
    lesson_id: Optional[int] = None
    native_language: str = "Turkish"

# Python'dan Flutter'a: Veritabanından çekilip gönderilen soru paketi
class SentenceFetchResponse(BaseModel):
    id: int                      # Veritabanındaki satır ID'si
    original_sentence: str       # Örn: "Ben eve gidiyorum."
    correct_sentence: str        # Örn: "I am going home."
    scrambled_words: List[str]   # Örn: ["home", "I", "am", "going", "to"] (Kelimeler Python'da karıştırılıp yollanır)


#bilinmeyen cümleleri tutar
class AddMistakeRequest(BaseModel):
    username: str
    puzzle_id: int
    puzzle_type: str
    target_language: str # 🌟 EKLENDİ

# Boşluk doldurma sorularını isterken Flutter'dan gelen bilgiler (20.06.2026)
class BlankPuzzleFetchRequest(BaseModel):
    target_language: str
    lesson_id: int
    native_language: str = "Turkish"




# 🌟 YENİ EKLENEN: Boşluk Doldurma Yanıt Şablonu
class BlankFetchResponse(BaseModel):
    id: int
    before_text: str
    after_text: str
    correct_answer: str
    translation: str


# -----------------------------------------
# HIZLI OKUMA VE BOSS SAVAŞI ŞEMALARI
# -----------------------------------------

class QuizResult(BaseModel):
    username: str
    correct_count: int
    total_questions: int
    learned_words: List[str] # Öğrenilen kelimelerin metin halleri (Örn: ["courage", "hesitate"])
    target_language : str
    lesson_id: int

# SEVİYE BELİRLEME TESTİ ŞEMASI
class PlacementResult(BaseModel):
    username: str
    level: str
    target_language: str #

class TestRequest(BaseModel):
    lesson_id: int
    level: str
    target_language: str
    native_language: str = "Turkish"

class PronunciationCorrectionRequest(BaseModel):
    target_word: str      # Örn: Ship
    spoken_word: str      # Örn: Sheep
    native_language: str  # Örn: Turkish
    target_language: str  # Örn: English

class PuzzleAnswerRequest(BaseModel):
    username: str
    puzzle_id: int
    puzzle_type: str # 'flashcard', 'blank_puzzle', 'minimal_pair' vb.
    tested_word: str # Test edilen kelime (Örn: "usually")
    is_correct: bool # Kullanıcı doğru mu bildi, yanlış mı?
    


class MarkLearnedRequest(BaseModel):
    username: str
    word_id: int


# Gelen kargoyu karşılayacak şablon
class ResolveMistakeRequest(BaseModel):
    username: str
    puzzle_id: int
    puzzle_type: str


class UpdatePreferencesRequest(BaseModel):
    username: str
    target_language: str
    notifications_enabled: bool = True # Bildirim ayarı
    

class UpgradeLevelRequest(BaseModel):
    username: str
    target_language: str
    new_level: str
    


class HintRequest(BaseModel):
    topic: str
    target_language: str
    history: list
    native_language: str = "Turkish"

class TranslateRequest(BaseModel):
    text: str
    native_language: str = "Turkish"



class BuyLivesRequest(BaseModel):
    username: str
    target_language: str

class Config:
        from_attributes = True