import 'package:flutter/material.dart';
import '/services/api_service.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class PronunciationScreen extends StatefulWidget {
  final String username;
  final String targetLanguage;
  final String userLevel;
  final String targetWords; // API'ye gidecek kelimeler
  final int lessonId;
  final int sectionIndex;
  final String nativeLanguage;

  const PronunciationScreen({
    super.key,
    required this.username,
    required this.targetLanguage,
    required this.userLevel,
    required this.targetWords,
    required this.lessonId,
    required this.sectionIndex,
    required this.nativeLanguage,
  });

  @override
  State<PronunciationScreen> createState() => _PronunciationScreenState();
}

class _PronunciationScreenState extends State<PronunciationScreen> {
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;
  bool _isListening = false;
  bool _isAnalyzing = false;
  bool _isTtsPlaying = false;
  // ignore: unused_field
  bool _speechEnabled = false;
  String _recognizedText = "";

  String _targetText = "";
  final List<String> _usedPronunciationTexts = [];
  bool _isLoadingText = true;

  int _currentRound = 1;
  final int _totalRounds = 3;
  bool _isAllFinished = false;

  int _lives = 0;
  bool _isLoadingLives = true;
  bool _isGameOver = false;

  int _remainingSeconds = 0;
  Timer? _countdownTimer;

