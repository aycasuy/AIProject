import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:mobile_app/l10n/app_localizations.dart';
import 'package:mobile_app/services/api_service.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:http/http.dart' as http;
import 'dart:convert';

class MinimalPairsScreen extends StatefulWidget {
  // final int lessonId;
  final int
  id; // 🌟 Eskiden lessonId idi, artık genel bir ID yaptık (Ders ID veya Puzzle ID olabilir)
  final bool isPracticeMode; //
  final String username;
  final Color themeColor;
  final String targetLanguage;
  final String nativeLanguage;

  const MinimalPairsScreen({
    super.key,
    //  required this.lessonId,
    required this.username,
    required this.themeColor,
    required this.targetLanguage,
    required this.nativeLanguage,
    required this.id,
    this.isPracticeMode = false,
  });

  @override
  State<MinimalPairsScreen> createState() => _MinimalPairsScreenState();
}

class _MinimalPairsScreenState extends State<MinimalPairsScreen> {
  // --- Servisler ---
  final FlutterTts _flutterTts = FlutterTts();
  late stt.SpeechToText _speech;

  // --- Değişkenler ---
  bool _isLoading = true;
  List<dynamic> _pairsList = [];
  int _currentIndex = 0;

  bool _isListening = false;
  String _recognizedText = "";
  bool _isAnswerChecked = false;
  bool _isCorrect = false;

  // 🌟 YENİ: CAN SİSTEMİ DEĞİŞKENLERİ
  int _lives = 0;
  bool _isLoadingLives = true;
  bool _isGameOver = false;

  // AI Koçu Mesajı
  String _aiFeedback = "";

