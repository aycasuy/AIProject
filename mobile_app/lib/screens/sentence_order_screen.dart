/*import 'package:flutter/material.dart';
import '/services/api_service.dart';

// Kendi dosya yollarına göre buraları güncelle lütfen:

import '/widgets/word_chip.dart';
import '/widgets/ai_result_bottom_sheet.dart';

class SentenceOrderScreen extends StatefulWidget {
  final String targetLanguage;
  final String originalSentence;
  final String correctSentence;
  final List<String> scrambledWords;
  final String username;

  const SentenceOrderScreen({
    Key? key,
    required this.targetLanguage,
    required this.originalSentence,
    required this.correctSentence,
    required this.scrambledWords,
    required this.username,
  }) : super(key: key);

  @override
  State<SentenceOrderScreen> createState() => _SentenceOrderScreenState();
}

class _SentenceOrderScreenState extends State<SentenceOrderScreen> {
  // Kelime listelerimiz
  List<String> availableWords = [];
  List<String> selectedWords = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Sayfa açıldığında kelimeleri karıştırarak havuza doldur
    availableWords = List.from(widget.scrambledWords);
    availableWords.shuffle();
  }

  // 👇 Aşağıdan Yukarıya (Havuza Tıklayınca)
  void _moveToSelected(String word) {
    setState(() {
      availableWords.remove(word);
      selectedWords.add(word);
    });
  }

  // 👆 Yukarıdan Aşağıya (Seçilene Tıklayınca)
  void _moveToAvailable(String word) {
    setState(() {
      selectedWords.remove(word);
      availableWords.add(word);
    });
  }

  // 🚀 API'YE GÖNDERME VE KONTROL İŞLEMİ (Artık ApiService kullanıyoruz)
  Future<void> _checkSentence() async {
    setState(() => isLoading = true);

    try {
      final data = await ApiService.evaluateSentence(
        username: widget.username,
        targetLanguage: widget.targetLanguage,
        originalSentence: widget.originalSentence,
        correctSentence: widget.correctSentence,
        submittedWords: selectedWords,
      );

      // İşlem başarılıysa sonucu bizim özel BottomSheet widget'ı ile göster
      if (mounted) {
        showModalBottomSheet(
          context: context,
          isDismissible: false,
          enableDrag: false,
          backgroundColor: Colors.transparent,
          builder: (context) => AiResultBottomSheet(
            isCorrect: data['is_correct'],
            xp: data['xp_earned'],
            aiFeedback: data['ai_feedback'],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(e.toString().replaceAll("Exception: ", ""));
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // ==========================================
  // ANA ARAYÜZ (EKRAN ÇİZİMİ)
  // ==========================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Cümle Kur", style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 🎯 HEDEF CÜMLE (TÜRKÇE)
              const Text(
                "Çevir:",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.originalSentence,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 40),

              // 📥 DROP ZONE (Kullanıcının Dizdiği Alan)
              Container(
                height: 120,
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: selectedWords.isEmpty
                      ? Colors.grey.shade100
                      : Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: selectedWords.isEmpty
                        ? Colors.grey.shade300
                        : Colors.blue.shade300,
                    width: 2,
                  ),
                ),
                child: selectedWords.isEmpty
                    ? const Center(
                        child: Text(
                          "Kelimelere dokunarak cümleni oluştur",
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: selectedWords.map((word) {
                          return GestureDetector(
                            onTap: () => _moveToAvailable(word),
                            // 🌟 Kendi yarattığımız WordChip widget'ını kullanıyoruz
                            child: WordChip(word: word, isSelected: true),
                          );
                        }).toList(),
                      ),
              ),

              const SizedBox(height: 40),

              // 📤 WORD BANK (Aşağıdaki Karışık Kelimeler)
              Wrap(
                spacing: 10,
                runSpacing: 15,
                alignment: WrapAlignment.center,
                children: availableWords.map((word) {
                  return GestureDetector(
                    onTap: () => _moveToSelected(word),
                    // 🌟 Kendi yarattığımız WordChip widget'ını kullanıyoruz
                    child: WordChip(word: word, isSelected: false),
                  );
                }).toList(),
              ),

              const Spacer(),

              // 🚀 KONTROL ET BUTONU
              ElevatedButton(
                onPressed: (selectedWords.isEmpty || isLoading)
                    ? null
                    : _checkSentence,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  backgroundColor: selectedWords.isEmpty
                      ? Colors.grey.shade300
                      : Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: selectedWords.isEmpty ? 0 : 4,
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : Text(
                        "KONTROL ET",
                        style: TextStyle(
                          fontSize: 18,
                          color: selectedWords.isEmpty
                              ? Colors.grey.shade600
                              : Colors.white,
                          fontWeight: FontWeight.bold,
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
*/
