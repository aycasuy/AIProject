import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_app/l10n/app_localizations.dart';
// Kendi api_service.dart dosyanın yolunu buraya doğru girdiğinden emin ol
//import '../services/api_service.dart';

class FlashcardPracticeScreen extends StatefulWidget {
  final String username;
  final String targetLanguage; // 🌟 Öğrenilen dil (Örn: İngilizce, İspanyolca)
  final String nativeLanguage;

  const FlashcardPracticeScreen({
    Key? key,
    required this.username,
    required this.targetLanguage,
    required this.nativeLanguage,
  }) : super(key: key);

  @override
  State<FlashcardPracticeScreen> createState() =>
      _FlashcardPracticeScreenState();
}

class _FlashcardPracticeScreenState extends State<FlashcardPracticeScreen> {
  List<dynamic> _words = [];
  bool _isLoading = true;
  int _currentIndex = 0;
  bool _isFlipped = false;

  @override
  void initState() {
    super.initState();
    _fetchWords();
  }

  String _localizedLanguageName(AppLocalizations loc, String language) {
    switch (language.toLowerCase()) {
      case 'english':
        return loc.langEnglish;
      case 'spanish':
        return loc.langSpanish;
      case 'german':
        return loc.langGerman;
      case 'french':
        return loc.langFrench;
      case 'turkish':
        return loc.langTurkish;
      default:
        return language;
    }
  }

  // --- KELİMELERİ ÇEK ---
  Future<void> _fetchWords() async {
    try {
      final url =
          Uri.parse(
            'http://10.0.2.2:8000/get_flashcard_practice/'
            '${widget.username}',
          ).replace(
            queryParameters: {
              'target_language': widget.targetLanguage,
              'native_language': widget.nativeLanguage,
            },
          );

      debugPrint(
        'FLASHCARD PRACTICE REQUEST → '
        'target=${widget.targetLanguage}, '
        'native=${widget.nativeLanguage}, '
        'url=$url',
      );

      final response = await http.get(url);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(utf8.decode(response.bodyBytes));

        setState(() {
          _words = decoded is List ? List<dynamic>.from(decoded) : <dynamic>[];

          _currentIndex = 0;
          _isFlipped = false;
          _isLoading = false;
        });
      } else {
        debugPrint(
          'Kelime çekme başarısız: '
          '${response.statusCode} - ${response.body}',
        );

        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Kelime çekme hatası: $e');

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // --- KELİMEYİ ÖĞRENİLDİ OLARAK İŞARETLE ---
  Future<void> _markAsLearned(int wordId) async {
    try {
      final url = Uri.parse('http://10.0.2.2:8000/mark_word_learned');
      await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({"username": widget.username, "word_id": wordId}),
      );
    } catch (e) {
      print("İşaretleme hatası: $e");
    }
  }

  // --- SONRAKİ KARTA GEÇİŞ ---
  Future<void> _nextCard(bool learned) async {
    if (learned) {
      await _markAsLearned(_words[_currentIndex]['id']);
    }

    if (!mounted) return;

    if (_currentIndex < _words.length - 1) {
      setState(() {
        _isFlipped = false;
        _currentIndex++;
      });
    } else {
      setState(() {
        _isFlipped = false;
        _currentIndex = 0;
        _words.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
        title: Text(
          loc.flashcardPracticeTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF6C5CE7)),
            )
          : _words.isEmpty
          ? _buildDoneScreen(loc)
          : _buildStudyBoard(loc),
    );
  }

  // --- ÇALIŞMA MASASI (KARTLAR VE BUTONLAR BURADA) ---
  Widget _buildStudyBoard(AppLocalizations loc) {
    final currentWord = _words[_currentIndex];

    return Column(
      children: [
        // Üst İlerleme Çubuğu ve Seviye Etiketi
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                loc.flashcardPracticeCounter(_currentIndex + 1, _words.length),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  currentWord['cefr_level'] ?? "A1",
                  style: const TextStyle(
                    color: Color(0xFF6C5CE7),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),

        const Spacer(),

        // KARTIN KENDİSİ (Animasyonlu)
        GestureDetector(
          onTap: () {
            setState(() {
              _isFlipped = !_isFlipped;
            });
          },
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return ScaleTransition(
                scale: animation,
                child: child,
              ); // Yumuşak bir büyüme-küçülme efekti
            },
            child: _isFlipped
                ? _buildBackOfCard(currentWord, loc)
                : _buildFrontOfCard(currentWord, loc),
          ),
        ),

        const Spacer(),

        // BUTONLAR (Sadece kart arkaya çevrildiğinde görünür)
        AnimatedOpacity(
          opacity: _isFlipped ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.redAccent,
                      elevation: 0,
                      side: BorderSide(
                        color: Colors.redAccent.shade100,
                        width: 2,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: _isFlipped ? () => _nextCard(false) : null,
                    child: Text(
                      loc.flashcardPracticeReviewAgain,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C5CE7),
                      elevation: 5,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: _isFlipped ? () => _nextCard(true) : null,
                    child: Text(
                      loc.flashcardPracticeLearned,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // --- KARTIN ÖN YÜZÜ (Öğrenilen Dil) ---
  Widget _buildFrontOfCard(dynamic word, AppLocalizations loc) {
    return Container(
      key: const ValueKey("front"),
      width: MediaQuery.of(context).size.width * 0.85,
      height: 380,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C5CE7).withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 🌟 Dinamik dil ismi burada (Örn: İngilizce, İspanyolca vb.)
          Text(
            _localizedLanguageName(loc, widget.targetLanguage).toUpperCase(),
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
              letterSpacing: 1.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              word['word'],
              style: const TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D2D2D),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 50),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.touch_app_rounded,
                color: Colors.grey.shade400,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                loc.flashcardPracticeTapToTranslate,
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- KARTIN ARKA YÜZÜ (Ana Dil Çevirisi) ---
  Widget _buildBackOfCard(dynamic word, AppLocalizations loc) {
    return Container(
      key: const ValueKey("back"),
      width: MediaQuery.of(context).size.width * 0.85,
      height: 380,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C5CE7), Color(0xFF81ECEC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C5CE7).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 🌟 Evrensel ana dil uyarısı
          Text(
            loc.flashcardPracticeNativeTranslation,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              letterSpacing: 1.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              word['translation'],
              style: const TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // --- BİTİRME EKRANI (Tüm kartlar bittiğinde görünür) ---
  Widget _buildDoneScreen(AppLocalizations loc) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.workspace_premium_rounded,
              size: 80,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 30),
          Text(
            loc.flashcardPracticeDoneTitle,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D2D2D),
            ),
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              loc.flashcardPracticeDoneMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 50),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C5CE7),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: Text(
              loc.flashcardPracticeBackToProfile,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
