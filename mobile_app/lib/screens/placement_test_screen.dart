import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_tts/flutter_tts.dart';
//import 'home_screen.dart';
//import 'path_screen.dart';
import 'main_navigation.dart';

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

  // Hangi seviyeden kaç doğru yaptığını tutacağımız karne
  final Map<String, int> _levelScores = {
    'A1': 0,
    'A2': 0,
    'B1': 0,
    'B2': 0,
    'C1': 0,
  };

  // Seslendirme (TTS) motoru
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

  // --- 1. SES MOTORU KURULUMU ---
  void _initTts() {
    flutterTts = FlutterTts();
    flutterTts.setLanguage(_getTtsLanguageCode(widget.targetLanguage));
    flutterTts.setSpeechRate(
      0.45,
    ); // Öğrenciler için ideal, hafif yavaş okuma hızı
    flutterTts.setPitch(1.0);

    // Okuma bitince butonun tekrar oynatılabilir hale gelmesi için
    flutterTts.setCompletionHandler(() {
      if (mounted) setState(() => _isPlaying = false);
    });
  }

  // --- 2. PYTHON'DAN SINAVI ÇEKME (GET İŞLEMİ) ---
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

  // --- 3. DİNLEME (LISTENING) FONKSİYONLARI ---
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

  // --- 4. SONRAKİ SORUYA GEÇİŞ VE PUANLAMA ---
  void _nextQuestion() {
    if (_selectedAnswer.isEmpty) return;

    final currentQ = _questions[_currentIndex];

    // Eğer cevap doğruysa, o sorunun seviyesine 1 puan ekle
    if (_selectedAnswer == currentQ['answer']) {
      String level = currentQ['level'];
      if (_levelScores.containsKey(level)) {
        _levelScores[level] = _levelScores[level]! + 1;
      }
    }

    // Okuma/Dinleme varsa durdur ki diğer soruya ses sarkmasın
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

    /*
    Her seviyede 3 soru var.
    Bir seviyeyi geçmiş saymak için en az 2 doğru gerekiyor.

    Mantık:
    - A1 geçilemezse A1
    - A1 geçilir ama A2 geçilemezse A1
    - A1 + A2 geçilirse A2
    - B1 de geçilirse B1
    - B2 de geçilirse B2
    - C1 de geçilirse C1
  */

    if (a1 < 2) return "A1";
    if (a2 < 2) return "A1";
    if (b1 < 2) return "A2";
    if (b2 < 2) return "B1";
    if (c1 < 2) return "B2";

    return "C1";
  }

  // --- 5. SINAV BİTİŞİ, SEVİYE HESAPLAMA VE VERİTABANINA KAYIT ---
  Future<void> _finishTest() async {
    setState(() => _isLoading = true);

    String finalLevel = _calculateFinalLevel();

    try {
      // PYTHON'A SEVİYEYİ GÖNDERİYORUZ!
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

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text("Sınav Tamamlandı!"),
            content: Text(
              "Harika iş çıkardın.\n\nBelirlenen Seviyen: $finalLevel\nÖdül: +50 XP",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MainNavigationScreen(
                        // 🌟 ARTIK İSKELETE GİDİYOR
                        username: widget.username,
                        targetLanguage: widget.targetLanguage,
                        minLevel: finalLevel,
                        nativeLanguage: widget.nativeLanguage,

                        // 🌟 Sınavdan çıkan yeni seviyeyi verdik!
                      ),
                    ),
                    (Route<dynamic> route) => false,
                  );
                },
                child: const Text("Ana Menüye Dön"),
              ),
            ],
          ),
        );
      } else {
        print("🚨 SAVE PROGRESS ERROR: ${response.statusCode}");
        print("🚨 BODY: ${response.body}");

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

  // --- 6. ARAYÜZ (UI) ---
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FF),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(color: Color(0xFF118AB2)),
              SizedBox(height: 20),
              Text(
                "Yapay Zeka Sınavını Hazırlıyor...",
                style: TextStyle(
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
      return const Scaffold(body: Center(child: Text("Soru bulunamadı.")));
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
              "Soru ${_currentIndex + 1}/${_questions.length}",
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
              // --- DİNAMİK ALAN: SORU TİPİNE GÖRE EKRAN DEĞİŞİR ---
              if (type == 'reading' && contextText != null) ...[
                // OKUMA KARTI
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
                // DİNLEME BUTONU (METİN GİZLİ!)
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
                      const Text(
                        "Metni dinlemek için butona bas",
                        style: TextStyle(
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
                        label: Text(_isPlaying ? "Durdur" : "Dinle"),
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

              // --- ASIL SORU METNİ ---
              Text(
                questionText,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF073B4C),
                ),
              ),
              const SizedBox(height: 30),

              // --- ŞIKLAR ---
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

              // --- SONRAKİ SORU BUTONU ---
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
                child: const Text(
                  "Sonraki Soru",
                  style: TextStyle(
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
