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
  String get learnHintTitle => 'Here\'s a Hint!';

  @override
  String learnHintContent(String firstLetter, int length) {
    return 'The answer starts with the letter \'$firstLetter\'...\\nAnd it is exactly $length characters long!';
  }

  @override
  String get learnHintThanks => 'Thanks!';

  @override
  String get learnHintBubble => 'Hint?';

  @override
  String learnCorrectAnswer(String answer) {
    return 'Correct Answer: $answer';
  }

  @override
  String learnGenericError(String error) {
    return 'Error: $error';
  }

  @override
  String get learnNoCards => 'There are no cards in this lesson yet.';

  @override
  String get learnGreatJob => 'Great Job!';

  @override
  String get learnDeckCompleted => 'You completed the word deck.';

  @override
  String learnWordsAddedToVocabulary(int count) {
    return '$count words were added to your Vocabulary Notebook. 📚';
  }

  @override
  String get learnBackToMap => 'Back to Map';

  @override
  String get learnSwipeInstruction =>
      'Swipe right if you learned it 👉 | 👈 Swipe left to review';

  @override
  String get learnTapToSeeTranslation => 'Tap to see the translation';

  @override
  String get learnQuestionsCouldNotLoad =>
      'Questions could not be loaded. Please check your internet connection.';

  @override
  String get learnNoBlankQuestions =>
      'There are no fill-in-the-blank questions in this lesson yet.';

  @override
  String get learnNoSentenceQuestions =>
      'There are no sentence building questions in this lesson yet.';

  @override
  String get learnNewQuestionsComing =>
      'New questions will appear here when added.';

  @override
  String get learnGameOverTitle => 'Out of Lives!';

  @override
  String get learnGameOverBlankMessage =>
      'Rest a bit, you can continue filling in the blanks when your lives refill.';

  @override
  String get learnGameOverOrderMessage =>
      'Rest a bit, you can continue again when your lives refill.';

  @override
  String learnNewLife(String time) {
    return 'New life in: $time';
  }

  @override
  String get learnRefillLives => 'Refill Lives for 300 XP';

  @override
  String get learnLivesRefilled => 'Lives Refilled! Adventure Continues 🚀';

  @override
  String get learnPerfectTitle => 'Perfect!';

  @override
  String get learnBlankCompleted =>
      'You completed all fill-in-the-blank questions.';

  @override
  String get learnOrderCompleted =>
      'You successfully completed the sentence building task.';

  @override
  String get learnBlankTitle => 'Fill in the Blanks';

  @override
  String get learnSentenceOrderTitle => 'Sentence Building';

  @override
  String learnQuestionCounter(int current, int total) {
    return '$current / $total questions';
  }

  @override
  String get learnCompleteMissingWord => 'Complete the missing word';

  @override
  String get learnAnswerInputHint => 'Type your answer here...';

  @override
  String get learnWrongWordError => 'Wrong word, you lost a life. Try again.';

  @override
  String get learnStuckHintText => 'You can get a hint if you\'re stuck.';

  @override
  String get learnGetHint => 'Get a hint';

  @override
  String get learnCheckAnswer => 'Check ✨';

  @override
  String get learnSkipBlank => 'I couldn\'t fill the blank, skip it';

  @override
  String get learnSkipOrder => 'I couldn\'t build the sentence, skip it';

  @override
  String learnTranslateFromNative(String language) {
    return 'Translate from $language';
  }

  @override
  String get learnBuildSentence => 'Build your sentence';

  @override
  String get learnTapWordsToBuildSentence =>
      'Tap the words to build the sentence';

  @override
  String get learnWords => 'Words';

  @override
  String get learnTapAndOrder => 'Tap and order';

  @override
  String get learnWeakPointHunterTitle => 'Weak Point Hunter';

  @override
  String get learnWeakPointHunterDescription =>
      'AI will analyze the words you previously struggled with and prepare a personalized timed reading quiz for you. Are you ready for the challenge?';

  @override
  String get learnChallengeButton => 'Start Challenge!';

  @override
  String get learnModuleNotFound => 'Module not found.';

  @override
  String get minimalPairsTitle => 'Pronunciation & Minimal Pairs';

  @override
  String get minimalPairsNoPairs =>
      'No sound pairs were found for this lesson.';

  @override
  String minimalPairsStep(int current, int total) {
    return 'Step $current / $total';
  }

  @override
  String get minimalPairsListenDifference => 'Listen to the difference';

  @override
  String get minimalPairsSayNow => 'Now you say:';

  @override
  String get minimalPairsAnalyzing => 'Analyzing... 🤖';

  @override
  String get minimalPairsConnectionRetry =>
      'Connection error, can you try again?';

  @override
  String get minimalPairsNoVoice => 'I could not hear your voice.';

  @override
  String get minimalPairsGreatPronunciation => 'Great pronunciation! 🎯';

  @override
  String get minimalPairsPerfectPronunciation =>
      'Great! Perfect pronunciation.';

  @override
  String get minimalPairsCoachNote => 'Coach\'s Note:';

  @override
  String get minimalPairsHoldToSpeak => 'Hold to speak';

  @override
  String get minimalPairsSkip => 'I couldn\'t say it, skip 🤔';

  @override
  String get minimalPairsContinue => 'CONTINUE';

  @override
  String get minimalPairsAddedPractice =>
      'The word was added to your practice list! 📚 (1 life lost)';

  @override
  String get minimalPairsGameOverMessage =>
      'Sorry, you made too many mistakes in pronunciation practice. You can refill your lives by spending 300 XP or return to the map.';

  @override
  String get pronunciationCoachTitle => 'Pronunciation Coach 🎙️';

  @override
  String get pronunciationInitialPrompt =>
      'Tap the microphone and start reading...';

  @override
  String get pronunciationPreparingText =>
      'AI is preparing a suitable text for you... ⏳';

  @override
  String get pronunciationNoText =>
      'No suitable pronunciation text was found for this lesson.';

  @override
  String get pronunciationConnectionError =>
      'Connection error! Please check your internet connection.';

  @override
  String pronunciationRound(int current, int total) {
    return 'Text $current / $total';
  }

  @override
  String get pronunciationReadClearly => 'Read the sentence clearly and calmly';

  @override
  String get pronunciationReadSentence => 'Read the sentence below';

  @override
  String get pronunciationStop => 'Stop';

  @override
  String get pronunciationListenFirst => 'Listen First';

  @override
  String get pronunciationListening => 'Listening...';

  @override
  String get pronunciationTranscriptHint =>
      'What you say will appear here after you tap the microphone.';

  @override
  String get pronunciationWaitingForSpeech => 'Waiting for Your Speech';

  @override
  String get pronunciationAnalyze => 'Analyze';

  @override
  String get pronunciationTaskPreparing =>
      'Preparing your pronunciation task...';

  @override
  String get pronunciationGameOverMessage =>
      'Wait a little. You can continue when you receive a new life.';

  @override
  String get pronunciationSuccessTitle => 'Great Speaking!';

  @override
  String get pronunciationSuccessMessage =>
      'You completed all pronunciation tasks.';

  @override
  String get pronunciationSuccessful => 'Successful Pronunciation';

  @override
  String get pronunciationTryAgain => 'Let\'s Try Again';

  @override
  String get pronunciationScoreUnit => 'points';

  @override
  String pronunciationXpEarned(int xp) {
    return 'You Earned +$xp XP!';
  }

  @override
  String get pronunciationLifeLost => '1 Life Lost! Try Again.';

  @override
  String get pronunciationWordsToWatch => 'Words you should pay attention to:';

  @override
  String get pronunciationNextText => 'Next Text 🚀';

  @override
  String get pronunciationAmazing => 'Amazing! 🚀';

  @override
  String get pronunciationRetry => 'Try Again 🔄';
}
