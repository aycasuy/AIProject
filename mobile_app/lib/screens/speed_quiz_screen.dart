import 'package:flutter/material.dart';
import 'package:mobile_app/l10n/app_localizations.dart';
import 'package:mobile_app/services/api_service.dart';
import 'package:lottie/lottie.dart';
import 'package:audioplayers/audioplayers.dart';

class SpeedQuizScreen extends StatefulWidget {
  final List<dynamic> comprehensionQuestions;
  final List<dynamic> vocabularyQuestions;
  final String level;
  final String username;
  final List<String> targetWords;
  final String targetLanguage;
  final int lessonId;

  const SpeedQuizScreen({
    Key? key,
    required this.comprehensionQuestions,
    required this.vocabularyQuestions,
    required this.level,
    required this.username,
    required this.targetWords,
    required this.targetLanguage,
    required this.lessonId,
  }) : super(key: key);

  @override
  State<SpeedQuizScreen> createState() => _SpeedQuizScreenState();
}

class _SpeedQuizScreenState extends State<SpeedQuizScreen> {
  List<dynamic> _allQuestions = [];
  int _currentIndex = 0;
  String? _selectedOption;
  bool _isAnswerChecked = false;
  int _correctCount = 0;

  // 🌟 YENİ: Çeviri durumunu tutan değişken
  bool _showTranslation = false;

  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _allQuestions = [
      ...widget.comprehensionQuestions,
      ...widget.vocabularyQuestions,
    ];
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  String _cleanAnswerText(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'^[a-d][\.\)\-]\s*'), '')
        .trim();
  }

  bool _isOptionCorrect(dynamic option, dynamic correctAnswer) {
    final String opt = option.toString().trim().toLowerCase();
    final String ans = correctAnswer.toString().trim().toLowerCase();

    final String cleanOption = _cleanAnswerText(opt);
    final String cleanCorrect = _cleanAnswerText(ans);

    if (cleanOption == cleanCorrect) {
      return true;
    }

    if (ans.length <= 2 && opt.isNotEmpty) {
      final String optionFirstLetter = opt.substring(0, 1);
      final String answerFirstLetter = ans.replaceAll(RegExp(r'[^a-d]'), '');

      return optionFirstLetter == answerFirstLetter &&
          ['a', 'b', 'c', 'd'].contains(optionFirstLetter);
    }

    return false;
  }

  void _checkAnswer() {
    if (_selectedOption == null) return;

    final currentQuestion = _allQuestions[_currentIndex];
    final bool isCorrect = _isOptionCorrect(
      _selectedOption,
      currentQuestion['correct_answer'],
    );

    setState(() {
      _isAnswerChecked = true;

      if (isCorrect) {
        _correctCount++;
      }
    });

    if (isCorrect) {
      _audioPlayer.play(AssetSource('lottie/sounds/click-.wav'));
    }
  }

  Future<void> _nextQuestion() async {
    if (_currentIndex < _allQuestions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOption = null;
        _isAnswerChecked = false;
        // 🌟 YENİ: Soru değişince çeviriyi tekrar gizle
        _showTranslation = false;
      });
      return;
    }

    _audioPlayer.play(AssetSource('lottie/sounds/win-sound.wav'));

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          const Center(child: CircularProgressIndicator(color: Colors.amber)),
    );

    final result = await ApiService.submitBossResult(
      username: widget.username,
      correctCount: _correctCount,
      totalQuestions: _allQuestions.length,
      targetWords: widget.targetWords,
      targetLanguage: widget.targetLanguage,
      lessonId: widget.lessonId,
    );

    if (context.mounted) Navigator.pop(context);

    if (!context.mounted) return;

    if (result != null) {
      _showResultDialog(
        earnedXp: result['earned_xp'] ?? 0,
        levelUp: result['level_up'] ?? false,
      );
    } else {
      _showResultDialog(earnedXp: 0, levelUp: false);
    }
  }

  void _showResultDialog({required int earnedXp, required bool levelUp}) {
    final loc = AppLocalizations.of(context)!;

    final Color themeColor = getThemeColor(widget.level);

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.58),
      transitionDuration: const Duration(milliseconds: 360),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: Lottie.asset(
                    'assets/lottie/animations/confetti.json',
                    fit: BoxFit.cover,
                    repeat: false,
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(26, 30, 26, 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(34),
                      boxShadow: [
                        BoxShadow(
                          color: themeColor.withOpacity(0.30),
                          blurRadius: 36,
                          offset: const Offset(0, 18),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 650),
                          curve: Curves.easeOutBack,
                          builder: (context, value, child) {
                            return Transform.scale(scale: value, child: child);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: themeColor.withOpacity(0.14),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              levelUp
                                  ? Icons.rocket_launch_rounded
                                  : Icons.emoji_events_rounded,
                              size: 66,
                              color: themeColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        Text(
                          levelUp
                              ? loc.speedQuizLevelUpTitle
                              : loc.speedQuizCongratulations,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF202124),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          levelUp
                              ? loc.speedQuizLevelUpMessage
                              : loc.speedQuizCompletedMessage,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: _buildResultStatCard(
                                icon: Icons.check_circle_rounded,
                                title: loc.speedQuizCorrectAnswers,
                                value:
                                    "$_correctCount / ${_allQuestions.length}",
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildResultStatCard(
                                icon: Icons.bolt_rounded,
                                title: loc.speedQuizXp,
                                value: "+$earnedXp",
                                color: Colors.amber.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          height: 58,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: themeColor,
                              elevation: 8,
                              shadowColor: themeColor.withOpacity(0.35),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(dialogContext);

                              if (mounted) {
                                Navigator.pop(context, true);
                              }
                            },
                            child: Text(
                              loc.speedQuizContinue,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );

        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: curvedAnimation, child: child),
        );
      },
    );
  }

  Widget _buildResultStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withOpacity(0.22)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF202124),
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    if (_allQuestions.isEmpty) {
      return const Scaffold(body: Center(child: Text("Soru bulunamadı.")));
    }

    final currentQuestion = _allQuestions[_currentIndex];
    final List<dynamic> options = currentQuestion['options'] ?? [];
    final Color themeColor = getThemeColor(widget.level);
    final String questionText = (currentQuestion['question'] ?? '').toString();
    final String questionTranslation =
        (currentQuestion['question_translation'] ?? '').toString().trim();

    return Scaffold(
      backgroundColor: themeColor.withOpacity(0.1),
      appBar: AppBar(
        backgroundColor: themeColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          "Soru ${_currentIndex + 1} / ${_allQuestions.length}",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 🌟 YENİ: ÇEVİRİYİ GÖSTER/GİZLE MEKANİZMALI SORU KARTI
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: themeColor, width: 2),
              ),
              child: Column(
                children: [
                  Text(
                    questionText,
                    style: const TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (questionTranslation.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    if (_showTranslation)
                      Text(
                        questionTranslation,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.62),
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      )
                    else
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _showTranslation = true;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: themeColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.g_translate,
                                color: themeColor,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                loc.speedQuizShowTranslation,
                                style: TextStyle(
                                  color: themeColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 32),
            ...options.map((option) {
              final bool isSelected = _selectedOption == option;
              final bool isCorrect = _isOptionCorrect(
                option,
                currentQuestion['correct_answer'],
              );

              Color buttonColor = Colors.grey[800]!;

              if (_isAnswerChecked) {
                if (isCorrect) {
                  buttonColor = Colors.green.shade700;
                } else if (isSelected && !isCorrect) {
                  buttonColor = Colors.red.shade700;
                }
              } else if (isSelected) {
                buttonColor = themeColor.withOpacity(0.35);
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: _isAnswerChecked
                      ? null
                      : () {
                          setState(() {
                            _selectedOption = option;
                          });
                        },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: buttonColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected && !_isAnswerChecked
                            ? themeColor
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      option.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
              );
            }).toList(),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedOption == null
                    ? Colors.grey
                    : themeColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: _selectedOption == null
                  ? null
                  : (_isAnswerChecked ? _nextQuestion : _checkAnswer),
              child: Text(
                _isAnswerChecked
                    ? loc.speedQuizNextQuestion
                    : loc.speedQuizCheckAnswer,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
}
