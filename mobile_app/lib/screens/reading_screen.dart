import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'analyzequiz_screen.dart';

class ReadingScreen extends StatefulWidget {
  final String username;
  final String targetLanguage;

  const ReadingScreen({
    super.key,
    required this.username,
    required this.targetLanguage,
  });

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen> {
  final TextEditingController _textController = TextEditingController();
  bool _isAnalyzing = false;
  bool _isGeneratingQuiz = false;

  String? _overallLevel;
  List<dynamic> _analyzedWords = [];
  String _originalText = "";

  bool get _hasText => _textController.text.trim().isNotEmpty;

  int get _wordCount {
    final text = _textController.text.trim();
    if (text.isEmpty) return 0;
    return text.split(RegExp(r'\s+')).where((w) => w.trim().isNotEmpty).length;
  }

  @override
  void initState() {
    super.initState();
    _textController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _analyzeText() async {
    if (_textController.text.trim().isEmpty) {
      _showError("Analiz için önce bir metin yapıştırmalısın. 📝");
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _overallLevel = null;
      _analyzedWords = [];
      _originalText = _textController.text.trim();
    });

    try {
      final url = Uri.parse('http://10.0.2.2:8000/analyze_text');
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "text": _originalText,
          "target_language": widget.targetLanguage,
          "native_language": "Turkish",
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          _overallLevel = data['overall_level'];
          _analyzedWords = data['words'] ?? [];
        });
      } else {
        _showError("Analiz başarısız oldu: ${response.statusCode}");
      }
    } catch (e) {
      _showError("Sunucuya bağlanılamadı! Hata: $e");
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  Future<void> _generateQuiz() async {
    String currentText = _textController.text.trim();

    if (currentText.isEmpty) {
      _showError("Test çözmek için önce kutuya metin yapıştırmalısın! 📝");
      return;
    }

    setState(() => _isGeneratingQuiz = true);

    try {
      final url = Uri.parse('http://10.0.2.2:8000/generate_quiz');

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json; charset=UTF-8",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "text": currentText,
          "target_language": widget.targetLanguage,
          "native_language": "Turkish",
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));

        if (!mounted) return;

        if (data != null &&
            data['questions'] != null &&
            data['questions'].isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuizScreen(
                questions: data['questions'],
                username: widget.username,
                targetLanguage: widget.targetLanguage,
                sectionIndex: 999,
                lessonId: 999,
                originalText: currentText,
              ),
            ),
          );
        } else {
          _showError(
            "Yapay zeka bu metinden soru üretemedi. Daha uzun bir metin dene! 📝",
          );
        }
      } else {
        print("GENERATE QUIZ ERROR STATUS: ${response.statusCode}");
        print("GENERATE QUIZ ERROR BODY: ${response.body}");
        _showError("Sınav oluşturulamadı: ${response.statusCode}");
      }
    } catch (e) {
      _showError("Bağlantı hatası: $e");
    } finally {
      if (mounted) setState(() => _isGeneratingQuiz = false);
    }
  }

  Future<void> _saveWordToDatabase(Map<String, dynamic> wordData) async {
    try {
      final url = Uri.parse('http://10.0.2.2:8000/add_vocabulary');
      await http.post(
        url,
        headers: {"Content-Type": "application/json; charset=UTF-8"},
        body: jsonEncode({
          "username": widget.username,
          "word": wordData['word'],
          "translation": wordData['translation'],
          "cefr_level": wordData['cefr_level'],
        }),
      );
    } catch (e) {
      print("Kelime kaydetme hatası: $e");
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  Color _getLevelColor(String? level) {
    switch ((level ?? '').toUpperCase()) {
      case 'A1':
        return Colors.green.shade500;
      case 'A2':
        return Colors.orange.shade500;
      case 'B1':
        return Colors.blue.shade500;
      case 'B2':
        return Colors.purple.shade500;
      case 'C1':
        return Colors.red.shade500;
      case 'C2':
        return Colors.amber.shade700;
      default:
        return const Color(0xFF8B5CF6);
    }
  }

  void _showWordDetails(Map<String, dynamic> wordData) {
    final String word = (wordData['word'] ?? '').toString();
    final String translation = (wordData['translation'] ?? '').toString();
    final String cefrLevel = (wordData['cefr_level'] ?? '').toString();
    final String example =
        (wordData['example_sentence'] ??
                wordData['example'] ??
                wordData['sentence'] ??
                '')
            .toString();
    final Color levelColor = _getLevelColor(cefrLevel);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 14,
            bottom: MediaQuery.of(context).viewInsets.bottom + 26,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              const SizedBox(height: 22),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: levelColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.auto_awesome_rounded,
                      color: levelColor,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          word.toUpperCase(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF2D2D2D),
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          translation,
                          style: TextStyle(
                            fontSize: 19,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: levelColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      cefrLevel.isEmpty ? '?' : cefrLevel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              if (example.trim().isNotEmpty) ...[
                const SizedBox(height: 22),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F7FB),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Örnek kullanım",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        example,
                        style: const TextStyle(
                          color: Color(0xFF2D2D2D),
                          fontSize: 16,
                          height: 1.35,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 26),
              DuoButton(
                text: "Kumbarama Ekle",
                icon: Icons.bookmark_add_rounded,
                mainColor: const Color(0xFFCE82FF),
                shadowColor: const Color(0xFFA55EEA),
                onPressed: () {
                  _saveWordToDatabase(wordData);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text("Kelime kumbaraya eklendi! 🚀"),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInteractiveText() {
    List<String> words = _originalText.split(RegExp(r'\s+'));

    return Wrap(
      spacing: 6.0,
      runSpacing: 8.0,
      children: words.map((word) {
        String cleanWord = word
            .replaceAll(RegExp(r'[^\w\s]+'), '')
            .toLowerCase();

        Map<String, dynamic>? matchedWordData;
        try {
          matchedWordData = _analyzedWords.firstWhere(
            (w) => w['word'].toString().toLowerCase() == cleanWord,
          );
        } catch (e) {
          matchedWordData = null;
        }

        bool isHighlight = matchedWordData != null;
        final Color levelColor = isHighlight
            ? _getLevelColor(matchedWordData['cefr_level'].toString())
            : const Color(0xFF4B4B4B);

        return GestureDetector(
          onTap: isHighlight ? () => _showWordDetails(matchedWordData!) : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: isHighlight
                ? const EdgeInsets.symmetric(horizontal: 7, vertical: 5)
                : EdgeInsets.zero,
            decoration: isHighlight
                ? BoxDecoration(
                    color: levelColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: levelColor.withOpacity(0.55),
                      width: 1.4,
                    ),
                  )
                : null,
            child: Text(
              word,
              style: TextStyle(
                fontSize: 18,
                color: isHighlight ? levelColor : const Color(0xFF4B4B4B),
                fontWeight: isHighlight ? FontWeight.w900 : FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildIntroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFCE82FF).withOpacity(0.18),
            const Color(0xFF1CB0F6).withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFFCE82FF).withOpacity(0.35),
          width: 1.6,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFCE82FF).withOpacity(0.10),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(22),
            ),
            alignment: Alignment.center,
            child: const Text("🕵️‍♂️", style: TextStyle(fontSize: 36)),
          ),
          const SizedBox(width: 15),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Metnini yapıştır, kelimeleri yakalayalım!",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF2D2D2D),
                    height: 1.15,
                  ),
                ),
                SizedBox(height: 7),
                Text(
                  "Zor kelimeleri analiz et, seviyesini gör ve istersen metinden test çöz.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF777777),
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextInputCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: _hasText
              ? const Color(0xFF1CB0F6).withOpacity(0.35)
              : const Color(0xFFE5E5E5),
          width: 1.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 12, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1CB0F6).withOpacity(0.10),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.article_rounded,
                    color: Color(0xFF1CB0F6),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _hasText ? "Metin hazır" : "Metin alanı",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                ),
                if (_hasText)
                  TextButton.icon(
                    onPressed: () {
                      _textController.clear();
                      setState(() {
                        _overallLevel = null;
                        _analyzedWords = [];
                        _originalText = "";
                      });
                    },
                    icon: const Icon(Icons.close_rounded, size: 18),
                    label: const Text("Temizle"),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey.shade600,
                    ),
                  ),
              ],
            ),
          ),
          TextField(
            controller: _textController,
            minLines: 6,
            maxLines: 11,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF4B4B4B),
              fontWeight: FontWeight.w600,
              height: 1.45,
            ),
            decoration: InputDecoration(
              hintText: "${widget.targetLanguage} metnini buraya yapıştır...",
              hintStyle: const TextStyle(
                color: Color(0xFFAFAFAF),
                fontWeight: FontWeight.w600,
              ),
              contentPadding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
              border: InputBorder.none,
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F7FB),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(26),
              ),
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.notes_rounded,
                  size: 18,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 7),
                Text(
                  "$_wordCount kelime",
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                Text(
                  _overallLevel == null
                      ? "Analiz bekleniyor"
                      : "Seviye: $_overallLevel",
                  style: TextStyle(
                    color: _overallLevel == null
                        ? Colors.grey.shade600
                        : _getLevelColor(_overallLevel),
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisResult() {
    if (_overallLevel == null) return const SizedBox.shrink();

    final Color levelColor = _getLevelColor(_overallLevel);
    final int foundCount = _analyzedWords.length;

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: levelColor.withOpacity(0.20)),
            boxShadow: [
              BoxShadow(
                color: levelColor.withOpacity(0.10),
                blurRadius: 22,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: levelColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  Icons.insights_rounded,
                  color: levelColor,
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Analiz tamamlandı",
                      style: TextStyle(
                        color: Color(0xFF2D2D2D),
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "$foundCount kelime vurgulandı",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: levelColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _overallLevel!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: const Color(0xFFE5E5E5), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.035),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.touch_app_rounded, color: levelColor, size: 20),
                  const SizedBox(width: 7),
                  const Expanded(
                    child: Text(
                      "Renkli kelimelere dokun",
                      style: TextStyle(
                        color: Color(0xFF2D2D2D),
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _buildInteractiveText(),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text(
          "Kelime Avı",
          style: TextStyle(
            color: Color(0xFF2D2D2D),
            fontWeight: FontWeight.w900,
            fontSize: 23,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF6F7FB),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2D2D2D)),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
              child: Column(
                children: [
                  _buildIntroCard(),
                  const SizedBox(height: 22),
                  _buildTextInputCard(),
                  const SizedBox(height: 22),
                  _buildAnalysisResult(),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(26),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  offset: const Offset(0, -6),
                  blurRadius: 18,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DuoButton(
                  text: "Kelimeleri Analiz Et",
                  icon: Icons.search_rounded,
                  mainColor: const Color(0xFF1CB0F6),
                  shadowColor: const Color(0xFF1899D6),
                  isLoading: _isAnalyzing,
                  enabled: _hasText && !_isGeneratingQuiz,
                  onPressed: _analyzeText,
                ),
                const SizedBox(height: 14),
                DuoButton(
                  text: "Bu Metinle Test Çöz",
                  icon: Icons.auto_awesome_rounded,
                  mainColor: const Color(0xFF58CC02),
                  shadowColor: const Color(0xFF58A700),
                  isLoading: _isGeneratingQuiz,
                  enabled: _hasText && !_isAnalyzing,
                  onPressed: _generateQuiz,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DuoButton extends StatefulWidget {
  final String text;
  final IconData icon;
  final Color mainColor;
  final Color shadowColor;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool enabled;

  const DuoButton({
    Key? key,
    required this.text,
    required this.icon,
    required this.mainColor,
    required this.shadowColor,
    required this.onPressed,
    this.isLoading = false,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<DuoButton> createState() => _DuoButtonState();
}

class _DuoButtonState extends State<DuoButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = !widget.enabled || widget.isLoading;
    final Color mainColor = isDisabled
        ? Colors.grey.shade300
        : widget.mainColor;
    final Color shadowColor = isDisabled
        ? Colors.grey.shade400
        : widget.shadowColor;

    return GestureDetector(
      onTapDown: (_) {
        if (!isDisabled) setState(() => _isPressed = true);
      },
      onTapUp: (_) {
        if (!isDisabled) {
          setState(() => _isPressed = false);
          widget.onPressed();
        }
      },
      onTapCancel: () {
        if (!isDisabled) setState(() => _isPressed = false);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        height: 60,
        width: double.infinity,
        decoration: BoxDecoration(
          color: shadowColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 100),
          padding: EdgeInsets.only(
            top: _isPressed ? 4.0 : 0.0,
            bottom: _isPressed ? 0.0 : 4.0,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: mainColor,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: widget.isLoading
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
                        Icon(
                          widget.icon,
                          color: isDisabled
                              ? Colors.grey.shade600
                              : Colors.white,
                          size: 23,
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            widget.text.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isDisabled
                                  ? Colors.grey.shade600
                                  : Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.0,
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
