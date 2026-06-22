import datetime

from sqlalchemy import Boolean, Column, DateTime, Integer, String, ForeignKey, Text, UniqueConstraint, func
from sqlalchemy.orm import relationship
from database import Base
from sqlalchemy import Date

# 1. Kullanıcılar Tablosu (Öğrenci Profili)
class UserDB(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, index=True)
    email = Column(String, unique=True, index=True)
    hashed_password = Column(String)
    native_language=Column(String , default="Turkish")

    # 🌟 YENİ: Kullanıcının günlük loglarına erişmek için bağlantı
    daily_xps = relationship("DailyXPLog", back_populates="user")
    progresses = relationship("UserProgressDB", back_populates="owner", cascade="all, delete-orphan")
    vocabulary = relationship("VocabularyDB", back_populates="owner", cascade="all, delete-orphan")

class UserProgressDB(Base):
    __tablename__ = "user_progress"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))

    target_language=Column(String , default="English")
    level = Column(String, default="Belirlenmedi")
    xp_score = Column(Integer, default=0)

    # --- YENİ EKLENEN ZIGZAG HARİTA VE OYUNLAŞTIRMA SÜTUNLARI ---
    current_section = Column(Integer, default=1) # 1: AI, 2: Kelime, 3: Telaffuz, 4: Dinleme
    current_lesson = Column(Integer, default=1)  # 1'den 8'e kadar olan dersler
    streak_days = Column(Integer, default=0)     # Ateş (🔥) ikonu için seri gün sayısı
    level_completion_percentage = Column(Integer, default=0) # %70 barajını takip etmek için
    lives = Column(Integer, default=5)  # 🌟 Artık 5 can
    last_heart_lost = Column(DateTime, nullable=True) # İlk can kaybedildiğinde dolar
    last_active_date = Column(Date, nullable=True) # Kullanıcının ders bitirdiği son gün
    last_roleplay_date = Column(Date, nullable=True)
    
    owner = relationship("UserDB", back_populates="progresses")

    # 🌟 İŞTE MİMARİYİ KURTARAN O SATIR 🌟
    # Bu kural der ki: "Bir user_id ve target_language ikilisi sadece 1 kez var olabilir."
    __table_args__ = (
        UniqueConstraint('user_id', 'target_language', name='uix_user_language'),
    )

# 3. TABLO: Kullanıcının Bilmediği/Öğrenmek İstediği Kelimeler (Kelime Kumbarası)
class VocabularyDB(Base):
    __tablename__ = "user_vocabulary"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    
    word = Column(String, index=True)           # İngilizce kelime (Örn: "Diligently")
    translation = Column(String)                # Türkçe karşılığı (Örn: "Özenle")
    cefr_level = Column(String)                 # Kelimenin zorluk seviyesi (Örn: "C1")
    is_learned = Column(Boolean, default=False) # Öğrenildi mi? (Daha sonra kelime oyunlarında kullanırız!)
    # 🌟 MİMARİ KURTARICI: Bu kelime hangi dilde?
    target_language = Column(String, default="English", index=True)

    # İLİŞKİ: Bu kelime hangi kullanıcıya ait?
    owner = relationship("UserDB", back_populates="vocabulary")



class AICache(Base):
    __tablename__ = "ai_cache"

    id = Column(Integer, primary_key=True, index=True)
    # İstek nereden geldi? ('roleplay', 'flashcard', 'grammar_check' vb.)
    feature_type = Column(String, index=True) 
    # Kullanıcının sorduğu şey (Örn: "Apple ne demek?" veya "I want a coffee")
    input_text = Column(Text, index=True)     
    # Yapay Zekanın verdiği cevap
    ai_response = Column(Text)


