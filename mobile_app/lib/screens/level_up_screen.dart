import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../l10n/app_localizations.dart';
import '../services/api_service.dart';

class LevelUpScreen extends StatefulWidget {
  final String username;
  final String targetLanguage;
  final String nativeLanguage;
  final String currentLevel;
  final int lessonId;

  const LevelUpScreen({
    super.key,
    required this.username,
    required this.targetLanguage,
    required this.nativeLanguage,
    required this.currentLevel,
    required this.lessonId,
  });

  @override
  State<LevelUpScreen> createState() => _LevelUpScreenState();
}

class _LevelUpScreenState extends State<LevelUpScreen> {
  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _isTestFinished = false;
  bool _isListening = false;

  String? _loadError;

  List<dynamic> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  int _correctAnswers = 0;

  final TextEditingController _textController = TextEditingController();

  final FlutterTts _flutterTts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();

  String _recognizedText = '';

  List<String> _availableWords = [];
  List<String> _selectedWords = [];

  @override
  void initState() {
    super.initState();
    _configureLanguageTools();
    _fetchLevelUpQuestions();
  }

  @override
  void dispose() {
    _textController.dispose();
    _speech.stop();
    _flutterTts.stop();
    super.dispose();
  }

  String _getNextLevel(String current) {
    switch (current.trim().toUpperCase()) {
      case 'A1':
        return 'A2';
      case 'A2':
        return 'B1';
      case 'B1':
        return 'B2';
      case 'B2':
        return 'C1';
      case 'C1':
        return 'C2';
      default:
        return 'MAX';
    }
  }

  String _targetLocale() {
    switch (widget.targetLanguage.trim().toLowerCase()) {
      case 'spanish':
        return 'es-ES';
      case 'german':
        return 'de-DE';
      case 'french':
        return 'fr-FR';
      case 'turkish':
        return 'tr-TR';
      case 'english':
      default:
        return 'en-US';
    }
  }

  String _localizedTargetLanguage(AppLocalizations loc) {
    switch (widget.targetLanguage.trim().toLowerCase()) {
      case 'spanish':
        return loc.langSpanish;
      case 'german':
        return loc.langGerman;
      case 'french':
        return loc.langFrench;
      case 'turkish':
        return loc.langTurkish;
      case 'english':
      default:
        return loc.langEnglish;
    }
  }

  Future<void> _configureLanguageTools() async {
    await _flutterTts.setLanguage(_targetLocale());
    await _flutterTts.setSpeechRate(0.45);
    await _flutterTts.setPitch(1.0);
    await _speech.initialize();
  }

