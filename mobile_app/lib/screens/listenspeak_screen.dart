import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../services/api_service.dart';

class ListeningScreen extends StatefulWidget {
  final String username;
  final String targetLanguage;
  final String userLevel;
  final String targetWords;
  final int sectionIndex;
  final int lessonId;

  const ListeningScreen({
    super.key,
    required this.username,
    required this.targetLanguage,
    required this.userLevel,
    required this.targetWords,
    required this.sectionIndex,
    required this.lessonId,
  });

  @override
  State<ListeningScreen> createState() => _ListeningScreenState();
}

class _ListeningScreenState extends State<ListeningScreen>
    with TickerProviderStateMixin {
  late FlutterTts _flutterTts;
  bool _isLoadingText = true;
  bool _isSpeaking = false;
  bool _showInput = false;
  bool _isAnalyzing = false;

  String _targetText = "";
  final TextEditingController _textController = TextEditingController();
  late final AnimationController _lottieController;

  int _currentRound = 1;
  final int _totalRounds = 3;
  bool _isAllFinished = false;

  int _lives = 0;
  bool _isLoadingLives = true;
  bool _isGameOver = false;

  int _remainingSeconds = 0;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();

    _lottieController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );

    _initTts();
    _fetchCurrentLives();
    _fetchDictationText();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _flutterTts.stop();
    _textController.dispose();
    _lottieController.dispose();
    super.dispose();
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
        return Colors.green.shade500;
    }
  }

  String _getLanguageCode(String language) {
    switch (language.toLowerCase()) {
      case "english":
        return "en-US";
      case "spanish":
        return "es-ES";
      case "french":
        return "fr-FR";
      case "german":
        return "de-DE";
      case "turkish":
        return "tr-TR";
      case "italian":
        return "it-IT";
      default:
        return "en-US";
    }
  }

  String get _formattedTime {
    int minutes = _remainingSeconds ~/ 60;
    int seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _startTimer() {
    _countdownTimer?.cancel();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        timer.cancel();
        _fetchCurrentLives();
      }
    });
  }

  Future<void> _fetchCurrentLives() async {
    try {
      final progress = await ApiService.fetchUserProgress(
        widget.username,
        widget.targetLanguage,
      );

      if (mounted) {
        setState(() {
          _lives = progress.lives;
          _remainingSeconds = progress.remainingSeconds;
          _isLoadingLives = false;

          if (_lives <= 0) {
            _isGameOver = true;
            if (_remainingSeconds > 0) _startTimer();
          } else {
            _isGameOver = false;
            if (_lives < 5 && _remainingSeconds > 0) _startTimer();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingLives = false);
      }
    }
  }

  void _initTts() {
    _flutterTts = FlutterTts();
    _flutterTts.setLanguage(_getLanguageCode(widget.targetLanguage));
    _flutterTts.setSpeechRate(0.45);
    _flutterTts.setPitch(1.0);

    _flutterTts.setCompletionHandler(() {
      if (mounted) {
        setState(() {
          _isSpeaking = false;
          _showInput = true;
        });
        _lottieController.stop();
      }
    });

    _flutterTts.setErrorHandler((message) {
      if (mounted) {
        setState(() {
          _isSpeaking = false;
          _showInput = true;
        });
        _lottieController.stop();
      }
    });
  }

  Future<void> _fetchDictationText() async {
    setState(() => _isLoadingText = true);

    try {
      final url = Uri.parse('http://10.0.2.2:8000/generate_pronunciation_text');

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "target_language": widget.targetLanguage,
          "level": widget.userLevel,
          "target_words": widget.targetWords,
          "lesson_id": widget.lessonId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));

        if (mounted) {
          setState(() {
            _targetText = data['text'];
            _isLoadingText = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _targetText = "";
            _isLoadingText = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _targetText = "";
          _isLoadingText = false;
        });
      }
    }
  }

  Future<void> _speakText() async {
    if (_targetText.isEmpty || _isSpeaking) return;

    setState(() {
      _isSpeaking = true;
      _showInput = false;
    });

    _lottieController.repeat();
    await _flutterTts.speak(_targetText);
  }

  Future<void> _checkAnswer() async {
    setState(() => _isAnalyzing = true);

    try {
      final url = Uri.parse('http://10.0.2.2:8000/analyze_listening');
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": widget.username,
          "target_language": widget.targetLanguage,
          "original_text": _targetText,
          "user_text": _textController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final analysis = data['analysis'];

        final int score = analysis['score'] ?? 0;
        final String feedback =
            analysis['feedback'] ?? "Değerlendirme tamamlandı.";
        final List<String> missedWords = List<String>.from(
          analysis['missed_words'] ?? [],
        );

        final bool isSuccess = score >= 60;

        // 🌟 DEĞİŞİKLİK 1: Flutter artık kendi kafasına göre XP hesaplamıyor!
        // Sadece kullanıcının testi geçip geçmediğini kontrol ediyoruz. XP işi Backend'e ait.
        int xpToGive = 0;

        if (!isSuccess) {
          setState(() => _lives--);
          await ApiService.decreaseLife(
            widget.username,
            targetLanguage: widget.targetLanguage,
          );

          if (_lives <= 0) {
            final p = await ApiService.fetchUserProgress(
              widget.username,
              widget.targetLanguage,
            );
            setState(() {
              _remainingSeconds = p.remainingSeconds;
              _isGameOver = true;
            });
            _startTimer();
          }
        } else {
          // 🌟 DEĞİŞİKLİK 2: ApiService.addXp SİLİNDİ!
          // Her soruda XP basmak yerine, ilerlemeyi ve bölüm/ders kontrolünü Python'a bırakıyoruz.

          // Kullanıcı bu soruyu geçti, eğer son turdaysa (3/3 bittiyse) Backend'e İlerlemeyi (ve XP'yi) güncellemesini söyle.
          if (_currentRound == _totalRounds) {
            // ApiService.updateProgress zaten Backend'e bağlı, xp'yi ve replay durumunu oradan çekeceğiz!
            // 50 yazsak bile Backend "Aaa bu replay, 0 XP vereyim" diyebilir.
          } else {
            // Son tur değilse (Örn 1/3) XP'yi 15 falan ayarlayabilirsin ama güvenliği Backend yapacak.
            xpToGive = 15; // 🌟 Sembolik görsel XP, istersen 0 yapabilirsin
          }
        }

        if (mounted) {
          _showResultDialog(score, feedback, missedWords, xpToGive, isSuccess);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Bağlantı hatası: $e"),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  Widget _buildProgressBar(int current, int total, Color themeColor) {
    return Container(
      height: 12,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(20),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: total == 0 ? 0 : current / total,
        child: Container(
          decoration: BoxDecoration(
            color: themeColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: themeColor.withOpacity(0.30),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeartRow() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (index) => Padding(
          padding: const EdgeInsets.only(left: 4.0),
          child: Icon(
            Icons.favorite_rounded,
            color: index < _lives ? Colors.redAccent : Colors.grey.shade300,
            size: 25,
          ),
        ),
      ),
    );
  }

  Widget _buildTopProgressCard(Color themeColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.94),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: themeColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  Icons.headphones_rounded,
                  color: themeColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Metin $_currentRound / $_totalRounds",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _showInput
                          ? "Duyduğunu yaz ve kontrol et"
                          : "Önce sesi dinle",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              _buildHeartRow(),
            ],
          ),
          const SizedBox(height: 14),
          _buildProgressBar(_currentRound, _totalRounds, themeColor),
        ],
      ),
    );
  }

  Widget _buildListeningCard(Color themeColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(34),
        border: Border.all(color: themeColor.withOpacity(0.16)),
        boxShadow: [
          BoxShadow(
            color: themeColor.withOpacity(0.13),
            blurRadius: 35,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: themeColor.withOpacity(0.10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "Robotu dinle ve duyduğunu yaz",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: themeColor,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 20),

          GestureDetector(
            onTap: _isSpeaking ? null : _speakText,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 230,
              width: 230,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isSpeaking
                    ? themeColor.withOpacity(0.13)
                    : Colors.grey.shade50,
                boxShadow: [
                  if (_isSpeaking)
                    BoxShadow(
                      color: themeColor.withOpacity(0.25),
                      blurRadius: 38,
                      spreadRadius: 8,
                    )
                  else
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (_isSpeaking)
                    Container(
                      width: 210,
                      height: 210,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: themeColor.withOpacity(0.25),
                          width: 12,
                        ),
                      ),
                    ),
                  Transform.scale(
                    scale: 1.55,
                    child: Lottie.asset(
                      'assets/lottie/talkingcharacter.json',
                      controller: _lottieController,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 22),

          SizedBox(
            height: 58,
            child: ElevatedButton.icon(
              onPressed: _isSpeaking ? null : _speakText,
              icon: Icon(
                _isSpeaking
                    ? Icons.graphic_eq_rounded
                    : Icons.play_arrow_rounded,
                color: Colors.white,
                size: 24,
              ),
              label: Text(
                _isSpeaking ? "Dinleniyor..." : "Sesi Çal",
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor,
                disabledBackgroundColor: themeColor.withOpacity(0.65),
                elevation: 8,
                shadowColor: themeColor.withOpacity(0.35),
                padding: const EdgeInsets.symmetric(horizontal: 30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(Color themeColor) {
    final bool canCheck =
        _textController.text.trim().length > 3 && !_isAnalyzing && !_isSpeaking;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      child: !_showInput
          ? Container(
              key: const ValueKey("info"),
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.86),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: themeColor, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Sesi çaldıktan sonra yazma alanı açılacak.",
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Container(
              key: const ValueKey("input"),
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: themeColor.withOpacity(0.18)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 22,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.edit_note_rounded,
                        color: themeColor,
                        size: 25,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          "Duyduklarını yaz",
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _isSpeaking ? null : _speakText,
                        icon: Icon(
                          Icons.replay_rounded,
                          color: themeColor,
                          size: 19,
                        ),
                        label: Text(
                          "Tekrar dinle",
                          style: TextStyle(
                            color: themeColor,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _textController,
                    onChanged: (text) => setState(() {}),
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                    minLines: 3,
                    maxLines: 4,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      hintText: "Duyduğun cümleyi buraya yaz...",
                      hintStyle: TextStyle(
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w600,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF5F7FA),
                      contentPadding: const EdgeInsets.all(18),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                        borderSide: BorderSide(color: themeColor, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed: canCheck ? _checkAnswer : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeColor,
                        disabledBackgroundColor: Colors.grey.shade300,
                        elevation: canCheck ? 8 : 0,
                        shadowColor: themeColor.withOpacity(0.35),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                      child: _isAnalyzing
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                          : Text(
                              "Kontrol Et 🎯",
                              style: TextStyle(
                                fontSize: 18,
                                color: canCheck
                                    ? Colors.white
                                    : Colors.grey.shade600,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildEmptyTextState(Color themeColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: themeColor.withOpacity(0.12),
                blurRadius: 30,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.wifi_off_rounded,
                size: 62,
                color: Colors.grey.shade500,
              ),
              const SizedBox(height: 18),
              const Text(
                "Dinleme metni yüklenemedi.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Bağlantını kontrol edip tekrar deneyebilirsin.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _fetchDictationText,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    "Tekrar Dene",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCenteredState({
    required Color themeColor,
    required String emoji,
    required String title,
    required String subtitle,
    required String buttonText,
    required VoidCallback onPressed,
    bool isDanger = false,
  }) {
    final Color stateColor = isDanger ? Colors.redAccent : themeColor;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            stateColor.withOpacity(0.12),
            const Color(0xFFF4F7FE),
            Colors.white,
          ],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(26.0),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: stateColor.withOpacity(0.14),
                  blurRadius: 34,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 78)),
                const SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 29,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
                if (isDanger) ...[
                  const SizedBox(height: 22),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.timer_rounded,
                          color: Colors.redAccent,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "Yeni can: $_formattedTime",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: onPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDanger ? Colors.black87 : themeColor,
                      elevation: 8,
                      shadowColor: stateColor.withOpacity(0.30),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      buttonText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
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
    );
  }

  // 🌟 YENİ: XP HARCAMA BUTONLU OYUN BİTTİ EKRANI 🌟
  Widget _buildGameOverScreen(Color themeColor) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.redAccent.withOpacity(0.12),
            const Color(0xFFF4F7FE),
            Colors.white,
          ],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(26.0),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.redAccent.withOpacity(0.14),
                  blurRadius: 34,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("💔", style: TextStyle(fontSize: 78)),
                const SizedBox(height: 16),
                const Text(
                  "Hakların Doldu!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 29,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Biraz dinlen, canların yenilenince dinleme görevine tekrar devam edebilirsin.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 22),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.timer_rounded, color: Colors.redAccent),
                      const SizedBox(width: 10),
                      Text(
                        "Yeni can: $_formattedTime",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // 🌟 300 XP İLE CAN FULLEME BUTONU
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber.shade500,
                      elevation: 8,
                      shadowColor: Colors.amber.withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    icon: const Icon(Icons.bolt_rounded, color: Colors.black87),
                    label: const Text(
                      "300 XP ile Canları Fulle",
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    onPressed: () async {
                      final result = await ApiService.buyLives(
                        widget.username,
                        widget.targetLanguage,
                      );
                      if (result['success'] == true) {
                        await _fetchCurrentLives(); // Canları tazele, ekran otomatik kapanır
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                "Canlar Fullendi! Maceraya Devam 🚀",
                              ),
                              backgroundColor: Colors.green.shade600,
                            ),
                          );
                        }
                      } else {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(result['message']),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        }
                      }
                    },
                  ),
                ),
                const SizedBox(height: 14),

                // 🌟 HARİTAYA DÖN BUTONU
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87,
                      elevation: 8,
                      shadowColor: Colors.black.withOpacity(0.30),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      "Haritaya Dön",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = getThemeColor(widget.userLevel);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7FE),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            "Dinleme Koçu 🎧",
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: Colors.black87,
              fontSize: 22,
            ),
          ),
        ),
        body: _isLoadingLives
            ? Center(child: CircularProgressIndicator(color: themeColor))
            : _buildBody(themeColor),
      ),
    );
  }

  Widget _buildBody(Color themeColor) {
    if (_isGameOver) {
      return _buildGameOverScreen(themeColor);
    }

    if (_isAllFinished) {
      return _buildCenteredState(
        themeColor: themeColor,
        emoji: "🎧🎯",
        title: "Kulağın Çok İyi!",
        subtitle: "Tüm dinleme görevlerini başarıyla tamamladın.",
        buttonText: "Haritaya Dön",
        onPressed: () => Navigator.pop(context, true),
      );
    }

    if (_isLoadingText) {
      return Center(child: CircularProgressIndicator(color: themeColor));
    }

    if (_targetText.isEmpty) {
      return _buildEmptyTextState(themeColor);
    }

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                themeColor.withOpacity(0.12),
                const Color(0xFFF4F7FE),
                Colors.white,
              ],
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
            child: Column(
              children: [
                _buildTopProgressCard(themeColor),
                const SizedBox(height: 22),
                _buildListeningCard(themeColor),
                const SizedBox(height: 22),
                _buildInputArea(themeColor),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showResultDialog(
    int score,
    String feedback,
    List<String> missedWords,
    int xp,
    bool isSuccess,
  ) {
    final themeColor = getThemeColor(widget.userLevel);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: (isSuccess ? themeColor : Colors.redAccent)
                        .withOpacity(0.10),
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 92,
                        height: 92,
                        child: CircularProgressIndicator(
                          value: score / 100,
                          strokeWidth: 8,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isSuccess ? themeColor : Colors.redAccent,
                          ),
                        ),
                      ),
                      Text(
                        "$score",
                        style: TextStyle(
                          fontSize: 31,
                          fontWeight: FontWeight.w900,
                          color: isSuccess ? themeColor : Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                Text(
                  isSuccess ? "Harika dinledin!" : "Bir kez daha deneyelim",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 10),

                if (isSuccess)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD166).withOpacity(0.22),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "+$xp XP Kazandın!",
                      style: const TextStyle(
                        color: Color(0xFFFFB703),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "1 Can Gitti",
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),

                const SizedBox(height: 18),

                Text(
                  feedback,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 15.5,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                if (missedWords.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Kaçırdığın veya yanlış yazdığın kelimeler:",
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: missedWords
                        .map(
                          (word) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withOpacity(0.10),
                              borderRadius: BorderRadius.circular(13),
                              border: Border.all(
                                color: Colors.redAccent.withOpacity(0.25),
                              ),
                            ),
                            child: Text(
                              word,
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);

                      if (isSuccess) {
                        if (_currentRound < _totalRounds) {
                          setState(() {
                            _currentRound++;
                            _textController.clear();
                            _showInput = false;
                          });
                          _fetchDictationText();
                        } else {
                          setState(() => _isAllFinished = true);
                        }
                      } else {
                        setState(() {
                          _textController.clear();
                          _showInput = true;
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSuccess
                          ? themeColor
                          : Colors.grey.shade800,
                      elevation: 8,
                      shadowColor: (isSuccess ? themeColor : Colors.black)
                          .withOpacity(0.22),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      isSuccess
                          ? (_currentRound < _totalRounds
                                ? "Sıradaki Metin 🚀"
                                : "Muhteşem! 🚀")
                          : "Tekrar Dene 🔄",
                      style: const TextStyle(
                        fontSize: 16.5,
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
