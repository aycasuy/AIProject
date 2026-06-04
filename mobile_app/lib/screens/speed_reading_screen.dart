import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile_app/screens/speed_quiz_screen.dart';

class SpeedReadingScreen extends StatefulWidget {
  final String storyText;
  final int userWpm;
  final List<String>
  targetWords; // API'den gelen veya bizim bulduğumuz zor kelimeler listesi
  final List<dynamic> comprehensionQuestions;
  final List<dynamic> vocabularyQuestions;
  final String level;
  final String username;
  final String targetLanguage;
  final int lessonId;

  const SpeedReadingScreen({
    Key? key,
    required this.storyText,
    required this.userWpm,
    required this.targetWords,
    required this.comprehensionQuestions,
    required this.vocabularyQuestions,
    required this.level,
    required this.username,
    required this.targetLanguage,
    required this.lessonId,
  }) : super(key: key);

  @override
  _SpeedReadingScreenState createState() => _SpeedReadingScreenState();
}

class _SpeedReadingScreenState extends State<SpeedReadingScreen> {
  List<String> _sentences = [];
  int _currentIndex = 0;
  Timer? _timer;
  bool _isReadingFinished = false;

  @override
  void initState() {
    super.initState();
    // Metni noktalama işaretlerinden (., !, ?) cümlelere bölüyoruz
    _sentences = widget.storyText
        .split(RegExp(r'(?<=[.!?])\s+'))
        .where((s) => s.trim().isNotEmpty)
        .toList();

    _startDynamicSentenceTimer();
  }

  void _startDynamicSentenceTimer() {
    if (_currentIndex >= _sentences.length) {
      setState(() {
        _isReadingFinished = true;
      });
      return;
    }

    // Ekranda gösterilecek mevcut cümle
    String currentSentence = _sentences[_currentIndex];

    // Cümlede kaç kelime var?
    int wordCount = currentSentence.split(' ').length;

    // DİNAMİK HIZ HESAPLAMA:
    // Cümledeki kelime sayısını kullanıcının WPM hızına bölüp milisaniyeye çeviriyoruz.
    // +800 ms "Nefes alma" payı ekliyoruz ki çok hızlı geçmesin.
    int durationMs = ((wordCount / widget.userWpm) * 60000).round() + 800;

    _timer = Timer(Duration(milliseconds: durationMs), () {
      setState(() {
        _currentIndex++;
      });
      _startDynamicSentenceTimer(); // Bir sonraki cümle için kendini tekrar çağırır
    });
  }

  // Cümleyi kelimelere ayırıp, 'targetWords' içindeki kelimeleri SARI yapan fonksiyon
  TextSpan _buildHighlightedSentence(String sentence) {
    List<String> words = sentence.split(' ');
    List<TextSpan> spans = [];

    for (String word in words) {
      // Kelimenin sonundaki virgül veya noktayı temizleyip öyle kıyaslıyoruz
      String cleanWord = word.replaceAll(RegExp(r'[^\w\s]'), '').toLowerCase();

      // Eğer bu kelime bizim hedef kelimelerimizden biriyse sarı yap
      bool isTarget = widget.targetWords.any(
        (target) => target.toLowerCase() == cleanWord,
      );

      spans.add(
        TextSpan(
          text: "$word ",
          style: TextStyle(
            fontSize:
                36, // Cümle olduğu için fontu biraz küçülttük (48'den 36'ya)
            fontWeight: isTarget ? FontWeight.w900 : FontWeight.w500,
            color: isTarget ? Colors.yellowAccent : Colors.white,
          ),
        ),
      );
    }

    return TextSpan(children: spans);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color themeColor = getThemeColor(widget.level);

    return Scaffold(
      // backgroundColor yerine Container içinde Gradient kullanıyoruz
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              themeColor.withOpacity(0.7), // Üst kısım biraz açık
              themeColor, // Alt kısım tam doygun renk
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: _isReadingFinished
                ? _buildFinishButton(context, themeColor) // Butonu şıklaştırdık
                : RichText(
                    textAlign: TextAlign.center,
                    text: _buildHighlightedSentence(_sentences[_currentIndex]),
                  ),
          ),
        ),
      ),
    );
  }

  // 🌟 Okuma bittiğinde ekrana çıkacak o gösterişli ekran
  Widget _buildFinishButton(BuildContext context, Color themeColor) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Kocaman bir onay ikonu
        const Icon(Icons.check_circle_outline, size: 80, color: Colors.white),
        const SizedBox(height: 16),

        // Kullanıcıyı gaza getiren metin
        const Text(
          "Harika Okudun!",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Şimdi anladıklarını test etme zamanı.",
          style: TextStyle(fontSize: 16, color: Colors.white70),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),

        // O Muazzam Buton
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor:
                Colors.white, // Buton beyaz olsun ki arka plandan fırlasın
            foregroundColor:
                themeColor, // Yazı rengi senin o dinamik seviye rengin olacak
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            elevation: 10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SpeedQuizScreen(
                  level: widget.level,
                  comprehensionQuestions: widget.comprehensionQuestions,
                  vocabularyQuestions: widget.vocabularyQuestions,
                  targetWords: widget.targetWords,
                  username: widget.username,
                  targetLanguage: widget.targetLanguage,
                  lessonId: widget.lessonId,
                ),
              ),
            );
            if (context.mounted) {
              Navigator.pop(context, result);
            }
          },
          icon: const Icon(Icons.flash_on, size: 28),
          label: const Text(
            "Quize Başla!",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Color getThemeColor(String level) {
    switch (level) {
      case "A1":
        return Colors.green.shade500;
      case "A2":
        return Colors.orange.shade500;
      case "B1":
        return Colors.blue.shade500;
      case "B2":
        return Colors.purple.shade500;
      case "C1":
        return Colors.red.shade500;
      case "C2":
        return Colors.amber.shade600;
      default:
        return Colors.green;
    }
  }
}
