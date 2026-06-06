// lib/screens/path_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/screens/minimal_pairs_screen.dart';

import '/screens/final_test_screen.dart';
import '/screens/pronunciation_screen.dart';
import '../models/user_progress_model.dart';
import '../services/api_service.dart';
import '../widgets/lesson_node.dart';
//import 'ai_teacher_correction_screen.dart';
import 'learn_activity_screen.dart';
import 'listenspeak_screen.dart';
import 'level_up_screen.dart'; // 🌟 BÜYÜK SINAV EKRANINI İÇERİ AKTAR
import '../screens/notification_service.dart'; // Yolu kendi projene göre uyarla

class PathScreen extends StatefulWidget {
  final String username;
  final String selectedLanguage;
  final String
  displayLevel; // Ayarlardan seçilen harita/pratik seviyesi. Örn: gerçek seviye A2 iken A1 gösterilebilir.
  final String nativeLanguage;
  const PathScreen({
    Key? key,
    required this.username,
    required this.selectedLanguage,
    required this.displayLevel,
    required this.nativeLanguage,
  }) : super(key: key);

  @override
  State<PathScreen> createState() => _PathScreenState();
}

class _PathScreenState extends State<PathScreen> {
  late Future<UserProgress> _progressFuture;
  late Future<List<dynamic>> _lessonsFuture;

  // Standart Derslerin 8 Adımı
  final List<Map<String, dynamic>> stepDefinitions = [
    {"type": "learn_image", "title": "Görsel Öğrenim", "icon": "🖼️"},
    {"type": "learn_blank", "title": "Boşluk Doldurma", "icon": "✍️"},
    {"type": "learn_order", "title": "Cümle Kurma", "icon": "🧩"},
    {"type": "learn_quiz", "title": "Hızlı Quiz", "icon": "❓"},
    // {"type": "use_ai", "title": "Kullan (AI)", "icon": "🤖"},
    {"type": "minimal_pairs", "title": "Ses Çiftleri", "icon": "⚖️"},
    {"type": "speak", "title": "Telaffuz", "icon": "🎙️"},
    {"type": "listen", "title": "Dinleme", "icon": "🎧"},
    {"type": "test", "title": "Test", "icon": "📝"},
  ];

  @override
  void initState() {
    super.initState();

    // Açık arka planda status bar ikonları net görünsün.
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    _progressFuture =
        ApiService.fetchUserProgress(
          widget.username,
          widget.selectedLanguage,
        ).then((progress) {
          // Veri başarıyla çekilince, arka planda saat 20:00 alarmını kur!
          NotificationService().scheduleDailyWorkoutReminder(progress.userName);

          return progress;
        });
    _lessonsFuture = ApiService.fetchAllLessons();
  }

  Color getThemeColor(String level) {
    switch (level) {
      case "A1":
        return Colors.green.shade500;
      case "A2":
        return Colors.orange.shade500;
      case "B1":
        return Colors.blue.shade500;
      case "B2":
        return Colors.purple.shade500;
      case "C1":
        return Colors.red.shade500;
      case "C2":
        return Colors.amber.shade600;
      default:
        return Colors.green;
    }
  }

  final List<String> _levelOrder = ["A1", "A2", "B1", "B2", "C1", "C2"];

  int _levelIndex(String level) {
    final index = _levelOrder.indexOf(level);
    return index == -1 ? 0 : index;
  }

  bool _isPastLevel(UserProgress progress) {
    return _levelIndex(widget.displayLevel) <
        _levelIndex(progress.currentLevel);
  }

  String getStepStatus(
    UserProgress progress,
    int targetLesson,
    int targetStep,
  ) {
    // Eğer kullanıcı gerçek seviyesinden daha eski bir seviyeyi görüntülüyorsa
    // o seviye zaten tamamlanmış kabul edilir.
    // Örn: gerçek seviye A2 iken A1 haritası tamamen açık/tamamlanmış görünür.
    if (_isPastLevel(progress)) return "completed";

    if (targetLesson < progress.currentSection) return "completed";
    if (targetLesson == progress.currentSection &&
        targetStep < progress.currentLesson) {
      return "completed";
    }
    if (targetLesson == progress.currentSection &&
        targetStep == progress.currentLesson) {
      return "active";
    }
    return "locked";
  }

  Alignment getZigzagAlignment(int index) {
    int mod = index % 4;
    if (mod == 0) return Alignment.center;
    if (mod == 1) return Alignment.centerRight;
    if (mod == 2) return Alignment.center;
    return Alignment.centerLeft;
  }

