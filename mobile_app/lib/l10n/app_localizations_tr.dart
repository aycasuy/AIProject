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

  @override
  String get placementLoading => 'Yapay Zeka Sınavını Hazırlıyor...';

  @override
  String placementQuestion(int current, int total) {
    return 'Soru $current/$total';
  }

  @override
  String get placementNext => 'Sonraki Soru';

  @override
  String get placementFinishedTitle => 'Sınav Tamamlandı!';

  @override
  String placementFinishedBody(String level) {
    return 'Harika iş çıkardın.\n\nBelirlenen Seviyen: $level';
  }

  @override
  String get placementBackToMenu => 'Ana Menüye Dön';

  @override
  String get placementListenButton => 'Dinle';

  @override
  String get placementStopButton => 'Durdur';

  @override
  String get placementListenInstruction => 'Metni dinlemek için butona bas';

  @override
  String get placementNoQuestion => 'Soru bulunamadı.';

  @override
  String get learnHintTitle => 'Sana Bir İpucu!';

  @override
  String learnHintContent(String firstLetter, int length) {
    return 'Cevap \'$firstLetter\' harfi ile başlıyor...\nVe tam $length karakter uzunluğunda!';
  }

  @override
  String get learnHintThanks => 'Teşekkürler!';

  @override
  String get learnHintBubble => 'İpucu?';

  @override
  String learnCorrectAnswer(String answer) {
    return 'Doğru Cevap: $answer';
  }

  @override
  String learnGenericError(String error) {
    return 'Hata: $error';
  }

  @override
  String get learnNoCards => 'Bu derste henüz kart bulunmuyor.';

  @override
  String get learnGreatJob => 'Harika İş!';

  @override
  String get learnDeckCompleted => 'Kelime destesini tamamladın.';

  @override
  String learnWordsAddedToVocabulary(int count) {
    return '$count kelime \'Kelime Defteri\'ne eklendi. 📚';
  }

  @override
  String get learnBackToMap => 'Haritaya Dön';

  @override
  String get learnSwipeInstruction =>
      'Öğrendiysen Sağa 👉  |  👈 Tekrar için Sola';

  @override
  String get learnTapToSeeTranslation => 'Çeviriyi görmek için dokun';

  @override
  String get learnQuestionsCouldNotLoad =>
      'Sorular yüklenemedi. İnternetinizi kontrol edin.';

  @override
  String get learnNoBlankQuestions =>
      'Bu derste henüz boşluk doldurma sorusu yok.';

  @override
  String get learnNoSentenceQuestions =>
      'Bu derste henüz cümle kurma sorusu yok.';

  @override
  String get learnNewQuestionsComing =>
      'Yeni sorular eklendiğinde burada görünecek.';

  @override
  String get learnGameOverTitle => 'Hakların Doldu!';

  @override
  String get learnGameOverBlankMessage =>
      'Biraz dinlen, canların yenilenince boşluk doldurmaya tekrar devam edebilirsin.';

  @override
  String get learnGameOverOrderMessage =>
      'Biraz dinlen, canların yenilenince tekrar devam edebilirsin.';

  @override
  String learnNewLife(String time) {
    return 'Yeni can: $time';
  }

  @override
  String get learnRefillLives => '300 XP ile Canları Fulle';

  @override
  String get learnLivesRefilled => 'Canlar Fullendi! Maceraya Devam 🚀';

  @override
  String get learnPerfectTitle => 'Mükemmel!';

  @override
  String get learnBlankCompleted =>
      'Tüm boşluk doldurma sorularını tamamladın.';

  @override
  String get learnOrderCompleted =>
      'Cümle kurma görevini başarıyla tamamladın.';

  @override
  String get learnBlankTitle => 'Boşluk Doldurma';

  @override
  String get learnSentenceOrderTitle => 'Cümle Kurma';

  @override
  String learnQuestionCounter(int current, int total) {
    return '$current / $total soru';
  }

  @override
  String get learnCompleteMissingWord => 'Eksik kelimeyi tamamla';

  @override
  String get learnAnswerInputHint => 'Cevabını buraya yaz...';

  @override
  String get learnWrongWordError =>
      'Yanlış kelime, bir can gitti. Tekrar dene.';

  @override
  String get learnStuckHintText => 'Takılırsan ipucu alabilirsin.';

  @override
  String get learnGetHint => 'İpucu al';

  @override
  String get learnCheckAnswer => 'Kontrol Et ✨';

  @override
  String get learnSkipBlank => 'Boşluğu dolduramadım, pas geç';

  @override
  String get learnSkipOrder => 'Cümleyi kuramadım, pas geç';

  @override
  String learnTranslateFromNative(String language) {
    return '$language dilinden çevir';
  }

  @override
  String get learnBuildSentence => 'Cümleni oluştur';

  @override
  String get learnTapWordsToBuildSentence => 'Kelimelere dokunarak cümleyi kur';

  @override
  String get learnWords => 'Kelimeler';

  @override
  String get learnTapAndOrder => 'Dokun ve sırala';

  @override
  String get learnWeakPointHunterTitle => 'Zayıf Nokta Avcısı';

  @override
  String get learnWeakPointHunterDescription =>
      'Yapay zeka, geçmişte hata yaptığın kelimeleri analiz ederek sana özel, zamana karşı bir okuma testi hazırlayacak. Meydan okumaya hazır mısın?';

  @override
  String get learnChallengeButton => 'Meydan Oku!';

  @override
  String get learnModuleNotFound => 'Modül bulunamadı.';

  @override
  String get minimalPairsTitle => 'Telaffuz & Ses Çiftleri';

  @override
  String get minimalPairsNoPairs => 'Bu ders için ses çifti bulunamadı.';

  @override
  String minimalPairsStep(int current, int total) {
    return 'Adım $current / $total';
  }

  @override
  String get minimalPairsListenDifference => 'Aralarındaki farkı dinle';

  @override
  String get minimalPairsSayNow => 'Şimdi sen söyle:';

  @override
  String get minimalPairsAnalyzing => 'Analiz ediliyor... 🤖';

  @override
  String get minimalPairsConnectionRetry =>
      'Bağlantı hatası, tekrar dener misin?';

  @override
  String get minimalPairsNoVoice => 'Sesini alamadım.';

  @override
  String get minimalPairsGreatPronunciation => 'Harika telaffuz! 🎯';

  @override
  String get minimalPairsPerfectPronunciation => 'Harika! Kusursuz telaffuz.';

  @override
  String get minimalPairsCoachNote => 'Koçun Notu:';

  @override
  String get minimalPairsHoldToSpeak => 'Konuşmak için basılı tut';

  @override
  String get minimalPairsSkip => 'Söyleyemedim, pas geç 🤔';

  @override
  String get minimalPairsContinue => 'DEVAM ET';

  @override
  String get minimalPairsAddedPractice =>
      'Kelime pratik listene eklendi! 📚 (1 Can gitti)';

  @override
  String get minimalPairsGameOverMessage =>
      'Üzgünüm, telaffuz pratiğinde çok hata yaptın. 300 XP harcayarak canlarını fulleyebilir veya haritaya dönebilirsin.';

  @override
  String get pronunciationCoachTitle => 'Telaffuz Koçu 🎙️';

  @override
  String get pronunciationInitialPrompt => 'Mikrofona bas ve okumaya başla...';

  @override
  String get pronunciationPreparingText =>
      'Yapay zeka senin için uygun bir metin hazırlıyor... ⏳';

  @override
  String get pronunciationNoText =>
      'Bu ders için uygun telaffuz metni bulunamadı.';

  @override
  String get pronunciationConnectionError =>
      'Bağlantı hatası! Lütfen internetini kontrol et.';

  @override
  String pronunciationRound(int current, int total) {
    return 'Metin $current / $total';
  }

  @override
  String get pronunciationReadClearly => 'Cümleyi net ve sakin oku';

  @override
  String get pronunciationReadSentence => 'Aşağıdaki cümleyi oku';

  @override
  String get pronunciationStop => 'Durdur';

  @override
  String get pronunciationListenFirst => 'Önce Dinle';

  @override
  String get pronunciationListening => 'Dinliyorum...';

  @override
  String get pronunciationTranscriptHint =>
      'Mikrofona basınca söylediklerin burada görünecek.';

  @override
  String get pronunciationWaitingForSpeech => 'Konuşman Bekleniyor';

  @override
  String get pronunciationAnalyze => 'Analiz Et';

  @override
  String get pronunciationTaskPreparing => 'Telaffuz görevin hazırlanıyor...';

  @override
  String get pronunciationGameOverMessage =>
      'Biraz bekle, yeni can geldiğinde devam edebilirsin.';

  @override
  String get pronunciationSuccessTitle => 'Harika Konuştun!';

  @override
  String get pronunciationSuccessMessage =>
      'Tüm telaffuz görevlerini tamamladın.';

  @override
  String get pronunciationSuccessful => 'Başarılı Telaffuz';

  @override
  String get pronunciationTryAgain => 'Tekrar Deneyelim';

  @override
  String get pronunciationScoreUnit => 'puan';

  @override
  String pronunciationXpEarned(int xp) {
    return '+$xp XP Kazandın!';
  }

  @override
  String get pronunciationLifeLost => '1 Can Gitti! Tekrar Dene.';

  @override
  String get pronunciationWordsToWatch => 'Dikkat etmen gereken kelimeler:';

  @override
  String get pronunciationNextText => 'Sıradaki Metin 🚀';

  @override
  String get pronunciationAmazing => 'Muhteşem! 🚀';

  @override
  String get pronunciationRetry => 'Tekrar Dene 🔄';

  @override
  String get listeningCoachTitle => 'Dinleme Koçu 🎧';

  @override
  String listeningRound(int current, int total) {
    return 'Metin $current / $total';
  }

  @override
  String get listeningWriteAndCheck => 'Duyduğunu yaz ve kontrol et';

  @override
  String get listeningListenFirst => 'Önce sesi dinle';

  @override
  String get listeningInstruction => 'Robotu dinle ve duyduğunu yaz';

  @override
  String get listeningPlaying => 'Dinleniyor...';

  @override
  String get listeningPlayAudio => 'Sesi Çal';

  @override
  String get listeningInputLockedInfo =>
      'Sesi çaldıktan sonra yazma alanı açılacak.';

  @override
  String get listeningWriteWhatYouHear => 'Duyduklarını yaz';

  @override
  String get listeningReplay => 'Tekrar dinle';

  @override
  String get listeningInputHint => 'Duyduğun cümleyi buraya yaz...';

  @override
  String get listeningCheck => 'Kontrol Et 🎯';

  @override
  String get listeningTextLoadFailed => 'Dinleme metni yüklenemedi.';

  @override
  String get listeningCheckConnection =>
      'Bağlantını kontrol edip tekrar deneyebilirsin.';

  @override
  String get listeningRetryLoad => 'Tekrar Dene';

  @override
  String get listeningGameOverMessage =>
      'Biraz dinlen, canların yenilenince dinleme görevine tekrar devam edebilirsin.';

  @override
  String get listeningSuccessTitle => 'Kulağın Çok İyi!';

  @override
  String get listeningSuccessMessage =>
      'Tüm dinleme görevlerini başarıyla tamamladın.';

  @override
  String get listeningEvaluationCompleted => 'Değerlendirme tamamlandı.';

  @override
  String get listeningSuccessResult => 'Harika dinledin!';

  @override
  String get listeningTryAgainResult => 'Bir kez daha deneyelim';

  @override
  String listeningXpEarned(int xp) {
    return '+$xp XP Kazandın!';
  }

  @override
  String get listeningLifeLost => '1 Can Gitti';

  @override
  String get listeningMissedWords =>
      'Kaçırdığın veya yanlış yazdığın kelimeler:';

  @override
  String get listeningNextText => 'Sıradaki Metin 🚀';

  @override
  String get listeningAmazing => 'Muhteşem! 🚀';

  @override
  String get listeningTryAgainButton => 'Tekrar Dene 🔄';

  @override
  String get pathVisualLearning => 'Görsel Öğrenim';

  @override
  String get pathFillBlank => 'Boşluk Doldurma';

  @override
  String get pathSentenceOrder => 'Cümle Kurma';

  @override
  String get pathQuickQuiz => 'Hızlı Quiz';

  @override
  String get pathMinimalPairs => 'Ses Çiftleri';

  @override
  String get pathPronunciation => 'Telaffuz';

  @override
  String get pathListening => 'Dinleme';

  @override
  String get pathTest => 'Test';

  @override
  String get pathLevelUp => 'SEVİYE ATLA';

  @override
  String get pathFinalTest => 'FİNAL TESTİ';

  @override
  String pathLessonNumber(int number) {
    return 'DERS $number';
  }

  @override
  String get pathUnknownLesson => 'Bilinmeyen Ders';

  @override
  String get pathSectionFallback => 'Bölüm';

  @override
  String get pathExam => 'Sınav';

  @override
  String get pathNext => 'Sıradaki';

  @override
  String get pathLockedMessage => 'Bu adım henüz kilitli! Öncekileri tamamla.';

  @override
  String get pathOldFinalMessage =>
      'Bu final sınavı zaten tamamlandı. Eski seviyelerde sadece pratik yapabilirsin.';

  @override
  String get pathWelcomeNewLevel => 'Yepyeni bir seviyeye hoş geldin! 🎉';

  @override
  String pathLoadError(String error) {
    return 'Harita yüklenirken hata oluştu: $error';
  }

  @override
  String get finalTestTitle => 'FİNAL SINAVI 🚀';

  @override
  String get finalTestLoading => 'Final sınavın hazırlanıyor...';

  @override
  String get finalTestLoadFailed => 'Final sınavı yüklenemedi.';

  @override
  String get finalTestNoQuestions => 'Bu sınav için soru bulunamadı.';

  @override
  String get finalTestRetry => 'Tekrar Dene';

  @override
  String finalTestQuestionCounter(int current, int total) {
    return 'Soru $current / $total';
  }

  @override
  String get finalTestAnswer => 'Cevapla';

  @override
  String get finalTestCorrect => '✅ Doğru!';

  @override
  String get finalTestWrong => '❌ Yanlış!';

  @override
  String get finalTestFillBlank => 'Boşluğu Doldur';

  @override
  String get finalTestBuildSentence => 'Cümleyi Kur';

  @override
  String get finalTestListenAndWrite => 'Duyduğunu Yaz';

  @override
  String get finalTestReadAloud => 'Yüksek Sesle Oku';

  @override
  String get finalTestAnswerHint => 'Cevabını yaz...';

  @override
  String finalTestWriteInLanguage(String language) {
    return '$language dilinde yaz...';
  }

  @override
  String get finalTestMicrophoneHint => 'Mikrofona bas...';

  @override
  String get finalTestListening => 'Dinleniyor...';

  @override
  String get finalTestCongratulations => 'TEBRİKLER!';

  @override
  String get finalTestFailedTitle => 'SINAVI GEÇEMEDİN';

  @override
  String finalTestScore(int score) {
    return 'Puanın: $score / 100';
  }

  @override
  String get finalTestPassedMessage =>
      'Harika iş çıkardın! Yeni dersin kilidi açıldı.';

  @override
  String get finalTestFailedMessage =>
      '70 puanı geçemedin. Eksiklerini kapatıp tekrar denemelisin.';

  @override
  String get finalTestNextLesson => 'Sonraki Derse Geç 🚀';

  @override
  String get finalTestBackToMap => 'Haritaya Dön';

  @override
  String get profileTitle => 'Profilim';

  @override
  String profileLanguageLevel(String language, String level) {
    return '$language • $level Seviyesi';
  }

  @override
  String get profileTotalXp => 'Toplam XP';

  @override
  String get profileRemainingLives => 'Kalan Can';

  @override
  String get profileProgress => 'İlerleme';

  @override
  String profileProgressValue(int section, int lesson) {
    return 'Böl. $section • Ders $lesson';
  }

  @override
  String get profileDayStreak => 'Gün Serisi';

  @override
  String profileDayCount(int count) {
    return '$count Gün';
  }

  @override
  String get profileWeeklyXpAnalysis => 'Haftalık XP Analizi';

  @override
  String get profileMondayShort => 'Pzt';

  @override
  String get profileTuesdayShort => 'Sal';

  @override
  String get profileWednesdayShort => 'Çar';

  @override
  String get profileThursdayShort => 'Per';

  @override
  String get profileFridayShort => 'Cum';

  @override
  String get profileSaturdayShort => 'Cmt';

  @override
  String get profileSundayShort => 'Paz';

  @override
  String get profileLearningCenter => 'Öğrenme Merkezi';

  @override
  String get profileWordBank => 'Kelime Kumbaram';

  @override
  String get profileDailyTraining => 'Günlük Antrenman';

  @override
  String profileDailyQuestions(int count) {
    return 'Bugün seni bekleyen $count özel soru var!';
  }

  @override
  String get profileWordTraining => 'Kelime Antrenmanı';

  @override
  String profileUnlearnedWords(int count) {
    return 'Öğrenilmeyi bekleyen $count kelime var';
  }

  @override
  String get profileStatsLoadFailed => 'Profil istatistikleri yüklenemedi.';

  @override
  String get speedReadingFinishedTitle => 'Harika Okudun!';

  @override
  String get speedReadingFinishedSubtitle =>
      'Şimdi anladıklarını test etme zamanı.';

  @override
  String get speedReadingStartQuiz => 'Quiz\'e Başla!';

  @override
  String get speedQuizNoQuestions => 'Soru bulunamadı.';

  @override
  String speedQuizQuestionCounter(int current, int total) {
    return 'Soru $current / $total';
  }

  @override
  String get speedQuizShowTranslation => 'Çeviriyi Göster';

  @override
  String get speedQuizCheckAnswer => 'Kontrol Et ✔️';

  @override
  String get speedQuizNextQuestion => 'Sıradaki Soru ➡️';

  @override
  String get speedQuizLevelUpTitle => 'Seviye Atladın!';

  @override
  String get speedQuizCongratulations => 'Tebrikler!';

  @override
  String get speedQuizLevelUpMessage =>
      'Harika performans! Yeni seviyenin kilidi açıldı.';

  @override
  String get speedQuizCompletedMessage => 'Hızlı quizi başarıyla tamamladın.';

  @override
  String get speedQuizCorrectAnswers => 'Doğru';

  @override
  String get speedQuizXp => 'XP';

  @override
  String get speedQuizContinue => 'Devam Et';

  @override
  String get practiceScreenTitle => 'Zayıf Noktaları Çalış';

  @override
  String get practiceUnknownQuestion => 'Bilinmeyen Soru';

  @override
  String practiceQuestionInfo(String type, int count) {
    return 'Soru Tipi: $type | Hata: $count kez';
  }

  @override
  String get practiceSolve => 'Çöz';

  @override
  String get practiceInvalidQuestion => 'Bu soru geçersiz veya eski bir kayıt.';

  @override
  String practiceUnknownPuzzleType(String type) {
    return 'Bilinmeyen soru tipi: $type';
  }

  @override
  String get practiceBlankTitle => 'Pratik: Boşluk Doldurma';

  @override
  String get practiceSentenceTitle => 'Pratik: Cümle Kur';

  @override
  String get practiceTypeBlank => 'Boşluk Doldurma';

  @override
  String get practiceTypeSentence => 'Cümle Kurma';

  @override
  String get practiceTypeMinimalPair => 'Ses Çiftleri';

  @override
  String get practiceTypeUnknown => 'Bilinmeyen';

  @override
  String get practiceEmptyTitle => 'Harika İş Çıkardın!';

  @override
  String get practiceEmptyMessage => 'Tekrar etmen gereken hiçbir hatan yok.';

  @override
  String get flashcardPracticeTitle => 'Kelime Antrenmanı';

  @override
  String flashcardPracticeCounter(int current, int total) {
    return 'Kelime $current / $total';
  }

  @override
  String get flashcardPracticeReviewAgain => 'Tekrar Sor';

  @override
  String get flashcardPracticeLearned => 'Öğrendim!';

  @override
  String get flashcardPracticeTapToTranslate => 'Çevirmek için karta dokun';

  @override
  String get flashcardPracticeNativeTranslation => 'ANA DİL ÇEVİRİSİ';

  @override
  String get flashcardPracticeDoneTitle => 'Harika İş Çıkardın!';

  @override
  String get flashcardPracticeDoneMessage =>
      'Bugün için ayrılan tüm yeni kelimeleri tekrar ettin. Profiline dönüp istatistiklerini kontrol edebilirsin.';

  @override
  String get flashcardPracticeBackToProfile => 'Profile Dön';

  @override
  String get wordHuntTitle => 'Kelime Avı';

  @override
  String get wordHuntIntroTitle => 'Metnini yapıştır, kelimeleri yakalayalım!';

  @override
  String get wordHuntIntroDescription =>
      'Zor kelimeleri analiz et, seviyesini gör ve istersen metinden test çöz.';

  @override
  String get wordHuntTextReady => 'Metin hazır';

  @override
  String get wordHuntTextField => 'Metin alanı';

  @override
  String get wordHuntClear => 'Temizle';

  @override
  String wordHuntPasteHint(String language) {
    return '$language metnini buraya yapıştır...';
  }

  @override
  String wordHuntWordCount(int count) {
    return '$count kelime';
  }

  @override
  String get wordHuntAnalysisPending => 'Analiz bekleniyor';

  @override
  String wordHuntLevel(String level) {
    return 'Seviye: $level';
  }

  @override
  String get wordHuntAnalysisCompleted => 'Analiz tamamlandı';

  @override
  String wordHuntHighlightedWords(int count) {
    return '$count kelime vurgulandı';
  }

  @override
  String get wordHuntTapColoredWords => 'Renkli kelimelere dokun';

  @override
  String get wordHuntAnalyzeButton => 'Kelimeleri Analiz Et';

  @override
  String get wordHuntQuizButton => 'Bu Metinle Test Çöz';

  @override
  String get wordHuntExampleUsage => 'Örnek kullanım';

  @override
  String get wordHuntAddToBank => 'Kumbarama Ekle';

  @override
  String get wordHuntAddedToBank => 'Kelime kumbaraya eklendi! 🚀';

  @override
  String get wordHuntAnalyzeEmpty =>
      'Analiz için önce bir metin yapıştırmalısın. 📝';

  @override
  String wordHuntAnalyzeFailed(int status) {
    return 'Analiz başarısız oldu: $status';
  }

  @override
  String wordHuntConnectionError(String error) {
    return 'Sunucuya bağlanılamadı: $error';
  }

  @override
  String get wordHuntQuizEmpty =>
      'Test çözmek için önce kutuya metin yapıştırmalısın. 📝';

  @override
  String get wordHuntQuizGenerationFailed =>
      'Yapay zeka bu metinden soru üretemedi. Daha uzun bir metin dene! 📝';

  @override
  String wordHuntQuizCreateFailed(int status) {
    return 'Sınav oluşturulamadı: $status';
  }

  @override
  String get wordHuntQuizTitle => 'Kelime Avı Testi';

  @override
  String get wordHuntOriginalTextTitle => 'Orijinal Metin';

  @override
  String get wordHuntOriginalTextSubtitle =>
      'Soruları çözerken metne tekrar bakabilirsin.';

  @override
  String get wordHuntOriginalTextMissing =>
      'Bu test için gösterilecek metin bulunamadı.';

  @override
  String wordHuntQuestionNumber(int current) {
    return 'Soru $current';
  }

  @override
  String get wordHuntTypeFillBlank => 'Boşluk Doldurma';

  @override
  String get wordHuntTypeMultipleChoice => 'Çoktan Seçmeli';

  @override
  String get wordHuntChooseMissingWord =>
      'Doğru kelimeyi seç ve boşluğu tamamla';

  @override
  String get wordHuntWordBank => 'Kelime bankası';

  @override
  String get wordHuntAnswerQuestion => 'Soruyu cevapla';

  @override
  String get wordHuntExplanationMissing => 'Açıklama bulunmuyor.';

  @override
  String wordHuntCorrectFeedback(String explanation) {
    return 'Harika! Doğru cevap.\n$explanation';
  }

  @override
  String wordHuntRetryFeedback(String explanation) {
    return 'Tekrar bakalım.\n$explanation';
  }

  @override
  String get wordHuntExcellentTitle => 'Mükemmel!';

  @override
  String get wordHuntCompletedTitle => 'Test Tamamlandı!';

  @override
  String get wordHuntExcellentMessage => 'Kelime avında çok iyi iş çıkardın.';

  @override
  String get wordHuntCompletedMessage =>
      'Pratik yaptıkça daha da hızlanacaksın.';

  @override
  String get wordHuntScore => 'Skor';

  @override
  String get wordHuntXp => 'XP';

  @override
  String get wordHuntContinue => 'Devam Et';

  @override
  String get wordHuntNoQuestions => 'Soru bulunamadı.';

  @override
  String get wordHuntSeeResult => 'Sonucu Gör';

  @override
  String wordHuntXpSaveError(String error) {
    return 'XP kaydedilirken hata oluştu: $error';
  }

  @override
  String get settingsPracticeLevelHint =>
      'Geçmiş seviyelere dönüp pratik yapabilirsin. Ulaşmadığın seviyeler kilitli kalır.';

  @override
  String get settingsSavedMessage => 'Ayarlar başarıyla kaydedildi! 🎉';

  @override
  String settingsSaveError(String error) {
    return 'Ayarlar kaydedilemedi: $error';
  }

  @override
  String get settingsLogoutTitle => 'Çıkış Yap';

  @override
  String get settingsLogoutConfirmMessage =>
      'Hesabından çıkmak istediğine emin misin?';

  @override
  String get settingsCancel => 'İptal';
}
