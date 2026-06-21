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
    return 'Escenario: $lessonTitle 🎭\n\nTu objetivo es construir $count oraciones sin errores en $targetLanguage. ¡Escribe tu primer mensaje para comenzar! 😊';
  }

  @override
  String roleplayGoal(int current, int count) {
    return 'Objetivo: $current / $count oraciones correctas';
  }

  @override
  String get roleplayHint => 'Me quedé atascado, dame una pista';

  @override
  String get writtenAnswer => 'Escribe tu respuesta...';

  @override
  String get correctedAnswer => 'Escribe la versión corregida...';

  @override
  String get dailyLimitTitle => '¡Suficiente por hoy!';

  @override
  String get dailyLimitMessage =>
      'Has usado tu intento diario gratuito de roleplay con IA. ¡Buen trabajo! Vuelve mañana para un nuevo escenario o explora Premium para tener chat ilimitado.';

  @override
  String get useBottomMenuHint =>
      '👇 Usa el menú inferior para otras actividades';

  @override
  String get dailyWords => 'Palabras del día';

  @override
  String get aiResults => 'Aquí están tus resultados:';

  @override
  String get coachThinking => 'El entrenador está pensando...';

  @override
  String get finishLessonWithXp => '✅ Terminar lección (+50 XP)';

  @override
  String get greatJobTitle => '🎉 ¡Buen trabajo!';

  @override
  String get greatJobMessage =>
      'Completaste el escenario con éxito y ganaste +50 XP.';

  @override
  String get ok => 'Aceptar';

  @override
  String get translationTitle => 'Traducción';

  @override
  String get holdForTranslation => 'Mantén pulsado para traducir';

  @override
  String get noMistakeFound => '¡Genial! No se encontraron errores.';

  @override
  String mistakesFound(int count) {
    return 'Se encontraron $count errores';
  }

  @override
  String get levelJourneyTitle => '¡Tu viaje comienza!';

  @override
  String levelJourneySubtitle(String language) {
    return 'Elijamos el mejor punto de inicio para ti mientras aprendes $language.';
  }

  @override
  String get startFromA1Title => 'Puedes empezar desde A1';

  @override
  String get startFromA1Subtitle =>
      'Avanza desde lo básico y desbloquea todos los módulos paso a paso.';

  @override
  String get placementInfoTitle => 'Puedes hacer una prueba de nivel';

  @override
  String get placementInfoSubtitle =>
      'Determinaremos tu nivel adecuado con una prueba corta.';

  @override
  String get startFromScratchA1 => 'Empecemos desde cero (A1)';

  @override
  String get knowMyLevelTest => 'Sé mi nivel / Hacer prueba';

  @override
  String get levelSaveFailed => '¡No se pudo guardar el nivel!';

  @override
  String connectionErrorWithDetail(String error) {
    return 'Error de conexión: $error';
  }

  @override
  String get placementLoading => 'Preparando tu prueba de nivel con IA...';

  @override
  String placementQuestion(int current, int total) {
    return 'Pregunta $current/$total';
  }

  @override
  String get placementNext => 'Siguiente pregunta';

  @override
  String get placementFinishedTitle => '¡Prueba completada!';

  @override
  String placementFinishedBody(String level) {
    return 'Buen trabajo\n\nNivel determinado: $level';
  }

  @override
  String get placementBackToMenu => 'Volver al menú principal';

  @override
  String get placementListenButton => 'Escuchar';

  @override
  String get placementStopButton => 'Detener';

  @override
  String get placementListenInstruction =>
      'Pulsa el botón para escuchar el texto';

  @override
  String get placementNoQuestion => 'No se encontraron preguntas.';

  @override
  String get learnHintTitle => '¡Aquí tienes una pista!';

  @override
  String learnHintContent(String firstLetter, int length) {
    return 'La respuesta empieza con la letra \'$firstLetter\'...\\n¡Y tiene exactamente $length caracteres!';
  }

  @override
  String get learnHintThanks => '¡Gracias!';

  @override
  String get learnHintBubble => '¿Pista?';

  @override
  String learnCorrectAnswer(String answer) {
    return 'Respuesta correcta: $answer';
  }

  @override
  String learnGenericError(String error) {
    return 'Error: $error';
  }

  @override
  String get learnNoCards => 'Aún no hay tarjetas en esta lección.';

  @override
  String get learnGreatJob => '¡Buen trabajo!';

  @override
  String get learnDeckCompleted => 'Completaste el mazo de palabras';

  @override
  String learnWordsAddedToVocabulary(int count) {
    return '$count palabras fueron añadidas a tu cuaderno de vocabulario. 📚';
  }

  @override
  String get learnBackToMap => 'Volver al mapa';

  @override
  String get learnSwipeInstruction =>
      'Desliza a la derecha si lo aprendiste 👉 | 👈 Desliza a la izquierda para repasar';

  @override
  String get learnTapToSeeTranslation => 'Toca para ver la traducción';

  @override
  String get learnQuestionsCouldNotLoad =>
      'No se pudieron cargar las preguntas. Revisa tu conexión a internet.';

  @override
  String get learnNoBlankQuestions =>
      'Aún no hay preguntas de completar espacios en esta lección.';

  @override
  String get learnNoSentenceQuestions =>
      'Aún no hay preguntas de formar oraciones en esta lección.';

  @override
  String get learnNewQuestionsComing =>
      'Las nuevas preguntas aparecerán aquí cuando se agreguen.';

  @override
  String get learnGameOverTitle => '¡Sin vidas!';

  @override
  String get learnGameOverBlankMessage =>
      'Descansa un poco, puedes seguir completando los espacios cuando se recarguen tus vidas.';

  @override
  String get learnGameOverOrderMessage =>
      'Descansa un poco, puedes continuar de nuevo cuando se recarguen tus vidas.';

  @override
  String learnNewLife(String time) {
    return 'Nueva vida en: $time';
  }

  @override
  String get learnRefillLives => 'Recargar vidas por 300 XP';

  @override
  String get learnLivesRefilled => '¡Vidas recargadas! La aventura continúa 🚀';

  @override
  String get learnPerfectTitle => '¡Perfecto!';

  @override
  String get learnBlankCompleted =>
      'Completaste todas las preguntas de rellenar espacios.';

  @override
  String get learnOrderCompleted =>
      'Completaste con éxito la tarea de formar oraciones.';

  @override
  String get learnBlankTitle => 'Completar espacios';

  @override
  String get learnSentenceOrderTitle => 'Formar oraciones';

  @override
  String learnQuestionCounter(int current, int total) {
    return '$current / $total preguntas';
  }

  @override
  String get learnCompleteMissingWord => 'Completa la palabra que falta';

  @override
  String get learnAnswerInputHint => 'Escribe tu respuesta aquí...';

  @override
  String get learnWrongWordError =>
      'Palabra incorrecta, perdiste una vida. Inténtalo de nuevo.';

  @override
  String get learnStuckHintText => 'Puedes pedir una pista si te atascas.';

  @override
  String get learnGetHint => 'Obtener una pista';

  @override
  String get learnCheckAnswer => 'Comprobar ✨';

  @override
  String get learnSkipBlank => 'No pude completar el espacio, saltar';

  @override
  String get learnSkipOrder => 'No pude formar la oración, saltar';

  @override
  String learnTranslateFromNative(String language) {
    return 'Traducir del $language';
  }

  @override
  String get learnBuildSentence => 'Forma tu oración';

  @override
  String get learnTapWordsToBuildSentence =>
      'Toca las palabras para formar la oración';

  @override
  String get learnWords => 'Palabras';

  @override
  String get learnTapAndOrder => 'Tocar y ordenar';

  @override
  String get learnWeakPointHunterTitle => 'Cazador de puntos débiles';

  @override
  String get learnWeakPointHunterDescription =>
      'La IA analizará las palabras en las que cometiste errores antes y preparará una prueba de lectura cronometrada personalizada para ti. ¿Aceptas el desafío?';

  @override
  String get learnChallengeButton => '¡Aceptar el desafío!';

  @override
  String get learnModuleNotFound => 'Módulo no encontrado.';

  @override
  String get minimalPairsTitle => 'Pronunciación y pares mínimos';

  @override
  String get minimalPairsNoPairs =>
      'No se encontraron pares de sonidos para esta lección.';

  @override
  String minimalPairsStep(int current, int total) {
    return 'Paso $current / $total';
  }

  @override
  String get minimalPairsListenDifference => 'Escucha la diferencia';

  @override
  String get minimalPairsSayNow => 'Ahora dilo tú:';

  @override
  String get minimalPairsAnalyzing => 'Analizando... 🤖';

  @override
  String get minimalPairsConnectionRetry =>
      'Error de conexión, ¿puedes intentarlo de nuevo?';

  @override
  String get minimalPairsNoVoice => 'No pude escuchar tu voz.';

  @override
  String get minimalPairsGreatPronunciation => '¡Muy buena pronunciación! 🎯';

  @override
  String get minimalPairsPerfectPronunciation =>
      '¡Genial! Pronunciación perfecta.';

  @override
  String get minimalPairsCoachNote => 'Nota del entrenador:';

  @override
  String get minimalPairsHoldToSpeak => 'Mantén pulsado para hablar';

  @override
  String get minimalPairsSkip => 'No pude decirlo, omitir 🤔';

  @override
  String get minimalPairsContinue => 'CONTINUAR';

  @override
  String get minimalPairsAddedPractice =>
      'La palabra fue añadida a tu lista de práctica. 📚 (perdiste 1 vida)';

  @override
  String get minimalPairsGameOverMessage =>
      'Lo siento, cometiste demasiados errores en la práctica de pronunciación. Puedes rellenar tus vidas gastando 300 XP o volver al mapa.';

  @override
  String get pronunciationCoachTitle => 'Entrenador de pronunciación 🎙️';

  @override
  String get pronunciationInitialPrompt =>
      'Pulsa el micrófono y empieza a leer...';

  @override
  String get pronunciationPreparingText =>
      'La IA está preparando un texto adecuado para ti... ⏳';

  @override
  String get pronunciationNoText =>
      'No se encontró un texto de pronunciación adecuado para esta lección.';

  @override
  String get pronunciationConnectionError =>
      '¡Error de conexión! Revisa tu conexión a internet.';

  @override
  String pronunciationRound(int current, int total) {
    return 'Texto $current / $total';
  }

  @override
  String get pronunciationReadClearly =>
      'Lee la frase de forma clara y tranquila';

  @override
  String get pronunciationReadSentence => 'Lee la siguiente frase';

  @override
  String get pronunciationStop => 'Detener';

  @override
  String get pronunciationListenFirst => 'Escuchar primero';

  @override
  String get pronunciationListening => 'Escuchando...';

  @override
  String get pronunciationTranscriptHint =>
      'Lo que digas aparecerá aquí cuando pulses el micrófono.';

  @override
  String get pronunciationWaitingForSpeech => 'Esperando tu voz';

  @override
  String get pronunciationAnalyze => 'Analizar';

  @override
  String get pronunciationTaskPreparing =>
      'Preparando tu tarea de pronunciación...';

  @override
  String get pronunciationGameOverMessage =>
      'Espera un poco. Podrás continuar cuando recibas una nueva vida.';

  @override
  String get pronunciationSuccessTitle => '¡Hablaste muy bien!';

  @override
  String get pronunciationSuccessMessage =>
      'Completaste todas las tareas de pronunciación.';

  @override
  String get pronunciationSuccessful => 'Pronunciación correcta';

  @override
  String get pronunciationTryAgain => 'Intentémoslo de nuevo';

  @override
  String get pronunciationScoreUnit => 'puntos';

  @override
  String pronunciationXpEarned(int xp) {
    return '¡Ganaste +$xp XP!';
  }

  @override
  String get pronunciationLifeLost => '¡Perdiste 1 vida! Inténtalo de nuevo.';

  @override
  String get pronunciationWordsToWatch =>
      'Palabras a las que debes prestar atención:';

  @override
  String get pronunciationNextText => 'Siguiente texto 🚀';

  @override
  String get pronunciationAmazing => '¡Excelente! 🚀';

  @override
  String get pronunciationRetry => 'Intentar de nuevo 🔄';

  @override
  String get listeningCoachTitle => 'Entrenador de comprensión auditiva 🎧';

  @override
  String listeningRound(int current, int total) {
    return 'Texto $current / $total';
  }

  @override
  String get listeningWriteAndCheck =>
      'Escribe lo que escuchaste y compruébalo';

  @override
  String get listeningListenFirst => 'Escucha primero el audio';

  @override
  String get listeningInstruction => 'Escucha al robot y escribe lo que oyes';

  @override
  String get listeningPlaying => 'Reproduciendo...';

  @override
  String get listeningPlayAudio => 'Reproducir audio';

  @override
  String get listeningInputLockedInfo =>
      'El área de escritura se abrirá cuando termine el audio.';

  @override
  String get listeningWriteWhatYouHear => 'Escribe lo que escuchas';

  @override
  String get listeningReplay => 'Escuchar de nuevo';

  @override
  String get listeningInputHint => 'Escribe aquí la frase que escuchaste...';

  @override
  String get listeningCheck => 'Comprobar 🎯';

  @override
  String get listeningTextLoadFailed =>
      'No se pudo cargar el texto de escucha.';

  @override
  String get listeningCheckConnection =>
      'Comprueba tu conexión e inténtalo de nuevo.';

  @override
  String get listeningRetryLoad => 'Intentar de nuevo';

  @override
  String get listeningGameOverMessage =>
      'Descansa un poco. Podrás continuar la tarea de escucha cuando recuperes tus vidas.';

  @override
  String get listeningSuccessTitle => '¡Muy buena comprensión auditiva!';

  @override
  String get listeningSuccessMessage =>
      'Completaste correctamente todas las tareas de escucha.';

  @override
  String get listeningEvaluationCompleted => 'Evaluación completada.';

  @override
  String get listeningSuccessResult => '¡Escuchaste muy bien!';

  @override
  String get listeningTryAgainResult => 'Intentémoslo una vez más';

  @override
  String listeningXpEarned(int xp) {
    return '¡Ganaste +$xp XP!';
  }

  @override
  String get listeningLifeLost => 'Perdiste 1 vida';

  @override
  String get listeningMissedWords =>
      'Palabras que omitiste o escribiste incorrectamente:';

  @override
  String get listeningNextText => 'Siguiente texto 🚀';

  @override
  String get listeningAmazing => '¡Excelente! 🚀';

  @override
  String get listeningTryAgainButton => 'Intentar de nuevo 🔄';

  @override
  String get pathVisualLearning => 'Aprendizaje visual';

  @override
  String get pathFillBlank => 'Completar espacios';

  @override
  String get pathSentenceOrder => 'Construir oraciones';

  @override
  String get pathQuickQuiz => 'Cuestionario rápido';

  @override
  String get pathMinimalPairs => 'Pares mínimos';

  @override
  String get pathPronunciation => 'Pronunciación';

  @override
  String get pathListening => 'Comprensión auditiva';

  @override
  String get pathTest => 'Prueba';

  @override
  String get pathLevelUp => 'SUBIR DE NIVEL';

  @override
  String get pathFinalTest => 'PRUEBA FINAL';

  @override
  String pathLessonNumber(int number) {
    return 'LECCIÓN $number';
  }

  @override
  String get pathUnknownLesson => 'Lección desconocida';

  @override
  String get pathSectionFallback => 'Sección';

  @override
  String get pathExam => 'Examen';

  @override
  String get pathNext => 'Siguiente';

  @override
  String get pathLockedMessage =>
      '¡Este paso todavía está bloqueado! Completa primero los pasos anteriores.';

  @override
  String get pathOldFinalMessage =>
      'Ya completaste esta prueba final. En los niveles anteriores solo puedes practicar.';

  @override
  String get pathWelcomeNewLevel =>
      '¡Te damos la bienvenida a un nuevo nivel! 🎉';

  @override
  String pathLoadError(String error) {
    return 'Se produjo un error al cargar la ruta de aprendizaje: $error';
  }

  @override
  String get finalTestTitle => 'PRUEBA FINAL 🚀';

  @override
  String get finalTestLoading => 'Preparando tu prueba final...';

  @override
  String get finalTestLoadFailed => 'No se pudo cargar la prueba final.';

  @override
  String get finalTestNoQuestions =>
      'No se encontraron preguntas para esta prueba.';

  @override
  String get finalTestRetry => 'Intentar de nuevo';

  @override
  String finalTestQuestionCounter(int current, int total) {
    return 'Pregunta $current / $total';
  }

  @override
  String get finalTestAnswer => 'Responder';

  @override
  String get finalTestCorrect => '✅ ¡Correcto!';

  @override
  String get finalTestWrong => '❌ ¡Incorrecto!';

  @override
  String get finalTestFillBlank => 'Completa el espacio';

  @override
  String get finalTestBuildSentence => 'Construye la oración';

  @override
  String get finalTestListenAndWrite => 'Escribe lo que escuchas';

  @override
  String get finalTestReadAloud => 'Leer en voz alta';

  @override
  String get finalTestAnswerHint => 'Escribe tu respuesta...';

  @override
  String finalTestWriteInLanguage(String language) {
    return 'Escribe en $language...';
  }

  @override
  String get finalTestMicrophoneHint => 'Pulsa el micrófono...';

  @override
  String get finalTestListening => 'Escuchando...';

  @override
  String get finalTestCongratulations => '¡CONGRATULACIONES!';

  @override
  String get finalTestFailedTitle => 'NO PASAS';

  @override
  String finalTestScore(int score) {
    return 'Tu puntuación: $score / 100';
  }

  @override
  String get finalTestPassedMessage =>
      '¡Muy buen trabajo! Desbloqueaste la siguiente lección.';

  @override
  String get finalTestFailedMessage =>
      'No ha alcanzado 70 puntos. Revise sus errores y vuelva a intentarlo.';

  @override
  String get finalTestNextLesson => 'Continuar a la siguiente lección 🚀';

  @override
  String get finalTestBackToMap => 'Volver al mapa';

  @override
  String get profileTitle => 'Mi perfil';

  @override
  String profileLanguageLevel(String language, String level) {
    return '$language • Nivel $level';
  }

  @override
  String get profileTotalXp => 'XP total';

  @override
  String get profileRemainingLives => 'Vidas restantes';

  @override
  String get profileProgress => '\"Progreso';

  @override
  String profileProgressValue(int section, int lesson) {
    return 'Secc. $section • Lecc. $lesson';
  }

  @override
  String get profileDayStreak => 'Racha diaria';

  @override
  String profileDayCount(int count) {
    return '$count días';
  }

  @override
  String get profileWeeklyXpAnalysis => 'Análisis semanal de XP';

  @override
  String get profileMondayShort => 'Mon';

  @override
  String get profileTuesdayShort => 'Tue';

  @override
  String get profileWednesdayShort => 'Mié';

  @override
  String get profileThursdayShort => 'Thu';

  @override
  String get profileFridayShort => 'Vie';

  @override
  String get profileSaturdayShort => 'Sáb';

  @override
  String get profileSundayShort => 'Sol';

  @override
  String get profileLearningCenter => 'Centro de aprendizaje';

  @override
  String get profileWordBank => 'Mi Banco de palabras';

  @override
  String get profileDailyTraining => 'Entrenamiento diario';

  @override
  String profileDailyQuestions(int count) {
    return '$count preguntas personalizadas te están esperando hoy!';
  }

  @override
  String get profileWordTraining => 'Entrenamiento vocabulario';

  @override
  String profileUnlearnedWords(int count) {
    return '$count palabras están esperando ser aprendidas';
  }

  @override
  String get profileStatsLoadFailed =>
      'No se han podido cargar las estadísticas del perfil.';

  @override
  String get speedReadingFinishedTitle => '¡Excelente lectura!';

  @override
  String get speedReadingFinishedSubtitle =>
      'Ahora es el momento de comprobar lo que entendiste.';

  @override
  String get speedReadingStartQuiz => '¡Comenzar cuestionario!';

  @override
  String get speedQuizNoQuestions => 'No se encontraron preguntas.';

  @override
  String speedQuizQuestionCounter(int current, int total) {
    return 'Pregunta $current / $total';
  }

  @override
  String get speedQuizShowTranslation => 'Mostrar traducción';

  @override
  String get speedQuizCheckAnswer => 'Comprobar ✔️';

  @override
  String get speedQuizNextQuestion => 'Siguiente pregunta ➡️';

  @override
  String get speedQuizLevelUpTitle => '¡Has subido de nivel!';

  @override
  String get speedQuizCongratulations => '¡Felicidades!';

  @override
  String get speedQuizLevelUpMessage =>
      '¡Gran rendimiento! Desbloqueaste un nuevo nivel.';

  @override
  String get speedQuizCompletedMessage =>
      'Has completado con éxito el cuestionario rápido.';

  @override
  String get speedQuizCorrectAnswers => 'Corregido';

  @override
  String get speedQuizXp => 'EP';

  @override
  String get speedQuizContinue => 'Continuar';

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
}