  bool get _canAnalyze {
    return _recognizedText.trim().length > 5 &&
        _recognizedText != "" &&
        !_isLoadingText &&
        !_isListening &&
        !_isTtsPlaying &&
        !_isAnalyzing;
  }

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
    _initSpeech();
    _initTts();
    _fetchCurrentLives();
    _fetchDynamicText();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _speech.stop();
    _flutterTts.stop();
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
        return Colors.green;
    }
  }

  String _cleanPronunciationText(String rawText) {
    return rawText
        .replaceAll("**", "")
        .replaceAll("*", "")
        .replaceAll(RegExp(r"\s+"), " ")
        .trim();
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
      case "italian":
        return "it_IT";
      case "turkish":
        return "tr_TR";
      default:
        return "en_US";
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
      case "italian":
        return "it-IT";
      case "turkish":
        return "tr-TR";
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
      if (mounted) setState(() => _isLoadingLives = false);
    }
  }

  void _initSpeech() async {
    _speechEnabled = await _speech.initialize(
      onStatus: (val) => print('Mikrofon Durumu: $val'),
      onError: (val) => print('Mikrofon Hatası: $val'),
    );
    if (mounted) setState(() {});
  }

  void _initTts() {
    _flutterTts.setLanguage(_getTtsLanguageCode(widget.targetLanguage));
    _flutterTts.setSpeechRate(0.42);
    _flutterTts.setPitch(1.0);

    _flutterTts.setCompletionHandler(() {
      if (mounted) {
        setState(() => _isTtsPlaying = false);
      }
    });

    _flutterTts.setCancelHandler(() {
      if (mounted) {
        setState(() => _isTtsPlaying = false);
      }
    });

    _flutterTts.setErrorHandler((message) {
      if (mounted) {
        setState(() => _isTtsPlaying = false);
      }
    });
  }

  Future<void> _fetchDynamicText() async {
    if (_isTtsPlaying) {
      await _stopTts();
    }

    setState(() => _isLoadingText = true);

    try {
      String? newText;

      // Backend farklı metin döndürüyorsa aynı metni yakalayıp tekrar deniyoruz.
      // Backend henüz exclude_texts / round alanlarını kullanmıyorsa bile uygulama bozulmaz.
      for (int attempt = 0; attempt < 3; attempt++) {
        final url = Uri.parse(
          'http://10.0.2.2:8000/generate_pronunciation_text',
        );
        final response = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "target_language": widget.targetLanguage,
            "level": widget.userLevel,
            "target_words": widget.targetWords,
            "lesson_id": widget.lessonId,
            "round": _currentRound,
            "exclude_texts": _usedPronunciationTexts,
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(utf8.decode(response.bodyBytes));
          final cleanedText = _cleanPronunciationText(data['text'] ?? "");

          if (cleanedText.isNotEmpty &&
              !_usedPronunciationTexts.contains(cleanedText)) {
            newText = cleanedText;
            break;
          }

          // Eğer backend hep aynı metni döndürüyorsa en azından boş kalmasın.
          newText ??= cleanedText;
        } else {
          print(
            "Telaffuz metni alınamadı: ${response.statusCode} - ${response.body}",
          );
        }
      }

      if (mounted) {
        setState(() {
          _targetText = (newText != null && newText.isNotEmpty)
              ? newText
              : "Bu ders için uygun telaffuz metni bulunamadı.";
          if (!_usedPronunciationTexts.contains(_targetText)) {
            _usedPronunciationTexts.add(_targetText);
          }
          _isLoadingText = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _targetText = "Bağlantı hatası! Lütfen internetini kontrol et.";
          _isLoadingText = false;
        });
      }
    }
  }

  Future<void> _speakTargetText() async {
    if (_isLoadingText || _targetText.trim().isEmpty) return;

    if (_isListening) {
      await _speech.stop();
      if (mounted) {
        setState(() => _isListening = false);
      }
    }

    if (_isTtsPlaying) {
      await _stopTts();
      return;
    }

    if (mounted) {
      setState(() => _isTtsPlaying = true);
    }

    await _flutterTts.speak(_cleanPronunciationText(_targetText));
  }

  Future<void> _stopTts() async {
    await _flutterTts.stop();

    if (mounted) {
      setState(() => _isTtsPlaying = false);
    }
  }

  void _listen() async {
    if (_isTtsPlaying) {
      await _stopTts();
    }

    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() {
          _isListening = true;
          _recognizedText = "";
        });

        String localeId = _getSpeechLocaleId(widget.targetLanguage);

        _speech.listen(
          localeId: localeId,
          onResult: (val) => setState(() {
            _recognizedText = val.recognizedWords;
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  Future<void> _analyzePronunciation() async {
    setState(() => _isAnalyzing = true);

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/analyze_pronunciation'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": widget.username,
          "target_language": widget.targetLanguage,
          "original_text": _cleanPronunciationText(_targetText),
          "spoken_text": _recognizedText,
          "native_language": widget.nativeLanguage,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final int score = data['analysis']['score'] ?? 0;
        bool isSuccess = score >= 60;

        // 🌟 DEĞİŞİKLİK 1: Backend'den gelen 'added_xp' değerini artık körü körüne kabul edip hemen eklemiyoruz.
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
          // Her başarılı cümlede XP vermek yerine, 3 cümlenin tamamı bitince Backend'e "İlerlememi kaydet" diyeceğiz.
          if (_currentRound == _totalRounds) {
            // Kullanıcı 3 metni de bitirdi! Haritada ilerleme zamanı.
            // XP'yi ve tekrar (replay) olup olmadığını Python belirleyecek.
            xpToGive = data['added_xp'] ?? 50;
          } else {
            // Ara metinleri (1. veya 2. metin) başarıyla okudu. Arayüzde küçük bir görsel motivasyon (15 XP) gösterebilirsin.
            xpToGive =
                15; // 🌟 Sembolik görsel XP, gerçek veritabanına işlenmez.
          }
        }

        _showResultDialog(
          score,
          data['analysis']['feedback'],
          List<String>.from(data['analysis']['mispronounced_words']),
          xpToGive,
          isSuccess,
        );
      }
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  Widget _buildScreenBackground({
    required Widget child,
    required Color themeColor,
  }) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [themeColor.withOpacity(0.16), Colors.white, Colors.white],
          stops: const [0.0, 0.36, 1.0],
        ),
      ),
      child: child,
    );
  }

  Widget _buildProgressBar(int current, int total, Color themeColor) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 13,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.07),
          borderRadius: BorderRadius.circular(20),
        ),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: current / total,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [themeColor, themeColor.withOpacity(0.75)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLevelBadge(Color themeColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: themeColor.withOpacity(0.13),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: themeColor.withOpacity(0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome, size: 16, color: themeColor),
          const SizedBox(width: 6),
          Text(
            widget.userLevel,
            style: TextStyle(
              color: themeColor,
              fontWeight: FontWeight.w900,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLives() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.72),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: List.generate(
          5,
          (index) => Padding(
            padding: const EdgeInsets.only(left: 2.0, right: 2.0),
            child: Icon(
              Icons.favorite_rounded,
              color: index < _lives ? Colors.redAccent : Colors.grey.shade300,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Color themeColor) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Metin $_currentRound / $_totalRounds",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Cümleyi net ve sakin oku",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Align(
                alignment: Alignment.centerRight,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildLevelBadge(themeColor),
                      const SizedBox(width: 8),
                      _buildLives(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildProgressBar(_currentRound, _totalRounds, themeColor),
      ],
    );
  }

  Widget _buildTargetTextCard(Color themeColor, {bool compact = false}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 22 : 26,
        vertical: compact ? 22 : 28,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(34),
        border: Border.all(color: themeColor.withOpacity(0.22), width: 1.4),
        boxShadow: [
          BoxShadow(
            color: themeColor.withOpacity(0.14),
            blurRadius: 34,
            spreadRadius: 2,
            offset: const Offset(0, 18),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(compact ? 12 : 15),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: themeColor.withOpacity(0.12),
            ),
            child: Icon(
              Icons.record_voice_over_rounded,
              color: themeColor,
              size: compact ? 28 : 32,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "Aşağıdaki cümleyi oku",
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 18),
          _isLoadingText
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: CircularProgressIndicator(color: themeColor),
                )
              : ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: compact ? 230 : 285),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Text(
                      _targetText,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: compact ? 21 : 23,
                        fontWeight: FontWeight.w900,
                        height: 1.45,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ),
          if (!_isLoadingText) ...[
            const SizedBox(height: 18),
            _buildListenFirstButton(themeColor),
          ],
        ],
      ),
    );
  }

  Widget _buildListenFirstButton(Color themeColor) {
    return OutlinedButton.icon(
      onPressed: _isLoadingText ? null : _speakTargetText,
      icon: Icon(
        _isTtsPlaying ? Icons.stop_rounded : Icons.volume_up_rounded,
        color: themeColor,
      ),
      label: Text(
        _isTtsPlaying ? "Durdur" : "Önce Dinle",
        style: TextStyle(
          color: themeColor,
          fontWeight: FontWeight.w900,
          fontSize: 15,
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: themeColor.withOpacity(0.35), width: 1.5),
        backgroundColor: themeColor.withOpacity(0.06),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }

  Widget _buildTranscriptBox(Color themeColor) {
    final bool hasSpeech =
        _recognizedText.trim().isNotEmpty &&
        _recognizedText != "Mikrofona bas ve okumaya başla...";

    String text;
    if (_isListening && !hasSpeech) {
      text = "Dinliyorum...";
    } else if (hasSpeech) {
      text = _recognizedText;
    } else {
      text = "Mikrofona basınca söylediklerin burada görünecek.";
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: _isListening
            ? themeColor.withOpacity(0.08)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: _isListening
              ? themeColor.withOpacity(0.22)
              : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isListening ? Icons.hearing_rounded : Icons.closed_caption_rounded,
            color: _isListening ? themeColor : Colors.grey.shade500,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 96),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Text(
                  text,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: hasSpeech ? themeColor : Colors.grey.shade600,
                    fontSize: 15,
                    fontStyle: _isListening && !hasSpeech
                        ? FontStyle.italic
                        : FontStyle.normal,
                    fontWeight: hasSpeech ? FontWeight.w700 : FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMicButton(Color themeColor, {bool compact = false}) {
    return GestureDetector(
      onTap: _listen,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        padding: EdgeInsets.all(
          compact ? (_isListening ? 12 : 7) : (_isListening ? 16 : 10),
        ),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _isListening
              ? Colors.redAccent.withOpacity(0.12)
              : themeColor.withOpacity(0.10),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: EdgeInsets.all(compact ? 11 : 14),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _isListening
                ? Colors.redAccent.withOpacity(0.18)
                : themeColor.withOpacity(0.16),
          ),
          child: Container(
            width: compact ? 72 : 82,
            height: compact ? 72 : 82,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _isListening
                    ? [Colors.redAccent, Colors.red.shade700]
                    : [themeColor.withOpacity(0.88), themeColor],
              ),
              boxShadow: [
                BoxShadow(
                  color: _isListening
                      ? Colors.redAccent.withOpacity(0.38)
                      : themeColor.withOpacity(0.32),
                  blurRadius: _isListening ? 34 : 26,
                  spreadRadius: _isListening ? 7 : 2,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Icon(
              _isListening ? Icons.graphic_eq_rounded : Icons.mic_rounded,
              color: Colors.white,
              size: compact ? 36 : 42,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyzeButton(Color themeColor, {bool compact = false}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: compact ? 56 : 62,
      child: ElevatedButton(
        onPressed: _canAnalyze ? _analyzePronunciation : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: themeColor,
          disabledBackgroundColor: Colors.grey.shade200,
          elevation: _canAnalyze ? 9 : 0,
          shadowColor: themeColor.withOpacity(0.32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
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
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isListening ? "Konuşman Bekleniyor" : "Analiz Et",
                    style: TextStyle(
                      fontSize: 18,
                      color: _canAnalyze ? Colors.white : Colors.grey.shade500,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "🎯",
                    style: TextStyle(
                      fontSize: 20,
                      color: _canAnalyze ? Colors.white : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildLoadingScreen(Color themeColor) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _buildScreenBackground(
        themeColor: themeColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: themeColor),
              const SizedBox(height: 18),
              Text(
                "Telaffuz görevin hazırlanıyor...",
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameOverScreen(Color themeColor) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _buildScreenBackground(
        themeColor: Colors.redAccent,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(34),
                boxShadow: [
                  BoxShadow(
                    color: Colors.redAccent.withOpacity(0.16),
                    blurRadius: 30,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("💔", style: TextStyle(fontSize: 76)),
                  const SizedBox(height: 18),
                  const Text(
                    "Hakların Doldu!",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Biraz bekle, yeni can geldiğinde devam edebilirsin.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.09),
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
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
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
                          fontSize: 16,
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
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade900,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        "Haritaya Dön",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessScreen(Color themeColor) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _buildScreenBackground(
        themeColor: themeColor,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(34),
                boxShadow: [
                  BoxShadow(
                    color: themeColor.withOpacity(0.18),
                    blurRadius: 32,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: themeColor.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Text("🎙️🎯", style: TextStyle(fontSize: 54)),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    "Harika Konuştun!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Tüm telaffuz görevlerini tamamladın.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeColor,
                        elevation: 8,
                        shadowColor: themeColor.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        "Haritaya Dön",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = getThemeColor(widget.userLevel);

    if (_isLoadingLives) {
      return _buildLoadingScreen(themeColor);
    }

    if (_isGameOver) {
      return _buildGameOverScreen(themeColor);
    }

    if (_isAllFinished) {
      return _buildSuccessScreen(themeColor);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        title: const Text(
          "Telaffuz Koçu 🎙️",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: Colors.black87,
            fontSize: 23,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: _buildScreenBackground(
        themeColor: themeColor,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bool compact = constraints.maxHeight < 760;

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      24,
                      compact ? 8 : 12,
                      24,
                      compact ? 12 : 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeader(themeColor),
                        SizedBox(height: compact ? 16 : 24),
                        _buildTargetTextCard(themeColor, compact: compact),
                        SizedBox(height: compact ? 14 : 20),
                        _buildTranscriptBox(themeColor),
                        SizedBox(height: compact ? 10 : 18),
                        Center(
                          child: _buildMicButton(themeColor, compact: compact),
                        ),
                        SizedBox(height: compact ? 12 : 22),
                        _buildAnalyzeButton(themeColor, compact: compact),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showResultDialog(
    int score,
    String feedback,
    List<String> mispronounced,
    int xp,
    bool isSuccess,
  ) {
    final themeColor = getThemeColor(widget.userLevel);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 30,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSuccess
                        ? const Color(0xFF06D6A0).withOpacity(0.12)
                        : const Color(0xFFFF6B6B).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isSuccess ? "Başarılı Telaffuz" : "Tekrar Deneyelim",
                    style: TextStyle(
                      color: isSuccess
                          ? const Color(0xFF06D6A0)
                          : const Color(0xFFFF6B6B),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 112,
                      height: 112,
                      child: CircularProgressIndicator(
                        value: score / 100,
                        strokeWidth: 9,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isSuccess
                              ? const Color(0xFF06D6A0)
                              : const Color(0xFFFF6B6B),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "$score",
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            color: isSuccess
                                ? const Color(0xFF06D6A0)
                                : const Color(0xFFFF6B6B),
                          ),
                        ),
                        Text(
                          "puan",
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (isSuccess)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD166).withOpacity(0.20),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "+$xp XP Kazandın!",
                      style: const TextStyle(
                        color: Color(0xFFE5A900),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "1 Can Gitti! Tekrar Dene.",
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
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
                if (mispronounced.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Dikkat etmen gereken kelimeler:",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: mispronounced
                        .map(
                          (word) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6B6B).withOpacity(0.10),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(
                                  0xFFFF6B6B,
                                ).withOpacity(0.25),
                              ),
                            ),
                            child: Text(
                              word,
                              style: const TextStyle(
                                color: Color(0xFFFF6B6B),
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
                        _stopTts();
                        if (_currentRound < _totalRounds) {
                          setState(() {
                            _currentRound++;
                            _recognizedText =
                                "Mikrofona bas ve okumaya başla...";
                          });
                          _fetchDynamicText();
                        } else {
                          setState(() => _isAllFinished = true);
                        }
                      } else {
                        setState(() {
                          _recognizedText = "Mikrofona bas ve okumaya başla...";
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSuccess
                          ? themeColor
                          : Colors.grey.shade800,
                      elevation: 8,
                      shadowColor: isSuccess
                          ? themeColor.withOpacity(0.28)
                          : Colors.black.withOpacity(0.16),
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
                        fontSize: 16,
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