  int _completedStepsForLesson(UserProgress progress, int lessonNumber) {
    // Eski seviyeler tekrar açıldığında tüm dersler tamamlanmış görünsün.
    if (_isPastLevel(progress)) return stepDefinitions.length;

    if (lessonNumber < progress.currentSection) return stepDefinitions.length;
    if (lessonNumber == progress.currentSection) {
      final completed = progress.currentLesson - 1;
      return completed.clamp(0, stepDefinitions.length).toInt();
    }
    return 0;
  }

  Widget _buildTopProfileCard(UserProgress progress, Color themeColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withOpacity(0.9), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: themeColor.withOpacity(0.10),
              blurRadius: 28,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [themeColor, themeColor.withOpacity(0.78)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: themeColor.withOpacity(0.28),
                    blurRadius: 14,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                progress.userName.isNotEmpty
                    ? progress.userName[0].toUpperCase()
                    : "?",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    progress.userName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF202124),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: themeColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.displayLevel,
                          style: TextStyle(
                            color: themeColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 7),
                      Flexible(
                        child: Text(
                          "${progress.xpScore} XP",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: themeColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("🔥", style: TextStyle(fontSize: 19)),
                  const SizedBox(width: 5),
                  Text(
                    "${progress.streakDays}",
                    style: TextStyle(
                      color: Colors.orange.shade800,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonHeader({
    required dynamic lesson,
    required int lessonIndex,
    required UserProgress progress,
    required Color themeColor,
    required bool isFinalLesson,
  }) {
    final lessonNumber = lessonIndex + 1;
    final completedSteps = isFinalLesson
        ? 0
        : _completedStepsForLesson(progress, lessonNumber);
    final totalSteps = isFinalLesson ? 1 : stepDefinitions.length;
    final progressValue = isFinalLesson ? 0.0 : completedSteps / totalSteps;
    final bool isUnlocked =
        isFinalLesson || lessonNumber <= progress.currentSection;
    final Color cardColor = isFinalLesson
        ? Colors.amber.shade700
        : isUnlocked
        ? themeColor
        : Colors.grey.shade400;

    return Container(
      margin: const EdgeInsets.only(bottom: 28, top: 18),
      padding: const EdgeInsets.all(18),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cardColor, cardColor.withOpacity(0.84)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: cardColor.withOpacity(0.26),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.25)),
            ),
            alignment: Alignment.center,
            child: Text(
              isFinalLesson ? "🚀" : "${lessonNumber}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isFinalLesson ? "FİNAL TESTİ" : "DERS $lessonNumber",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.82),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  lesson['title'] ?? "Bilinmeyen Ders",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (!isFinalLesson) ...[
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: progressValue,
                      minHeight: 7,
                      backgroundColor: Colors.white.withOpacity(0.22),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.17),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              isFinalLesson ? "Sınav" : "$completedSteps/$totalSteps",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepPill({
    required Map<String, dynamic> stepDef,
    required String status,
    required Color themeColor,
    required bool isFinalLesson,
  }) {
    final Color activeColor = isFinalLesson
        ? Colors.amber.shade700
        : themeColor;
    final bool isActive = status == "active";
    final bool isCompleted = status == "completed";
    final Color textColor = isActive
        ? activeColor
        : isCompleted
        ? Colors.grey.shade700
        : Colors.grey.shade500;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? activeColor.withOpacity(0.12) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isActive
              ? activeColor.withOpacity(0.26)
              : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("${stepDef['icon']}", style: const TextStyle(fontSize: 15)),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              "${stepDef['title']}",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: textColor,
                fontSize: isFinalLesson ? 15 : 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          if (isActive && !isFinalLesson) ...[
            const SizedBox(width: 7),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: activeColor,
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                "Sıradaki",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNodeSpot({
    required String status,
    required bool isFinalLesson,
    required Color themeColor,
    required VoidCallback onTap,
  }) {
    final Color nodeColor = isFinalLesson ? Colors.amber.shade600 : themeColor;
    final bool isActive = status == "active";
    final bool isCompleted = status == "completed";

    return AnimatedScale(
      scale: isActive
          ? 1.08
          : isCompleted
          ? 0.96
          : 0.90,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutBack,
      child: SizedBox(
        width: 116,
        height: 116,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (isActive)
              Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: nodeColor.withOpacity(0.12),
                ),
              ),
            if (isActive)
              Container(
                width: 94,
                height: 94,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: nodeColor.withOpacity(0.18),
                ),
              ),
            if (isCompleted)
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: nodeColor.withOpacity(0.08),
                ),
              ),
            LessonNode(status: status, themeColor: nodeColor, onTap: onTap),
          ],
        ),
      ),
    );
  }

  Future<void> _handleStepTap({
    required BuildContext context,
    required String status,
    required Map<String, dynamic> stepDef,
    required dynamic lesson,
    required int lessonIndex,
    required int stepIndex,
    required UserProgress progress,
    required Color themeColor,
  }) async {
    if (status == "locked") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Bu adım henüz kilitli! Öncekileri tamamla."),
        ),
      );
      return;
    }

    if (stepDef['type'] == "level_jump" &&
        widget.displayLevel != progress.currentLevel) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Bu final sınavı zaten tamamlandı. Eski seviyelerde sadece pratik yapabilirsin.",
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    dynamic result;

    if (stepDef['type'] == "minimal_pairs") {
      result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MinimalPairsScreen(
            id: lesson['id'] ?? 1,
            isPracticeMode: false,
            username: progress.userName,
            themeColor: themeColor,
            targetLanguage: widget.selectedLanguage,
            nativeLanguage: widget.nativeLanguage,
          ),
        ),
      );
    } else if (stepDef['type'].toString().startsWith("learn_")) {
      result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LearnActivityScreen(
            activityType: stepDef['type'],
            lessonTitle: lesson['title'] ?? "Bölüm",
            themeColor: themeColor,
            username: progress.userName,
            minLevel: lesson['min_level'] ?? "A1",
            targetLanguage: widget.selectedLanguage,
            lessonId: lesson['id'] ?? 1,
            sectionIndex: lessonIndex + 1, // 🌟 Python için Bölüm Numarası!
            nativeLanguage: widget.nativeLanguage,
          ),
        ),
      );
    } else if (stepDef['type'] == "speak") {
      result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PronunciationScreen(
            username: progress.userName,
            targetLanguage: widget.selectedLanguage,
            userLevel: lesson['min_level'] ?? "A1",
            targetWords: lesson['target_words'] ?? "",
            lessonId: lesson['id'],
            sectionIndex: lessonIndex + 1, // 🌟 Python için Bölüm Numarası!
            nativeLanguage: widget.nativeLanguage,
          ),
        ),
      );
    } else if (stepDef['type'] == "listen") {
      result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ListeningScreen(
            username: progress.userName,
            targetLanguage: widget.selectedLanguage,
            userLevel: lesson['min_level'] ?? "A1",
            targetWords: lesson['target_words'] ?? "",
            lessonId: lesson['id'],
            sectionIndex: lessonIndex + 1, // 🌟 Python için Bölüm Numarası!
            nativeLanguage: widget.nativeLanguage,
          ),
        ),
      );
    } else if (stepDef['type'] == "test") {
      result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FinalTestScreen(
            username: progress.userName,
            targetLanguage: widget.selectedLanguage,
            userLevel: widget.displayLevel,
            lessonId: lesson['id'],
          ),
        ),
      );
    } else if (stepDef['type'] == "level_jump") {
      bool? levelUpResult = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LevelUpScreen(
            username: progress.userName,
            targetLanguage: widget.selectedLanguage,
            currentLevel: progress.currentLevel,
            lessonId: lesson['id'] ?? (lessonIndex + 1),
          ),
        ),
      );

      if (levelUpResult == true && mounted) {
        setState(() {
          _progressFuture = ApiService.fetchUserProgress(
            widget.username,
            widget.selectedLanguage,
          );
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Yepyeni bir seviyeye hoş geldin! 🎉",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            backgroundColor: Color(0xFF06D6A0),
            duration: Duration(seconds: 3),
          ),
        );
      }
      result = null;
    }

    // 🌟 3. HARİTAYI İLERLETME VE XP KAZANMA MANTIĞI
    if (result == true && widget.displayLevel == progress.currentLevel) {
      // 🌟 KRİTİK DÜZELTME: Veritabanındaki 'current_section' listendeki sıradır (1, 2, 3...)
      int currentSect = lessonIndex + 1;
      int currentStep = stepIndex + 1;

      // Kullanıcı gerçekten haritada kaldığı son adımı tamamladıysa ilerlet!
      if (currentSect == progress.currentSection &&
          currentStep == progress.currentLesson) {
        int nextStep = currentStep + 1;
        int nextSect = currentSect;

        // Eğer o dersin 8 adımı da bittiyse bir sonraki Bölüme (Ders'e) geç!
        if (nextStep > stepDefinitions.length) {
          nextSect++;
          nextStep = 1;
        }

        // Dinleme ve Konuşma kendi içinden API'ye bağlanıp XP'yi (Örn 50) veriyor.
        // O yüzden Harita ekranı burada tekrar XP göndermesin (0 göndersin).
        // Görsel Öğrenim, Boşluk Doldurma ve Cümle Kurma için Harita XP verecek (+50).
        final bool isXpGivenInside =
            stepDef['type'] == "test" || stepDef['type'] == "learn_quiz";

        final int completionXp = isXpGivenInside ? 0 : 50;

        await ApiService.updateProgress(
          progress.userName,
          nextSect, // İlerlediği yeni bölüm (Örn: 2)
          nextStep, // İlerlediği yeni adım (Örn: 1)
          completionXp,
          widget.selectedLanguage,
          // Python'a "Bana bu kadar XP ekle" talebi
        );
      }
    }

    if (mounted) {
      setState(() {
        _progressFuture = ApiService.fetchUserProgress(
          widget.username,
          widget.selectedLanguage,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7FE),
        body: FutureBuilder<List<dynamic>>(
          future: Future.wait([_progressFuture, _lessonsFuture]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.blueAccent),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  "Hata: ${snapshot.error}",
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            final progress = snapshot.data![0] as UserProgress;
            final lessonsList = snapshot.data![1] as List<dynamic>;
            final themeColor = getThemeColor(widget.displayLevel);

            // 🌟 YENİ NESİL LİSTE (FLATTENING) 🌟
            // Tüm düğümleri dinamik olarak bu listeye dolduracağız
            List<Map<String, dynamic>> allNodes = [];

            final filteredLessons = lessonsList.where((lesson) {
              return lesson['min_level'] == widget.displayLevel;
            }).toList();

            for (int i = 0; i < filteredLessons.length; i++) {
              final lesson = filteredLessons[i];
              // Eğer listedeki SON ders ise bu Final Testidir!
              bool isFinalLesson = (i == filteredLessons.length - 1);

              if (isFinalLesson) {
                // FİNAL TESTİ İÇİN SADECE 1 DÜĞÜM (NODE) EKLE
                allNodes.add({
                  "lessonIndex": i,
                  "stepIndex": 0,
                  "lesson": lesson,
                  "stepDef": {
                    "type": "level_jump",
                    "title": "SEVİYE ATLA",
                    "icon": "🚀",
                  },
                  "isFirstStep": true,
                  "isFinalLesson": true,
                });
              } else {
                // DİĞER DERSLER İÇİN STANDART 8 ADIMI EKLE
                for (int j = 0; j < stepDefinitions.length; j++) {
                  allNodes.add({
                    "lessonIndex": i,
                    "stepIndex": j,
                    "lesson": lesson,
                    "stepDef": stepDefinitions[j],
                    "isFirstStep": (j == 0),
                    "isFinalLesson": false,
                  });
                }
              }
            }

            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    themeColor.withOpacity(0.10),
                    const Color(0xFFF4F7FE),
                    Colors.white,
                  ],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    _buildTopProfileCard(progress, themeColor),

                    // --- ZIGZAG HARİTA ---
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(34, 18, 34, 130),
                        itemCount: allNodes.length,
                        itemBuilder: (context, index) {
                          // Düğümün verilerini listeden çekiyoruz
                          final node = allNodes[index];
                          final int lessonIndex = node["lessonIndex"];
                          final int stepIndex = node["stepIndex"];
                          final lesson = node["lesson"];
                          final Map<String, dynamic> stepDef =
                              Map<String, dynamic>.from(node["stepDef"]);
                          final bool isFinalLesson = node["isFinalLesson"];

                          // Eğer geçmiş bir seviye görüntüleniyorsa final dahil her şey tamamlanmış görünür.
                          // Mevcut seviyede final testi yine aktif kalır.
                          String status = isFinalLesson
                              ? (_isPastLevel(progress)
                                    ? "completed"
                                    : "active")
                              : getStepStatus(
                                  progress,
                                  lessonIndex + 1,
                                  stepIndex + 1,
                                );

                          Alignment alignment = getZigzagAlignment(stepIndex);
                          final Color nodeThemeColor = isFinalLesson
                              ? Colors.amber.shade600
                              : themeColor;

                          return Column(
                            children: [
                              // HER DERSİN BAŞINDA (ve Final Testinde) BAŞLIK ÇIKAR
                              if (node["isFirstStep"])
                                _buildLessonHeader(
                                  lesson: lesson,
                                  lessonIndex: lessonIndex,
                                  progress: progress,
                                  themeColor: themeColor,
                                  isFinalLesson: isFinalLesson,
                                ),

                              // YUVARLAK DÜĞME
                              Align(
                                alignment: alignment,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 32.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _buildStepPill(
                                        stepDef: stepDef,
                                        status: status,
                                        themeColor: themeColor,
                                        isFinalLesson: isFinalLesson,
                                      ),
                                      const SizedBox(height: 10),
                                      _buildNodeSpot(
                                        status: status,
                                        isFinalLesson: isFinalLesson,
                                        themeColor: nodeThemeColor,
                                        onTap: () async {
                                          await _handleStepTap(
                                            context: context,
                                            status: status,
                                            stepDef: stepDef,
                                            lesson: lesson,
                                            lessonIndex: lessonIndex,
                                            stepIndex: stepIndex,
                                            progress: progress,
                                            themeColor: themeColor,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
