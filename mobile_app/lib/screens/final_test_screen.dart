import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:http/http.dart' as http;
import 'dart:convert';
//import '../services/api_service.dart';

class FinalTestScreen extends StatefulWidget {
  final String username;
  final String targetLanguage;
  final String userLevel;
  final int lessonId;

  const FinalTestScreen({
    super.key,
    required this.username,
    required this.targetLanguage,
    required this.userLevel,
    required this.lessonId,
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

  @override
  void initState() {
    super.initState();
    _initTools();
    _fetchTestQuestions();
  }

  void _initTools() async {
    _flutterTts = FlutterTts();
    _speech = stt.SpeechToText();
    await _speech.initialize();
  }

  @override
  void dispose() {
    _textController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _fetchTestQuestions() async {
    try {
      final url = Uri.parse('http://10.0.2.2:8000/generate_final_test');
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "lesson_id": widget.lessonId,
          "level": widget.userLevel,
          "target_language": widget.targetLanguage,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          _questions = data['questions'];
          _isLoading = false;
          _prepareQuestionData(); // İlk sorunun verilerini hazırla
        });
      }
    } catch (e) {
      print("Sınav yüklenemedi: $e");
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
      String userAnswer = _recognizedText.trim().toLowerCase().replaceAll(
        RegExp(r'[^\w\s]'),
        '',
      );
      String correctAnswer = q['text'].toLowerCase().replaceAll(
        RegExp(r'[^\w\s]'),
        '',
      );
      // Konuşmada %80 benzerlik yeterli sayılabilir, basitlik için tam eşleşme veya kapsama bakıyoruz
      isCorrect =
          userAnswer.contains(correctAnswer) ||
          correctAnswer.contains(userAnswer) && userAnswer.length > 5;
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isCorrect ? "✅ Doğru!" : "❌ Yanlış!", // Doğru cevabı SÖYLEMİYORUZ!
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
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF1E1E2C),
        body: Center(child: CircularProgressIndicator(color: Colors.amber)),
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
        title: const Text(
          "FİNAL SINAVI 🚀",
          style: TextStyle(
            color: Colors.amber,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false, // Sınavdan geri çıkamaz!
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // İlerleme Çubuğu
            LinearProgressIndicator(
              value: (_currentIndex + 1) / _questions.length,
              backgroundColor: Colors.white24,
              color: Colors.amber,
              minHeight: 10,
              borderRadius: BorderRadius.circular(10),
            ),
            const SizedBox(height: 10),
            Text(
              "Soru ${_currentIndex + 1} / ${_questions.length}",
              style: const TextStyle(color: Colors.grey),
            ),

            const Spacer(),

            // Soru Tipine Göre Ekran Değişir
            if (q['type'] == 'blank') _buildBlankQuestion(q),
            if (q['type'] == 'order') _buildOrderQuestion(q),
            if (q['type'] == 'listen') _buildListenQuestion(q),
            if (q['type'] == 'speak') _buildSpeakQuestion(q),

            const Spacer(),

            // KONTROL ET BUTONU
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
                child: const Text(
                  "Cevapla",
                  style: TextStyle(
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
    return Column(
      children: [
        const Text(
          "Boşluğu Doldur",
          style: TextStyle(color: Colors.white54, fontSize: 16),
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
            hintText: "Cevabını yaz...",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderQuestion(Map<String, dynamic> q) {
    return Column(
      children: [
        const Text(
          "Cümleyi Kur",
          style: TextStyle(color: Colors.white54, fontSize: 16),
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
    return Column(
      children: [
        const Text(
          "Duyduğunu Yaz",
          style: TextStyle(color: Colors.white54, fontSize: 16),
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
            hintText: "İngilizce yaz...",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          ),
        ),
      ],
    );
  }

  Widget _buildSpeakQuestion(Map<String, dynamic> q) {
    return Column(
      children: [
        const Text(
          "Yüksek Sesle Oku",
          style: TextStyle(color: Colors.white54, fontSize: 16),
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
          _recognizedText.isEmpty ? "Mikrofona bas..." : _recognizedText,
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
                  onResult: (val) =>
                      setState(() => _recognizedText = val.recognizedWords),
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
              passed ? "TEBRİKLER!" : "SINAVI GEÇEMEDİN",
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
              "Puanın: $_score / 100",
              style: const TextStyle(fontSize: 24, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                passed
                    ? "Harika iş çıkardın! Yeni dersin kilidi açıldı."
                    : "70 puanı geçemedin. Eksiklerini kapatıp tekrar denemelisin.",
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
                passed ? "Sonraki Derse Geç 🚀" : "Haritaya Dön",
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
