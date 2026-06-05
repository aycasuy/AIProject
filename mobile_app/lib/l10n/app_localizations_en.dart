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
}
