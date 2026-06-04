from fastapi import FastAPI

import models
from database import SessionLocal, engine, Base

# Böldüğümüz Router'ları içeri alıyoruz
from routers import user , analyze , ai_service 
from routers import chat
from routers import quiz
from routers import pronunciation
from contextlib import asynccontextmanager
from fastapi import FastAPI
from routers import survival



# Tabloları veritabanında oluştur 
Base.metadata.create_all(bind=engine)

# Uygulamayı başlat
app = FastAPI(title="English AI Master Backend API")

# 1. YAŞAM DÖNGÜSÜ FONKSİYONU
@asynccontextmanager
async def lifespan(app: FastAPI):
    # --- YUKARISI: STARTUP (Uygulama açılırken çalışır) ---
    print("🚀 Sunucu uyanıyor, müfredat kontrol ediliyor...")
    db = SessionLocal()
    
    # Tüm dersleri (A1 ve A2) tanımlıyoruz
    all_lessons = [
        # --- A1 DERSLERİ ---
        models.Lesson(order=1, title="Selamlama", topic="Greetings and meeting people", min_level="A1", target_words="Hello, Morning, Name, Meet"),
        models.Lesson(order=2, title="Kendini tanıtma", topic="Introducing yourself", min_level="A1", target_words="I am, Years old, Country, Live"),
        models.Lesson(order=3, title="Sayılar", topic="Numbers 1 to 100", min_level="A1", target_words="One, Ten, Twenty, Hundred"),
        models.Lesson(order=4, title="Renkler", topic="Colors and describing things", min_level="A1", target_words="Red, Blue, Green, Yellow"),
        models.Lesson(order=5, title="Aile", topic="Family members", min_level="A1", target_words="Mother, Father, Brother, Sister"),
        models.Lesson(order=6, title="Günlük rutinler", topic="Daily routines", min_level="A1", target_words="Wake up, Breakfast, Work, Sleep"),
        models.Lesson(order=7, title="Yiyecekler", topic="Food and ordering", min_level="A1", target_words="Apple, Bread, Water, Menu"),
        models.Lesson(order=8, title="A1 Final Sınavı", topic="General review of A1", min_level="A1", target_words="Review, Test, Pass, Complete"),

        # --- 🌟 YENİ EKLENEN A2 DERSLERİ 🌟 ---
        models.Lesson(order=9, title="Ev & Eşyalar", topic="House and Home", min_level="A2", target_words="Kitchen, Bedroom, Furniture, Garden"),
        models.Lesson(order=10, title="Alışveriş", topic="Shopping and Money", min_level="A2", target_words="Price, Cash, Credit Card, Receipt"),
        models.Lesson(order=11, title="Ulaşım & Yönler", topic="Transport and Directions", min_level="A2", target_words="Bus, Train, Ticket, Station"),
        models.Lesson(order=12, title="Yerler & Mekânlar", topic="Places and Buildings", min_level="A2", target_words="Hospital, Bank, Museum, Pharmacy"),
        models.Lesson(order=13, title="Sağlık & Vücut", topic="Health and Body", min_level="A2", target_words="Doctor, Medicine, Pain, Stomach"),
        models.Lesson(order=14, title="Hobiler & Boş Zaman", topic="Sport and Leisure", min_level="A2", target_words="Football, Cinema, Hobby, Relax"),
        models.Lesson(order=15, title="Hava Durumu", topic="Weather and Seasons", min_level="A2", target_words="Rain, Sun, Winter, Summer"),
        models.Lesson(order=16, title="A2 Final Sınavı", topic="General review of A2", min_level="A2", target_words="Review, Test, Pass, Complete"),


        models.Lesson(order=17, title="İş & Kariyer", topic="Work and Careers", min_level="B1", target_words="Colleague, Salary, Interview, Manager"),
        models.Lesson(order=18, title="Eğitim & Okul", topic="Education and School", min_level="B1", target_words="Degree, Semester, Assignment, Graduate"),
        models.Lesson(order=19, title="Teknoloji & İnternet", topic="Technology and Media", min_level="B1", target_words="Device, Software, Network, Download"),
        models.Lesson(order=20, title="Çevre & Doğa", topic="Environment and Nature", min_level="B1", target_words="Pollution, Climate, Recycle, Planet"),
        models.Lesson(order=21, title="Kültür & Seyahat", topic="Culture and Travel", min_level="B1", target_words="Custom, Tradition, Abroad, Explore"),
        models.Lesson(order=22, title="Duygular & İlişkiler", topic="Emotions and Relationships", min_level="B1", target_words="Anxious, Confident, Friendship, Argue"),
        models.Lesson(order=23, title="Sağlıklı Yaşam", topic="Healthy Lifestyle", min_level="B1", target_words="Diet, Exercise, Mental, Stress"),
        models.Lesson(order=24, title="B1 Final Sınavı", topic="General review of B1", min_level="B1", target_words="Advanced, Review, Challenge, Succeed"),
    ]

    # Mevcut derslerin 'order' numaralarını bir kümede (Set) topluyoruz
    existing_lesson_orders = {lesson.order for lesson in db.query(models.Lesson).all()}

    # Sadece eksik olan dersleri veritabanına ekleyen akıllı döngü
    new_lessons_added = False
    for lesson in all_lessons:
        if lesson.order not in existing_lesson_orders:
            db.add(lesson)
            new_lessons_added = True

    if new_lessons_added:
        db.commit()
        print("✅ Yeni B1 dersleri başarıyla veritabanına eklendi!")
    else:
        print("⚡ Müfredat zaten güncel.")

    db.close()

    yield # 🌟 SİHİRLİ KELİME: Uygulama çalışırken burada bekler 🌟

    # --- AŞAĞISI: SHUTDOWN (Uygulama kapanırken çalışır) ---
    print("🛑 Sunucu kapanıyor, bağlantılar temizleniyor...")


# 2. FASTAPI'Yİ BAŞLATIRKEN BU DÖNGÜYÜ İÇİNE VERİYORUZ
app = FastAPI(lifespan=lifespan)

# Router'larını bunun altına ekleyebilirsin:
# app.include_router(lessons.router)
# Bütün kapıları (Router) sisteme bağlıyoruz
app.include_router(user.router, tags=["Kullanıcı İşlemleri"])
app.include_router(chat.router, tags=["AI Sohbet İşlemleri"])
app.include_router(quiz.router, tags=["AI Sınav İşlemleri"])
app.include_router(analyze.router, tags=["AI Analiz İşlemleri"])
app.include_router(pronunciation.router, tags=["AI Telaffuz İşlemleri"])
app.include_router(ai_service.router, tags=["AI Servis İşlemleri"])
app.include_router(survival.router, tags=["Can İşlemleri"])






