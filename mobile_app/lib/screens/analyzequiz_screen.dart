import 'package:flutter/material.dart';
import 'package:mobile_app/services/api_service.dart';
import 'package:lottie/lottie.dart';
import 'package:audioplayers/audioplayers.dart';

class QuizScreen extends StatefulWidget {
  final List<dynamic> questions;
  final String username;
  final String targetLanguage;
  final int sectionIndex;
  final int lessonId;
  final String originalText;
  final String nativeLanguage;

  const QuizScreen({
    super.key,
    required this.questions,
    required this.username,
    required this.targetLanguage,
    required this.sectionIndex,
    required this.lessonId,
    this.originalText = "",
    required this.nativeLanguage,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 0;
  int _score = 0;
  bool _isAnswered = false;
  String _selectedOption = "";
  bool _isFinishing = false;

  final AudioPlayer _audioPlayer = AudioPlayer();

  static const Color _primaryColor = Color(0xFF7C4DFF);
  static const Color _secondaryColor = Color(0xFF1CB0F6);
  static const Color _successColor = Color(0xFF58CC02);
  static const Color _dangerColor = Color(0xFFFF4B4B);
  static const Color _darkText = Color(0xFF2D2D2D);
  static const Color _softBackground = Color(0xFFF6F7FF);

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  bool _isCorrectAnswer(String option, Map<String, dynamic> question) {
    final correctAnswer = (question['correct_answer'] ?? '').toString().trim();
    return option.trim() == correctAnswer;
  }

  void _checkAnswer(String option) {
    if (_isAnswered) return;

    final question = Map<String, dynamic>.from(widget.questions[_currentIndex]);
    final bool isCorrect = _isCorrectAnswer(option, question);

    setState(() {
      _selectedOption = option;
      _isAnswered = true;

      if (isCorrect) {
        _score++;
      }
    });

    if (isCorrect) {
      _audioPlayer.play(AssetSource('lottie/sounds/click-.wav'));
    }
  }

  Future<void> _nextQuestion() async {
    if (_currentIndex < widget.questions.length - 1) {
      setState(() {
        _currentIndex++;
        _isAnswered = false;
        _selectedOption = "";
      });
      return;
    }

    await _finishQuiz();
  }

  Future<void> _finishQuiz() async {
    if (_isFinishing) return;

    setState(() => _isFinishing = true);

    _audioPlayer.play(AssetSource('lottie/sounds/win-sound.wav'));

    final int earnedXp = _score * 20;

    try {
      if (earnedXp > 0) {
        await ApiService.addXp(
          widget.username,
          widget.targetLanguage,
          earnedXp,
          widget.sectionIndex,
          widget.lessonId,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("XP kaydedilirken hata oluştu: $e"),
            backgroundColor: _dangerColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isFinishing = false);
        _showResultDialog(earnedXp: earnedXp);
      }
    }
  }

  double get _progressValue {
    if (widget.questions.isEmpty) return 0;
    return (_currentIndex + 1) / widget.questions.length;
  }

  void _showOriginalTextSheet() {
    final String text = widget.originalText.trim();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.78,
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      color: _primaryColor.withOpacity(0.11),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.article_rounded,
                      color: _primaryColor,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Orijinal Metin",
                          style: TextStyle(
                            color: _darkText,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "Soruları çözerken metne tekrar bakabilirsin.",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    color: Colors.grey,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: _softBackground,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: text.isEmpty
                      ? const Center(
                          child: Text(
                            "Bu test için gösterilecek metin bulunamadı.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Text(
                            text,
                            style: const TextStyle(
                              color: _darkText,
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              height: 1.55,
                            ),
                          ),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.96),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
                color: _darkText,
              ),
              Expanded(
                child: Text(
                  "Kelime Avı Testi",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _darkText,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _primaryColor.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      "$_score/${widget.questions.length}",
                      style: const TextStyle(
                        color: _primaryColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: _showOriginalTextSheet,
                    child: Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: _secondaryColor.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.article_rounded,
                        color: _secondaryColor,
                        size: 21,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                "Soru ${_currentIndex + 1}",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: _progressValue,
                    minHeight: 10,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      _primaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "${widget.questions.length}",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionTypePill(String qType) {
    final bool isBlank = qType == 'fill_in_the_blank';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      decoration: BoxDecoration(
        color: isBlank
            ? _secondaryColor.withOpacity(0.10)
            : _primaryColor.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isBlank
              ? _secondaryColor.withOpacity(0.20)
              : _primaryColor.withOpacity(0.20),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isBlank ? Icons.edit_note_rounded : Icons.quiz_rounded,
            color: isBlank ? _secondaryColor : _primaryColor,
            size: 18,
          ),
          const SizedBox(width: 7),
          Text(
            isBlank ? "Boşluk Doldurma" : "Çoktan Seçmeli",
            style: TextStyle(
              color: isBlank ? _secondaryColor : _primaryColor,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard({
    required Widget child,
    required IconData icon,
    required String title,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _primaryColor.withOpacity(0.12), width: 1.4),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.10),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: _primaryColor, size: 28),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }

  // --- BOŞLUK DOLDURMA ARAYÜZÜ ---
  Widget _buildFillInTheBlank(Map<String, dynamic> question) {
    final String sentence = (question['question'] ?? '').toString();
    final List<String> parts = sentence.split("___");
    final List<dynamic> wordBank = question['word_bank'] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildQuestionCard(
          icon: Icons.draw_rounded,
          title: "Doğru kelimeyi seç ve boşluğu tamamla",
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 10,
            children: [
              if (parts.isNotEmpty)
                Text(
                  parts[0],
                  style: const TextStyle(
                    fontSize: 22,
                    color: _darkText,
                    fontWeight: FontWeight.w900,
                    height: 1.35,
                  ),
                ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: _selectedOption.isEmpty
                      ? Colors.grey.shade100
                      : (_isAnswered
                            ? (_isCorrectAnswer(_selectedOption, question)
                                  ? _successColor
                                  : _dangerColor)
                            : _secondaryColor),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _selectedOption.isEmpty
                        ? Colors.grey.shade300
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Text(
                  _selectedOption.isEmpty ? "       " : _selectedOption,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    color: _selectedOption.isEmpty
                        ? Colors.transparent
                        : Colors.white,
                  ),
                ),
              ),
              if (parts.length > 1)
                Text(
                  parts[1],
                  style: const TextStyle(
                    fontSize: 22,
                    color: _darkText,
                    fontWeight: FontWeight.w900,
                    height: 1.35,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            const Icon(
              Icons.auto_awesome_rounded,
              color: _primaryColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              "Kelime bankası",
              style: TextStyle(
                color: Colors.grey.shade800,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: wordBank.map((word) {
            final String wordText = word.toString();
            final bool isSelected = wordText == _selectedOption;
            final bool isCorrect = _isCorrectAnswer(wordText, question);

            Color borderColor = _primaryColor.withOpacity(0.35);
            Color backgroundColor = Colors.white;
            Color textColor = _darkText;

            if (_isAnswered) {
              if (isCorrect) {
                backgroundColor = _successColor;
                borderColor = _successColor;
                textColor = Colors.white;
              } else if (isSelected && !isCorrect) {
                backgroundColor = _dangerColor;
                borderColor = _dangerColor;
                textColor = Colors.white;
              }
            } else if (isSelected) {
              backgroundColor = _primaryColor.withOpacity(0.12);
              borderColor = _primaryColor;
              textColor = _primaryColor;
            }

            return GestureDetector(
              onTap: _isAnswered ? null : () => _checkAnswer(wordText),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 13,
                ),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: borderColor, width: 1.6),
                  boxShadow: [
                    if (!_isAnswered)
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 7),
                      ),
                  ],
                ),
                child: Text(
                  wordText,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: textColor,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // --- ÇOKTAN SEÇMELİ ARAYÜZÜ ---
  Widget _buildMultipleChoice(Map<String, dynamic> question) {
    final List<dynamic> options = question['options'] ?? [];
    final String questionText = (question['question'] ?? '').toString();
    final String translation = (question['question_translation'] ?? '')
        .toString()
        .trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildQuestionCard(
          icon: Icons.help_rounded,
          title: "Soruyu cevapla",
          child: Column(
            children: [
              Text(
                questionText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                  color: _darkText,
                  height: 1.28,
                ),
              ),
              if (translation.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: _primaryColor.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    translation,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
        ...options.map((option) {
          final String optionText = option.toString();
          final bool isCorrect = _isCorrectAnswer(optionText, question);
          final bool isSelected = optionText == _selectedOption;

          Color btnColor = Colors.white;
          Color textColor = _darkText;
          Color borderColor = Colors.grey.shade200;
          IconData? trailingIcon;

          if (_isAnswered) {
            if (isCorrect) {
              btnColor = _successColor;
              textColor = Colors.white;
              borderColor = _successColor;
              trailingIcon = Icons.check_circle_rounded;
            } else if (isSelected && !isCorrect) {
              btnColor = _dangerColor;
              textColor = Colors.white;
              borderColor = _dangerColor;
              trailingIcon = Icons.cancel_rounded;
            }
          } else if (isSelected) {
            btnColor = _primaryColor.withOpacity(0.10);
            textColor = _primaryColor;
            borderColor = _primaryColor;
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: _isAnswered ? null : () => _checkAnswer(optionText),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  vertical: 17,
                  horizontal: 18,
                ),
                decoration: BoxDecoration(
                  color: btnColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor, width: 1.5),
                  boxShadow: [
                    if (!_isAnswered)
                      BoxShadow(
                        color: Colors.black.withOpacity(0.045),
                        blurRadius: 12,
                        offset: const Offset(0, 7),
                      ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        optionText,
                        style: TextStyle(
                          fontSize: 16.5,
                          color: textColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (trailingIcon != null)
                      Icon(trailingIcon, color: Colors.white, size: 24),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildFeedbackCard(Map<String, dynamic> question) {
    final bool isCorrect = _isCorrectAnswer(_selectedOption, question);
    final String explanation =
        (question['explanation'] ?? 'Açıklama bulunmuyor.').toString();

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: !_isAnswered
          ? const SizedBox.shrink()
          : Container(
              key: ValueKey(_currentIndex),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isCorrect
                    ? _successColor.withOpacity(0.10)
                    : _dangerColor.withOpacity(0.10),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isCorrect
                      ? _successColor.withOpacity(0.24)
                      : _dangerColor.withOpacity(0.24),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    isCorrect ? Icons.check_circle_rounded : Icons.info_rounded,
                    color: isCorrect ? _successColor : _dangerColor,
                    size: 26,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isCorrect
                          ? "Harika! Doğru cevap.\n$explanation"
                          : "Tekrar bakalım.\n$explanation",
                      style: TextStyle(
                        color: isCorrect
                            ? Colors.green.shade800
                            : Colors.red.shade800,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void _showResultDialog({required int earnedXp}) {
    final double successRate = widget.questions.isEmpty
        ? 0
        : _score / widget.questions.length;
    final bool excellent = successRate >= 0.8;

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.58),
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, animation, secondaryAnimation) {
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
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(34),
                      boxShadow: [
                        BoxShadow(
                          color: _primaryColor.withOpacity(0.25),
                          blurRadius: 35,
                          offset: const Offset(0, 18),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: (excellent ? _successColor : _primaryColor)
                                .withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            excellent
                                ? Icons.emoji_events_rounded
                                : Icons.flag_rounded,
                            size: 64,
                            color: excellent ? _successColor : _primaryColor,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          excellent ? "Mükemmel!" : "Test Tamamlandı!",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 30,
                            color: _darkText,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          excellent
                              ? "Kelime avında çok iyi iş çıkardın."
                              : "Pratik yaptıkça daha da hızlanacaksın.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: _buildResultStatCard(
                                icon: Icons.check_circle_rounded,
                                title: "Skor",
                                value: "$_score/${widget.questions.length}",
                                color: _successColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildResultStatCard(
                                icon: Icons.bolt_rounded,
                                title: "XP",
                                value: "+$earnedXp",
                                color: Colors.amber,
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
                              backgroundColor: _primaryColor,
                              elevation: 8,
                              shadowColor: _primaryColor.withOpacity(0.35),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pop(context, true);
                            },
                            child: const Text(
                              "Devam Et",
                              style: TextStyle(
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
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          child: FadeTransition(opacity: animation, child: child),
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
              color: _darkText,
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
    if (widget.questions.isEmpty) {
      return const Scaffold(
        backgroundColor: _softBackground,
        body: Center(
          child: Text(
            "Soru bulunamadı.",
            style: TextStyle(
              color: _darkText,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    final Map<String, dynamic> question = Map<String, dynamic>.from(
      widget.questions[_currentIndex],
    );
    final String qType = question['type'] ?? 'multiple_choice';

    return Scaffold(
      backgroundColor: _softBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressHeader(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _buildQuestionTypePill(qType),
                    ),
                    const SizedBox(height: 18),
                    if (qType == 'fill_in_the_blank')
                      _buildFillInTheBlank(question)
                    else
                      _buildMultipleChoice(question),
                    const SizedBox(height: 20),
                    _buildFeedbackCard(question),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: _isAnswered
                  ? Container(
                      key: const ValueKey("continue_button"),
                      padding: const EdgeInsets.fromLTRB(22, 12, 22, 22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 18,
                            offset: const Offset(0, -8),
                          ),
                        ],
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: ElevatedButton(
                          onPressed: _isFinishing ? null : _nextQuestion,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryColor,
                            disabledBackgroundColor: Colors.grey.shade300,
                            elevation: 8,
                            shadowColor: _primaryColor.withOpacity(0.32),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                          ),
                          child: _isFinishing
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3,
                                  ),
                                )
                              : Text(
                                  _currentIndex < widget.questions.length - 1
                                      ? "Devam Et"
                                      : "Sonucu Gör",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
