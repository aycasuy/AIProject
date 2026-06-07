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
