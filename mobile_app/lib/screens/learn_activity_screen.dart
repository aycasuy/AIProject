// lib/screens/learn_activity_screen.dart
import 'package:flutter/material.dart';
import 'package:mobile_app/l10n/app_localizations.dart';
import '../services/api_service.dart';
import 'dart:async'; // 🌟 Timer kullanmak için şart!
import '/widgets/ai_result_bottom_sheet.dart';
import 'package:appinio_swiper/appinio_swiper.dart';

class LearnActivityScreen extends StatefulWidget {
  final String activityType;
  final String lessonTitle;
  final Color themeColor;

  final String username;
  final String minLevel;
  final String targetLanguage;
  final int lessonId;
  final bool isPracticeMode;
  final int? practicePuzzleId;
  final int sectionIndex;
  final String nativeLanguage;

  const LearnActivityScreen({
    Key? key,
    required this.activityType,
    required this.lessonTitle,
    required this.themeColor,
    required this.username,
    required this.minLevel,
    required this.targetLanguage,
    required this.lessonId,
    this.isPracticeMode = false,
    this.practicePuzzleId,
    required this.sectionIndex,
    required this.nativeLanguage,
  }) : super(key: key);

  @override
  State<LearnActivityScreen> createState() => _LearnActivityScreenState();
}

class _LearnActivityScreenState extends State<LearnActivityScreen> {
  bool isLoading = false;

  // --- GÖRSEL ÖĞRENİM (FLASHCARD) DEĞİŞKENLERİ ---
  int _currentCardIndex = 0;
  bool _isActivityFinished = false;
  int _currentBlankIndex = 0;
  bool _isBlankFinished = false;
  final TextEditingController _blankController = TextEditingController();
  bool _showError = false;

  // --- YENİ: CAN VE BAĞLAM SİSTEMİ ---
  int _lives = 0;
  bool _isLoadingLives = true;
  bool _isGameOver = false;
  int _remainingSeconds = 0;
  Timer? _countdownTimer;

  // --- BOŞLUK DOLDURMA İÇİN DEĞİŞKENLER ---
  List<Map<String, dynamic>> _blankList = [];
  bool _isLoadingBlank = true;
  String _beforeText = "";
  String _afterText = "";
  String _correctAnswer = "";
  String _translationText = "";

  // --- CÜMLE KURMA DEĞİŞKENLERİ ---
  bool _isOrderFinished = false;
  List<String> _availableWords = [];
  List<String> _selectedWords = [];

  int _puzzleId = 0;
  List<Map<String, dynamic>> _puzzleList = [];
  int _currentPuzzleIndex = 0;
  String _originalSentence = "";
  String _correctSentence = "";
  bool _isLoadingPuzzle = true;

  // --- DİNAMİK FLASHCARD DEĞİŞKENLERİ ---
  List<Map<String, dynamic>> _flashcards = [];
  bool _isLoadingCards = true;

  // --- GÖRSEL ÖĞRENİM SWIPER DEĞİŞKENLERİ ---
  final AppinioSwiperController _swiperController = AppinioSwiperController();
  List<Map<String, dynamic>> _failedCards = [];
  bool _showTranslation = false;

  // =========================================================
  // 🌟 YENİ: İPUCU ROBOTU İÇİN DEĞİŞKENLER
  // =========================================================
  Timer? _hintTimer;
  bool _showHintRobot = false;

  // =========================================================
  // 🌟 İPUCU ROBOTU MOTORU (Timer ve Dialog)
  // =========================================================
  void _startHintTimer() {
    _hintTimer?.cancel();
    setState(() => _showHintRobot = false);

    _hintTimer = Timer(const Duration(seconds: 15), () {
      if (mounted) {
        setState(() => _showHintRobot = true);
      }
    });
  }

