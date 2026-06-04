from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.orm import declarative_base
import os
from dotenv import load_dotenv

# .env dosyasındaki verileri Python'a yükler
load_dotenv()


SQLALCHEMY_DATABASE_URL = os.getenv("SQLALCHEMY_DATABASE_URL")
# SQLAlchemy Motorunu Başlat
engine = create_engine(SQLALCHEMY_DATABASE_URL)

# Oturum (Session) Ayarları
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Tablo iskeletimiz (Modern SQLAlchemy'de declarative_base buradan çağrılır)
Base = declarative_base()

# --- TABLOLARIMIZ (İlişkisel Şema) ---
