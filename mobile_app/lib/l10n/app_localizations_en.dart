// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get settingsTitle => 'Settings';

  @override
  String get learningPreferences => 'LEARNING PREFERENCES';

  @override
  String get learnedLanguage => 'Target Language';

  @override
  String get practiceLevel => 'Practice Level';

  @override
  String get appSettings => 'APP SETTINGS';

  @override
  String get dailyReminders => 'Daily Reminders';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get logout => 'Logout';

  @override
  String get onboard1Title => 'Learn Anywhere,\nAnytime';

  @override
  String get onboard1Subtitle =>
      'Pocket-sized learning lessons designed\nfor your daily life.';

  @override
  String get onboard2Title => 'Real Conversations,\nReal Progress';

  @override
  String get onboard2Subtitle =>
      'Practice with AI-powered dialogues\nthat feel natural.';

  @override
  String get onboard3Title => 'Track Your\nJourney';

  @override
  String get onboard3Subtitle =>
      'See how far you\'ve come with\nbeautiful progress charts.';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next  →';

  @override
  String get letsStart => 'Let\'s Start! 🚀';

  @override
  String get loginSubtitle => 'Learn Languages. Live Better.';

  @override
  String get fillAllFields => 'Please fill in all fields! 🌟';

  @override
  String get registerSuccess => 'Registration Successful! You can sign in.';

  @override
  String get connectionError => 'Connection Error!';

  @override
  String comingSoon(String provider) {
    return 'Sign in with $provider is coming soon 🚀';
  }

  @override
  String get signIn => 'Sign In';

  @override
  String get signUp => 'Sign Up';

  @override
  String get username => 'Username';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get signInBtn => '🚀  Sign In';

  @override
  String get signUpBtn => '✨  Create Account';

  @override
  String get or => 'or';

  @override
  String get noAccount => 'Don\'t have an account? ';

  @override
  String get haveAccount => 'Already registered? ';

  @override
  String get langEnglish => 'English';

  @override
  String get langSpanish => 'Spanish';

  @override
  String get langGerman => 'German';

  @override
  String get langFrench => 'French';

  @override
  String get langTurkish => 'Turkish';

  @override
  String get readyToLearn => 'Ready to learn a new language? 🌍';

  @override
  String get continueLearning =>
      'Which language would you like to continue with? 🚀';

  @override
  String get whatIsNativeLanguage => 'What is your native language?';

  @override
  String get makeSelectionToPersonalize =>
      'Please make a selection so we can provide you with the best experience.';

  @override
  String stepProgress(int current, int total) {
    return 'Step $current / $total';
  }

  @override
  String languageComingSoonMsg(String lang) {
    return '$lang is coming soon! ';
  }

  @override
  String get connectionErrorServer =>
      'Connection error! Is the server running?';

  @override
  String roleplayIntro(String lessonTitle, String targetLanguage, int count) {
    return 'Scenario: $lessonTitle 🎭\n\nYour goal is to build $count error-free sentences in $targetLanguage. Type your first message to begin! 😊';
  }

  @override
  String roleplayGoal(int current, int count) {
    return 'Goal: $current / $count correct sentences';
  }

  @override
  String get roleplayHint => 'I\'m stuck, give me a hint';

  @override
  String get writtenAnswer => 'Write your answer...';

  @override
  String get correctedAnswer => 'Write the corrected version...';

  @override
  String get dailyLimitTitle => 'That\'s enough for today!';

  @override
  String get dailyLimitMessage =>
      'You have used your free daily AI roleplay attempt. Great job! Come back tomorrow for a new scenario or explore Premium for unlimited chat.';

  @override
  String get useBottomMenuHint => '👇 Use the bottom menu for other activities';

  @override
  String get dailyWords => 'Today\'s Words';

  @override
  String get aiResults => 'Here are your results:';

  @override
  String get coachThinking => 'Coach is thinking...';

  @override
  String get finishLessonWithXp => '✅ Finish Lesson (+50 XP)';

  @override
  String get greatJobTitle => '🎉 Great Job!';

  @override
  String get greatJobMessage =>
      'You completed the scenario successfully and earned +50 XP!';

  @override
  String get ok => 'OK';

  @override
  String get translationTitle => 'Translation';

  @override
  String get holdForTranslation => 'Long press to translate';

  @override
  String get noMistakeFound => 'Great! No mistakes found.';

  @override
  String mistakesFound(int count) {
    return '$count mistakes found';
  }

  @override
  String get levelJourneyTitle => 'Your Journey Begins!';

  @override
  String levelJourneySubtitle(String language) {
    return 'Let\'s choose the best starting point for you while learning $language.';
  }

  @override
  String get startFromA1Title => 'You can start from A1';

  @override
  String get startFromA1Subtitle =>
      'Start from the basics and unlock all modules step by step.';

  @override
  String get placementInfoTitle => 'You can take a level test';

  @override
  String get placementInfoSubtitle =>
      'We\'ll determine the right level for you with a short test.';

  @override
  String get startFromScratchA1 => 'Let\'s Start from Scratch (A1)';

  @override
  String get knowMyLevelTest => 'I Know My Level / Take Test';

  @override
  String get levelSaveFailed => 'Level could not be saved!';

  @override
  String connectionErrorWithDetail(String error) {
    return 'Connection error: $error';
  }

  @override
  String get placementLoading => 'Preparing your AI placement test...';

  @override
  String placementQuestion(int current, int total) {
    return 'Question $current/$total';
  }

  @override
  String get placementNext => 'Next Question';

  @override
  String get placementFinishedTitle => 'Test Completed!';

  @override
  String placementFinishedBody(String level) {
    return 'Great job.\n\nDetermined Level: $level';
  }

  @override
  String get placementBackToMenu => 'Return to Main Menu';

  @override
  String get placementListenButton => 'Listen';

  @override
  String get placementStopButton => 'Stop';

  @override
  String get placementListenInstruction =>
      'Press the button to listen to the text';

  @override
  String get placementNoQuestion => 'No questions found.';

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
}
