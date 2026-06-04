// widgets/word_chip.dart
import 'package:flutter/material.dart';

class WordChip extends StatelessWidget {
  final String word;
  final bool isSelected;

  const WordChip({Key? key, required this.word, this.isSelected = false})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          // Seçiliyken kenarlığı daha silik yapabiliriz
          color: isSelected ? Colors.grey.shade300 : Colors.blue.shade200,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            offset: const Offset(0, 4), // 3D basılma efekti
            blurRadius: 0,
          ),
        ],
      ),
      child: Text(
        word,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: isSelected ? Colors.grey.shade600 : Colors.black87,
        ),
      ),
    );
  }
}