class Lesson(Base):
    __tablename__ = "lessons"

    id = Column(Integer, primary_key=True, index=True)
    target_language = Column(String, default="English", index=True)
    order = Column(Integer, unique=True) # Dersin sırası (1, 2, 3...)
    title = Column(String, nullable=False) # "Selamlama"
    topic = Column(String, nullable=False) # "Greetings and meeting new people"
    min_level = Column(String, default="A1")
    target_words = Column(String, default="")
    xp_reward = Column(Integer, default=50) # Bu ders bitince kaç XP verecek?
    # 🌟 YENİ EKLENEN SATIR: Bu dersin içindeki bulmaca cümleleri
    # cascade="all, delete-orphan" -> Ders silinirse, o dersin soruları da otomatik silinir! (Çöp veri kalmaz)
    puzzles = relationship("SentencePuzzle", back_populates="lesson", cascade="all, delete-orphan")


#################################################################################

class LessonTranslation(Base):
    __tablename__ = "lesson_translations"

    id = Column(Integer, primary_key=True, index=True)

    lesson_id = Column(
        Integer,
        ForeignKey("lessons.id", ondelete="CASCADE"),
        nullable=False,
    )

    native_language = Column(
        String(30),
        nullable=False,
    )

    title = Column(
        Text,
        nullable=False,
    )

    topic = Column(
        Text,
        nullable=True,
    )

    created_at = Column(
        DateTime,
        server_default=func.now(),
    )

    __table_args__ = (
        UniqueConstraint(
            "lesson_id",
            "native_language",
            name="uq_lesson_translation",
        ),
    )

# -----------------------------------------
# OYUN MODÜLLERİ İÇİN SORU TABLOLARI
# -----------------------------------------

class SentencePuzzle(Base):
    __tablename__ = "sentence_puzzles"

    id = Column(Integer, primary_key=True, index=True)
    
    # 🌟 MİMARİNİN KALBİ: Bu cümle hangi derse ait? (Foreign Key)
    lesson_id = Column(Integer, ForeignKey("lessons.id", ondelete="CASCADE"))
    
    target_language = Column(String, default="English")
    original_sentence = Column(String, nullable=False)  # Örn: "Ben eve gidiyorum."
    correct_sentence = Column(String, nullable=False)   # Örn: "I am going home."

    # İLİŞKİ (Çift Yönlü Bağlantı)
    lesson = relationship("Lesson", back_populates="puzzles")



class SentencePuzzleTranslation(Base):
    __tablename__ = "sentence_puzzle_translations"

    id = Column(Integer, primary_key=True, index=True)

    puzzle_id = Column(
        Integer,
        ForeignKey("sentence_puzzles.id", ondelete="CASCADE"),
        nullable=False,
    )

    native_language = Column(
        String(30),
        nullable=False,
    )

    original_sentence = Column(
        Text,
        nullable=False,
    )

    created_at = Column(
        DateTime,
        server_default=func.now(),
    )

    __table_args__ = (
        UniqueConstraint(
            "puzzle_id",
            "native_language",
            name="uq_sentence_puzzle_translation",
        ),
    )




class Flashcard(Base):
    __tablename__ = "flashcards"

    id = Column(Integer, primary_key=True, index=True)
    lesson_id = Column(Integer, ForeignKey("lessons.id", ondelete="CASCADE"))
    word = Column(String, nullable=False)        # Örn: "Hello"
    translation = Column(String, nullable=False) # Örn: "Merhaba"
    image = Column(String, nullable=True)        # Örn: "👋" (Emoji)
    target_language = Column(String, default="English", nullable=False)

    lesson = relationship("Lesson")



class FlashcardTranslation(Base):
    __tablename__ = "flashcard_translations"

    id = Column(Integer, primary_key=True, index=True)

    flashcard_id = Column(
        Integer,
        ForeignKey("flashcards.id", ondelete="CASCADE"),
        nullable=False,
    )

    native_language = Column(
        String(30),
        nullable=False,
    )

    translation = Column(
        Text,
        nullable=False,
    )

    created_at = Column(
        DateTime,
        server_default=func.now(),
    )

    __table_args__ = (
        UniqueConstraint(
            "flashcard_id",
            "native_language",
            name="uq_flashcard_translation",
        ),
    )




