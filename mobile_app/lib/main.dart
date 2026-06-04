/*import 'package:flutter/material.dart';
import 'package:mobile_app/screens/onboarding_screen.dart';
//import 'screens/login_screen.dart';

void main() {
  runApp(const EnglishAIApp());
}

// --- UYGULAMA TEMASI VE AYARLARI ---
class EnglishAIApp extends StatelessWidget {
  const EnglishAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'English AI Master',
      // 2026 Trendi: Material 3 ve "Teal" (Turkuaz) Rengi
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF009688), // Modern Teal Rengi
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5), // Hafif gri arka plan
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent, // Şeffaf AppBar (Modern)
          titleTextStyle: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
      ),
      home: const OnboardingScreen(),
    );
  }
}*/

import 'package:flutter/material.dart';
// 🌟 1. YENİ EKLENEN KÜTÜPHANELER
import 'package:flutter_localizations/flutter_localizations.dart';
import '../l10n/app_localizations.dart';

import 'screens/onboarding_screen.dart';
import 'screens/notification_service.dart';

void main() async {
  // ← async yap
  WidgetsFlutterBinding.ensureInitialized(); // ← EKLE
  await NotificationService().init(); // ← EKLE
  runApp(const LinguaApp());
}

class LinguaApp extends StatelessWidget {
  const LinguaApp({super.key});
  static final ValueNotifier<Locale?> localeNotifier = ValueNotifier(null);

  @override
  Widget build(BuildContext context) {
    // 🌟 2. VALUE_LISTENABLE_BUILDER İLE MATERİAL_APP'İ SARIYORUZ
    return ValueListenableBuilder<Locale?>(
      valueListenable: localeNotifier,
      builder: (context, currentLocale, child) {
        return MaterialApp(
          title: 'Lingua',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(fontFamily: 'Nunito', useMaterial3: true),

          // 🌟 3. AKTİF DİLİ BURAYA BAĞLIYORUZ (Telefonun dilini ezer!)
          locale: currentLocale,

          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('tr', ''), Locale('en', '')],
          home: const OnboardingScreen(),
        );
      },
    );
  }
}
