import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('tr'),
  ];

  /// No description provided for @settingsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get settingsTitle;

  /// No description provided for @learningPreferences.
  ///
  /// In tr, this message translates to:
  /// **'ÖĞRENME TERCİHLERİ'**
  String get learningPreferences;

  /// No description provided for @learnedLanguage.
  ///
  /// In tr, this message translates to:
  /// **'Öğrenilen Dil'**
  String get learnedLanguage;

  /// No description provided for @practiceLevel.
  ///
  /// In tr, this message translates to:
  /// **'Pratik Seviyesi'**
  String get practiceLevel;

  /// No description provided for @appSettings.
  ///
  /// In tr, this message translates to:
  /// **'UYGULAMA AYARLARI'**
  String get appSettings;

  /// No description provided for @dailyReminders.
  ///
  /// In tr, this message translates to:
  /// **'Günlük Hatırlatıcılar'**
  String get dailyReminders;

  /// No description provided for @saveChanges.
  ///
  /// In tr, this message translates to:
  /// **'Değişiklikleri Kaydet'**
  String get saveChanges;

  /// No description provided for @logout.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış Yap'**
  String get logout;

  /// No description provided for @onboard1Title.
  ///
  /// In tr, this message translates to:
  /// **'Her Yerde,\nHer Zaman Öğren'**
  String get onboard1Title;

  /// No description provided for @onboard1Subtitle.
  ///
  /// In tr, this message translates to:
  /// **'Günlük hayatın için tasarlanmış\ncebe sığan dersler.'**
  String get onboard1Subtitle;

  /// No description provided for @onboard2Title.
  ///
  /// In tr, this message translates to:
  /// **'Gerçek Diyaloglar,\nGerçek İlerleme'**
  String get onboard2Title;

  /// No description provided for @onboard2Subtitle.
  ///
  /// In tr, this message translates to:
  /// **'Doğal hissettiren yapay zeka destekli\ndiyaloglarla pratik yap.'**
  String get onboard2Subtitle;

  /// No description provided for @onboard3Title.
  ///
  /// In tr, this message translates to:
  /// **'Yolculuğunu\nTakip Et'**
  String get onboard3Title;

  /// No description provided for @onboard3Subtitle.
  ///
  /// In tr, this message translates to:
  /// **'Şık ilerleme grafikleriyle\nne kadar geliştiğini gör.'**
  String get onboard3Subtitle;

  /// No description provided for @skip.
  ///
  /// In tr, this message translates to:
  /// **'Atla'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In tr, this message translates to:
  /// **'İleri  →'**
  String get next;

  /// No description provided for @letsStart.
  ///
  /// In tr, this message translates to:
  /// **'Hadi Başlayalım! 🚀'**
  String get letsStart;

  /// No description provided for @loginSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Dil Öğren. Daha İyi Yaşa.'**
  String get loginSubtitle;

  /// No description provided for @fillAllFields.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen tüm alanları doldurun! 🌟'**
  String get fillAllFields;

  /// No description provided for @registerSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt Başarılı! Giriş yapabilirsiniz.'**
  String get registerSuccess;

  /// No description provided for @connectionError.
  ///
  /// In tr, this message translates to:
  /// **'Bağlantı Hatası!'**
  String get connectionError;

  /// No description provided for @comingSoon.
  ///
  /// In tr, this message translates to:
  /// **'{provider} ile giriş yakında eklenecek 🚀'**
  String comingSoon(String provider);

  /// No description provided for @signIn.
  ///
  /// In tr, this message translates to:
  /// **'Giriş Yap'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt Ol'**
  String get signUp;

  /// No description provided for @username.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı Adı'**
  String get username;

  /// No description provided for @email.
  ///
  /// In tr, this message translates to:
  /// **'E-posta'**
  String get email;

  /// No description provided for @password.
  ///
  /// In tr, this message translates to:
  /// **'Şifre'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifremi unuttum?'**
  String get forgotPassword;

  /// No description provided for @signInBtn.
  ///
  /// In tr, this message translates to:
  /// **'🚀  Giriş Yap'**
  String get signInBtn;

  /// No description provided for @signUpBtn.
  ///
  /// In tr, this message translates to:
  /// **'✨  Hesap Oluştur'**
  String get signUpBtn;

  /// No description provided for @or.
  ///
  /// In tr, this message translates to:
  /// **'veya'**
  String get or;

  /// No description provided for @noAccount.
  ///
  /// In tr, this message translates to:
  /// **'Hesabın yok mu? '**
  String get noAccount;

  /// No description provided for @haveAccount.
  ///
  /// In tr, this message translates to:
  /// **'Zaten kayıtlı mısın? '**
  String get haveAccount;

  /// No description provided for @langEnglish.
  ///
  /// In tr, this message translates to:
  /// **'İngilizce'**
  String get langEnglish;

  /// No description provided for @langSpanish.
  ///
  /// In tr, this message translates to:
  /// **'İspanyolca'**
  String get langSpanish;

  /// No description provided for @langGerman.
  ///
  /// In tr, this message translates to:
  /// **'Almanca'**
  String get langGerman;

  /// No description provided for @langFrench.
  ///
  /// In tr, this message translates to:
  /// **'Fransızca'**
  String get langFrench;

  /// No description provided for @langTurkish.
  ///
  /// In tr, this message translates to:
  /// **'Türkçe'**
  String get langTurkish;

  /// No description provided for @readyToLearn.
  ///
  /// In tr, this message translates to:
  /// **'Yeni bir dil öğrenmeye hazır mısın? 🌍'**
  String get readyToLearn;

  /// No description provided for @continueLearning.
  ///
  /// In tr, this message translates to:
  /// **'Hangi dilden devam etmek istersiniz? 🚀'**
  String get continueLearning;

  /// No description provided for @whatIsNativeLanguage.
  ///
  /// In tr, this message translates to:
  /// **'Ana dilin nedir?'**
  String get whatIsNativeLanguage;

  /// No description provided for @makeSelectionToPersonalize.
  ///
  /// In tr, this message translates to:
  /// **'Sana en uygun deneyimi sunabilmemiz için lütfen seçim yap.'**
  String get makeSelectionToPersonalize;

  /// No description provided for @stepProgress.
  ///
  /// In tr, this message translates to:
  /// **'Adım {current} / {total}'**
  String stepProgress(int current, int total);

  /// No description provided for @languageComingSoonMsg.
  ///
  /// In tr, this message translates to:
  /// **'{lang} yakında eklenecek! Şimdilik İngilizce veya İspanyolca ile başlayalım. 🚀'**
  String languageComingSoonMsg(String lang);

  /// No description provided for @connectionErrorServer.
  ///
  /// In tr, this message translates to:
  /// **'Bağlantı hatası! Sunucu açık mı?'**
  String get connectionErrorServer;

  /// No description provided for @roleplayIntro.
  ///
  /// In tr, this message translates to:
  /// **'Senaryo: {lessonTitle} 🎭\n\nHedefin bu senaryoya uygun, {targetLanguage} dilinde {count} hatasız cümle kurmak. Hazırsan ilk mesajını yazarak sohbeti başlat! 😊'**
  String roleplayIntro(String lessonTitle, String targetLanguage, int count);

  /// No description provided for @roleplayGoal.
  ///
  /// In tr, this message translates to:
  /// **'Hedef: {current} / {count} doğru cümle'**
  String roleplayGoal(int current, int count);

  /// No description provided for @roleplayHint.
  ///
  /// In tr, this message translates to:
  /// **'Tıkandım, İpucu ver'**
  String get roleplayHint;

  /// No description provided for @writtenAnswer.
  ///
  /// In tr, this message translates to:
  /// **'Cevabını yaz...'**
  String get writtenAnswer;

  /// No description provided for @correctedAnswer.
  ///
  /// In tr, this message translates to:
  /// **'Düzeltilmiş halini yaz...'**
  String get correctedAnswer;

  /// No description provided for @dailyLimitTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bugünlük Yeter!'**
  String get dailyLimitTitle;

  /// No description provided for @dailyLimitMessage.
  ///
  /// In tr, this message translates to:
  /// **'Günlük ücretsiz yapay zeka roleplay hakkını doldurdun. Harika iş çıkardın! Yeni bir senaryo için yarın tekrar gel veya sınırsız sohbet için Premium\'u keşfet.'**
  String get dailyLimitMessage;

  /// No description provided for @useBottomMenuHint.
  ///
  /// In tr, this message translates to:
  /// **'👇 Başka etkinlikler için alt menüyü kullan'**
  String get useBottomMenuHint;

  /// No description provided for @dailyWords.
  ///
  /// In tr, this message translates to:
  /// **'Günün Kelimeleri'**
  String get dailyWords;

  /// No description provided for @aiResults.
  ///
  /// In tr, this message translates to:
  /// **'İşte sonuçların:'**
  String get aiResults;

  /// No description provided for @coachThinking.
  ///
  /// In tr, this message translates to:
  /// **'Koç düşünüyor...'**
  String get coachThinking;

  /// No description provided for @finishLessonWithXp.
  ///
  /// In tr, this message translates to:
  /// **'✅ Dersi Bitir (+50 XP)'**
  String get finishLessonWithXp;

  /// No description provided for @greatJobTitle.
  ///
  /// In tr, this message translates to:
  /// **'🎉 Harika İş!'**
  String get greatJobTitle;

  /// No description provided for @greatJobMessage.
  ///
  /// In tr, this message translates to:
  /// **'Senaryoyu başarıyla tamamladın ve +50 XP kazandın!'**
  String get greatJobMessage;

  /// No description provided for @ok.
  ///
  /// In tr, this message translates to:
  /// **'Tamam'**
  String get ok;

  /// No description provided for @translationTitle.
  ///
  /// In tr, this message translates to:
  /// **'Çeviri'**
  String get translationTitle;

  /// No description provided for @holdForTranslation.
  ///
  /// In tr, this message translates to:
  /// **'Çeviri için basılı tut'**
  String get holdForTranslation;

  /// No description provided for @noMistakeFound.
  ///
  /// In tr, this message translates to:
  /// **'Harika! Hiç hata bulunmadı.'**
  String get noMistakeFound;

  /// No description provided for @mistakesFound.
  ///
  /// In tr, this message translates to:
  /// **'{count} hata bulundu'**
  String mistakesFound(int count);

  /// No description provided for @levelJourneyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yolculuğun Başlıyor!'**
  String get levelJourneyTitle;

  /// No description provided for @levelJourneySubtitle.
  ///
  /// In tr, this message translates to:
  /// **'{language} öğrenirken sana en uygun başlangıcı seçelim.'**
  String levelJourneySubtitle(String language);

  /// No description provided for @startFromA1Title.
  ///
  /// In tr, this message translates to:
  /// **'A1’den başlayabilirsin'**
  String get startFromA1Title;

  /// No description provided for @startFromA1Subtitle.
  ///
  /// In tr, this message translates to:
  /// **'Temelden ilerleyip tüm modülleri sırayla açarsın.'**
  String get startFromA1Subtitle;

  /// No description provided for @placementInfoTitle.
  ///
  /// In tr, this message translates to:
  /// **'Seviye testi çözebilirsin'**
  String get placementInfoTitle;

  /// No description provided for @placementInfoSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Sana uygun seviyeyi kısa bir test ile belirleriz.'**
  String get placementInfoSubtitle;

  /// No description provided for @startFromScratchA1.
  ///
  /// In tr, this message translates to:
  /// **'Sıfırdan Başlayalım (A1)'**
  String get startFromScratchA1;

  /// No description provided for @knowMyLevelTest.
  ///
  /// In tr, this message translates to:
  /// **'Seviyemi Biliyorum / Test Et'**
  String get knowMyLevelTest;

  /// No description provided for @levelSaveFailed.
  ///
  /// In tr, this message translates to:
  /// **'Seviye kaydedilemedi!'**
  String get levelSaveFailed;

  /// No description provided for @connectionErrorWithDetail.
  ///
  /// In tr, this message translates to:
  /// **'Bağlantı hatası: {error}'**
  String connectionErrorWithDetail(String error);

  /// No description provided for @placementLoading.
  ///
  /// In tr, this message translates to:
  /// **'Yapay Zeka Sınavını Hazırlıyor...'**
  String get placementLoading;

  /// No description provided for @placementQuestion.
  ///
  /// In tr, this message translates to:
  /// **'Soru {current}/{total}'**
  String placementQuestion(int current, int total);

  /// No description provided for @placementNext.
  ///
  /// In tr, this message translates to:
  /// **'Sonraki Soru'**
  String get placementNext;

  /// No description provided for @placementFinishedTitle.
  ///
  /// In tr, this message translates to:
  /// **'Sınav Tamamlandı!'**
  String get placementFinishedTitle;

  /// No description provided for @placementFinishedBody.
  ///
  /// In tr, this message translates to:
  /// **'Harika iş çıkardın.\n\nBelirlenen Seviyen: {level}'**
  String placementFinishedBody(String level);

  /// No description provided for @placementBackToMenu.
  ///
  /// In tr, this message translates to:
  /// **'Ana Menüye Dön'**
  String get placementBackToMenu;

  /// No description provided for @placementListenButton.
  ///
  /// In tr, this message translates to:
  /// **'Dinle'**
  String get placementListenButton;

  /// No description provided for @placementStopButton.
  ///
  /// In tr, this message translates to:
  /// **'Durdur'**
  String get placementStopButton;

  /// No description provided for @placementListenInstruction.
  ///
  /// In tr, this message translates to:
  /// **'Metni dinlemek için butona bas'**
  String get placementListenInstruction;

  /// No description provided for @placementNoQuestion.
  ///
  /// In tr, this message translates to:
  /// **'Soru bulunamadı.'**
  String get placementNoQuestion;

  /// No description provided for @learnHintTitle.
  ///
  /// In tr, this message translates to:
  /// **'Sana Bir İpucu!'**
  String get learnHintTitle;

  /// No description provided for @learnHintContent.
  ///
  /// In tr, this message translates to:
  /// **'Cevap \'{firstLetter}\' harfi ile başlıyor...\nVe tam {length} karakter uzunluğunda!'**
  String learnHintContent(String firstLetter, int length);

  /// No description provided for @learnHintThanks.
  ///
  /// In tr, this message translates to:
  /// **'Teşekkürler!'**
  String get learnHintThanks;

  /// No description provided for @learnHintBubble.
  ///
  /// In tr, this message translates to:
  /// **'İpucu?'**
  String get learnHintBubble;

  /// No description provided for @learnCorrectAnswer.
  ///
  /// In tr, this message translates to:
  /// **'Doğru Cevap: {answer}'**
  String learnCorrectAnswer(String answer);

  /// No description provided for @learnGenericError.
  ///
  /// In tr, this message translates to:
  /// **'Hata: {error}'**
  String learnGenericError(String error);

  /// No description provided for @learnNoCards.
  ///
  /// In tr, this message translates to:
  /// **'Bu derste henüz kart bulunmuyor.'**
  String get learnNoCards;

  /// No description provided for @learnGreatJob.
  ///
  /// In tr, this message translates to:
  /// **'Harika İş!'**
  String get learnGreatJob;

  /// No description provided for @learnDeckCompleted.
  ///
  /// In tr, this message translates to:
  /// **'Kelime destesini tamamladın.'**
  String get learnDeckCompleted;

  /// No description provided for @learnWordsAddedToVocabulary.
  ///
  /// In tr, this message translates to:
  /// **'{count} kelime \'Kelime Defteri\'ne eklendi. 📚'**
  String learnWordsAddedToVocabulary(int count);

  /// No description provided for @learnBackToMap.
  ///
  /// In tr, this message translates to:
  /// **'Haritaya Dön'**
  String get learnBackToMap;

  /// No description provided for @learnSwipeInstruction.
  ///
  /// In tr, this message translates to:
  /// **'Öğrendiysen Sağa 👉  |  👈 Tekrar için Sola'**
  String get learnSwipeInstruction;

  /// No description provided for @learnTapToSeeTranslation.
  ///
  /// In tr, this message translates to:
  /// **'Çeviriyi görmek için dokun'**
  String get learnTapToSeeTranslation;

  /// No description provided for @learnQuestionsCouldNotLoad.
  ///
  /// In tr, this message translates to:
  /// **'Sorular yüklenemedi. İnternetinizi kontrol edin.'**
  String get learnQuestionsCouldNotLoad;

  /// No description provided for @learnNoBlankQuestions.
  ///
  /// In tr, this message translates to:
  /// **'Bu derste henüz boşluk doldurma sorusu yok.'**
  String get learnNoBlankQuestions;

  /// No description provided for @learnNoSentenceQuestions.
  ///
  /// In tr, this message translates to:
  /// **'Bu derste henüz cümle kurma sorusu yok.'**
  String get learnNoSentenceQuestions;

  /// No description provided for @learnNewQuestionsComing.
  ///
  /// In tr, this message translates to:
  /// **'Yeni sorular eklendiğinde burada görünecek.'**
  String get learnNewQuestionsComing;

  /// No description provided for @learnGameOverTitle.
  ///
  /// In tr, this message translates to:
  /// **'Hakların Doldu!'**
  String get learnGameOverTitle;

  /// No description provided for @learnGameOverBlankMessage.
  ///
  /// In tr, this message translates to:
  /// **'Biraz dinlen, canların yenilenince boşluk doldurmaya tekrar devam edebilirsin.'**
  String get learnGameOverBlankMessage;

  /// No description provided for @learnGameOverOrderMessage.
  ///
  /// In tr, this message translates to:
  /// **'Biraz dinlen, canların yenilenince tekrar devam edebilirsin.'**
  String get learnGameOverOrderMessage;

  /// No description provided for @learnNewLife.
  ///
  /// In tr, this message translates to:
  /// **'Yeni can: {time}'**
  String learnNewLife(String time);

  /// No description provided for @learnRefillLives.
  ///
  /// In tr, this message translates to:
  /// **'300 XP ile Canları Fulle'**
  String get learnRefillLives;

  /// No description provided for @learnLivesRefilled.
  ///
  /// In tr, this message translates to:
  /// **'Canlar Fullendi! Maceraya Devam 🚀'**
  String get learnLivesRefilled;

  /// No description provided for @learnPerfectTitle.
  ///
  /// In tr, this message translates to:
  /// **'Mükemmel!'**
  String get learnPerfectTitle;

  /// No description provided for @learnBlankCompleted.
  ///
  /// In tr, this message translates to:
  /// **'Tüm boşluk doldurma sorularını tamamladın.'**
  String get learnBlankCompleted;

  /// No description provided for @learnOrderCompleted.
  ///
  /// In tr, this message translates to:
  /// **'Cümle kurma görevini başarıyla tamamladın.'**
  String get learnOrderCompleted;

  /// No description provided for @learnBlankTitle.
  ///
  /// In tr, this message translates to:
  /// **'Boşluk Doldurma'**
  String get learnBlankTitle;

  /// No description provided for @learnSentenceOrderTitle.
  ///
  /// In tr, this message translates to:
  /// **'Cümle Kurma'**
  String get learnSentenceOrderTitle;

  /// No description provided for @learnQuestionCounter.
  ///
  /// In tr, this message translates to:
  /// **'{current} / {total} soru'**
  String learnQuestionCounter(int current, int total);

  /// No description provided for @learnCompleteMissingWord.
  ///
  /// In tr, this message translates to:
  /// **'Eksik kelimeyi tamamla'**
  String get learnCompleteMissingWord;

  /// No description provided for @learnAnswerInputHint.
  ///
  /// In tr, this message translates to:
  /// **'Cevabını buraya yaz...'**
  String get learnAnswerInputHint;

  /// No description provided for @learnWrongWordError.
  ///
  /// In tr, this message translates to:
  /// **'Yanlış kelime, bir can gitti. Tekrar dene.'**
  String get learnWrongWordError;

  /// No description provided for @learnStuckHintText.
  ///
  /// In tr, this message translates to:
  /// **'Takılırsan ipucu alabilirsin.'**
  String get learnStuckHintText;

  /// No description provided for @learnGetHint.
  ///
  /// In tr, this message translates to:
  /// **'İpucu al'**
  String get learnGetHint;

  /// No description provided for @learnCheckAnswer.
  ///
  /// In tr, this message translates to:
  /// **'Kontrol Et ✨'**
  String get learnCheckAnswer;

  /// No description provided for @learnSkipBlank.
  ///
  /// In tr, this message translates to:
  /// **'Boşluğu dolduramadım, pas geç'**
  String get learnSkipBlank;

  /// No description provided for @learnSkipOrder.
  ///
  /// In tr, this message translates to:
  /// **'Cümleyi kuramadım, pas geç'**
  String get learnSkipOrder;

  /// No description provided for @learnTranslateFromNative.
  ///
  /// In tr, this message translates to:
  /// **'{language} dilinden çevir'**
  String learnTranslateFromNative(String language);

  /// No description provided for @learnBuildSentence.
  ///
  /// In tr, this message translates to:
  /// **'Cümleni oluştur'**
  String get learnBuildSentence;

  /// No description provided for @learnTapWordsToBuildSentence.
  ///
  /// In tr, this message translates to:
  /// **'Kelimelere dokunarak cümleyi kur'**
  String get learnTapWordsToBuildSentence;

  /// No description provided for @learnWords.
  ///
  /// In tr, this message translates to:
  /// **'Kelimeler'**
  String get learnWords;

  /// No description provided for @learnTapAndOrder.
  ///
  /// In tr, this message translates to:
  /// **'Dokun ve sırala'**
  String get learnTapAndOrder;

  /// No description provided for @learnWeakPointHunterTitle.
  ///
  /// In tr, this message translates to:
  /// **'Zayıf Nokta Avcısı'**
  String get learnWeakPointHunterTitle;

  /// No description provided for @learnWeakPointHunterDescription.
  ///
  /// In tr, this message translates to:
  /// **'Yapay zeka, geçmişte hata yaptığın kelimeleri analiz ederek sana özel, zamana karşı bir okuma testi hazırlayacak. Meydan okumaya hazır mısın?'**
  String get learnWeakPointHunterDescription;

  /// No description provided for @learnChallengeButton.
  ///
  /// In tr, this message translates to:
  /// **'Meydan Oku!'**
  String get learnChallengeButton;

  /// No description provided for @learnModuleNotFound.
  ///
  /// In tr, this message translates to:
  /// **'Modül bulunamadı.'**
  String get learnModuleNotFound;

  /// No description provided for @minimalPairsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Telaffuz & Ses Çiftleri'**
  String get minimalPairsTitle;

  /// No description provided for @minimalPairsNoPairs.
  ///
  /// In tr, this message translates to:
  /// **'Bu ders için ses çifti bulunamadı.'**
  String get minimalPairsNoPairs;

  /// No description provided for @minimalPairsStep.
  ///
  /// In tr, this message translates to:
  /// **'Adım {current} / {total}'**
  String minimalPairsStep(int current, int total);

  /// No description provided for @minimalPairsListenDifference.
  ///
  /// In tr, this message translates to:
  /// **'Aralarındaki farkı dinle'**
  String get minimalPairsListenDifference;

  /// No description provided for @minimalPairsSayNow.
  ///
  /// In tr, this message translates to:
  /// **'Şimdi sen söyle:'**
  String get minimalPairsSayNow;

  /// No description provided for @minimalPairsAnalyzing.
  ///
  /// In tr, this message translates to:
  /// **'Analiz ediliyor... 🤖'**
  String get minimalPairsAnalyzing;

  /// No description provided for @minimalPairsConnectionRetry.
  ///
  /// In tr, this message translates to:
  /// **'Bağlantı hatası, tekrar dener misin?'**
  String get minimalPairsConnectionRetry;

  /// No description provided for @minimalPairsNoVoice.
  ///
  /// In tr, this message translates to:
  /// **'Sesini alamadım.'**
  String get minimalPairsNoVoice;

  /// No description provided for @minimalPairsGreatPronunciation.
  ///
  /// In tr, this message translates to:
  /// **'Harika telaffuz! 🎯'**
  String get minimalPairsGreatPronunciation;

  /// No description provided for @minimalPairsPerfectPronunciation.
  ///
  /// In tr, this message translates to:
  /// **'Harika! Kusursuz telaffuz.'**
  String get minimalPairsPerfectPronunciation;

  /// No description provided for @minimalPairsCoachNote.
  ///
  /// In tr, this message translates to:
  /// **'Koçun Notu:'**
  String get minimalPairsCoachNote;

  /// No description provided for @minimalPairsHoldToSpeak.
  ///
  /// In tr, this message translates to:
  /// **'Konuşmak için basılı tut'**
  String get minimalPairsHoldToSpeak;

  /// No description provided for @minimalPairsSkip.
  ///
  /// In tr, this message translates to:
  /// **'Söyleyemedim, pas geç 🤔'**
  String get minimalPairsSkip;

  /// No description provided for @minimalPairsContinue.
  ///
  /// In tr, this message translates to:
  /// **'DEVAM ET'**
  String get minimalPairsContinue;

  /// No description provided for @minimalPairsAddedPractice.
  ///
  /// In tr, this message translates to:
  /// **'Kelime pratik listene eklendi! 📚 (1 Can gitti)'**
  String get minimalPairsAddedPractice;

  /// No description provided for @minimalPairsGameOverMessage.
  ///
  /// In tr, this message translates to:
  /// **'Üzgünüm, telaffuz pratiğinde çok hata yaptın. 300 XP harcayarak canlarını fulleyebilir veya haritaya dönebilirsin.'**
  String get minimalPairsGameOverMessage;

  /// No description provided for @pronunciationCoachTitle.
  ///
  /// In tr, this message translates to:
  /// **'Telaffuz Koçu 🎙️'**
  String get pronunciationCoachTitle;

  /// No description provided for @pronunciationInitialPrompt.
  ///
  /// In tr, this message translates to:
  /// **'Mikrofona bas ve okumaya başla...'**
  String get pronunciationInitialPrompt;

  /// No description provided for @pronunciationPreparingText.
  ///
  /// In tr, this message translates to:
  /// **'Yapay zeka senin için uygun bir metin hazırlıyor... ⏳'**
  String get pronunciationPreparingText;

  /// No description provided for @pronunciationNoText.
  ///
  /// In tr, this message translates to:
  /// **'Bu ders için uygun telaffuz metni bulunamadı.'**
  String get pronunciationNoText;

  /// No description provided for @pronunciationConnectionError.
  ///
  /// In tr, this message translates to:
  /// **'Bağlantı hatası! Lütfen internetini kontrol et.'**
  String get pronunciationConnectionError;

  /// No description provided for @pronunciationRound.
  ///
  /// In tr, this message translates to:
  /// **'Metin {current} / {total}'**
  String pronunciationRound(int current, int total);

  /// No description provided for @pronunciationReadClearly.
  ///
  /// In tr, this message translates to:
  /// **'Cümleyi net ve sakin oku'**
  String get pronunciationReadClearly;

  /// No description provided for @pronunciationReadSentence.
  ///
  /// In tr, this message translates to:
  /// **'Aşağıdaki cümleyi oku'**
  String get pronunciationReadSentence;

  /// No description provided for @pronunciationStop.
  ///
  /// In tr, this message translates to:
  /// **'Durdur'**
  String get pronunciationStop;

  /// No description provided for @pronunciationListenFirst.
  ///
  /// In tr, this message translates to:
  /// **'Önce Dinle'**
  String get pronunciationListenFirst;

  /// No description provided for @pronunciationListening.
  ///
  /// In tr, this message translates to:
  /// **'Dinliyorum...'**
  String get pronunciationListening;

  /// No description provided for @pronunciationTranscriptHint.
  ///
  /// In tr, this message translates to:
  /// **'Mikrofona basınca söylediklerin burada görünecek.'**
  String get pronunciationTranscriptHint;

  /// No description provided for @pronunciationWaitingForSpeech.
  ///
  /// In tr, this message translates to:
  /// **'Konuşman Bekleniyor'**
  String get pronunciationWaitingForSpeech;

  /// No description provided for @pronunciationAnalyze.
  ///
  /// In tr, this message translates to:
  /// **'Analiz Et'**
  String get pronunciationAnalyze;

  /// No description provided for @pronunciationTaskPreparing.
  ///
  /// In tr, this message translates to:
  /// **'Telaffuz görevin hazırlanıyor...'**
  String get pronunciationTaskPreparing;

  /// No description provided for @pronunciationGameOverMessage.
  ///
  /// In tr, this message translates to:
  /// **'Biraz bekle, yeni can geldiğinde devam edebilirsin.'**
  String get pronunciationGameOverMessage;

  /// No description provided for @pronunciationSuccessTitle.
  ///
  /// In tr, this message translates to:
  /// **'Harika Konuştun!'**
  String get pronunciationSuccessTitle;

  /// No description provided for @pronunciationSuccessMessage.
  ///
  /// In tr, this message translates to:
  /// **'Tüm telaffuz görevlerini tamamladın.'**
  String get pronunciationSuccessMessage;

  /// No description provided for @pronunciationSuccessful.
  ///
  /// In tr, this message translates to:
  /// **'Başarılı Telaffuz'**
  String get pronunciationSuccessful;

  /// No description provided for @pronunciationTryAgain.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar Deneyelim'**
  String get pronunciationTryAgain;

  /// No description provided for @pronunciationScoreUnit.
  ///
  /// In tr, this message translates to:
  /// **'puan'**
  String get pronunciationScoreUnit;

  /// No description provided for @pronunciationXpEarned.
  ///
  /// In tr, this message translates to:
  /// **'+{xp} XP Kazandın!'**
  String pronunciationXpEarned(int xp);

  /// No description provided for @pronunciationLifeLost.
  ///
  /// In tr, this message translates to:
  /// **'1 Can Gitti! Tekrar Dene.'**
  String get pronunciationLifeLost;

  /// No description provided for @pronunciationWordsToWatch.
  ///
  /// In tr, this message translates to:
  /// **'Dikkat etmen gereken kelimeler:'**
  String get pronunciationWordsToWatch;

  /// No description provided for @pronunciationNextText.
  ///
  /// In tr, this message translates to:
  /// **'Sıradaki Metin 🚀'**
  String get pronunciationNextText;

  /// No description provided for @pronunciationAmazing.
  ///
  /// In tr, this message translates to:
  /// **'Muhteşem! 🚀'**
  String get pronunciationAmazing;

  /// No description provided for @pronunciationRetry.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar Dene 🔄'**
  String get pronunciationRetry;

  /// No description provided for @listeningCoachTitle.
  ///
  /// In tr, this message translates to:
  /// **'Dinleme Koçu 🎧'**
  String get listeningCoachTitle;

  /// No description provided for @listeningRound.
  ///
  /// In tr, this message translates to:
  /// **'Metin {current} / {total}'**
  String listeningRound(int current, int total);

  /// No description provided for @listeningWriteAndCheck.
  ///
  /// In tr, this message translates to:
  /// **'Duyduğunu yaz ve kontrol et'**
  String get listeningWriteAndCheck;

  /// No description provided for @listeningListenFirst.
  ///
  /// In tr, this message translates to:
  /// **'Önce sesi dinle'**
  String get listeningListenFirst;

  /// No description provided for @listeningInstruction.
  ///
  /// In tr, this message translates to:
  /// **'Robotu dinle ve duyduğunu yaz'**
  String get listeningInstruction;

  /// No description provided for @listeningPlaying.
  ///
  /// In tr, this message translates to:
  /// **'Dinleniyor...'**
  String get listeningPlaying;

  /// No description provided for @listeningPlayAudio.
  ///
  /// In tr, this message translates to:
  /// **'Sesi Çal'**
  String get listeningPlayAudio;

  /// No description provided for @listeningInputLockedInfo.
  ///
  /// In tr, this message translates to:
  /// **'Sesi çaldıktan sonra yazma alanı açılacak.'**
  String get listeningInputLockedInfo;

  /// No description provided for @listeningWriteWhatYouHear.
  ///
  /// In tr, this message translates to:
  /// **'Duyduklarını yaz'**
  String get listeningWriteWhatYouHear;

  /// No description provided for @listeningReplay.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar dinle'**
  String get listeningReplay;

  /// No description provided for @listeningInputHint.
  ///
  /// In tr, this message translates to:
  /// **'Duyduğun cümleyi buraya yaz...'**
  String get listeningInputHint;

  /// No description provided for @listeningCheck.
  ///
  /// In tr, this message translates to:
  /// **'Kontrol Et 🎯'**
  String get listeningCheck;

  /// No description provided for @listeningTextLoadFailed.
  ///
  /// In tr, this message translates to:
  /// **'Dinleme metni yüklenemedi.'**
  String get listeningTextLoadFailed;

  /// No description provided for @listeningCheckConnection.
  ///
  /// In tr, this message translates to:
  /// **'Bağlantını kontrol edip tekrar deneyebilirsin.'**
  String get listeningCheckConnection;

  /// No description provided for @listeningRetryLoad.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar Dene'**
  String get listeningRetryLoad;

  /// No description provided for @listeningGameOverMessage.
  ///
  /// In tr, this message translates to:
  /// **'Biraz dinlen, canların yenilenince dinleme görevine tekrar devam edebilirsin.'**
  String get listeningGameOverMessage;

  /// No description provided for @listeningSuccessTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kulağın Çok İyi!'**
  String get listeningSuccessTitle;

  /// No description provided for @listeningSuccessMessage.
  ///
  /// In tr, this message translates to:
  /// **'Tüm dinleme görevlerini başarıyla tamamladın.'**
  String get listeningSuccessMessage;

  /// No description provided for @listeningEvaluationCompleted.
  ///
  /// In tr, this message translates to:
  /// **'Değerlendirme tamamlandı.'**
  String get listeningEvaluationCompleted;

  /// No description provided for @listeningSuccessResult.
  ///
  /// In tr, this message translates to:
  /// **'Harika dinledin!'**
  String get listeningSuccessResult;

  /// No description provided for @listeningTryAgainResult.
  ///
  /// In tr, this message translates to:
  /// **'Bir kez daha deneyelim'**
  String get listeningTryAgainResult;

  /// No description provided for @listeningXpEarned.
  ///
  /// In tr, this message translates to:
  /// **'+{xp} XP Kazandın!'**
  String listeningXpEarned(int xp);

  /// No description provided for @listeningLifeLost.
  ///
  /// In tr, this message translates to:
  /// **'1 Can Gitti'**
  String get listeningLifeLost;

  /// No description provided for @listeningMissedWords.
  ///
  /// In tr, this message translates to:
  /// **'Kaçırdığın veya yanlış yazdığın kelimeler:'**
  String get listeningMissedWords;

  /// No description provided for @listeningNextText.
  ///
  /// In tr, this message translates to:
  /// **'Sıradaki Metin 🚀'**
  String get listeningNextText;

  /// No description provided for @listeningAmazing.
  ///
  /// In tr, this message translates to:
  /// **'Muhteşem! 🚀'**
  String get listeningAmazing;

  /// No description provided for @listeningTryAgainButton.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar Dene 🔄'**
  String get listeningTryAgainButton;

  /// No description provided for @pathVisualLearning.
  ///
  /// In tr, this message translates to:
  /// **'Görsel Öğrenim'**
  String get pathVisualLearning;

  /// No description provided for @pathFillBlank.
  ///
  /// In tr, this message translates to:
  /// **'Boşluk Doldurma'**
  String get pathFillBlank;

  /// No description provided for @pathSentenceOrder.
  ///
  /// In tr, this message translates to:
  /// **'Cümle Kurma'**
  String get pathSentenceOrder;

  /// No description provided for @pathQuickQuiz.
  ///
  /// In tr, this message translates to:
  /// **'Hızlı Quiz'**
  String get pathQuickQuiz;

  /// No description provided for @pathMinimalPairs.
  ///
  /// In tr, this message translates to:
  /// **'Ses Çiftleri'**
  String get pathMinimalPairs;

  /// No description provided for @pathPronunciation.
  ///
  /// In tr, this message translates to:
  /// **'Telaffuz'**
  String get pathPronunciation;

  /// No description provided for @pathListening.
  ///
  /// In tr, this message translates to:
  /// **'Dinleme'**
  String get pathListening;

  /// No description provided for @pathTest.
  ///
  /// In tr, this message translates to:
  /// **'Test'**
  String get pathTest;

  /// No description provided for @pathLevelUp.
  ///
  /// In tr, this message translates to:
  /// **'SEVİYE ATLA'**
  String get pathLevelUp;

  /// No description provided for @pathFinalTest.
  ///
  /// In tr, this message translates to:
  /// **'FİNAL TESTİ'**
  String get pathFinalTest;

  /// No description provided for @pathLessonNumber.
  ///
  /// In tr, this message translates to:
  /// **'DERS {number}'**
  String pathLessonNumber(int number);

  /// No description provided for @pathUnknownLesson.
  ///
  /// In tr, this message translates to:
  /// **'Bilinmeyen Ders'**
  String get pathUnknownLesson;

  /// No description provided for @pathSectionFallback.
  ///
  /// In tr, this message translates to:
  /// **'Bölüm'**
  String get pathSectionFallback;

  /// No description provided for @pathExam.
  ///
  /// In tr, this message translates to:
  /// **'Sınav'**
  String get pathExam;

  /// No description provided for @pathNext.
  ///
  /// In tr, this message translates to:
  /// **'Sıradaki'**
  String get pathNext;

  /// No description provided for @pathLockedMessage.
  ///
  /// In tr, this message translates to:
  /// **'Bu adım henüz kilitli! Öncekileri tamamla.'**
  String get pathLockedMessage;

  /// No description provided for @pathOldFinalMessage.
  ///
  /// In tr, this message translates to:
  /// **'Bu final sınavı zaten tamamlandı. Eski seviyelerde sadece pratik yapabilirsin.'**
  String get pathOldFinalMessage;

  /// No description provided for @pathWelcomeNewLevel.
  ///
  /// In tr, this message translates to:
  /// **'Yepyeni bir seviyeye hoş geldin! 🎉'**
  String get pathWelcomeNewLevel;

  /// No description provided for @pathLoadError.
  ///
  /// In tr, this message translates to:
  /// **'Harita yüklenirken hata oluştu: {error}'**
  String pathLoadError(String error);

  /// No description provided for @finalTestTitle.
  ///
  /// In tr, this message translates to:
  /// **'FİNAL SINAVI 🚀'**
  String get finalTestTitle;

  /// No description provided for @finalTestLoading.
  ///
  /// In tr, this message translates to:
  /// **'Final sınavın hazırlanıyor...'**
  String get finalTestLoading;

  /// No description provided for @finalTestLoadFailed.
  ///
  /// In tr, this message translates to:
  /// **'Final sınavı yüklenemedi.'**
  String get finalTestLoadFailed;

  /// No description provided for @finalTestNoQuestions.
  ///
  /// In tr, this message translates to:
  /// **'Bu sınav için soru bulunamadı.'**
  String get finalTestNoQuestions;

  /// No description provided for @finalTestRetry.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar Dene'**
  String get finalTestRetry;

  /// No description provided for @finalTestQuestionCounter.
  ///
  /// In tr, this message translates to:
  /// **'Soru {current} / {total}'**
  String finalTestQuestionCounter(int current, int total);

  /// No description provided for @finalTestAnswer.
  ///
  /// In tr, this message translates to:
  /// **'Cevapla'**
  String get finalTestAnswer;

  /// No description provided for @finalTestCorrect.
  ///
  /// In tr, this message translates to:
  /// **'✅ Doğru!'**
  String get finalTestCorrect;

  /// No description provided for @finalTestWrong.
  ///
  /// In tr, this message translates to:
  /// **'❌ Yanlış!'**
  String get finalTestWrong;

  /// No description provided for @finalTestFillBlank.
  ///
  /// In tr, this message translates to:
  /// **'Boşluğu Doldur'**
  String get finalTestFillBlank;

  /// No description provided for @finalTestBuildSentence.
  ///
  /// In tr, this message translates to:
  /// **'Cümleyi Kur'**
  String get finalTestBuildSentence;

  /// No description provided for @finalTestListenAndWrite.
  ///
  /// In tr, this message translates to:
  /// **'Duyduğunu Yaz'**
  String get finalTestListenAndWrite;

  /// No description provided for @finalTestReadAloud.
  ///
  /// In tr, this message translates to:
  /// **'Yüksek Sesle Oku'**
  String get finalTestReadAloud;

  /// No description provided for @finalTestAnswerHint.
  ///
  /// In tr, this message translates to:
  /// **'Cevabını yaz...'**
  String get finalTestAnswerHint;

  /// No description provided for @finalTestWriteInLanguage.
  ///
  /// In tr, this message translates to:
  /// **'{language} dilinde yaz...'**
  String finalTestWriteInLanguage(String language);

  /// No description provided for @finalTestMicrophoneHint.
  ///
  /// In tr, this message translates to:
  /// **'Mikrofona bas...'**
  String get finalTestMicrophoneHint;

  /// No description provided for @finalTestListening.
  ///
  /// In tr, this message translates to:
  /// **'Dinleniyor...'**
  String get finalTestListening;

  /// No description provided for @finalTestCongratulations.
  ///
  /// In tr, this message translates to:
  /// **'TEBRİKLER!'**
  String get finalTestCongratulations;

  /// No description provided for @finalTestFailedTitle.
  ///
  /// In tr, this message translates to:
  /// **'SINAVI GEÇEMEDİN'**
  String get finalTestFailedTitle;

  /// No description provided for @finalTestScore.
  ///
  /// In tr, this message translates to:
  /// **'Puanın: {score} / 100'**
  String finalTestScore(int score);

  /// No description provided for @finalTestPassedMessage.
  ///
  /// In tr, this message translates to:
  /// **'Harika iş çıkardın! Yeni dersin kilidi açıldı.'**
  String get finalTestPassedMessage;

  /// No description provided for @finalTestFailedMessage.
  ///
  /// In tr, this message translates to:
  /// **'70 puanı geçemedin. Eksiklerini kapatıp tekrar denemelisin.'**
  String get finalTestFailedMessage;

  /// No description provided for @finalTestNextLesson.
  ///
  /// In tr, this message translates to:
  /// **'Sonraki Derse Geç 🚀'**
  String get finalTestNextLesson;

  /// No description provided for @finalTestBackToMap.
  ///
  /// In tr, this message translates to:
  /// **'Haritaya Dön'**
  String get finalTestBackToMap;

  /// No description provided for @profileTitle.
  ///
  /// In tr, this message translates to:
  /// **'Profilim'**
  String get profileTitle;

  /// No description provided for @profileLanguageLevel.
  ///
  /// In tr, this message translates to:
  /// **'{language} • {level} Seviyesi'**
  String profileLanguageLevel(String language, String level);

  /// No description provided for @profileTotalXp.
  ///
  /// In tr, this message translates to:
  /// **'Toplam XP'**
  String get profileTotalXp;

  /// No description provided for @profileRemainingLives.
  ///
  /// In tr, this message translates to:
  /// **'Kalan Can'**
  String get profileRemainingLives;

  /// No description provided for @profileProgress.
  ///
  /// In tr, this message translates to:
  /// **'İlerleme'**
  String get profileProgress;

  /// No description provided for @profileProgressValue.
  ///
  /// In tr, this message translates to:
  /// **'Böl. {section} • Ders {lesson}'**
  String profileProgressValue(int section, int lesson);

  /// No description provided for @profileDayStreak.
  ///
  /// In tr, this message translates to:
  /// **'Gün Serisi'**
  String get profileDayStreak;

  /// No description provided for @profileDayCount.
  ///
  /// In tr, this message translates to:
  /// **'{count} Gün'**
  String profileDayCount(int count);

  /// No description provided for @profileWeeklyXpAnalysis.
  ///
  /// In tr, this message translates to:
  /// **'Haftalık XP Analizi'**
  String get profileWeeklyXpAnalysis;

  /// No description provided for @profileMondayShort.
  ///
  /// In tr, this message translates to:
  /// **'Pzt'**
  String get profileMondayShort;

  /// No description provided for @profileTuesdayShort.
  ///
  /// In tr, this message translates to:
  /// **'Sal'**
  String get profileTuesdayShort;

  /// No description provided for @profileWednesdayShort.
  ///
  /// In tr, this message translates to:
  /// **'Çar'**
  String get profileWednesdayShort;

  /// No description provided for @profileThursdayShort.
  ///
  /// In tr, this message translates to:
  /// **'Per'**
  String get profileThursdayShort;

  /// No description provided for @profileFridayShort.
  ///
  /// In tr, this message translates to:
  /// **'Cum'**
  String get profileFridayShort;

  /// No description provided for @profileSaturdayShort.
  ///
  /// In tr, this message translates to:
  /// **'Cmt'**
  String get profileSaturdayShort;

  /// No description provided for @profileSundayShort.
  ///
  /// In tr, this message translates to:
  /// **'Paz'**
  String get profileSundayShort;

  /// No description provided for @profileLearningCenter.
  ///
  /// In tr, this message translates to:
  /// **'Öğrenme Merkezi'**
  String get profileLearningCenter;

  /// No description provided for @profileWordBank.
  ///
  /// In tr, this message translates to:
  /// **'Kelime Kumbaram'**
  String get profileWordBank;

  /// No description provided for @profileDailyTraining.
  ///
  /// In tr, this message translates to:
  /// **'Günlük Antrenman'**
  String get profileDailyTraining;

  /// No description provided for @profileDailyQuestions.
  ///
  /// In tr, this message translates to:
  /// **'Bugün seni bekleyen {count} özel soru var!'**
  String profileDailyQuestions(int count);

  /// No description provided for @profileWordTraining.
  ///
  /// In tr, this message translates to:
  /// **'Kelime Antrenmanı'**
  String get profileWordTraining;

  /// No description provided for @profileUnlearnedWords.
  ///
  /// In tr, this message translates to:
  /// **'Öğrenilmeyi bekleyen {count} kelime var'**
  String profileUnlearnedWords(int count);

  /// No description provided for @profileStatsLoadFailed.
  ///
  /// In tr, this message translates to:
  /// **'Profil istatistikleri yüklenemedi.'**
  String get profileStatsLoadFailed;

  /// No description provided for @speedReadingFinishedTitle.
  ///
  /// In tr, this message translates to:
  /// **'Harika Okudun!'**
  String get speedReadingFinishedTitle;

  /// No description provided for @speedReadingFinishedSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Şimdi anladıklarını test etme zamanı.'**
  String get speedReadingFinishedSubtitle;

  /// No description provided for @speedReadingStartQuiz.
  ///
  /// In tr, this message translates to:
  /// **'Quiz\'e Başla!'**
  String get speedReadingStartQuiz;

  /// No description provided for @speedQuizNoQuestions.
  ///
  /// In tr, this message translates to:
  /// **'Soru bulunamadı.'**
  String get speedQuizNoQuestions;

  /// No description provided for @speedQuizQuestionCounter.
  ///
  /// In tr, this message translates to:
  /// **'Soru {current} / {total}'**
  String speedQuizQuestionCounter(int current, int total);

  /// No description provided for @speedQuizShowTranslation.
  ///
  /// In tr, this message translates to:
  /// **'Çeviriyi Göster'**
  String get speedQuizShowTranslation;

  /// No description provided for @speedQuizCheckAnswer.
  ///
  /// In tr, this message translates to:
  /// **'Kontrol Et ✔️'**
  String get speedQuizCheckAnswer;

  /// No description provided for @speedQuizNextQuestion.
  ///
  /// In tr, this message translates to:
  /// **'Sıradaki Soru ➡️'**
  String get speedQuizNextQuestion;

  /// No description provided for @speedQuizLevelUpTitle.
  ///
  /// In tr, this message translates to:
  /// **'Seviye Atladın!'**
  String get speedQuizLevelUpTitle;

  /// No description provided for @speedQuizCongratulations.
  ///
  /// In tr, this message translates to:
  /// **'Tebrikler!'**
  String get speedQuizCongratulations;

  /// No description provided for @speedQuizLevelUpMessage.
  ///
  /// In tr, this message translates to:
  /// **'Harika performans! Yeni seviyenin kilidi açıldı.'**
  String get speedQuizLevelUpMessage;

  /// No description provided for @speedQuizCompletedMessage.
  ///
  /// In tr, this message translates to:
  /// **'Hızlı quizi başarıyla tamamladın.'**
  String get speedQuizCompletedMessage;

  /// No description provided for @speedQuizCorrectAnswers.
  ///
  /// In tr, this message translates to:
  /// **'Doğru'**
  String get speedQuizCorrectAnswers;

  /// No description provided for @speedQuizXp.
  ///
  /// In tr, this message translates to:
  /// **'XP'**
  String get speedQuizXp;

  /// No description provided for @speedQuizContinue.
  ///
  /// In tr, this message translates to:
  /// **'Devam Et'**
  String get speedQuizContinue;

  /// No description provided for @practiceScreenTitle.
  ///
  /// In tr, this message translates to:
  /// **'Zayıf Noktaları Çalış'**
  String get practiceScreenTitle;

  /// No description provided for @practiceUnknownQuestion.
  ///
  /// In tr, this message translates to:
  /// **'Bilinmeyen Soru'**
  String get practiceUnknownQuestion;

  /// No description provided for @practiceQuestionInfo.
  ///
  /// In tr, this message translates to:
  /// **'Soru Tipi: {type} | Hata: {count} kez'**
  String practiceQuestionInfo(String type, int count);

  /// No description provided for @practiceSolve.
  ///
  /// In tr, this message translates to:
  /// **'Çöz'**
  String get practiceSolve;

  /// No description provided for @practiceInvalidQuestion.
  ///
  /// In tr, this message translates to:
  /// **'Bu soru geçersiz veya eski bir kayıt.'**
  String get practiceInvalidQuestion;

  /// No description provided for @practiceUnknownPuzzleType.
  ///
  /// In tr, this message translates to:
  /// **'Bilinmeyen soru tipi: {type}'**
  String practiceUnknownPuzzleType(String type);

  /// No description provided for @practiceBlankTitle.
  ///
  /// In tr, this message translates to:
  /// **'Pratik: Boşluk Doldurma'**
  String get practiceBlankTitle;

  /// No description provided for @practiceSentenceTitle.
  ///
  /// In tr, this message translates to:
  /// **'Pratik: Cümle Kur'**
  String get practiceSentenceTitle;

  /// No description provided for @practiceTypeBlank.
  ///
  /// In tr, this message translates to:
  /// **'Boşluk Doldurma'**
  String get practiceTypeBlank;

  /// No description provided for @practiceTypeSentence.
  ///
  /// In tr, this message translates to:
  /// **'Cümle Kurma'**
  String get practiceTypeSentence;

  /// No description provided for @practiceTypeMinimalPair.
  ///
  /// In tr, this message translates to:
  /// **'Ses Çiftleri'**
  String get practiceTypeMinimalPair;

  /// No description provided for @practiceTypeUnknown.
  ///
  /// In tr, this message translates to:
  /// **'Bilinmeyen'**
  String get practiceTypeUnknown;

  /// No description provided for @practiceEmptyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Harika İş Çıkardın!'**
  String get practiceEmptyTitle;

  /// No description provided for @practiceEmptyMessage.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar etmen gereken hiçbir hatan yok.'**
  String get practiceEmptyMessage;

  /// No description provided for @flashcardPracticeTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kelime Antrenmanı'**
  String get flashcardPracticeTitle;

  /// No description provided for @flashcardPracticeCounter.
  ///
  /// In tr, this message translates to:
  /// **'Kelime {current} / {total}'**
  String flashcardPracticeCounter(int current, int total);

  /// No description provided for @flashcardPracticeReviewAgain.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar Sor'**
  String get flashcardPracticeReviewAgain;

  /// No description provided for @flashcardPracticeLearned.
  ///
  /// In tr, this message translates to:
  /// **'Öğrendim!'**
  String get flashcardPracticeLearned;

  /// No description provided for @flashcardPracticeTapToTranslate.
  ///
  /// In tr, this message translates to:
  /// **'Çevirmek için karta dokun'**
  String get flashcardPracticeTapToTranslate;

  /// No description provided for @flashcardPracticeNativeTranslation.
  ///
  /// In tr, this message translates to:
  /// **'ANA DİL ÇEVİRİSİ'**
  String get flashcardPracticeNativeTranslation;

  /// No description provided for @flashcardPracticeDoneTitle.
  ///
  /// In tr, this message translates to:
  /// **'Harika İş Çıkardın!'**
  String get flashcardPracticeDoneTitle;

  /// No description provided for @flashcardPracticeDoneMessage.
  ///
  /// In tr, this message translates to:
  /// **'Bugün için ayrılan tüm yeni kelimeleri tekrar ettin. Profiline dönüp istatistiklerini kontrol edebilirsin.'**
  String get flashcardPracticeDoneMessage;

  /// No description provided for @flashcardPracticeBackToProfile.
  ///
  /// In tr, this message translates to:
  /// **'Profile Dön'**
  String get flashcardPracticeBackToProfile;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
