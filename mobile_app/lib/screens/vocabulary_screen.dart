/*import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'word_quiz_screen.dart';

class VocabularyScreen extends StatefulWidget {
  final String username;
  const VocabularyScreen({super.key, required this.username});

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  List<dynamic> _words = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchVocabulary();
  }

  Future<void> _fetchVocabulary() async {
    try {
      final url = Uri.parse(
        'http://10.0.2.2:8000/get_vocabulary/${widget.username}',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _words = jsonDecode(utf8.decode(response.bodyBytes));
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Quiz ekranına geçiş yap
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  const WordQuizScreen(), // Az önce yazdığımız dosya
            ),
          );
        },
        backgroundColor: const Color(0xFF06D6A0), // Canlı yeşil rengimiz
        elevation: 8,
        icon: const Icon(
          Icons.psychology_rounded,
          color: Colors.white,
          size: 28,
        ),
        label: const Text(
          "Kendini Test Et",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      // ...
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        title: const Text(
          "Kelime Kumbarası 🏦",
          style: TextStyle(
            color: Color(0xFF073B4C),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF073B4C)),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF118AB2)),
            )
          : _words.isEmpty
          ? const Center(
              child: Text(
                "Kumbaran henüz boş. Hadi metin okuyup kelime ekle! 📚",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _words.length,
              itemBuilder: (context, index) {
                final word = _words[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD166).withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.bookmark,
                          color: Color(0xFFE8B01E),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              word['word'].toString().toUpperCase(),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF073B4C),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              word['translation'],
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF118AB2).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          word['cefr_level'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF118AB2),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
*/
