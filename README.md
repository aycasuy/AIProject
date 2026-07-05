# Yapay Zeka Destekli Yabancı Dil Öğrenme Uygulaması

<p align="center">
  <b>Flutter, FastAPI, PostgreSQL ve Google Gemini API ile geliştirilmiş yapay zekâ destekli mobil dil öğrenme uygulaması.</b>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-Mobile-blue?logo=flutter" />
  <img src="https://img.shields.io/badge/FastAPI-Backend-009688?logo=fastapi" />
  <img src="https://img.shields.io/badge/PostgreSQL-Database-336791?logo=postgresql" />
  <img src="https://img.shields.io/badge/Google%20Gemini-AI-8E75B2" />
  <img src="https://img.shields.io/badge/Status-Graduation%20Project-success" />
</p>

---

## İçindekiler

- [Proje Hakkında](#proje-hakkında)
- [Temel Özellikler](#temel-özellikler)
- [Kullanılan Teknolojiler](#kullanılan-teknolojiler)
- [Proje Mimarisi](#proje-mimarisi)
- [Klasör Yapısı](#klasör-yapısı)
- [Kurulum](#kurulum)
- [Backend Çalıştırma](#backend-çalıştırma)
- [Mobil Uygulama Çalıştırma](#mobil-uygulama-çalıştırma)
- [Veritabanı Kurulumu](#veritabanı-kurulumu)
- [Ortam Değişkenleri](#ortam-değişkenleri)
- [Ekran Görüntüleri](#ekran-görüntüleri)
- [Güvenlik Notları](#güvenlik-notları)
- [Sorun Giderme](#sorun-giderme)
- [Geliştirici](#geliştirici)

---

## Proje Hakkında

**Yapay Zeka Destekli Yabancı Dil Öğrenme Uygulaması**, kullanıcıların yabancı dil öğrenme sürecini daha etkileşimli, kişiselleştirilebilir ve sürdürülebilir hâle getirmek amacıyla geliştirilmiş bir mobil eğitim uygulamasıdır.

Uygulama; kullanıcıların seviye belirleme testi çözmesini, CEFR tabanlı ders haritası üzerinden ilerlemesini, kelime ve cümle egzersizleri yapmasını, telaffuz çalışmasını, dinleme ve okuma becerilerini geliştirmesini sağlar. Ayrıca yapay zekâ destekli roleplay ve içerik üretimi ile kullanıcıya daha dinamik bir öğrenme deneyimi sunar.

Bu proje, Bilgisayar Mühendisliği mezuniyet projesi kapsamında geliştirilmiştir.

---

## Temel Özellikler

- Kullanıcı kayıt ve giriş sistemi
- Ana dil ve hedef dil seçimi
- CEFR seviyelerine göre seviye belirleme testi
- Seviyeye göre açılan ders haritası
- Kelime kartları
- Boşluk doldurma alıştırmaları
- Cümle kurma modülü
- Dinleme ve dikte çalışmaları
- Telaffuz pratikleri
- Minimal pairs alıştırmaları
- Hızlı okuma modülü
- Kelime Avı
- Yapay zekâ destekli roleplay
- Hata takip ve tekrar sistemi
- Bilinmeyen kelimeler için kelime kumbarası
- Final sınavı ve seviye atlama sınavı
- XP ve ilerleme takibi
- Çoklu dil / yerelleştirme desteği

---

## Kullanılan Teknolojiler

### Mobil Uygulama

| Teknoloji | Açıklama |
|---|---|
| Flutter | Mobil uygulama geliştirme |
| Dart | Flutter uygulama dili |
| Material Design | Arayüz bileşenleri |
| HTTP | Backend API istekleri |
| Speech to Text | Sesli cevap ve telaffuz işlemleri |
| Text to Speech | Metinleri seslendirme |
| Audioplayers | Ses dosyalarını oynatma |
| Lottie | Animasyon desteği |
| ARB / Localization | Çoklu dil desteği |

### Backend

| Teknoloji | Açıklama |
|---|---|
| Python | Backend geliştirme dili |
| FastAPI | REST API geliştirme |
| SQLAlchemy | ORM ve veritabanı işlemleri |
| Pydantic | Veri doğrulama |
| Uvicorn | ASGI sunucusu |
| Google Gemini API | Yapay zekâ destekli içerik üretimi |
| Alembic | Veritabanı migration yönetimi |

### Veritabanı

| Teknoloji | Açıklama |
|---|---|
| PostgreSQL | İlişkisel veritabanı |
| pgAdmin | Veritabanı yönetim aracı |

---

## Proje Mimarisi

```text
Flutter Mobil Uygulama
        |
        | HTTP Requests
        v
FastAPI Backend
        |
        | SQLAlchemy ORM
        v
PostgreSQL Veritabanı

FastAPI Backend
        |
        | API Request
        v
Google Gemini API
```

Uygulama genel olarak üç temel katmandan oluşur:

1. **Mobil Katman:** Kullanıcı arayüzü, ders ekranları, testler, alıştırmalar ve ilerleme ekranları.
2. **Backend Katmanı:** API uç noktaları, kullanıcı işlemleri, ders verileri, yapay zekâ istekleri ve iş kuralları.
3. **Veritabanı Katmanı:** Kullanıcı ilerlemeleri, dersler, kelimeler, hatalar, test sonuçları ve öğrenme verileri.

---

## Klasör Yapısı

```text
Ayca_Su_Yildirim_Proje_Kodlari/
├── README.md
├── mobile_app/
│   ├── lib/
│   ├── assets/
│   ├── android/
│   ├── ios/
│   ├── pubspec.yaml
│   └── pubspec.lock
├── backend/
│   ├── alembic/
│   ├── routers/
│   ├── main.py
│   ├── models.py
│   ├── schemas.py
│   ├── database.py
│   ├── config.py
│   ├── alembic.ini
│   ├── requirements.txt
│   └── .env.example
└── database/
    └── language_learning_database.sql
```

---

## Kurulum

Projeyi çalıştırmak için sisteminizde aşağıdaki yazılımlar kurulu olmalıdır:

- Flutter SDK
- Dart SDK
- Android Studio veya Visual Studio Code
- Python 3.10 veya üzeri
- PostgreSQL
- pgAdmin
- Google Gemini API anahtarı

Kurulumları kontrol etmek için:

```bash
flutter doctor
python --version
psql --version
```

---

## Backend Çalıştırma

Backend klasörüne geçin:

```bash
cd backend
```

Sanal ortam oluşturun:

```bash
python -m venv venv
```

### Windows CMD

```cmd
venv\Scripts\activate
```

### Windows PowerShell

```powershell
.\venv\Scripts\Activate.ps1
```

PowerShell betik çalıştırma izni hatası alınırsa:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

Ardından sanal ortamı tekrar etkinleştirin:

```powershell
.\venv\Scripts\Activate.ps1
```

### macOS / Linux

```bash
source venv/bin/activate
```

Gerekli paketleri yükleyin:

```bash
pip install -r requirements.txt
```

Backend sunucusunu başlatın:

```bash
uvicorn main:app --reload
```

Backend çalıştığında:

```text
http://127.0.0.1:8000
```

API dokümantasyonu:

```text
http://127.0.0.1:8000/docs
```

---

## Mobil Uygulama Çalıştırma

Mobil uygulama klasörüne geçin:

```bash
cd mobile_app
```

Flutter paketlerini yükleyin:

```bash
flutter pub get
```

Yerelleştirme dosyalarını üretin:

```bash
flutter gen-l10n
```

Bağlı cihazları kontrol edin:

```bash
flutter devices
```

Uygulamayı çalıştırın:

```bash
flutter run
```

### Backend Adresi

Android Emulator kullanılıyorsa backend adresi genellikle şu şekilde olmalıdır:

```text
http://10.0.2.2:8000
```

Fiziksel Android cihaz kullanılıyorsa bilgisayarın yerel IP adresi kullanılmalıdır:

```text
http://192.168.x.x:8000
```

Fiziksel cihaz ve bilgisayar aynı Wi-Fi ağına bağlı olmalıdır.

---

## Veritabanı Kurulumu

1. PostgreSQL ve pgAdmin açılır.
2. Yeni bir veritabanı oluşturulur.
3. Oluşturulan veritabanı seçilir.
4. pgAdmin üzerinden **Query Tool** açılır.
5. `database/language_learning_database.sql` dosyası çalıştırılır.
6. Tabloların ve örnek verilerin oluştuğu kontrol edilir.
7. `.env` dosyasındaki `DATABASE_URL` değeri oluşturulan veritabanına göre düzenlenir.

Örnek bağlantı:

```env
DATABASE_URL=postgresql://postgres:parola@localhost:5432/language_learning_db
```

---

## Ortam Değişkenleri

Gerçek API anahtarları ve veritabanı şifreleri repoya eklenmemelidir.

Backend klasöründeki `.env.example` dosyasını `.env` adıyla kopyalayın.

### Windows CMD

```cmd
copy .env.example .env
```

### Windows PowerShell

```powershell
Copy-Item .env.example .env
```

### macOS / Linux

```bash
cp .env.example .env
```

`.env` dosyasını kendi bilgilerinizle doldurun:

```env
DATABASE_URL=postgresql://KULLANICI_ADI:SIFRE@localhost:5432/VERITABANI_ADI
GEMINI_API_KEY=GEMINI_API_ANAHTARINIZ
```

> Not: Ortam değişkeni adları `config.py` ve `database.py` dosyalarında kullanılan adlarla birebir aynı olmalıdır.

---

## Ekran Görüntüleri

Aşağıdaki alanlara uygulama ekran görüntüleri eklenebilir.

| Ders Haritası | Roleplay |
|---|---|
| ![Ders Haritası](docs/screenshots/path.png) | ![Roleplay](docs/screenshots/roleplay.png) |

| Profil | Kelime Avı |
|---|---|
| ![Profil](docs/screenshots/profile.png) | ![Kelime Avı](docs/screenshots/word_hunt.png) |

Örnek klasör yapısı:

```text
docs/
└── screenshots/
    ├── home.png
    ├── path.png
    └── roleplay.png
```

---

## Güvenlik Notları

Aşağıdaki dosya ve bilgiler GitHub reposuna eklenmemelidir:

```text
.env
venv/
__pycache__/
.dart_tool/
build/
android/.gradle/
.idea/
.vscode/
*.pyc
```

Ayrıca aşağıdaki bilgiler repoya yüklenmemelidir:

- Gerçek Gemini API anahtarı
- PostgreSQL parolası
- Kullanıcı parolaları
- Kişisel kullanıcı verileri
- Sertifika veya özel anahtar dosyaları

Bu nedenle `.env` yerine yalnızca `.env.example` dosyası paylaşılmalıdır.

---

## Sorun Giderme

### Backend bağlantısı kurulamıyor

- FastAPI sunucusunun çalıştığını kontrol edin.
- Android Emulator için `10.0.2.2` adresini kullanın.
- Fiziksel cihazda bilgisayarın yerel IP adresini kullanın.
- Güvenlik duvarının 8000 numaralı porta izin verdiğini kontrol edin.

### PostgreSQL bağlantı hatası

- PostgreSQL servisinin çalıştığını kontrol edin.
- `.env` dosyasındaki kullanıcı adı, parola, port ve veritabanı adını doğrulayın.
- Veritabanı tablolarının oluşturulduğundan emin olun.

### Flutter paket hatası

```bash
flutter clean
flutter pub get
flutter gen-l10n
flutter run
```

### Gemini API hatası

- API anahtarının doğru girildiğini kontrol edin.
- İnternet bağlantısını kontrol edin.
- API kullanım kotasını kontrol edin.

---

## Geliştirici

**Ayça Su Yıldırım**  
Bilgisayar Mühendisliği Mezuniyet Projesi  
İstanbul Topkapı Üniversitesi

---

## Not

Bu proje, akademik amaçla geliştirilmiş bir mezuniyet projesidir.
