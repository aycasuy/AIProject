// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get learningPreferences => 'PREFERENCIAS DE LIMITACIÓN';

  @override
  String get learnedLanguage => 'Idioma de destino';

  @override
  String get practiceLevel => 'Nivel de práctica';

  @override
  String get appSettings => 'APLICAR SETINGOS';

  @override
  String get dailyReminders => 'Recordatorios diarios';

  @override
  String get saveChanges => 'Guardar Cambios';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get onboard1Title =>
      'Aprende en cualquier lugar,\nen cualquier momento';

  @override
  String get onboard1Subtitle =>
      'Lecciones de aprendizaje grandes, diseñadas\npara tu vida diaria.';

  @override
  String get onboard2Title => 'Conversaciones reales, progreso real';

  @override
  String get onboard2Subtitle =>
      'Practica con diálogos generados por IA que se sienten naturales.';

  @override
  String get onboard3Title => 'Registra tu\nDiario';

  @override
  String get onboard3Subtitle =>
      'Mira lo lejos que has llegado con\nbonitos gráficos de progreso.';

  @override
  String get skip => 'Saltar';

  @override
  String get next => 'Siguiente →';

  @override
  String get letsStart => '¡Empecemos! 🚀';

  @override
  String get loginSubtitle => 'Aprende idiomas. Vive mejor.';

  @override
  String get fillAllFields => '¡Por favor, rellene todos los campos! 🌟';

  @override
  String get registerSuccess => '¡Registro exitoso! Puedes iniciar sesión.';

  @override
  String get connectionError => '¡Error de conexión!';

  @override
  String comingSoon(String provider) {
    return 'Inicia sesión con $provider próximamente 🚀';
  }

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get signUp => 'Regístrate';

  @override
  String get username => 'Usuario';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Contraseña';

  @override
  String get forgotPassword => '¿Olvidaste la contraseña?';

  @override
  String get signInBtn => '🚀 Iniciar sesión';

  @override
  String get signUpBtn => '✨ Crear cuenta';

  @override
  String get or => 'o';

  @override
  String get noAccount => '¿No tienes una cuenta?  ';

  @override
  String get haveAccount => '¿Ya está registrado? ';

  @override
  String get langEnglish => 'Inglés';

  @override
  String get langSpanish => 'Español';

  @override
  String get langGerman => 'Alemán';

  @override
  String get langFrench => 'Francés';

  @override
  String get langTurkish => 'Turco';

  @override
  String get readyToLearn => '¿Listo para aprender un nuevo idioma? 🌍';

  @override
  String get continueLearning => '¿Con qué idioma te gustaría continuar? 🚀';

  @override
  String get whatIsNativeLanguage => '¿Cuál es tu idioma nativo?';

  @override
  String get makeSelectionToPersonalize =>
      'Por favor, haz una selección para personalizar tu experiencia.';

  @override
  String stepProgress(int current, int total) {
    return 'Paso $current / $total';
  }

  @override
  String languageComingSoonMsg(String lang) {
    return '¡$lang estará disponible pronto! Comencemos con Inglés o Español por ahora. 🚀';
  }

  @override
  String get connectionErrorServer =>
      '¡Error de conexión! ¿Está funcionando el servidor?';

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
}
