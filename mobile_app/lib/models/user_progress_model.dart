// lib/models/user_progress_model.dart

class UserProgress {
  final String userName; // Şimdilik arayüzde göstermek için
  final String currentLevel;
  final int currentSection;
  final int currentLesson;
  final int xpScore;
  final int streakDays;
  final int lives;
  final int remainingSeconds;

  UserProgress({
    required this.userName,
    required this.currentLevel,
    required this.currentSection,
    required this.currentLesson,
    required this.xpScore,
    required this.streakDays,
    required this.lives,
    required this.remainingSeconds,
  });

  // Backend'den gelen JSON'u Dart objesine dönüştüren kurucu (Factory)
  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      userName: json['user_name'] ?? "Kullanıcı",
      currentLevel: json['level'] ?? "A1",
      currentSection: json['current_section'] ?? 1,
      currentLesson: json['current_lesson'] ?? 1,
      xpScore: json['xp_score'] ?? 0,
      streakDays: json['streak_days'] ?? 0,
      lives: json['lives'] ?? 5,
      remainingSeconds: json['remaining_seconds'] ?? 0, // 🌟 JSON'DAN OKU
    );
  }
}