  Future<void> _fetchLevelUpQuestions() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _loadError = null;
      });
    }

    try {
      final Uri url = Uri.parse('http://10.0.2.2:8000/generate_level_up_test');

      final http.Response response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'lesson_id': widget.lessonId,
          'level': widget.currentLevel,
          'target_language': widget.targetLanguage,
          'native_language': widget.nativeLanguage,
        }),
      );

      final dynamic decoded = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode != 200) {
        throw Exception(
          decoded is Map && decoded['detail'] != null
              ? decoded['detail'].toString()
              : 'HTTP ${response.statusCode}',
        );
      }

      if (decoded is! Map ||
          decoded['status'] != 'success' ||
          decoded['questions'] is! List) {
        throw Exception(
          decoded is Map && decoded['message'] != null
              ? decoded['message'].toString()
              : 'Invalid response',
        );
      }

      final List<dynamic> questions = List<dynamic>.from(decoded['questions']);

      if (!mounted) return;

      setState(() {
        _questions = questions;
        _currentIndex = 0;
        _score = 0;
        _correctAnswers = 0;
        _isTestFinished = false;
        _isLoading = false;
      });

      _prepareQuestionData();
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _loadError = error.toString();
      });
    }
  }

  void _prepareQuestionData() {
    if (_currentIndex >= _questions.length) return;

    _textController.clear();
    _recognizedText = '';

    if (_isListening) {
      _speech.stop();
      _isListening = false;
    }

    final Map<String, dynamic> question = Map<String, dynamic>.from(
      _questions[_currentIndex],
    );

    if (question['type'] == 'order') {
      _availableWords = List<String>.from(question['scrambled'] ?? <String>[]);
      _selectedWords = [];
    } else {
      _availableWords = [];
      _selectedWords = [];
    }
  }

  String _normalizeAnswer(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]', unicode: true), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  bool _isAnswerProvided(Map<String, dynamic> question) {
    switch (question['type']) {
      case 'blank':
      case 'listen':
        return _textController.text.trim().isNotEmpty;
      case 'order':
        return _selectedWords.isNotEmpty;
      case 'speak':
        return _recognizedText.trim().isNotEmpty;
      default:
        return false;
    }
  }

  Future<void> _submitAnswer() async {
    if (_isSubmitting || _currentIndex >= _questions.length) {
      return;
    }

    final AppLocalizations loc = AppLocalizations.of(context)!;

    final Map<String, dynamic> question = Map<String, dynamic>.from(
      _questions[_currentIndex],
    );

    if (!_isAnswerProvided(question)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.levelUpAnswerRequired),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    bool isCorrect = false;

    if (question['type'] == 'blank' || question['type'] == 'listen') {
      final String correctAnswer = question['type'] == 'blank'
          ? (question['answer'] ?? '').toString()
          : (question['text'] ?? '').toString();

      isCorrect =
          _normalizeAnswer(_textController.text) ==
          _normalizeAnswer(correctAnswer);
    } else if (question['type'] == 'order') {
      isCorrect =
          _normalizeAnswer(_selectedWords.join(' ')) ==
          _normalizeAnswer((question['correct'] ?? '').toString());
    } else if (question['type'] == 'speak') {
      final String userAnswer = _normalizeAnswer(_recognizedText);
      final String correctAnswer = _normalizeAnswer(
        (question['text'] ?? '').toString(),
      );

      isCorrect =
          userAnswer == correctAnswer ||
          userAnswer.contains(correctAnswer) ||
          (correctAnswer.contains(userAnswer) && userAnswer.length >= 6);
    }

    if (isCorrect) {
      _correctAnswers++;
    }

    _showFeedback(isCorrect);

    await Future<void>.delayed(const Duration(milliseconds: 850));

    if (!mounted) return;

    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _isSubmitting = false;
        _prepareQuestionData();
      });
    } else {
      setState(() => _isSubmitting = false);
      await _finishTest();
    }
  }

  void _showFeedback(bool isCorrect) {
    final AppLocalizations loc = AppLocalizations.of(context)!;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isCorrect ? loc.levelUpCorrect : loc.levelUpWrong,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        backgroundColor: isCorrect
            ? const Color(0xFF06D6A0)
            : const Color(0xFFFF6B6B),
        duration: const Duration(milliseconds: 700),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _finishTest() async {
    if (_questions.isEmpty) return;

    final int calculatedScore = ((_correctAnswers / _questions.length) * 100)
        .round();

    if (mounted) {
      setState(() {
        _score = calculatedScore;
        _isTestFinished = true;
      });
    }

    if (calculatedScore >= 70) {
      final String nextLevel = _getNextLevel(widget.currentLevel);

      if (nextLevel != 'MAX') {
        try {
          await ApiService.upgradeLevel(
            username: widget.username,
            targetLanguage: widget.targetLanguage,
            newLevel: nextLevel,
          );
        } catch (error) {
          debugPrint('Seviye güncellenemedi: $error');
        }
      }
    }
  }

  Future<void> _speakText(String text) async {
    await _flutterTts.stop();
    await _flutterTts.setLanguage(_targetLocale());
    await _flutterTts.speak(text);
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speech.stop();

      if (mounted) {
        setState(() => _isListening = false);
      }
      return;
    }

    final bool available = await _speech.initialize();

    if (!available || !mounted) return;

    setState(() {
      _isListening = true;
      _recognizedText = '';
    });

    await _speech.listen(
      localeId: _targetLocale(),
      onResult: (result) {
        if (!mounted) return;

        setState(() {
          _recognizedText = result.recognizedWords;

          if (result.finalResult) {
            _isListening = false;
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations loc = AppLocalizations.of(context)!;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF6F7FB),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Colors.deepPurpleAccent),
              const SizedBox(height: 16),
              Text(
                loc.levelUpLoading,
                style: const TextStyle(
                  color: Color(0xFF4B4B4B),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_loadError != null) {
      return _buildLoadError(loc);
    }

    if (_questions.isEmpty) {
      return _buildEmptyState(loc);
    }

    if (_isTestFinished) {
      return _buildReportCard(loc);
    }

    final Map<String, dynamic> question = Map<String, dynamic>.from(
      _questions[_currentIndex],
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F7FB),
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          loc.levelUpTitle,
          style: const TextStyle(
            color: Color(0xFF2D2D2D),
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressHeader(loc),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
                child: _buildQuestion(question, loc),
              ),
            ),
            Container(
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
                  onPressed: _isSubmitting ? null : _submitAnswer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : Text(
                          loc.levelUpAnswer,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressHeader(AppLocalizations loc) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 10, 22, 18),
      color: const Color(0xFFF6F7FB),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentIndex + 1) / _questions.length,
            backgroundColor: Colors.grey.shade200,
            color: Colors.deepPurpleAccent,
            minHeight: 10,
            borderRadius: BorderRadius.circular(999),
          ),
          const SizedBox(height: 10),
          Text(
            loc.levelUpQuestionCounter(_currentIndex + 1, _questions.length),
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestion(Map<String, dynamic> question, AppLocalizations loc) {
    switch (question['type']) {
      case 'blank':
        return _buildBlankQuestion(question, loc);
      case 'order':
        return _buildOrderQuestion(question, loc);
      case 'listen':
        return _buildListenQuestion(question, loc);
      case 'speak':
        return _buildSpeakQuestion(question, loc);
      default:
        return _buildEmptyState(loc);
    }
  }

  Widget _questionCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.deepPurpleAccent.withOpacity(0.14)),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurpleAccent.withOpacity(0.09),
            blurRadius: 25,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: Colors.deepPurpleAccent.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.deepPurpleAccent, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildBlankQuestion(
    Map<String, dynamic> question,
    AppLocalizations loc,
  ) {
    return _questionCard(
      icon: Icons.edit_note_rounded,
      title: loc.levelUpFillBlank,
      child: Column(
        children: [
          Text(
            (question['question'] ?? '').toString().replaceAll(
              '____',
              '________',
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 23,
              color: Color(0xFF2D2D2D),
              fontWeight: FontWeight.w900,
              height: 1.35,
            ),
          ),
          if ((question['translation'] ?? '').toString().trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              question['translation'].toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.deepPurpleAccent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 26),
          TextField(
            controller: _textController,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF2D2D2D),
              fontSize: 19,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF6F7FB),
              hintText: loc.levelUpAnswerHint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderQuestion(
    Map<String, dynamic> question,
    AppLocalizations loc,
  ) {
    return _questionCard(
      icon: Icons.reorder_rounded,
      title: loc.levelUpBuildSentence,
      child: Column(
        children: [
          Text(
            (question['original'] ?? '').toString(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              color: Color(0xFF2D2D2D),
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 80),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F7FB),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Wrap(
              spacing: 9,
              runSpacing: 9,
              children: _selectedWords
                  .map(
                    (word) => _wordChip(
                      word: word,
                      selected: true,
                      onTap: () {
                        setState(() {
                          _selectedWords.remove(word);
                          _availableWords.add(word);
                        });
                      },
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 22),
          Wrap(
            spacing: 9,
            runSpacing: 9,
            alignment: WrapAlignment.center,
            children: _availableWords
                .map(
                  (word) => _wordChip(
                    word: word,
                    selected: false,
                    onTap: () {
                      setState(() {
                        _availableWords.remove(word);
                        _selectedWords.add(word);
                      });
                    },
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _wordChip({
    required String word,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Colors.deepPurpleAccent : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.deepPurpleAccent, width: 1.6),
        ),
        child: Text(
          word,
          style: TextStyle(
            color: selected ? Colors.white : Colors.deepPurpleAccent,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _buildListenQuestion(
    Map<String, dynamic> question,
    AppLocalizations loc,
  ) {
    return _questionCard(
      icon: Icons.headphones_rounded,
      title: loc.levelUpListenAndWrite,
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () => _speakText((question['text'] ?? '').toString()),
            child: const CircleAvatar(
              radius: 48,
              backgroundColor: Colors.deepPurpleAccent,
              child: Icon(
                Icons.volume_up_rounded,
                size: 46,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 28),
          TextField(
            controller: _textController,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF2D2D2D),
              fontSize: 19,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF6F7FB),
              hintText: loc.levelUpWriteInLanguage(
                _localizedTargetLanguage(loc),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeakQuestion(
    Map<String, dynamic> question,
    AppLocalizations loc,
  ) {
    return _questionCard(
      icon: Icons.record_voice_over_rounded,
      title: loc.levelUpReadAloud,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F7FB),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.deepPurpleAccent.withOpacity(0.25),
              ),
            ),
            child: Text(
              (question['text'] ?? '').toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                color: Color(0xFF2D2D2D),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _recognizedText.isEmpty
                ? (_isListening
                      ? loc.levelUpListening
                      : loc.levelUpMicrophoneHint)
                : _recognizedText,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.deepPurpleAccent,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 22),
          InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: _toggleListening,
            child: CircleAvatar(
              radius: 40,
              backgroundColor: _isListening
                  ? Colors.redAccent
                  : Colors.deepPurpleAccent,
              child: Icon(
                _isListening ? Icons.stop_rounded : Icons.mic_rounded,
                size: 38,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadError(AppLocalizations loc) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 70,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 16),
              Text(
                loc.levelUpLoadFailed,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF2D2D2D),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _loadError ?? '',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _fetchLevelUpQuestions,
                child: Text(loc.levelUpRetry),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations loc) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Text(
            loc.levelUpNoQuestions,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF2D2D2D),
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReportCard(AppLocalizations loc) {
    final bool passed = _score >= 70;
    final String nextLevel = _getNextLevel(widget.currentLevel);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color:
                        (passed
                                ? const Color(0xFF06D6A0)
                                : const Color(0xFFFF6B6B))
                            .withOpacity(0.18),
                    blurRadius: 30,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    passed ? '🏆' : '💔',
                    style: const TextStyle(fontSize: 86),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    passed ? loc.levelUpPassedTitle : loc.levelUpFailedTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: passed
                          ? const Color(0xFF06D6A0)
                          : const Color(0xFFFF6B6B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    loc.levelUpScore(_score),
                    style: const TextStyle(
                      fontSize: 22,
                      color: Color(0xFF2D2D2D),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    passed
                        ? loc.levelUpPassedMessage(nextLevel)
                        : loc.levelUpFailedMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 16,
                      height: 1.45,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, passed),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: passed
                            ? const Color(0xFF06D6A0)
                            : Colors.deepPurpleAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        passed ? loc.levelUpNextMap : loc.levelUpBackToMap,
                        style: const TextStyle(
                          fontSize: 17,
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
}
