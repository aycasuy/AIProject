import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:http/http.dart' as http;
import 'dart:convert';
//import '../services/api_service.dart';
import 'package:mobile_app/l10n/app_localizations.dart';

class FinalTestScreen extends StatefulWidget {
  final String username;
  final String targetLanguage;
  final String userLevel;
  final int lessonId;
  final String nativeLanguage;

  const FinalTestScreen({
    super.key,
    required this.username,
    required this.targetLanguage,
    required this.userLevel,
    required this.lessonId,
    required this.nativeLanguage,
  });

  @override
  State<FinalTestScreen> createState() => _FinalTestScreenState();
}

class _FinalTestScreenState extends State<FinalTestScreen> {
  bool _isLoading = true;
  List<dynamic> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  bool _isTestFinished = false;
  int _correctAnswers = 0; // 🌟 YENİ: Doğru cevap sayısını tutmak için

  // Araçlar
  final TextEditingController _textController = TextEditingController();
  late FlutterTts _flutterTts;
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _recognizedText = "";

  // Drag & Drop için
  List<String> _availableWords = [];
  List<String> _selectedWords = [];
  String? _loadError;
  bool _initialLoadStarted = false;

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
    _initTools();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialLoadStarted) {
      _initialLoadStarted = true;
      _fetchTestQuestions();
    }
  }

  void _initTools() async {
    _flutterTts = FlutterTts();
    _speech = stt.SpeechToText();

    await _flutterTts.setLanguage(_getTtsLanguageCode(widget.targetLanguage));
    await _flutterTts.setSpeechRate(0.45);
    await _flutterTts.setPitch(1.0);
    await _speech.initialize();
  }

  @override
  void dispose() {
    _textController.dispose();
    _speech.stop();
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _fetchTestQuestions() async {
    final loc = AppLocalizations.of(context)!;

    setState(() {
      _isLoading = true;
      _loadError = null;
      _questions = [];
    });

    try {
      final url = Uri.parse('http://10.0.2.2:8000/generate_final_test');

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "lesson_id": widget.lessonId,
          "level": widget.userLevel,
          "target_language": widget.targetLanguage,
          "native_language": widget.nativeLanguage,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));

        final List<dynamic> questions = data['questions'] is List
            ? List<dynamic>.from(data['questions'])
            : <dynamic>[];

        setState(() {
          _questions = questions;
          _isLoading = false;

          if (_questions.isNotEmpty) {
            _prepareQuestionData();
          }
        });
      } else {
        debugPrint(
          "FINAL TEST ERROR: ${response.statusCode} - ${response.body}",
        );

        setState(() {
          _loadError = "${loc.finalTestLoadFailed} (${response.statusCode})";
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loadError = loc.connectionErrorWithDetail(e.toString());
        _isLoading = false;
      });
    }
  }

  void _prepareQuestionData() {
    if (_currentIndex >= _questions.length) return;

    final q = _questions[_currentIndex];
    _textController.clear();
    _recognizedText = "";

    if (q['type'] == 'order') {
      _availableWords = List<String>.from(q['scrambled']);
      _selectedWords = [];
    }
  }

  // 🌟 BURAYA EKLİYORUZ: YENİ NORMALİZASYON FONKSİYONU
  String _normalizeSpokenText(String text) {
    if (text.isEmpty) return "";

    String normalized = text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .trim();

    Map<String, String> numberWords = {
      '0': 'zero',
      '1': 'one',
      '2': 'two',
      '3': 'three',
      '4': 'four',
      '5': 'five',
      '6': 'six',
      '7': 'seven',
      '8': 'eight',
      '9': 'nine',
      '10': 'ten',
      '11': 'eleven',
      '12': 'twelve',
      '20': 'twenty',
      '30': 'thirty',
      '40': 'forty',
      '50': 'fifty',
      '100': 'one hundred',
      '1000': 'one thousand',
    };

    List<String> words = normalized.split(' ');

    for (int i = 0; i < words.length; i++) {
      if (RegExp(r'^[0-9]+$').hasMatch(words[i]) &&
          numberWords.containsKey(words[i])) {
        words[i] = numberWords[words[i]]!;
      }
    }

    return words.join(' ');
  }

  // 🎯 CEVAP KONTROL MOTORU (ACIMASIZ SINAV MODU)
  void _submitAnswer() {
    final q = _questions[_currentIndex];
    bool isCorrect = false;

    if (q['type'] == 'blank' || q['type'] == 'listen') {
      String answer = q['type'] == 'blank' ? q['answer'] : q['text'];
      // Basit temizlik (Noktalama ve büyük/küçük harf duyarlılığını kaldır)
      String userAnswer = _textController.text.trim().toLowerCase().replaceAll(
        RegExp(r'[^\w\s]'),
        '',
      );
      String correctAnswer = answer.toLowerCase().replaceAll(
        RegExp(r'[^\w\s]'),
        '',
      );
      isCorrect = userAnswer == correctAnswer;
    } else if (q['type'] == 'order') {
      String userAnswer = _selectedWords.join(" ");
      isCorrect = userAnswer.toLowerCase() == q['correct'].toLowerCase();
    } else if (q['type'] == 'speak') {
      // 🌟 YENİ KOD: Kendi normalizasyon fonksiyonumuzla sayıları metne çeviriyoruz
      String userAnswer = _normalizeSpokenText(_recognizedText);
      String correctAnswer = _normalizeSpokenText(q['text']);
      // Konuşmada %80 benzerlik yeterli sayılabilir, basitlik için tam eşleşme veya kapsama bakıyoruz
      isCorrect =
          userAnswer.length > 5 &&
          (userAnswer.contains(correctAnswer) ||
              correctAnswer.contains(userAnswer));
    }

    // Puanlama ve Geçiş
    if (isCorrect) {
      _correctAnswers++; // Her soru 10 puan (Toplam 100)
      _showFeedback(true);
    } else {
      _showFeedback(false);
    }

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        if (_currentIndex < _questions.length - 1) {
          _currentIndex++;
          _prepareQuestionData();
        } else {
          _finishTest();
        }
      });
    });
  }

  void _showFeedback(bool isCorrect) {
    final loc = AppLocalizations.of(context)!;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isCorrect ? loc.finalTestCorrect : loc.finalTestWrong,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        backgroundColor: isCorrect
            ? const Color(0xFF06D6A0)
            : const Color(0xFFFF6B6B),
        duration: const Duration(milliseconds: 800),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _finishTest() async {
    setState(() {
      // 🌟 DİNAMİK SKOR HESABI: (Doğru Sayısı / Toplam Soru Sayısı) * 100
      _score = ((_correctAnswers / _questions.length) * 100).round();
      _isTestFinished = true;
    });
  }

  // --- UI GÖVDESİ ---

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF1E1E2C),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.amber),
              const SizedBox(height: 18),
              Text(
                loc.finalTestLoading,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_loadError != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF1E1E2C),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: Colors.redAccent,
                  size: 58,
                ),
                const SizedBox(height: 16),
                Text(
                  _loadError!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 22),
                ElevatedButton(
                  onPressed: _fetchTestQuestions,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black87,
                  ),
                  child: Text(loc.finalTestRetry),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF1E1E2C),
        body: Center(
          child: Text(
            loc.finalTestNoQuestions,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 17),
          ),
        ),
      );
    }

    if (_isTestFinished) {
      return _buildReportCard();
    }

    final q = _questions[_currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          loc.finalTestTitle,
          style: const TextStyle(
            color: Colors.amber,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (_currentIndex + 1) / _questions.length,
              backgroundColor: Colors.white24,
              color: Colors.amber,
              minHeight: 10,
              borderRadius: BorderRadius.circular(10),
            ),
            const SizedBox(height: 10),
            Text(
              loc.finalTestQuestionCounter(
                _currentIndex + 1,
                _questions.length,
              ),
              style: const TextStyle(color: Colors.grey),
            ),

            const Spacer(),

            if (q['type'] == 'blank') _buildBlankQuestion(q),
            if (q['type'] == 'order') _buildOrderQuestion(q),
            if (q['type'] == 'listen') _buildListenQuestion(q),
            if (q['type'] == 'speak') _buildSpeakQuestion(q),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitAnswer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  loc.finalTestAnswer,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- SORU TİPİ WIDGET'LARI ---

  Widget _buildBlankQuestion(Map<String, dynamic> q) {
    final loc = AppLocalizations.of(context)!;

    return Column(
      children: [
        Text(
          loc.finalTestFillBlank,
          style: const TextStyle(color: Colors.white54, fontSize: 16),
        ),
        const SizedBox(height: 20),
        Text(
          q['question'].replaceAll('____', '________'),
          style: const TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(q['translation'], style: const TextStyle(color: Colors.amber)),
        const SizedBox(height: 30),
        TextField(
          controller: _textController,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 20),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white10,
            hintText: loc.finalTestAnswerHint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderQuestion(Map<String, dynamic> q) {
    final loc = AppLocalizations.of(context)!;

    return Column(
      children: [
        Text(
          loc.finalTestBuildSentence,
          style: const TextStyle(color: Colors.white54, fontSize: 16),
        ),
        const SizedBox(height: 20),
        Text(
          q['original'],
          style: const TextStyle(
            fontSize: 22,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),
        // Seçilen Kelimeler Kutusu
        Container(
          width: double.infinity,
          height: 80,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _selectedWords
                .map(
                  (w) => GestureDetector(
                    onTap: () => setState(() {
                      _selectedWords.remove(w);
                      _availableWords.add(w);
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        w,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 30),
        // Havuz (Seçilecek Kelimeler)
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _availableWords
              .map(
                (w) => GestureDetector(
                  onTap: () => setState(() {
                    _availableWords.remove(w);
                    _selectedWords.add(w);
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(color: Colors.amber, width: 2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      w,
                      style: const TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildListenQuestion(Map<String, dynamic> q) {
    final loc = AppLocalizations.of(context)!;
    final languageName = _localizedLanguageName(widget.targetLanguage, loc);
    return Column(
      children: [
        Text(
          loc.finalTestListenAndWrite,
          style: const TextStyle(color: Colors.white54, fontSize: 16),
        ),
        const SizedBox(height: 30),
        GestureDetector(
          onTap: () => _flutterTts.speak(q['text']),
          child: const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.amber,
            child: Icon(Icons.volume_up, size: 50, color: Colors.black87),
          ),
        ),
        const SizedBox(height: 40),
        TextField(
          controller: _textController,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 20),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white10,
            hintText: loc.finalTestWriteInLanguage(languageName),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          ),
        ),
      ],
    );
  }

  Widget _buildSpeakQuestion(Map<String, dynamic> q) {
    final loc = AppLocalizations.of(context)!;
    return Column(
      children: [
        Text(
          loc.finalTestReadAloud,
          style: const TextStyle(color: Colors.white54, fontSize: 16),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.amber),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(
            q['text'],
            style: const TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 40),
        Text(
          _recognizedText.isEmpty
              ? loc.finalTestMicrophoneHint
              : _recognizedText,
          style: const TextStyle(color: Colors.amber, fontSize: 18),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),
        GestureDetector(
          onTap: () async {
            if (!_isListening) {
              bool available = await _speech.initialize();
              if (available) {
                setState(() => _isListening = true);
                _speech.listen(
                  localeId: _getSpeechLocaleId(widget.targetLanguage),
                  onResult: (val) {
                    setState(() {
                      _recognizedText = val.recognizedWords;
                    });
                  },
                );
              }
            } else {
              setState(() => _isListening = false);
              _speech.stop();
            }
          },
          child: CircleAvatar(
            radius: 40,
            backgroundColor: _isListening ? Colors.red : Colors.amber,
            child: Icon(
              _isListening ? Icons.mic_off : Icons.mic,
              size: 40,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  // 🏆 KARNE EKRANI (BÖLÜM SONU)
  Widget _buildReportCard() {
    final loc = AppLocalizations.of(context)!;

    bool passed = _score >= 70;
    return Scaffold(
      backgroundColor: passed
          ? const Color(0xFF06D6A0).withOpacity(0.1)
          : const Color(0xFFFF6B6B).withOpacity(0.1),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(passed ? "🎉" : "💔", style: const TextStyle(fontSize: 100)),
            const SizedBox(height: 20),
            Text(
              passed ? loc.finalTestCongratulations : loc.finalTestFailedTitle,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: passed
                    ? const Color(0xFF06D6A0)
                    : const Color(0xFFFF6B6B),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              loc.finalTestScore(_score),
              style: const TextStyle(fontSize: 24, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                passed
                    ? loc.finalTestPassedMessage
                    : loc.finalTestFailedMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () => Navigator.pop(
                context,
                passed,
              ), // Haritaya passed (true/false) gönder
              style: ElevatedButton.styleFrom(
                backgroundColor: passed
                    ? const Color(0xFF06D6A0)
                    : Colors.grey.shade800,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                passed ? loc.finalTestNextLesson : loc.finalTestBackToMap,
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
