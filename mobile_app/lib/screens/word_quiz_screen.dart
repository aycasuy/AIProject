/*import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WordQuizScreen extends StatefulWidget {
  const WordQuizScreen({Key? key}) : super(key: key);

  @override
  State<WordQuizScreen> createState() => _WordQuizScreenState();
}

class _WordQuizScreenState extends State<WordQuizScreen> {
  List<dynamic> _wordBank = [];
  bool _isLoading = true;

  int _currentIndex = 0;
  bool _isFlipped = false;

  final String baseUrl = "http://10.0.2.2:8000";

  @override
  void initState() {
    super.initState();
    _fetchWordsFromBackend();
  }

  // 📥 1. PYTHON'DAN KELİMELERİ İSTE
  Future<void> _fetchWordsFromBackend() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/get_vocabulary/${widget}"),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _wordBank =
              data['word']; // Python'dan gelen JSON'daki 'words' listesi
          _isLoading = false;
        });
      } else {
        print("Sunucu Hatası: Kelimeler alınamadı.");
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print("Bağlantı Hatası: $e");
      setState(() => _isLoading = false);
    }
  }

  // 📤 2. KULLANICININ CEVABINI PYTHON'A GÖNDER VE İLERLE
  Future<void> _nextWord(bool knewIt) async {
    final currentWordId = _wordBank[_currentIndex]['id'];

    // Kullanıcıyı hiç bekletmeden arkadan Python'a sonucu fırlatıyoruz
    http
        .post(
          Uri.parse("$baseUrl/api/words/update"),
          headers: {"Content-Type": "application/json"},
          body: json.encode({"word_id": currentWordId, "knew_it": knewIt}),
          // ignore: invalid_return_type_for_catch_error
        )
        .catchError((error) => print("Skor güncellenemedi: $error"));

    // Arayüzde hemen bir sonraki kelimeye geç
    setState(() {
      if (_currentIndex < _wordBank.length - 1) {
        _currentIndex++;
        _isFlipped = false; // Yeni kartı kapalı hale getir
      } else {
        // Kelimeler bittiyse tebrikler ekranını göster
        _showCompletionDialog();
      }
    });
  }

  // 🎉 TEST BİTİŞ EKRANI
  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E2235),
        title: const Text(
          "Tebrikler! 🎉",
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          "Günlük kelime kumbara testini tamamladın. Skorların kaydedildi!",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Dialogu kapat
              Navigator.pop(
                context,
              ); // Test ekranından çıkıp önceki sayfaya dön
            },
            child: const Text(
              "Geri Dön",
              style: TextStyle(
                color: Color(0xFF06D6A0),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121421),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Kumbara Testi",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      // Eğer yükleniyorsa dönen top göster, liste boşsa uyarı ver, veri varsa kartları çiz!
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF06D6A0)),
            )
          : _wordBank.isEmpty
          ? Center(
              child: Text(
                "Kumbaranda test edilecek\nhiç kelime yok! 😢",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 18,
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // SAYAÇ (Örn: 1 / 10)
                  Text(
                    "Kelime ${_currentIndex + 1} / ${_wordBank.length}",
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // 🎴 DOKUNUNCA ÇEVRİLEN KART (FLASHCARD)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isFlipped = !_isFlipped;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      width: double.infinity,
                      height: 250,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: _isFlipped
                            ? const Color(0xFF2A2F45)
                            : const Color(0xFF1E2235),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(
                            0xFF06D6A0,
                          ).withOpacity(_isFlipped ? 0.5 : 0.0),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _isFlipped
                                ? const Color(0xFF06D6A0).withOpacity(0.1)
                                : Colors.black12,
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isFlipped
                                ? _wordBank[_currentIndex]["tr"]
                                : _wordBank[_currentIndex]["en"],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _isFlipped
                                  ? const Color(0xFF06D6A0)
                                  : Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          if (_isFlipped &&
                              _wordBank[_currentIndex]["example"] != null) ...[
                            const Divider(color: Colors.white24),
                            const SizedBox(height: 10),
                            Text(
                              'Örn: "${_wordBank[_currentIndex]["example"]}"',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ] else if (!_isFlipped) ...[
                            const Text(
                              "Anlamını görmek için dokun",
                              style: TextStyle(
                                color: Colors.white38,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 50),

                  // 🛑 BUTONLAR (Sadece kart çevrilince ortaya çıkarlar)
                  AnimatedOpacity(
                    opacity: _isFlipped ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // ❌ BİLEMEDİM BUTONU
                        ElevatedButton.icon(
                          onPressed: _isFlipped ? () => _nextWord(false) : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: const Color(0xFFFF6B6B),
                            side: const BorderSide(color: Color(0xFFFF6B6B)),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 15,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          icon: const Icon(Icons.close),
                          label: const Text("Tekrar Sor"),
                        ),

                        // ✅ BİLDİM BUTONU
                        ElevatedButton.icon(
                          onPressed: _isFlipped ? () => _nextWord(true) : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF06D6A0),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 15,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 8,
                            shadowColor: const Color(
                              0xFF06D6A0,
                            ).withOpacity(0.4),
                          ),
                          icon: const Icon(Icons.check),
                          label: const Text(
                            "Bildim",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
*/
