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
}