  void _showHintDialog(String correctAnswer) {
    final loc = AppLocalizations.of(context)!;
    String cleanAnswer = correctAnswer.trim();
    String firstLetter = cleanAnswer.isNotEmpty
        ? cleanAnswer[0].toUpperCase()
        : "?";
    int wordLength = cleanAnswer.length;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.amber.shade50,
        title: Row(
          children: [
            Icon(Icons.lightbulb_circle, color: Colors.amber, size: 30),
            SizedBox(width: 10),
            Text(
              loc.learnHintTitle,
              style: TextStyle(
                color: Colors.brown,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          loc.learnHintContent(firstLetter, wordLength),
          style: const TextStyle(fontSize: 18, color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _showHintRobot = false);
              Navigator.pop(context);
            },
            child: Text(
              loc.learnHintThanks,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // 🌟 YENİ EKLENDİ: MODÜL BİTİNCE ÇALIŞACAK MOTOR (XP ve Seri Artırmak İçin) 🌟
  void _completeModuleAndExit() {
    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  void _onSwipeEnd(
    int previousIndex,
    int targetIndex,
    SwiperActivity activity,
  ) {
    setState(() {
      _showTranslation = false;
      _currentCardIndex = targetIndex;
    });

    if (activity is Swipe) {
      if (activity.direction == AxisDirection.left) {
        _failedCards.add(_flashcards[previousIndex]);
      }

      if (targetIndex == _flashcards.length) {
        _saveFailedCardsAndFinish();
      }
    }
  }

  Future<void> _saveFailedCardsAndFinish() async {
    setState(() => isLoading = true);

    for (var card in _failedCards) {
      try {
        await ApiService.saveWordToDatabase(
          widget.username,
          card["word"]!,
          card["translation"]!,
          widget.minLevel,
          widget.targetLanguage,
        );
      } catch (e) {
        print("Kelime kaydedilemedi: $e");
      }
    }

    setState(() {
      isLoading = false;
      _isActivityFinished = true;
    });
  }

  void _moveToSelected(String word) {
    setState(() {
      _availableWords.remove(word);
      _selectedWords.add(word);
    });
    // Kullanıcı bir hamle yaptı, ipucu sayacını durdur
    _hintTimer?.cancel();
    setState(() => _showHintRobot = false);
  }

  void _moveToAvailable(String word) {
    setState(() {
      _selectedWords.remove(word);
      _availableWords.add(word);
    });
  }

  Future<void> _handleCheckSentenceOrder() async {
    setState(() => isLoading = true);
    _hintTimer?.cancel();

    try {
      final data = await ApiService.evaluateSentence(
        username: widget.username,
        targetLanguage: widget.targetLanguage,
        nativeLanguage: widget.nativeLanguage,
        originalSentence: _originalSentence,
        correctSentence: _correctSentence,
        submittedWords: _selectedWords,
      );

      if (mounted) {
        final bool? result = await showModalBottomSheet<bool>(
          context: context,
          isDismissible: false,
          enableDrag: false,
          backgroundColor: Colors.transparent,
          builder: (context) => AiResultBottomSheet(
            isCorrect: data['is_correct'],
            // 🌟 DİKKAT: Artık ara sorularda XP göstermiyoruz veya sembolik 0 yolluyoruz, XP en sonda toptan verilecek!
            xp: data['is_correct'] == true ? 10 : 0,
            aiFeedback: data['ai_feedback'],
          ),
        );

        if (data['is_correct'] == true && result == true) {
          if (widget.isPracticeMode) {
            await ApiService.resolveMistake(
              username: widget.username,
              puzzleId: _puzzleId,
              puzzleType: "sentence_puzzle",
            );
          }

          // 🌟 YENİ GÜVENLİ MANTIK
          if (_currentPuzzleIndex < _puzzleList.length - 1) {
            setState(() {
              _currentPuzzleIndex++;
              _loadCurrentPuzzle();
            });
            _startHintTimer();
          } else {
            // Tüm cümle kurma soruları bitti! İlerlemeyi ve XP'yi Backend'e bildir!

            setState(() {
              _isOrderFinished = true;
            });
          }
        } else if (data['is_correct'] == false) {
          int remainingLives = await ApiService.decreaseLife(
            widget.username,
            targetLanguage: widget.targetLanguage,
          );

          if (mounted) {
            setState(() {
              _lives = remainingLives;
              if (_lives <= 0) {
                _isGameOver = true;
              }
            });
            _startHintTimer();
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Hata: $e"), backgroundColor: Colors.red),
        );
        _startHintTimer();
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _fetchPuzzleData() async {
    try {
      final List<Map<String, dynamic>> dataList =
          await ApiService.fetchSentencePuzzle(
            targetLanguage: widget.targetLanguage,
            lessonId: widget.lessonId,
          );

      if (mounted) {
        if (dataList.isNotEmpty) {
          setState(() {
            _puzzleList = dataList;
            _currentPuzzleIndex = 0;
            _loadCurrentPuzzle();
            _isLoadingPuzzle = false;
          });
          _startHintTimer(); // 🌟 Sorular geldi, sayacı başlat
        } else {
          setState(() => _isLoadingPuzzle = false);
        }
      }
    } catch (e) {
      print("Soru çekme hatası: $e");
      if (mounted) {
        setState(() => _isLoadingPuzzle = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Sorular yüklenemedi. İnternetinizi kontrol edin."),
          ),
        );
      }
    }
  }

  Future<void> _fetchBlankData() async {
    try {
      final data = await ApiService.fetchBlankPuzzles(
        targetLanguage: widget.targetLanguage,
        lessonId: widget.lessonId,
      );

      if (mounted) {
        if (data.isNotEmpty) {
          setState(() {
            _blankList = data;
            _currentBlankIndex = 0;
            _loadCurrentBlank();
            _isLoadingBlank = false;
          });
          _startHintTimer(); // 🌟 Sorular geldi, sayacı başlat
        } else {
          setState(() => _isLoadingBlank = false);
        }
      }
    } catch (e) {
      print("Boşluk doldurma hatası: $e");
      if (mounted) setState(() => _isLoadingBlank = false);
    }
  }

  void _loadCurrentBlank() {
    final current = _blankList[_currentBlankIndex];

    setState(() {
      _puzzleId = current['id'];
      _beforeText = current['before_text'] ?? "";
      _afterText = current['after_text'] ?? "";
      _correctAnswer = current['correct_answer'] ?? "";
      _translationText = current['translation'] ?? "";

      _blankController.clear();
      _showError = false;
    });
  }

  void _loadCurrentPuzzle() {
    final currentPuzzle = _puzzleList[_currentPuzzleIndex];

    setState(() {
      _puzzleId = currentPuzzle['id'];
      _originalSentence = currentPuzzle['original_sentence'];
      _correctSentence = currentPuzzle['correct_sentence'];

      _availableWords = List<String>.from(currentPuzzle['scrambled_words']);
      _selectedWords = [];
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

          if (_lives >= 5) {
            _isGameOver = false;
            _countdownTimer?.cancel();
          } else if (_lives > 0) {
            _isGameOver = false;
            if (_remainingSeconds > 0) {
              _startTimer();
            }
          } else {
            _isGameOver = true;
            if (_remainingSeconds > 0) {
              _startTimer();
            }
          }
        });
      }
    } catch (e) {
      print("Canlar çekilemedi: $e");
      if (mounted) setState(() => _isLoadingLives = false);
    }
  }

  Future<void> _loadFlashcards() async {
    try {
      final cards = await ApiService.fetchFlashcards(
        widget.lessonId,
        widget.targetLanguage,
      );
      setState(() {
        _flashcards = cards;
        _isLoadingCards = false;
      });
    } catch (e) {
      setState(() => _isLoadingCards = false);
      print("Kartlar yüklenemedi: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _loadFlashcards();
    _fetchCurrentLives();

    if (widget.activityType == "learn_order") {
      if (widget.isPracticeMode && widget.practicePuzzleId != null) {
        _fetchPracticeSinglePuzzle(widget.practicePuzzleId!, "sentence_puzzle");
      } else {
        _fetchPuzzleData();
      }
    } else if (widget.activityType == "learn_blank") {
      if (widget.isPracticeMode && widget.practicePuzzleId != null) {
        _fetchPracticeSinglePuzzle(widget.practicePuzzleId!, "blank_puzzle");
      } else {
        _fetchBlankData();
      }
    }
  }

  Future<void> _fetchPracticeSinglePuzzle(int id, String type) async {
    final data = await ApiService.fetchPracticePuzzle(id, type);
    if (mounted && data.isNotEmpty) {
      setState(() {
        if (type == "blank_puzzle") {
          _blankList = List<Map<String, dynamic>>.from(data);
          _currentBlankIndex = 0;
          _loadCurrentBlank();
          _isLoadingBlank = false;
        } else {
          _puzzleList = List<Map<String, dynamic>>.from(data);
          _currentPuzzleIndex = 0;
          _loadCurrentPuzzle();
          _isLoadingPuzzle = false;
        }
      });
      _startHintTimer(); // 🌟 Pratik modunda soru gelince sayacı başlat
    }
  }

  void _startTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            _fetchCurrentLives();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _hintTimer?.cancel(); // 🌟 Çıkarken robot sayacını kesin iptal et
    _countdownTimer?.cancel();
    _blankController.dispose();
    super.dispose();
  }

  String get _formattedTime {
    int minutes = _remainingSeconds ~/ 60;
    int seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Widget _buildProgressBar(int current, int total) {
    return Container(
      height: 12,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(10),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: total == 0 ? 0 : current / total,
        child: Container(
          decoration: BoxDecoration(
            color: widget.themeColor,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildImageActivity() {
    // (Flashcard modülünde ipucu robotu kullanmaya gerek yok, o yüzden aynen bırakıyoruz)
    if (_isLoadingCards || isLoading) {
      return Center(child: CircularProgressIndicator(color: widget.themeColor));
    }

    if (_flashcards.isEmpty) {
      return const Center(child: Text("Bu derste henüz kart bulunmuyor."));
    }

    if (_isActivityFinished) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("🎉", style: TextStyle(fontSize: 80)),
            const SizedBox(height: 20),
            const Text(
              "Harika İş!",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Kelime destesini tamamladın.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            if (_failedCards.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  "${_failedCards.length} kelime 'Kelime Defteri'ne eklendi. 📚",
                  style: TextStyle(
                    color: widget.themeColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.themeColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: _completeModuleAndExit,
              child: const Text(
                "Haritaya Dön",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              _buildProgressBar(_currentCardIndex, _flashcards.length),
              const SizedBox(height: 10),
              Text(
                "${_currentCardIndex} / ${_flashcards.length}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          "Öğrendiysen Sağa 👉  |  👈 Tekrar için Sola",
          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: AppinioSwiper(
              controller: _swiperController,
              cardCount: _flashcards.length,
              onSwipeEnd: _onSwipeEnd,
              cardBuilder: (BuildContext context, int index) {
                final card = _flashcards[index];
                return GestureDetector(
                  onTap: () =>
                      setState(() => _showTranslation = !_showTranslation),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: widget.themeColor.withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: 5,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          card["image"] ?? "🃏",
                          style: const TextStyle(fontSize: 100),
                        ),
                        const SizedBox(height: 30),
                        Text(
                          card["word"]!,
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        AnimatedOpacity(
                          opacity: _showTranslation ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            card["translation"]!,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w600,
                              color: widget.themeColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        if (!_showTranslation)
                          const Padding(
                            padding: EdgeInsets.only(top: 20),
                            child: Text(
                              "Çeviriyi görmek için dokun",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 40, top: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FloatingActionButton(
                heroTag: "btn_left",
                backgroundColor: Colors.white,
                child: const Icon(
                  Icons.close,
                  color: Colors.redAccent,
                  size: 30,
                ),
                onPressed: () => _swiperController.swipeLeft(),
              ),
              FloatingActionButton(
                heroTag: "btn_right",
                backgroundColor: Colors.white,
                child: const Icon(
                  Icons.favorite,
                  color: Colors.green,
                  size: 30,
                ),
                onPressed: () => _swiperController.swipeRight(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handleCheckAnswer() async {
    _hintTimer?.cancel(); // Tıklandığı an sayacı durdur
    setState(() => _showHintRobot = false);

    String userAnswer = _blankController.text.trim().toLowerCase();

    if (userAnswer == _correctAnswer.toLowerCase()) {
      if (widget.isPracticeMode) {
        await ApiService.resolveMistake(
          username: widget.username,
          puzzleId: _puzzleId,
          puzzleType: "blank_puzzle",
        );
      }

      // 🌟 YENİ GÜVENLİ MANTIK
      if (_currentBlankIndex < _blankList.length - 1) {
        setState(() {
          _currentBlankIndex++;
          _loadCurrentBlank();
          _startHintTimer(); // Yeni soru, yeni süre!
        });
      } else {
        // Tıpkı Dinleme modülündeki gibi: Tüm sorular bittiğinde İlerlemeyi ve XP'yi Backend'e bildir!
        setState(() {
          //isLoading = true;
          _isBlankFinished = true;
        });
      }
    } else {
      int remainingLives = await ApiService.decreaseLife(
        widget.username,
        targetLanguage: widget.targetLanguage,
      );
      if (mounted) {
        setState(() {
          _lives = remainingLives;
          _showError = true;
          if (_lives <= 0) {
            _isGameOver = true;
          }
        });
        _startHintTimer();
      }
    }
  }

  Future<void> _handleBlankBilemedim() async {
    _hintTimer?.cancel();
    setState(() => _showHintRobot = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Doğru Cevap: $_correctAnswer"),
        backgroundColor: Colors.blueGrey.shade800,
        duration: const Duration(seconds: 3),
      ),
    );

    int remainingLives = await ApiService.decreaseLife(
      widget.username,
      targetLanguage: widget.targetLanguage,
    );
    if (mounted) {
      setState(() {
        _lives = remainingLives;
      });
    }

    try {
      await ApiService.logMistake(
        username: widget.username,
        puzzleId: _puzzleId,
        puzzleType: "blank_puzzle",
        targetLanguage: widget.targetLanguage,
      );
    } catch (e) {
      print("Hata kaydedilemedi: $e");
    }

    if (mounted && _lives <= 0) {
      setState(() => _isGameOver = true);
    } else {
      if (_currentBlankIndex < _blankList.length - 1) {
        setState(() {
          _currentBlankIndex++;
          _loadCurrentBlank();
        });
        _startHintTimer(); // Yeni soruya geçtik, sayacı başlat
      } else {
        setState(() => _isBlankFinished = true);
      }
    }
  }

  Future<void> _handleBilemedim() async {
    _hintTimer?.cancel();
    setState(() => _showHintRobot = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Doğru Cevap: $_correctSentence"),
        backgroundColor: Colors.blueGrey.shade800,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );

    int remainingLives = await ApiService.decreaseLife(
      widget.username,
      targetLanguage: widget.targetLanguage,
    );
    if (mounted) {
      setState(() {
        _lives = remainingLives;
      });
    }

    try {
      await ApiService.logMistake(
        username: widget.username,
        puzzleId: _puzzleId,
        puzzleType: "sentence_puzzle",
        targetLanguage: widget.targetLanguage,
      );
    } catch (e) {
      print("Hata kaydedilemedi: $e");
    }

    if (mounted && _lives <= 0) {
      setState(() {
        _isGameOver = true;
      });
    } else {
      if (_currentPuzzleIndex < _puzzleList.length - 1) {
        setState(() {
          _currentPuzzleIndex++;
          _loadCurrentPuzzle();
        });
        _startHintTimer(); // Yeni soruya geçtik, sayacı başlat
      } else {
        setState(() {
          _isOrderFinished = true;
        });
      }
    }
  }

  Widget _buildBlankActivity() {
    if (_isLoadingBlank) {
      return Center(child: CircularProgressIndicator(color: widget.themeColor));
    }

    if (_blankList.isEmpty) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              widget.themeColor.withOpacity(0.10),
              const Color(0xFFF4F7FE),
              Colors.white,
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: widget.themeColor.withOpacity(0.12),
                    blurRadius: 30,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: widget.themeColor.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.construction_rounded,
                      size: 58,
                      color: widget.themeColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Bu derste henüz boşluk doldurma sorusu yok.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Yeni sorular eklendiğinde burada görünecek.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (_isGameOver) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.redAccent.withOpacity(0.10),
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
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.redAccent.withOpacity(0.12),
                    blurRadius: 30,
                    offset: const Offset(0, 16),
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
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Biraz dinlen, canların yenilenince boşluk doldurmaya tekrar devam edebilirsin.",
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
                  const SizedBox(height: 28),
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
                      icon: const Icon(
                        Icons.bolt_rounded,
                        color: Colors.black87,
                      ),
                      label: const Text(
                        "300 XP ile Canları Fulle",
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      onPressed: () async {
                        final result = await ApiService.buyLives(
                          widget.username,
                          widget.targetLanguage,
                        );
                        if (result['success'] == true) {
                          await _fetchCurrentLives(); // Canları tazele, oyun bitti ekranı kendiliğinden kapanır!
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
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        "Haritaya Dön",
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
        ),
      );
    }

    if (_isBlankFinished) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              widget.themeColor.withOpacity(0.14),
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
                    color: widget.themeColor.withOpacity(0.16),
                    blurRadius: 34,
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
                      color: widget.themeColor.withOpacity(0.14),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.emoji_events_rounded,
                      color: widget.themeColor,
                      size: 58,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Mükemmel!",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Tüm boşluk doldurma sorularını tamamladın.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black54,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.themeColor,
                        elevation: 8,
                        shadowColor: widget.themeColor.withOpacity(0.35),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: _completeModuleAndExit,
                      child: const Text(
                        "Haritaya Dön",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
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

    final int totalQuestions = _blankList.isEmpty ? 1 : _blankList.length;
    final int questionNumber = _currentBlankIndex + 1;
    final bool canCheck = _blankController.text.trim().isNotEmpty && !isLoading;

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                widget.themeColor.withOpacity(0.13),
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
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 26),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(26),
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
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: widget.themeColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              Icons.edit_note_rounded,
                              color: widget.themeColor,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Boşluk Doldurma",
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "$questionNumber / $totalQuestions soru",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(
                                5,
                                (index) => Padding(
                                  padding: const EdgeInsets.only(left: 2.0),
                                  child: Icon(
                                    Icons.favorite_rounded,
                                    color: index < _lives
                                        ? Colors.redAccent
                                        : Colors.grey.shade300,
                                    size: 23,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _buildProgressBar(questionNumber, totalQuestions),
                    ],
                  ),
                ),

                const SizedBox(height: 26),

                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: widget.themeColor.withOpacity(0.14),
                        blurRadius: 32,
                        offset: const Offset(0, 18),
                      ),
                    ],
                    border: Border.all(
                      color: _showError
                          ? Colors.redAccent.withOpacity(0.85)
                          : widget.themeColor.withOpacity(0.16),
                      width: _showError ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _showError
                              ? Colors.redAccent.withOpacity(0.10)
                              : widget.themeColor.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _showError
                              ? Icons.error_outline_rounded
                              : Icons.edit_note_rounded,
                          color: _showError
                              ? Colors.redAccent
                              : widget.themeColor,
                          size: 38,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: widget.themeColor.withOpacity(0.09),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(
                          "Eksik kelimeyi tamamla",
                          style: TextStyle(
                            color: widget.themeColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 10,
                        children: [
                          if (_beforeText.trim().isNotEmpty)
                            Text(
                              _beforeText.trim(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Colors.black87,
                                height: 1.25,
                              ),
                            ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: _showError
                                    ? Colors.redAccent.withOpacity(0.50)
                                    : widget.themeColor.withOpacity(0.26),
                              ),
                            ),
                            child: Text(
                              "?",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: _showError
                                    ? Colors.redAccent
                                    : widget.themeColor,
                              ),
                            ),
                          ),
                          if (_afterText.trim().isNotEmpty)
                            Text(
                              _afterText.trim(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Colors.black87,
                                height: 1.25,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _translationText,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: widget.themeColor,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _blankController,
                        textAlign: TextAlign.center,
                        textInputAction: TextInputAction.done,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.black87,
                        ),
                        decoration: InputDecoration(
                          hintText: "Cevabını buraya yaz...",
                          hintStyle: TextStyle(
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w700,
                          ),
                          prefixIcon: Icon(
                            Icons.keyboard_alt_rounded,
                            color: _showError
                                ? Colors.redAccent
                                : widget.themeColor,
                          ),
                          filled: true,
                          fillColor: _showError
                              ? Colors.redAccent.withOpacity(0.06)
                              : const Color(0xFFF5F6FA),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 18,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(
                              color: _showError
                                  ? Colors.redAccent
                                  : widget.themeColor,
                              width: 1.8,
                            ),
                          ),
                          errorText: _showError
                              ? "Yanlış kelime, bir can gitti. Tekrar dene."
                              : null,
                          errorStyle: const TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        onChanged: (val) {
                          _hintTimer?.cancel();
                          setState(() {
                            _showError = false;
                            _showHintRobot = false;
                          });
                        },
                        onSubmitted: (_) {
                          if (_blankController.text.trim().isNotEmpty &&
                              !isLoading) {
                            _handleCheckAnswer();
                          }
                        },
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Icon(
                            Icons.tips_and_updates_rounded,
                            color: Colors.amber.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Takılırsan ipucu alabilirsin.",
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => _showHintDialog(_correctAnswer),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.amber.shade800,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                            ),
                            child: const Text(
                              "İpucu al",
                              style: TextStyle(fontWeight: FontWeight.w900),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                SizedBox(
                  height: 60,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: canCheck ? _handleCheckAnswer : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.themeColor,
                      disabledBackgroundColor: Colors.grey.shade300,
                      elevation: canCheck ? 8 : 0,
                      shadowColor: widget.themeColor.withOpacity(0.35),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : Text(
                            "Kontrol Et ✨",
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
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: isLoading ? null : _handleBlankBilemedim,
                  icon: Icon(
                    Icons.help_outline_rounded,
                    color: Colors.grey.shade600,
                    size: 20,
                  ),
                  label: Text(
                    "Boşluğu dolduramadım, pas geç",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        AnimatedPositioned(
          duration: const Duration(milliseconds: 750),
          curve: Curves.elasticOut,
          top: 86,
          right: _showHintRobot ? -8 : -220,
          child: GestureDetector(
            onTap: () => _showHintDialog(_correctAnswer),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade300,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.13),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Text(
                    "İpucu?",
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      color: Colors.brown,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.10),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.smart_toy_rounded,
                    color: Colors.amber,
                    size: 38,
                  ),
                ),
                const SizedBox(width: 15),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderActivity() {
    if (_isLoadingPuzzle) {
      return Center(child: CircularProgressIndicator(color: widget.themeColor));
    }

    if (_puzzleList.isEmpty ||
        _puzzleList[0]['original_sentence'].contains('YEDEK')) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: widget.themeColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.construction_rounded,
                  size: 58,
                  color: widget.themeColor,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Bu derste henüz cümle kurma sorusu yok.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Yeni sorular eklendiğinde burada görünecek.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
          ),
        ),
      );
    }

    if (_isGameOver) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.redAccent.withOpacity(0.10),
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
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.redAccent.withOpacity(0.12),
                    blurRadius: 30,
                    offset: const Offset(0, 16),
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
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Biraz dinlen, canların yenilenince tekrar devam edebilirsin.",
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
                  const SizedBox(height: 28),
                  // 🌟 YENİ: 300 XP İLE CAN FULLEME BUTONU
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
                      icon: const Icon(
                        Icons.bolt_rounded,
                        color: Colors.black87,
                      ),
                      label: const Text(
                        "300 XP ile Canları Fulle",
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      onPressed: () async {
                        final result = await ApiService.buyLives(
                          widget.username,
                          widget.targetLanguage,
                        );
                        if (result['success'] == true) {
                          await _fetchCurrentLives();
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
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        "Haritaya Dön",
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
        ),
      );
    }

    if (_isOrderFinished) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              widget.themeColor.withOpacity(0.14),
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
                    color: widget.themeColor.withOpacity(0.16),
                    blurRadius: 34,
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
                      color: widget.themeColor.withOpacity(0.14),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.emoji_events_rounded,
                      color: widget.themeColor,
                      size: 58,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Mükemmel!",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Cümle kurma görevini başarıyla tamamladın.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black54,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.themeColor,
                        elevation: 8,
                        shadowColor: widget.themeColor.withOpacity(0.35),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: _completeModuleAndExit,
                      child: const Text(
                        "Haritaya Dön",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
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

    final int totalQuestions = _puzzleList.isEmpty ? 1 : _puzzleList.length;
    final int questionNumber = _currentPuzzleIndex + 1;
    final bool canCheck = _selectedWords.isNotEmpty && !isLoading;

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                widget.themeColor.withOpacity(0.13),
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
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 26),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(26),
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
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: widget.themeColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              Icons.extension_rounded,
                              color: widget.themeColor,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Cümle Kurma",
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "$questionNumber / $totalQuestions soru",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(
                                5,
                                (index) => Padding(
                                  padding: const EdgeInsets.only(left: 2.0),
                                  child: Icon(
                                    Icons.favorite_rounded,
                                    color: index < _lives
                                        ? Colors.redAccent
                                        : Colors.grey.shade300,
                                    size: 23,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _buildProgressBar(questionNumber, totalQuestions),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: widget.themeColor.withOpacity(0.12),
                        blurRadius: 28,
                        offset: const Offset(0, 16),
                      ),
                    ],
                    border: Border.all(
                      color: widget.themeColor.withOpacity(0.16),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                              color: widget.themeColor.withOpacity(0.10),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.translate_rounded,
                              color: widget.themeColor,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "Türkçeden çevir",
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text(
                        _originalSentence,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: Colors.black87,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(minHeight: 128),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _selectedWords.isEmpty
                        ? Colors.white.withOpacity(0.82)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(
                      color: _selectedWords.isEmpty
                          ? Colors.grey.shade300
                          : widget.themeColor.withOpacity(0.55),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _selectedWords.isEmpty
                            ? Colors.black.withOpacity(0.03)
                            : widget.themeColor.withOpacity(0.10),
                        blurRadius: 22,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.draw_rounded,
                            color: _selectedWords.isEmpty
                                ? Colors.grey.shade500
                                : widget.themeColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Cümleni oluştur",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: _selectedWords.isEmpty
                                    ? Colors.grey.shade600
                                    : widget.themeColor,
                              ),
                            ),
                          ),
                          if (_selectedWords.isNotEmpty)
                            InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                setState(() {
                                  _availableWords.addAll(_selectedWords);
                                  _selectedWords.clear();
                                });
                                _startHintTimer();
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: Icon(
                                  Icons.refresh_rounded,
                                  color: Colors.grey.shade500,
                                  size: 22,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      if (_selectedWords.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 22),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.touch_app_rounded,
                                color: Colors.grey.shade400,
                                size: 28,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Kelimelere dokunarak cümleyi kur",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: _selectedWords.map((word) {
                            return GestureDetector(
                              onTap: () => _moveToAvailable(word),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: widget.themeColor,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: widget.themeColor.withOpacity(
                                        0.22,
                                      ),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      word,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Icon(
                                      Icons.close_rounded,
                                      color: Colors.white,
                                      size: 17,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      color: widget.themeColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "Kelimeler",
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      "Dokun ve sırala",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Wrap(
                  spacing: 10,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: _availableWords.map((word) {
                    return GestureDetector(
                      onTap: () => _moveToSelected(word),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: widget.themeColor.withOpacity(0.45),
                            width: 1.6,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 12,
                              offset: const Offset(0, 7),
                            ),
                          ],
                        ),
                        child: Text(
                          word,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 26),

                SizedBox(
                  height: 60,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: canCheck ? _handleCheckSentenceOrder : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.themeColor,
                      disabledBackgroundColor: Colors.grey.shade300,
                      elevation: canCheck ? 8 : 0,
                      shadowColor: widget.themeColor.withOpacity(0.35),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : Text(
                            "Kontrol Et ✨",
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
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: isLoading ? null : _handleBilemedim,
                  icon: Icon(
                    Icons.help_outline_rounded,
                    color: Colors.grey.shade600,
                    size: 20,
                  ),
                  label: Text(
                    "Cümleyi kuramadım, pas geç",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        AnimatedPositioned(
          duration: const Duration(milliseconds: 750),
          curve: Curves.elasticOut,
          top: 86,
          right: _showHintRobot ? -8 : -220,
          child: GestureDetector(
            onTap: () => _showHintDialog(_correctSentence.split(' ').first),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade300,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.13),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Text(
                    "İpucu?",
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      color: Colors.brown,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.10),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.smart_toy_rounded,
                    color: Colors.amber,
                    size: 38,
                  ),
                ),
                const SizedBox(width: 15),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuizActivity() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.bolt, size: 80, color: Colors.amber),
            ),
            const SizedBox(height: 24),
            const Text(
              "Zayıf Nokta Avcısı",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Yapay zeka, geçmişte hata yaptığın kelimeleri analiz ederek sana özel, zamana karşı bir okuma testi hazırlayacak. Meydan okumaya hazır mısın?",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey, height: 1.5),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () async {
                final result = await ApiService.startFastQuiz(
                  context,
                  widget.username,
                  widget.targetLanguage,
                  200,
                  widget.minLevel,
                  widget.lessonId,
                  widget.nativeLanguage,
                );
                if (result == true && mounted) {
                  Navigator.pop(context, true);
                }
              },
              icon: const Icon(Icons.rocket_launch, size: 24),
              label: const Text(
                "Meydan Oku!",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getActiveModule() {
    switch (widget.activityType) {
      case "learn_image":
        return _buildImageActivity();
      case "learn_blank":
        return _buildBlankActivity();
      case "learn_order":
        return _buildOrderActivity();
      case "learn_quiz":
        return _buildQuizActivity();
      default:
        return const Center(child: Text("Modül bulunamadı."));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.lessonTitle,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: _isLoadingLives
          ? const Center(child: CircularProgressIndicator())
          : _getActiveModule(),
    );
  }
}
