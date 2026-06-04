// lib/widgets/lesson_node.dart

import 'package:flutter/material.dart';

class LessonNode extends StatelessWidget {
  final String status; // "completed", "active", "locked"
  final Color themeColor;
  final VoidCallback onTap;

  const LessonNode({
    Key? key,
    required this.status,
    required this.themeColor,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    IconData icon;
    double size = status == "active" ? 90.0 : 80.0;

    if (status == "completed") {
      bgColor = themeColor;
      icon = Icons.check;
    } else if (status == "active") {
      bgColor = themeColor;
      icon = Icons.star;
    } else {
      bgColor = Colors.grey.shade300;
      icon = Icons.lock;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 5),
          boxShadow: [
            BoxShadow(
              color: status == "locked"
                  ? Colors.grey.shade400
                  : bgColor.withOpacity(0.6),
              offset: const Offset(0, 8),
              blurRadius: 0,
            ),
          ],
        ),
        child: Center(
          child: Icon(
            icon,
            color: status == "locked" ? Colors.grey.shade500 : Colors.white,
            size: 40,
          ),
        ),
      ),
    );
  }
}
