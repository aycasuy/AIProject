import os
from dotenv import load_dotenv

# .env dosyasındaki verileri Python'a yükler
load_dotenv()

# API anahtarını bir değişkene atıyoruz
GOOGLE_API_KEY = os.getenv("GOOGLE_API_KEY")

if not GOOGLE_API_KEY:
    raise ValueError("GOOGLE_API_KEY .env dosyasında bulunamadı!")