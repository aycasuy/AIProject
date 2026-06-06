// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String get learningPreferences => 'ÖĞRENME TERCİHLERİ';

  @override
  String get learnedLanguage => 'Öğrenilen Dil';

  @override
  String get practiceLevel => 'Pratik Seviyesi';

  @override
  String get appSettings => 'UYGULAMA AYARLARI';

  @override
  String get dailyReminders => 'Günlük Hatırlatıcılar';

  @override
  String get saveChanges => 'Değişiklikleri Kaydet';

  @override
  String get logout => 'Çıkış Yap';

  @override
  String get onboard1Title => 'Her Yerde,\nHer Zaman Öğren';

  @override
  String get onboard1Subtitle =>
      'Günlük hayatın için tasarlanmış\ncebe sığan dersler.';

  @override
  String get onboard2Title => 'Gerçek Diyaloglar,\nGerçek İlerleme';

  @override
  String get onboard2Subtitle =>
      'Doğal hissettiren yapay zeka destekli\ndiyaloglarla pratik yap.';

  @override
  String get onboard3Title => 'Yolculuğunu\nTakip Et';

  @override
  String get onboard3Subtitle =>
      'Şık ilerleme grafikleriyle\nne kadar geliştiğini gör.';

  @override
  String get skip => 'Atla';

  @override
  String get next => 'İleri  →';

  @override
  String get letsStart => 'Hadi Başlayalım! 🚀';

  @override
  String get loginSubtitle => 'Dil Öğren. Daha İyi Yaşa.';

  @override
  String get fillAllFields => 'Lütfen tüm alanları doldurun! 🌟';

  @override
  String get registerSuccess => 'Kayıt Başarılı! Giriş yapabilirsiniz.';

  @override
  String get connectionError => 'Bağlantı Hatası!';

  @override
  String comingSoon(String provider) {
    return '$provider ile giriş yakında eklenecek 🚀';
  }

  @override
  String get signIn => 'Giriş Yap';

  @override
  String get signUp => 'Kayıt Ol';

  @override
  String get username => 'Kullanıcı Adı';

  @override
  String get email => 'E-posta';

  @override
  String get password => 'Şifre';

  @override
  String get forgotPassword => 'Şifremi unuttum?';

  @override
  String get signInBtn => '🚀  Giriş Yap';

  @override
  String get signUpBtn => '✨  Hesap Oluştur';

  @override
  String get or => 'veya';

  @override
  String get noAccount => 'Hesabın yok mu? ';

  @override
  String get haveAccount => 'Zaten kayıtlı mısın? ';

  @override
  String get langEnglish => 'İngilizce';

  @override
  String get langSpanish => 'İspanyolca';

  @override
  String get langGerman => 'Almanca';

  @override
  String get langFrench => 'Fransızca';

  @override
  String get langTurkish => 'Türkçe';

  @override
  String get readyToLearn => 'Yeni bir dil öğrenmeye hazır mısın? 🌍';

  @override
  String get continueLearning => 'Hangi dilden devam etmek istersiniz? 🚀';

  @override
  String get whatIsNativeLanguage => 'Ana dilin nedir?';

  @override
  String get makeSelectionToPersonalize =>
      'Sana en uygun deneyimi sunabilmemiz için lütfen seçim yap.';

  @override
  String stepProgress(int current, int total) {
    return 'Adım $current / $total';
  }

  @override
  String languageComingSoonMsg(String lang) {
    return '$lang yakında eklenecek! Şimdilik İngilizce veya İspanyolca ile başlayalım. 🚀';
  }

  @override
  String get connectionErrorServer => 'Bağlantı hatası! Sunucu açık mı?';

  @override
  String roleplayIntro(String lessonTitle, String targetLanguage, int count) {
    return 'Senaryo: $lessonTitle 🎭\n\nHedefin bu senaryoya uygun, $targetLanguage dilinde $count hatasız cümle kurmak. Hazırsan ilk mesajını yazarak sohbeti başlat! 😊';
  }

  @override
  String roleplayGoal(int current, int count) {
    return 'Hedef: $current / $count doğru cümle';
  }

  @override
  String get roleplayHint => 'Tıkandım, İpucu ver';

  @override
  String get writtenAnswer => 'Cevabını yaz...';

  @override
  String get correctedAnswer => 'Düzeltilmiş halini yaz...';

  @override
  String get dailyLimitTitle => 'Bugünlük Yeter!';

  @override
  String get dailyLimitMessage =>
      'Günlük ücretsiz yapay zeka roleplay hakkını doldurdun. Harika iş çıkardın! Yeni bir senaryo için yarın tekrar gel veya sınırsız sohbet için Premium\'u keşfet.';

  @override
  String get useBottomMenuHint => '👇 Başka etkinlikler için alt menüyü kullan';

  @override
  String get dailyWords => 'Günün Kelimeleri';

  @override
  String get aiResults => 'İşte sonuçların:';

  @override
  String get coachThinking => 'Koç düşünüyor...';

  @override
  String get finishLessonWithXp => '✅ Dersi Bitir (+50 XP)';

  @override
  String get greatJobTitle => '🎉 Harika İş!';

  @override
  String get greatJobMessage =>
      'Senaryoyu başarıyla tamamladın ve +50 XP kazandın!';

  @override
  String get ok => 'Tamam';

  @override
  String get translationTitle => 'Çeviri';

  @override
  String get holdForTranslation => 'Çeviri için basılı tut';

  @override
  String get noMistakeFound => 'Harika! Hiç hata bulunmadı.';

  @override
  String mistakesFound(int count) {
    return '$count hata bulundu';
  }

  @override
  String get levelJourneyTitle => 'Yolculuğun Başlıyor!';

  @override
  String levelJourneySubtitle(String language) {
    return '$language öğrenirken sana en uygun başlangıcı seçelim.';
  }

  @override
  String get startFromA1Title => 'A1’den başlayabilirsin';

  @override
  String get startFromA1Subtitle =>
      'Temelden ilerleyip tüm modülleri sırayla açarsın.';

  @override
  String get placementInfoTitle => 'Seviye testi çözebilirsin';

  @override
  String get placementInfoSubtitle =>
      'Sana uygun seviyeyi kısa bir test ile belirleriz.';

  @override
  String get startFromScratchA1 => 'Sıfırdan Başlayalım (A1)';

  @override
  String get knowMyLevelTest => 'Seviyemi Biliyorum / Test Et';

  @override
  String get levelSaveFailed => 'Seviye kaydedilemedi!';

  @override
  String connectionErrorWithDetail(String error) {
    return 'Bağlantı hatası: $error';
  }
}
