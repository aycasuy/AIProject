import 'package:flutter/material.dart';
import 'package:mobile_app/screens/flashcard_practice_screen.dart';
import 'package:mobile_app/screens/main_navigation.dart';
import 'package:mobile_app/screens/practice_screen.dart';
import 'package:mobile_app/screens/settings_screen.dart';
// 🌟 GRAFİK KÜTÜPHANESİ EKLENDİ
import '../services/api_service.dart'; // Bu yolu kendi projene göre düzelt
import 'package:mobile_app/l10n/app_localizations.dart';

class ProfileScreen extends StatefulWidget {
  final String username;
  final String targetLanguage;
  final String userLevel;
  final String nativeLanguage;

  const ProfileScreen({
    super.key,
    required this.username,
    required this.targetLanguage,
    required this.userLevel,
    required this.nativeLanguage,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // 🌟 VERİ DEĞİŞKENLERİ
  bool _isLoading = true;
  int _totalXp = 0;
  int _lives = 5;
  int _currentSection = 1;
  int _currentLesson = 1;
  int _streak = 0;
  List<int> _weeklyXp = [
    0,
    0,
    0,
    0,
    0,
    0,
    0,
  ]; // Pzt, Sal, Çar... başlangıçta sıfır
  // 🌟 YENİ: Öğrenme Merkezi Değişkenleri
  int _totalWords = 0;
  int _learnedWords = 0;
  int _mistakeCount = 0;
  int _unlearnedWords = 0;
  String _realMaxLevel = ""; // 🌟 EKLENECEK YENİ DEĞİŞKEN

  String _localizedLanguageName(String language, AppLocalizations loc) {
    switch (language.toLowerCase()) {
      case "english":
        return loc.langEnglish;
      case "spanish":
        return loc.langSpanish;
      case "german":
        return loc.langGerman;
      case "french":
        return loc.langFrench;
      case "turkish":
        return loc.langTurkish;
      default:
        return language;
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserStats();
  }

  // --- API'DEN İSTATİSTİKLERİ ÇEKME ---
  Future<void> _fetchUserStats() async {
    try {
      final progress = await ApiService.fetchUserProgress(
        widget.username,
        widget.targetLanguage,
      );
      // 2. 🌟 YENİ: Haftalık XP listesini çek
      final weeklyData = await ApiService.fetchWeeklyXp(widget.username);

      final List<int> safeWeeklyXp = List<int>.filled(7, 0);

      for (int i = 0; i < weeklyData.length && i < safeWeeklyXp.length; i++) {
        safeWeeklyXp[i] = weeklyData[i];
      }

      // 🌟 YENİ: Öğrenme İstatistiklerini Çek
      final learningStats = await ApiService.fetchLearningStats(
        widget.username,
        widget.targetLanguage,
      );

      if (mounted) {
        setState(() {
          _totalXp = progress.xpScore;
          _lives = progress.lives;
          _currentSection = progress.currentSection;
          _currentLesson = progress.currentLesson;
          _streak = progress.streakDays;
          _weeklyXp = safeWeeklyXp;
          // 🌟 YENİ: Gelen verileri state'e kaydet
          _totalWords = learningStats["total_words"] ?? 0;
          _learnedWords = learningStats["learned_words"] ?? 0;
          _mistakeCount = learningStats["mistake_count"] ?? 0;
          _unlearnedWords = learningStats["unlearned_words"] ?? 0;
          _realMaxLevel = progress
              .currentLevel; // 🌟 GERÇEK SEVİYEYİ DB'DEN ÇEKİP SAKLIYORUZ
          _isLoading = false;
        });
      }
    } catch (e) {
      print("İstatistik çekme hatası: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          loc.profileTitle,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black54),
            onPressed: () async {
              // 1. Ayarlar sayfasına git ve oradan dönen cevabı (result) bekle
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(
                    username: widget.username,
                    currentLanguage: widget.targetLanguage,
                    currentLevel: _realMaxLevel.isNotEmpty
                        ? _realMaxLevel
                        : widget.userLevel,
                  ),
                ),
              );

              // 🌟 YENİ MANTIK: Gelen cevap bir Map (Sözlük) ise işleme alıyoruz!
              if (result != null && result is Map<String, String>) {
                String newLanguage =
                    result["language"] ?? widget.targetLanguage;
                String newLevel = result["level"] ?? widget.userLevel;

                try {
                  // Eğer kullanıcı dili DEĞİŞTİRDİYSE, veritabanından o yeni dilin GERÇEK maksimum seviyesini öğrenmeliyiz.
                  // Yoksa İspanyolcaya geçer ama A2'den başlatırız, halbuki İspanyolcası A1 olabilir!
                  if (newLanguage != widget.targetLanguage) {
                    final progress = await ApiService.fetchUserProgress(
                      widget.username,
                      newLanguage,
                    );
                    newLevel = progress.currentLevel;
                  }

                  if (mounted) {
                    // 🌟 BÜTÜN UYGULAMAYI YENİ DİL VEYA SEVİYEYLE BAŞTAN BAŞLAT!
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MainNavigationScreen(
                          username: widget.username,
                          targetLanguage: newLanguage, // Örn: English
                          nativeLanguage: widget.nativeLanguage,
                          minLevel:
                              newLevel, // 🌟 A1'i seçtiyse A1, A2'yi seçtiyse A2 olarak haritayı açar!
                        ),
                      ),
                      (Route<dynamic> route) => false,
                    );
                  }
                } catch (e) {
                  print("Dil/Seviye değiştirilirken hata oluştu: $e");
                }
              }
              // Eğer ayarlardan sadece bildirim vs. değişip true döndüyse
              else if (result == true) {
                _fetchUserStats();
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF118AB2)),
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // 1. AŞAMA: HERO BÖLÜMÜ
                  _buildHeroSection(),

                  const SizedBox(height: 30),

                  // 2. AŞAMA: 4'LÜ İSTATİSTİK GRID'İ
                  _buildStatGrid(),

                  const SizedBox(height: 30),

                  // 🌟 3. AŞAMA: HAFTALIK XP GRAFİĞİ
                  _buildWeeklyXpChart(),

                  const SizedBox(height: 40),

                  // 🌟 4. AŞAMA: Öğrenme Merkezi
                  _buildLearningCenter(),

                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  // --- 1. HERO BÖLÜMÜ ---
  Widget _buildHeroSection() {
    final loc = AppLocalizations.of(context)!;

    final String languageName = _localizedLanguageName(
      widget.targetLanguage,
      loc,
    );

    final String currentLevel = _realMaxLevel.isNotEmpty
        ? _realMaxLevel
        : widget.userLevel;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF06D6A0), Color(0xFF118AB2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF118AB2).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 55,
            backgroundColor: Colors.white,
            child: Text(
              widget.username.isNotEmpty
                  ? widget.username[0].toUpperCase()
                  : "?",
              style: const TextStyle(
                fontSize: 45,
                fontWeight: FontWeight.bold,
                color: Color(0xFF118AB2),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          widget.username,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D2D2D),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade300, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.language, size: 20, color: Color(0xFF118AB2)),
              const SizedBox(width: 8),
              Text(
                loc.profileLanguageLevel(languageName, currentLevel),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- 2. İSTATİSTİK GRID TASARIMI ---
  Widget _buildStatGrid() {
    final loc = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.1,
        children: [
          _buildStatCard(
            loc.profileTotalXp,
            "$_totalXp",
            Icons.bolt,
            const Color(0xFFFFB703),
          ),
          _buildStatCard(
            loc.profileRemainingLives,
            "$_lives / 5",
            Icons.favorite,
            const Color(0xFFFF4D6D),
          ),
          _buildStatCard(
            loc.profileProgress,
            loc.profileProgressValue(_currentSection, _currentLesson),
            Icons.map_rounded,
            const Color(0xFF00B4D8),
            valueFontSize: 17,
          ),
          _buildStatCard(
            loc.profileDayStreak,
            loc.profileDayCount(_streak),
            Icons.local_fire_department_rounded,
            const Color(0xFFF4A261),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color themeColor, {
    double valueFontSize = 22,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: themeColor.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: themeColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: themeColor, size: 32),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: valueFontSize,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D2D2D),
              height: 1.15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // --- 🌟 PAKETSİZ, %100 SAF FLUTTER XP GRAFİĞİ ---
  // --- 🌟 GERÇEK VERİYLE ÇALIŞAN SAF FLUTTER XP GRAFİĞİ ---
  Widget _buildWeeklyXpChart() {
    final loc = AppLocalizations.of(context)!;

    final List<String> days = [
      loc.profileMondayShort,
      loc.profileTuesdayShort,
      loc.profileWednesdayShort,
      loc.profileThursdayShort,
      loc.profileFridayShort,
      loc.profileSaturdayShort,
      loc.profileSundayShort,
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF118AB2).withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.profileWeeklyXpAnalysis,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D2D2D),
            ),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(
              7,
              (index) =>
                  _buildCustomBar(days[index], _weeklyXp[index].toDouble()),
            ),
          ),
        ],
      ),
    );
  }

  // --- SAF FLUTTER ÇUBUK ÇİZİCİ ---
  Widget _buildCustomBar(String day, double xp) {
    const double maxChartHeight = 150.0;
    const double maxKapasite = 500.0; // Günlük hedeflenen Max XP

    // XP oranına göre yüksekliği belirliyoruz
    double fillHeight = (xp / maxKapasite) * maxChartHeight;
    if (fillHeight > maxChartHeight) fillHeight = maxChartHeight;
    if (fillHeight < 0) fillHeight = 0;

    return Column(
      children: [
        SizedBox(
          height: maxChartHeight,
          width: 16,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutQuart,
                height: fillHeight,
                decoration: BoxDecoration(
                  color: const Color(0xFF118AB2),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          day,
          style: TextStyle(
            color: Colors.grey.shade500,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // --- 🌟 YENİ: ÖĞRENME MERKEZİ KARTLARI ---
  Widget _buildLearningCenter() {
    final loc = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Text(
            loc.profileLearningCenter,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D2D2D),
            ),
          ),
        ),

        // 1. Kelime Kumbarası (İlerleme Çubuğu)
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.blueGrey.withOpacity(0.08),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.menu_book_rounded,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        loc.profileWordBank,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "$_learnedWords / $_totalWords",
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              // Şık İlerleme Çubuğu
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: _totalWords > 0 ? (_learnedWords / _totalWords) : 0,
                  minHeight: 12,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              ),
            ],
          ),
        ),

        // 2. 🧠 HATALARI TEKRAR ET BUTONU (Sadece hata varsa görünür!)
        if (_mistakeCount > 0)
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PracticeScreen(
                    username: widget.username,
                    targetLanguage: widget.targetLanguage,
                    nativeLanguage: widget.nativeLanguage,
                  ),
                ),
              ).then((_) {
                // Sayfadan geri dönüldüğünde istatistikleri yenile (belki hata sayısını azaltmıştır!)
                _fetchUserStats();
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFF6B6B),
                    Color(0xFFEE5253),
                  ], // Ateşli Kırmızı!
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF6B6B).withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.psychology_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.profileDailyTraining,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          loc.profileDailyQuestions(_mistakeCount),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),

        const SizedBox(height: 30),

        // Sayfanın altına nefes payı
        if (_unlearnedWords > 0)
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FlashcardPracticeScreen(
                    username: widget.username,
                    targetLanguage: widget
                        .targetLanguage, // 🌟 Hedef dili buradan yolluyoruz!
                    nativeLanguage: widget.nativeLanguage,
                  ),
                ),
              ).then((_) {
                // Geri dönünce istatistikleri güncelle (Öğrenilen kelimeler artmış olabilir!)
                _fetchUserStats();
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF6C5CE7),
                    Color(0xFF81ECEC),
                  ], // Şık Mor-Turkuaz Geçişi
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6C5CE7).withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.style_rounded,
                    color: Colors.white,
                    size: 32,
                  ), // Flashcard İkonu
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.profileWordTraining,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          loc.profileUnlearnedWords(_unlearnedWords),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // --- SAF FLUTTER ÇUBUK ÇİZİCİ ---
}