  // Hangi kelimeyi okumasını istiyoruz? (0: Sol kelime, 1: Sağ kelime)
  int _targetWordIndex = 0;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initTts();
    _fetchCurrentLives(); // 🌟 SAYFA AÇILIRKEN CANLARI ÇEK
    _fetchPairs();
  }

  // 🌟 YENİ: VERİTABANINDAN GÜNCEL CANLARI ÇEKME FONKSİYONU
  Future<void> _fetchCurrentLives() async {
    try {
      final progress = await ApiService.fetchUserProgress(
        widget.username,
        widget.targetLanguage,
      );

      if (mounted) {
        setState(() {
          _lives = progress.lives;
          _isLoadingLives = false;

          if (_lives <= 0) {
            _isGameOver = true;
          }
        });
      }
    } catch (e) {
      print("Canlar çekilemedi: $e");
      if (mounted) setState(() => _isLoadingLives = false);
    }
  }

  String _getTtsLanguageCode(String language) {
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
      default:
        return "en-US";
    }
  }

  String _getSpeechLocaleId(String language) {
    switch (language.toLowerCase()) {
      case "english":
        return "en_US";
      case "spanish":
        return "es_ES";
      case "french":
        return "fr_FR";
      case "german":
        return "de_DE";
      case "turkish":
        return "tr_TR";
      default:
        return "en_US";
    }
  }

  // Okuma motorunu İngilizceye ayarla
  Future<void> _initTts() async {
    await _flutterTts.setLanguage(_getTtsLanguageCode(widget.targetLanguage));
    await _flutterTts.setSpeechRate(0.4);
    await _flutterTts.setPitch(1.0);
  }

  // Python API'den verileri çek

  Future<void> _fetchPairs() async {
    try {
      late final Uri url;

      if (widget.isPracticeMode) {
        // Pratik modu şimdilik kendi endpoint'ini kullanıyor.
        url =
            Uri.parse(
              'http://10.0.2.2:8000/api/get_single_minimal_pair/${widget.id}',
            ).replace(
              queryParameters: {
                'native_language': widget.nativeLanguage,
                'target_language': widget.targetLanguage,
              },
            );
      } else {
        // Normal ders modu
        url = Uri.parse('http://10.0.2.2:8000/fetch_minimal_pairs/${widget.id}')
            .replace(
              queryParameters: {
                'target_language': widget.targetLanguage,
                'native_language': widget.nativeLanguage,
              },
            );
      }

      debugPrint(
        'MINIMAL PAIRS REQUEST → '
        'target=${widget.targetLanguage}, '
        'native=${widget.nativeLanguage}, '
        'practice=${widget.isPracticeMode}, '
        'url=$url',
      );

      final response = await http.get(url);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(utf8.decode(response.bodyBytes));

        final List<dynamic> allPairs = decoded is List
            ? List<dynamic>.from(decoded)
            : <dynamic>[];

        setState(() {
          // Pratik modunda backend'den gelen tek soru korunur.
          // Normal derste sunum için yalnızca ilk 4 ses çifti gösterilir.
          _pairsList = widget.isPracticeMode
              ? allPairs
              : allPairs.take(4).toList();

          _isLoading = false;

          _targetWordIndex = DateTime.now().millisecondsSinceEpoch % 2 == 0
              ? 0
              : 1;
        });
      } else {
        debugPrint(
          'Minimal pairs API hatası: '
          '${response.statusCode} - ${response.body}',
        );

        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Ses çiftleri çekilemedi: $e');

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('Durum: $val'),
        onError: (val) => print('Hata: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        final String localeId = _getSpeechLocaleId(widget.targetLanguage);
        _speech.listen(
          listenOptions: stt.SpeechListenOptions(
            localeId: localeId, // 👈 yeni yol
          ),
          onResult: (val) => setState(() {
            _recognizedText = val.recognizedWords;
            if (val.hasConfidenceRating && val.confidence > 0) {
              _checkAnswer();
            }
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  // 🌟 Telaffuzu Kontrol Et ve Koça Sor (YENİLENMİŞ AKILLI YAPI)
  Future<void> _checkAnswer() async {
    final loc = AppLocalizations.of(context)!;

    if (_pairsList.isEmpty || _currentIndex >= _pairsList.length) {
      return;
    }

    final currentPair = _pairsList[_currentIndex];

    final String targetWord =
        (_targetWordIndex == 0 ? currentPair['word_1'] : currentPair['word_2'])
            .toString();

    final String recognizedText = _recognizedText.trim();

    // Flutter tarafında doğrudan eşleşme kontrolü
    final bool isMatch = recognizedText
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .contains(targetWord.trim().toLowerCase());

    setState(() {
      _isListening = false;
      _isAnswerChecked = true;
      _aiFeedback = loc.minimalPairsAnalyzing;
    });

    await _speech.stop();

    if (isMatch) {
      // Doğrudan eşleştiyse backend çağrısı yapmaya gerek yok.
      await _processCorrectAnswer(currentPair);
      return;
    }

    if (recognizedText.isEmpty) {
      if (!mounted) return;

      setState(() {
        _isCorrect = false;
        _aiFeedback = loc.minimalPairsNoVoice;
      });

      return;
    }

    try {
      final url = Uri.parse('http://10.0.2.2:8000/get_pronunciation_feedback');

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "target_word": targetWord,
          "spoken_word": recognizedText,
          "native_language": widget.nativeLanguage,
          "target_language": widget.targetLanguage,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(
          utf8.decode(response.bodyBytes),
        );

        final bool isCorrect = data['is_correct'] == true;
        final String feedback = (data['feedback'] ?? '').toString().trim();

        if (isCorrect) {
          await _processCorrectAnswer(currentPair);
        } else {
          await _processWrongAnswer(
            feedback.isNotEmpty ? feedback : loc.minimalPairsConnectionRetry,
            currentPair,
          );
        }
      } else {
        setState(() {
          _isCorrect = false;
          _aiFeedback = loc.minimalPairsConnectionRetry;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isCorrect = false;
        _aiFeedback = loc.minimalPairsConnectionRetry;
      });
    }
  }

  // 🌟 DOĞRU CEVAP İŞLEMLERİ (Otomatik Geçiş Eklendi)
  Future<void> _processCorrectAnswer(dynamic currentPair) async {
    setState(() {
      _isCorrect = true;
      _aiFeedback = AppLocalizations.of(
        context,
      )!.minimalPairsGreatPronunciation;
    });

    if (widget.isPracticeMode) {
      await ApiService.resolveMistake(
        username: widget.username,
        puzzleId: currentPair['id'],
        puzzleType: "minimal_pair",
      );
    }

    // 🌟 YAĞ GİBİ KAYARAK GEÇİŞ (Kullanıcının butona basmasına gerek kalmaz)
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted && _isCorrect) {
        _nextPair();
      }
    });
  }

  // 🌟 YANLIŞ CEVAP İŞLEMLERİ (Can Düşürme Buraya Taşındı)
  Future<void> _processWrongAnswer(String feedback, dynamic currentPair) async {
    int remainingLives = await ApiService.decreaseLife(
      widget.username,
      targetLanguage: widget.targetLanguage,
    );

    if (mounted) {
      setState(() {
        _isCorrect = false;
        _aiFeedback = feedback;
        _lives = remainingLives;
        if (_lives <= 0) _isGameOver = true;
      });
    }

    if (!_isGameOver && !widget.isPracticeMode) {
      await ApiService.logMistake(
        username: widget.username,
        puzzleId: currentPair['id'],
        puzzleType: "minimal_pair",
        targetLanguage: widget.targetLanguage,
      );
    }
  }

  // 🌟 BİLEMEDİM, PAS GEÇ (GÜNCELLENDİ)
  Future<void> _handleBilemedim() async {
    final currentPair = _pairsList[_currentIndex];

    // 🌟 1. CAN DÜŞÜRME EKLENDİ
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
      if (_isAnswerChecked) {
        await ApiService.logMistake(
          username: widget.username,
          puzzleId: currentPair['id'],
          puzzleType: "minimal_pair",
          targetLanguage: widget.targetLanguage,
        );
      }
    } catch (e) {
      print("Hata kaydedilemedi: $e");
    }

    if (mounted && _lives <= 0) {
      setState(() => _isGameOver = true);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.minimalPairsAddedPractice,
            ),
            backgroundColor: Colors.orange.shade700,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      _nextPair();
    }
  }

  void _nextPair() {
    setState(() {
      if (_currentIndex < _pairsList.length - 1) {
        _currentIndex++;
        _recognizedText = "";
        _isAnswerChecked = false;
        _isCorrect = false;
        _targetWordIndex = (DateTime.now().millisecondsSinceEpoch % 2 == 0)
            ? 0
            : 1;
      } else {
        Navigator.pop(context, true);
      }
    });
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    if (_isLoading || _isLoadingLives) {
      return Scaffold(
        backgroundColor: const Color(0xFFF4F7FE),
        body: Center(
          child: CircularProgressIndicator(color: widget.themeColor),
        ),
      );
    }

    // 🌟 OYUN BİTTİ (GAME OVER) EKRANI 🌟
    if (_isGameOver) {
      return Scaffold(
        backgroundColor: const Color(0xFFF4F7FE),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("💔", style: TextStyle(fontSize: 80)),
                const SizedBox(height: 20),
                Text(
                  loc.learnGameOverTitle,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  loc.minimalPairsGameOverMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 35),

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
                    icon: const Icon(Icons.bolt_rounded, color: Colors.black87),
                    label: Text(
                      loc.learnRefillLives,
                      style: const TextStyle(
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
                        await _fetchCurrentLives(); // Canları tazele, ekran kapanacak
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(loc.learnLivesRefilled),
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

                // ESKİ "HARİTAYA DÖN" BUTONU
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade800,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      loc.learnBackToMap,
                      style: const TextStyle(
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

    if (_pairsList.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF4F7FE),
        body: Center(child: Text(loc.minimalPairsNoPairs)),
      );
    }

    final currentPair = _pairsList[_currentIndex];
    final targetWord = _targetWordIndex == 0
        ? currentPair['word_1']
        : currentPair['word_2'];
    final targetIpa = _targetWordIndex == 0
        ? currentPair['ipa_1']
        : currentPair['ipa_2'];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        centerTitle: true,
        title: Text(
          loc.minimalPairsTitle,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 10.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 🌟 YENİ: İlerleme Çubuğu ve KALPLER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          loc.minimalPairsStep(
                            _currentIndex + 1,
                            _pairsList.length,
                          ),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        Row(
                          children: List.generate(
                            5,
                            (index) => Padding(
                              padding: const EdgeInsets.only(left: 4.0),
                              child: Icon(
                                Icons.favorite,
                                color: index < _lives
                                    ? Colors.redAccent
                                    : Colors.grey.shade300,
                                size: 24, // Biraz daha küçük tatlı kalpler
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: (_currentIndex + 1) / _pairsList.length,
                      backgroundColor: Colors.grey.shade300,
                      color: widget.themeColor,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    const SizedBox(height: 40),

                    Text(
                      loc.minimalPairsListenDifference,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // --- MİLYON DOLARLIK "SHIP VS SHEEP" KARTI ---
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: widget.themeColor.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: IntrinsicHeight(
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildWordSide(
                                currentPair['word_1'],
                                currentPair['ipa_1'],
                                currentPair['translation_1'],
                              ),
                            ),
                            VerticalDivider(
                              color: Colors.grey.shade200,
                              thickness: 2,
                              width: 2,
                            ),
                            Expanded(
                              child: _buildWordSide(
                                currentPair['word_2'],
                                currentPair['ipa_2'],
                                currentPair['translation_2'],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // --- HEDEF KELİME ALANI ---
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: widget.themeColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: widget.themeColor.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            loc.minimalPairsSayNow,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            targetWord,
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: widget.themeColor,
                            ),
                          ),
                          Text(
                            targetIpa,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // --- SONUÇ ALANI (Yapay Zeka Koçu Entegreli) ---
                    if (_isAnswerChecked && !_isGameOver)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: _isCorrect
                              ? Colors.green.shade50
                              : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: _isCorrect ? Colors.green : Colors.redAccent,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              _isCorrect
                                  ? Icons.check_circle
                                  : Icons.support_agent,
                              color: _isCorrect
                                  ? Colors.green
                                  : Colors.redAccent,
                              size: 30,
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _isCorrect
                                        ? loc.minimalPairsPerfectPronunciation
                                        : loc.minimalPairsCoachNote,
                                    style: TextStyle(
                                      color: _isCorrect
                                          ? Colors.green.shade800
                                          : Colors.red.shade800,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  if (!_isCorrect) ...[
                                    const SizedBox(height: 5),
                                    Text(
                                      _aiFeedback,
                                      style: TextStyle(
                                        color: Colors.red.shade900,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                    // --- MİKROFON VE İLERİ BUTONU ---
                    if (!_isAnswerChecked || !_isCorrect)
                      Column(
                        children: [
                          GestureDetector(
                            onTapDown: (_) => _listen(),
                            onTapUp: (_) => _speech.stop(),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              height: 80,
                              width: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _isListening
                                    ? Colors.redAccent
                                    : widget.themeColor,
                                boxShadow: [
                                  if (_isListening)
                                    BoxShadow(
                                      color: Colors.redAccent.withOpacity(0.5),
                                      blurRadius: 20,
                                      spreadRadius: 10,
                                    ),
                                ],
                              ),
                              child: const Icon(
                                Icons.mic,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            loc.minimalPairsHoldToSpeak,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 15),

                          TextButton(
                            onPressed: _isListening ? null : _handleBilemedim,
                            child: Text(
                              loc.minimalPairsSkip,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      ElevatedButton(
                        onPressed: _nextPair,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.themeColor,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          loc.minimalPairsContinue,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWordSide(String word, String ipa, String translation) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            word,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            ipa,
            style: TextStyle(
              fontSize: 16,
              color: widget.themeColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            translation,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          IconButton(
            icon: Icon(
              Icons.volume_up_rounded,
              color: widget.themeColor,
              size: 30,
            ),
            onPressed: () => _speak(word),
            style: IconButton.styleFrom(
              backgroundColor: widget.themeColor.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }
}
