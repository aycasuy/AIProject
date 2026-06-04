import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
// Kendi api_service.dart dosyanın yolunu buraya doğru girdiğinden emin ol
//import '../services/api_service.dart';

class FlashcardPracticeScreen extends StatefulWidget {
  final String username;
  final String targetLanguage; // 🌟 Öğrenilen dil (Örn: İngilizce, İspanyolca)

  const FlashcardPracticeScreen({
    Key? key,
    required this.username,
    required this.targetLanguage,
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

  // --- KELİMELERİ ÇEK ---
  Future<void> _fetchWords() async {
    try {
      final url = Uri.parse(
        'http://10.0.2.2:8000/get_flashcard_practice/${widget.username}',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _words = json.decode(response.body);
            _isLoading = false;
          });
        }
      } else {
        print("Kelime çekme başarısız: ${response.statusCode}");
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      print("Kelime çekme hatası: $e");
      if (mounted) setState(() => _isLoading = false);
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
  void _nextCard(bool learned) {
    if (learned) {
      _markAsLearned(
        _words[_currentIndex]['id'],
      ); // Arka planda sessizce API'ye bildir
    }

    if (_currentIndex < _words.length - 1) {
      setState(() {
        _isFlipped = false; // Kartı geri çevir
        _currentIndex++; // Sonraki kelimeye geç
      });
    } else {
      // Kelimeler bitti!
      setState(() {
        _words.clear(); // Bitti ekranını göstermek için listeyi temizliyoruz
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
        title: const Text(
          "Kelime Antrenmanı",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF6C5CE7)),
            )
          : _words.isEmpty
          ? _buildDoneScreen()
          : _buildStudyBoard(),
    );
  }

  // --- ÇALIŞMA MASASI (KARTLAR VE BUTONLAR BURADA) ---
  Widget _buildStudyBoard() {
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
                "Kelime ${_currentIndex + 1} / ${_words.length}",
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
                ? _buildBackOfCard(currentWord)
                : _buildFrontOfCard(currentWord),
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
                    child: const Text(
                      "Tekrar Sor",
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
                    child: const Text(
                      "Öğrendim!",
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
  Widget _buildFrontOfCard(dynamic word) {
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
            widget.targetLanguage.toUpperCase(),
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
                "Çevirmek için karta dokun",
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
  Widget _buildBackOfCard(dynamic word) {
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
          const Text(
            "ANA DİL ÇEVİRİSİ",
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
  Widget _buildDoneScreen() {
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
          const Text(
            "Harika İş Çıkardın!",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D2D2D),
            ),
          ),
          const SizedBox(height: 15),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "Bugün için ayrılan tüm yeni kelimeleri tekrar ettin. Profiline dönüp istatistiklerini kontrol edebilirsin.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16, height: 1.5),
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
            child: const Text(
              "Profile Dön",
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
