import 'package:flutter/material.dart';
import 'package:mobile_app/screens/learn_activity_screen.dart';
import 'package:mobile_app/services/api_service.dart';
import "minimal_pairs_screen.dart";

class PracticeScreen extends StatefulWidget {
  final String username;
  final String targetLanguage; // 🌟 YENİ
  final String nativeLanguage; // 🌟 YENİ

  const PracticeScreen({
    Key? key,
    required this.username,
    required this.targetLanguage,
    required this.nativeLanguage,
  }) : super(key: key);

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  List<dynamic> _mistakes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMistakes();
  }

  Future<void> _loadMistakes() async {
    final data = await ApiService.fetchMistakeDetails(
      widget.username,
      widget.targetLanguage,
    );
    if (mounted) {
      setState(() {
        _mistakes = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("Zayıf Noktaları Çalış"),
        backgroundColor: const Color(0xFFFF6B6B), // Kırmızı temalı
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF6B6B)),
            )
          : _mistakes.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _mistakes.length,
              itemBuilder: (context, index) {
                final item = _mistakes[index];
                return _buildMistakeCard(item);
              },
            ),
    );
  }

  Widget _buildMistakeCard(dynamic item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.redAccent.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.warning_amber_rounded,
            color: Colors.redAccent,
          ),
        ),
        title: Text(
          item['question_text'] ?? "Bilinmeyen Soru",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            "Soru Tipi: ${item['puzzle_type']} | Hata: ${item['mistake_count']} kez",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF6B6B),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            // 🚀 Buradan ilgili sorunun çözüm ekranına yönlendireceğiz!
            _navigateToPuzzle(context, item);
          },
          child: const Text("Çöz", style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  // --- 🚀 HANGİ SORUYSA O EKRANI AÇAN FONKSİYON ---
  void _navigateToPuzzle(BuildContext context, dynamic item) {
    final String puzzleType = item['puzzle_type'] ?? "null";
    final int puzzleId = item['puzzle_id'];

    // 1. Güvenlik Duvarı: Bozuk/Null kayıtlar için çökmesini engelle
    if (puzzleType == "null" || puzzleType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bu soru geçersiz veya eski bir kayıt.")),
      );
      return;
    }

    Widget? targetScreen;

    // 2. Soru Tipine Göre İlgili Ekranı Seç
    switch (puzzleType) {
      case "minimal_pair":
        // 🌟 Kendi Minimal Pair ekranının adını ve parametresini buraya yazmalısın!
        targetScreen = MinimalPairsScreen(
          //lessonId: puzzleId,
          id: puzzleId,
          isPracticeMode: true,
          username: widget.username,
          targetLanguage: widget.targetLanguage,
          nativeLanguage: widget.nativeLanguage,
          themeColor: const Color(0xFFFF6B6B),
        );
        print("Minimal Pair Ekranı açılacak: ID $puzzleId");
        break;

      case "blank_puzzle":
        targetScreen = LearnActivityScreen(
          activityType: "learn_blank",
          lessonTitle: "Pratik: Boşluk Doldurma",
          themeColor: const Color(0xFFFF6B6B),
          username: widget.username,
          minLevel: "A1", // İsteğe bağlı dinamik alabilirsin
          targetLanguage: widget.targetLanguage,
          lessonId: 0, // Pratik modunda olduğumuz için bunun bir önemi yok
          // 🌟 İŞTE SİHİR BURADA: ŞALTERİ AÇIYORUZ!
          isPracticeMode: true,
          practicePuzzleId: puzzleId,
          sectionIndex: 0,
          nativeLanguage: widget.nativeLanguage,
        );
        break;

      case "sentence_puzzle":
        targetScreen = LearnActivityScreen(
          activityType: "learn_order",
          lessonTitle: "Pratik: Cümle Kur",
          themeColor: const Color(0xFFFF6B6B),
          username: widget.username,
          minLevel: "A1",
          targetLanguage: widget.targetLanguage,
          lessonId: 0,

          // 🌟 ŞALTER AÇIK!
          isPracticeMode: true,
          practicePuzzleId: puzzleId,
          sectionIndex: 0,
          nativeLanguage: widget.nativeLanguage,
        );
        break;

      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Bilinmeyen soru tipi: $puzzleType")),
        );
        return;
    }

    // 3. Eğer ekran atandıysa Oraya Git!

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => targetScreen!),
    ).then((_) {
      // 🌟 KULLANICI SORUYU ÇÖZÜP GERİ DÖNDÜĞÜNDE LİSTEYİ YENİLE!
      // Belki soruyu doğru bildi ve o hata veritabanından silindi.
      _loadMistakes();
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            size: 80,
            color: Colors.green.shade300,
          ),
          const SizedBox(height: 16),
          const Text(
            "Harika İş Çıkardın!",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Tekrar etmen gereken hiçbir hatan yok.",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
