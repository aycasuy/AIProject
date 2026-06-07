import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_tts/flutter_tts.dart';
import 'main_navigation.dart';
import '../l10n/app_localizations.dart'; // 👈 ekle

class PlacementTestScreen extends StatefulWidget {
  final String username;
  final String targetLanguage;
  final String nativeLanguage;

  const PlacementTestScreen({
    super.key,
    required this.username,
    required this.targetLanguage,
    required this.nativeLanguage,
  });

  @override
  State<PlacementTestScreen> createState() => _PlacementTestScreenState();
}

class _PlacementTestScreenState extends State<PlacementTestScreen> {
  bool _isLoading = true;
  List<dynamic> _questions = [];
  int _currentIndex = 0;
  String _selectedAnswer = '';

  final Map<String, int> _levelScores = {
    'A1': 0,
    'A2': 0,
    'B1': 0,
    'B2': 0,
    'C1': 0,
  };

  late FlutterTts flutterTts;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initTts();
    _fetchQuestions();
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

  void _initTts() {
    flutterTts = FlutterTts();
    flutterTts.setLanguage(_getTtsLanguageCode(widget.targetLanguage));
    flutterTts.setSpeechRate(0.45);
    flutterTts.setPitch(1.0);
    flutterTts.setCompletionHandler(() {
      if (mounted) setState(() => _isPlaying = false);
    });
  }

  Future<void> _fetchQuestions() async {
    try {
      final url = Uri.parse('http://10.0.2.2:8000/generate_placement_test')
          .replace(
            queryParameters: {
              "target_language": widget.targetLanguage,
              "native_language": widget.nativeLanguage,
            },
          );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          _questions = data['questions'];
          _isLoading = false;
        });
      } else {
        _showError("Sınav yüklenirken sunucu hatası oluştu.");
      }
    } catch (e) {
      _showError("Bağlantı hatası! Sunucu açık mı?");
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
    );
    setState(() => _isLoading = false);
  }

  Future<void> _speak(String text) async {
    setState(() => _isPlaying = true);
    await flutterTts.speak(text);
  }

  Future<void> _stopSpeaking() async {
    setState(() => _isPlaying = false);
    await flutterTts.stop();
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  void _nextQuestion() {
    if (_selectedAnswer.isEmpty) return;

    final currentQ = _questions[_currentIndex];

    if (_selectedAnswer == currentQ['answer']) {
      String level = currentQ['level'];
      if (_levelScores.containsKey(level)) {
        _levelScores[level] = _levelScores[level]! + 1;
      }
    }

    _stopSpeaking();

    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedAnswer = '';
      });
    } else {
      _finishTest();
    }
  }

  String _calculateFinalLevel() {
    final int a1 = _levelScores['A1'] ?? 0;
    final int a2 = _levelScores['A2'] ?? 0;
    final int b1 = _levelScores['B1'] ?? 0;
    final int b2 = _levelScores['B2'] ?? 0;
    final int c1 = _levelScores['C1'] ?? 0;

    if (a1 < 2) return "A1";
    if (a2 < 2) return "A1";
    if (b1 < 2) return "A2";
    if (b2 < 2) return "B1";
    if (c1 < 2) return "B2";
    return "C1";
  }

  Future<void> _finishTest() async {
    setState(() => _isLoading = true);

    String finalLevel = _calculateFinalLevel();

    try {
      final url = Uri.parse('http://10.0.2.2:8000/save_progress');
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": widget.username,
          "level": finalLevel,
          "target_language": widget.targetLanguage,
        }),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        setState(() => _isLoading = false);

        final l10n = AppLocalizations.of(context)!;

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(l10n.placementFinishedTitle),
            content: Text(
              l10n.placementFinishedBody(finalLevel),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MainNavigationScreen(
                        username: widget.username,
                        targetLanguage: widget.targetLanguage,
                        minLevel: finalLevel,
                        nativeLanguage: widget.nativeLanguage,
                      ),
                    ),
                    (Route<dynamic> route) => false,
                  );
                },
                child: Text(l10n.placementBackToMenu),
              ),
            ],
          ),
        );
      } else {
        if (!mounted) return;
        setState(() => _isLoading = false);
        _showError("Seviye kaydedilemedi!");
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError("Seviyen hesaplandı ama veritabanına kaydedilemedi!");
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FF),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Color(0xFF118AB2)),
              const SizedBox(height: 20),
              Text(
                l10n.placementLoading,
                style: const TextStyle(
                  color: Color(0xFF073B4C),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(body: Center(child: Text(l10n.placementNoQuestion)));
    }

    final currentQ = _questions[_currentIndex];
    final String type = currentQ['type'];
    final String level = currentQ['level'];
    final String questionText = currentQ['question'];
    final String? contextText = currentQ['context_text'];
    final List<dynamic> options = currentQ['options'];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF073B4C)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.placementQuestion(_currentIndex + 1, _questions.length),
              style: const TextStyle(
                color: Color(0xFF073B4C),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF06D6A0).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                level,
                style: const TextStyle(
                  color: Color(0xFF06D6A0),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (type == 'reading' && contextText != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    contextText,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Color(0xFF073B4C),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ] else if (type == 'listening' && contextText != null) ...[
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF118AB2).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.headphones_rounded,
                        size: 48,
                        color: Color(0xFF118AB2),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.placementListenInstruction,
                        style: const TextStyle(
                          color: Color(0xFF073B4C),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _isPlaying
                            ? _stopSpeaking
                            : () => _speak(contextText),
                        icon: Icon(
                          _isPlaying
                              ? Icons.stop_rounded
                              : Icons.play_arrow_rounded,
                        ),
                        label: Text(
                          _isPlaying
                              ? l10n.placementStopButton
                              : l10n.placementListenButton,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isPlaying
                              ? Colors.redAccent
                              : const Color(0xFF118AB2),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              Text(
                questionText,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF073B4C),
                ),
              ),
              const SizedBox(height: 30),

              Expanded(
                child: ListView.builder(
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final option = options[index];
                    final isSelected = _selectedAnswer == option;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: InkWell(
                        onTap: () => setState(() => _selectedAnswer = option),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 18,
                            horizontal: 20,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF118AB2)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF118AB2)
                                  : Colors.grey.shade300,
                              width: 2,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF118AB2,
                                      ).withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Text(
                            option,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF073B4C),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              ElevatedButton(
                onPressed: _selectedAnswer.isEmpty ? null : _nextQuestion,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  backgroundColor: const Color(0xFF06D6A0),
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  l10n.placementNext,
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
    );
  }
}
