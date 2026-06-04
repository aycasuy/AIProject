import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'placement_test_screen.dart';
import 'main_navigation.dart';

class LevelDecisionScreen extends StatefulWidget {
  final String username;
  final String selectedLanguage;
  final String nativeLanguage;

  const LevelDecisionScreen({
    super.key,
    required this.username,
    required this.selectedLanguage,
    required this.nativeLanguage,
  });

  @override
  State<LevelDecisionScreen> createState() => _LevelDecisionScreenState();
}

class _LevelDecisionScreenState extends State<LevelDecisionScreen> {
  bool _isLoading = false;

  Future<void> _startFromScratch() async {
    setState(() => _isLoading = true);

    try {
      final url = Uri.parse('http://10.0.2.2:8000/update_progress');

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": widget.username,
          "target_language": widget.selectedLanguage,
          "new_level": "A1",
          "added_xp": 0,
          "current_section": 1,
          "current_lesson": 1,
        }),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => MainNavigationScreen(
              username: widget.username,
              targetLanguage: widget.selectedLanguage,
              minLevel: "A1",
              nativeLanguage: widget.nativeLanguage,
            ),
          ),
          (Route<dynamic> route) => false,
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Seviye kaydedilemedi!")));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Bağlantı hatası: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _goToPlacementTest() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PlacementTestScreen(
          username: widget.username,
          targetLanguage: widget.selectedLanguage,
          nativeLanguage: widget.nativeLanguage,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 28,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 28),
                      _buildInfoCard(),
                      const SizedBox(height: 24),
                      _buildStartButton(),
                      const SizedBox(height: 16),
                      _buildTestButton(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 92,
          height: 92,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF06D6A0), Color(0xFF118AB2)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF06D6A0).withOpacity(0.25),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: const Icon(
            Icons.rocket_launch_rounded,
            color: Colors.white,
            size: 44,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          "Yolculuğun Başlıyor!",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontSize: 30,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "${widget.selectedLanguage} öğrenirken sana en uygun başlangıcı seçelim.",
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 16,
            fontWeight: FontWeight.w500,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Column(
        children: [
          _InfoRow(
            icon: Icons.flag_rounded,
            iconColor: Color(0xFF06D6A0),
            title: "A1’den başlayabilirsin",
            subtitle: "Temelden ilerleyip tüm modülleri sırayla açarsın.",
          ),
          SizedBox(height: 14),
          _InfoRow(
            icon: Icons.quiz_rounded,
            iconColor: Color(0xFF118AB2),
            title: "Seviye testi çözebilirsin",
            subtitle: "Sana uygun seviyeyi kısa bir test ile belirleriz.",
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    if (_isLoading) {
      return Container(
        height: 64,
        decoration: BoxDecoration(
          color: const Color(0xFF06D6A0),
          borderRadius: BorderRadius.circular(22),
        ),
        child: const Center(
          child: SizedBox(
            width: 25,
            height: 25,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
          ),
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: _startFromScratch,
      icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
      label: const Text(
        "Sıfırdan Başlayalım (A1)",
        style: TextStyle(
          fontSize: 17,
          color: Colors.white,
          fontWeight: FontWeight.w900,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF06D6A0),
        elevation: 8,
        shadowColor: const Color(0xFF06D6A0).withOpacity(0.30),
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
    );
  }

  Widget _buildTestButton() {
    return OutlinedButton.icon(
      onPressed: _isLoading ? null : _goToPlacementTest,
      icon: const Icon(Icons.psychology_alt_rounded),
      label: const Text(
        "Seviyemi Biliyorum / Test Et",
        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF118AB2),
        side: const BorderSide(color: Color(0xFF118AB2), width: 2),
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        backgroundColor: Colors.white,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: iconColor, size: 25),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF1F2937),
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
