// widgets/ai_result_bottom_sheet.dart
import 'package:flutter/material.dart';

class AiResultBottomSheet extends StatelessWidget {
  final bool isCorrect;
  final int xp;
  final Map<String, dynamic> aiFeedback;

  const AiResultBottomSheet({
    Key? key,
    required this.isCorrect,
    required this.xp,
    required this.aiFeedback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isCorrect ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isCorrect ? "Tebrikler! 🎉" : "Neredeyse! 🧐",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isCorrect
                      ? Colors.green.shade800
                      : Colors.red.shade800,
                ),
              ),
              Text(
                aiFeedback['score'] ?? "",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),

          // 🌟🌟🌟 EKLENEN KISIM BAŞLANGICI 🌟🌟🌟
          // Flexible ve SingleChildScrollView kullanarak orta kısmı kaydırılabilir yapıyoruz!
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Kelime Analizi Listesi
                  if (!isCorrect && aiFeedback['word_breakdown'] != null)
                    ...((aiFeedback['word_breakdown'] as Map<String, dynamic>)
                        .entries
                        .map((entry) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 16,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: "${entry.key}: ",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        TextSpan(text: entry.value),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        })
                        .toList()),

                  const SizedBox(height: 15),

                  // Gramer İpucu Kutusu
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isCorrect
                            ? Colors.green.shade200
                            : Colors.red.shade200,
                      ),
                    ),
                    child: Text(
                      aiFeedback['ai_tip'] ?? "",
                      style: const TextStyle(
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 🌟🌟🌟 EKLENEN KISIM BİTİŞİ 🌟🌟🌟
          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: () {
              if (isCorrect) {
                // Doğru bildiyse BottomSheet'i kapat ve arkaya 'true' yolla (Sonraki Soruya Geç!)
                Navigator.pop(context, true);
              } else {
                // Yanlış bildiyse sadece BottomSheet'i kapat ve 'false' yolla (Tekrar Dene!)
                Navigator.pop(context, false);
              }
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: isCorrect ? Colors.green : Colors.red.shade400,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: Text(
              isCorrect ? "DEVAM ET (+$xp XP)" : "TEKRAR DENE",
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