#bilemedikleri cümleleri tutma tablosu
class MistakeDB(Base):
    __tablename__ = "mistakes"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    # 🌟 MİMARİ KURTARICI: Hatanın Dili
    target_language = Column(String, default="English", index=True)
    puzzle_id = Column(Integer) # Hangi cümleyi bilemediği
    mistake_count = Column(Integer, default=1) # Kaç kere yanlış yaptı
    puzzle_type = Column(String)


#boşluk doldurma database de tutulacak olan tablo
class BlankPuzzle(Base):
    __tablename__ = "blank_puzzles"
    id = Column(Integer, primary_key=True, index=True)
    lesson_id = Column(Integer, ForeignKey("lessons.id"))
    target_language = Column(String)
    before_text = Column(String)  # Örn: "I say "
    after_text = Column(String)   # Örn: " to my friends."
    correct_answer = Column(String) # Örn: "hello"
    translation = Column(String)   # Örn: "Arkadaşlarıma merhaba derim."

class PronunciationText(Base):
    __tablename__ = "pronunciation_texts"
    
    id = Column(Integer, primary_key=True, index=True)
    lesson_id = Column(Integer, index=True)
    level = Column(String(10), index=True)
    text = Column(Text)
    target_language = Column(String, default="English", index=True)


class MinimalPair(Base):
    __tablename__ = "minimal_pairs"

    id = Column(Integer, primary_key=True, index=True)
    lesson_id = Column(Integer, ForeignKey("lessons.id", ondelete="CASCADE"))
    
    # 1. Kelime (Kısa sesli - Örn: Ship)
    word_1 = Column(String, nullable=False)
    ipa_1 = Column(String) # Uluslararası Fonetik Alfabe okunuşu (Örn: /ʃɪp/)
    translation_1 = Column(String) # Örn: Gemi
    
    # 2. Kelime (Uzun sesli - Örn: Sheep)
    word_2 = Column(String, nullable=False)
    ipa_2 = Column(String) # Örn: /ʃiːp/
    translation_2 = Column(String) # Örn: Koyun
    
    target_language = Column(String, default="English")

    lesson = relationship("Lesson")



class MinimalPairTranslation(Base):
    __tablename__ = "minimal_pair_translations"

    id = Column(Integer, primary_key=True, index=True)

    minimal_pair_id = Column(
        Integer,
        ForeignKey("minimal_pairs.id", ondelete="CASCADE"),
        nullable=False,
    )

    native_language = Column(
        String(30),
        nullable=False,
    )

    translation_1 = Column(
        Text,
        nullable=True,
    )

    translation_2 = Column(
        Text,
        nullable=True,
    )

    created_at = Column(
        DateTime,
        server_default=func.now(),
    )

    __table_args__ = (
        UniqueConstraint(
            "minimal_pair_id",
            "native_language",
            name="uq_minimal_pair_translation",
        ),
    )
    

# --- 🌟 YENİ TABLOMUZ: GÜNLÜK XP LOGLARI ---
class DailyXPLog(Base):
    __tablename__ = "daily_xp_logs"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    date = Column(Date, default=datetime.date.today)
    xp_earned = Column(Integer, default=0)

    user = relationship("UserDB", back_populates="daily_xps")


############################################

class BlankPuzzleTranslation(Base):
    __tablename__ = "blank_puzzle_translations"

    id = Column(Integer, primary_key=True, index=True)

    puzzle_id = Column(
        Integer,
        ForeignKey("blank_puzzles.id", ondelete="CASCADE"),
        nullable=False,
    )

    native_language = Column(
        String(30),
        nullable=False,
    )

    translation = Column(
        Text,
        nullable=False,
    )

    created_at = Column(
        DateTime,
        server_default=func.now(),
    )

    __table_args__ = (
        UniqueConstraint(
            "puzzle_id",
            "native_language",
            name="uq_blank_puzzle_translation",
        ),
    )