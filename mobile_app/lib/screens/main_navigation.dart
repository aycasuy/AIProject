import 'package:flutter/material.dart';
import 'dart:math'; // 🌟 Rastgele senaryo seçmek için ekledik

// Kendi importlarını unutma
import 'path_screen.dart';
import 'ai_teacher_correction_screen.dart'; // Senaryonun oynanacağı ekran
import 'profile_screen.dart';
import 'reading_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final String username;
  final String targetLanguage;
  final String minLevel;
  final String nativeLanguage;

  const MainNavigationScreen({
    super.key,
    required this.username,
    required this.targetLanguage,
    required this.minLevel,
    required this.nativeLanguage,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  late List<Widget> _screens;

  // 🌟 SEVİYELERE GÖRE KATEGORİZE EDİLMİŞ SENARYO HAVUZU 🌟
  final List<Map<String, String>> _allScenarios = [
    // --- A1 SEVİYESİ (Çok Temel Kelimeler) ---
    {
      "level": "A1",
      "title": "👋 İlk Tanışma",
      "topic":
          "Sen yeni tanıştığım, çok arkadaş canlısı birisin. Bana sadece adımı, nasılsın ve nereli olduğumu sor. Çok basit ve kısa cümleler kullan.",
    },
    {
      "level": "A1",
      "title": "☕ Kafede Sipariş",
      "topic":
          "Sen bir baristasın. Ben kafeye geldim. Bana sadece ne içmek istediğimi sor ve basit bir sipariş al.",
    },

    // --- A2 SEVİYESİ (Günlük Hayat ve Yönlendirme) ---
    {
      "level": "A2",
      "title": "🚕 Taksi Şoförü",
      "topic":
          "Sen konuşkan bir taksi şoförüsün. Havalimanına gidiyoruz. Bana nereye uçacağımı, mesleğimi ve yolculuğun nasıl geçtiğini sor.",
    },
    {
      "level": "A2",
      "title": "🛍️ Kıyafet Alışverişi",
      "topic":
          "Sen bir mağaza görevlisisin. Bana nasıl yardımcı olabileceğini, bedenimi ve hangi rengi aradığımı sor.",
    },

    // --- B1 SEVİYESİ (Tartışma ve Problem Çözme) ---
    {
      "level": "B1",
      "title": "🛂 Pasaport Kontrolü",
      "topic":
          "Sen sert ve şüpheci bir gümrük memurusun. Ülkene girmek istiyorum. Bana neden geldiğimi, nerede kalacağımı ve dönüş biletimi sor.",
    },
    {
      "level": "B1",
      "title": "🏨 Otelde Sorun",
      "topic":
          "Sen bir otel resepsiyonistisin. Odamın kliması bozuk ve sıcak suyum akmıyor. Şikayetimi dinle ve bana bir çözüm bulmaya çalış.",
    },
  ];

  @override
  void initState() {
    super.initState();

    // 1. Sadece kullanıcının MEVCUT SEVİYESİNE (A1, A2 vs.) uygun senaryoları filtrele
    List<Map<String, String>> availableScenarios = _allScenarios
        .where((s) => s["level"] == widget.minLevel)
        .toList();

    // (Güvenlik Ağı: Eğer o seviyede bir senaryo bulamazsa, en azından boş kalmasın diye A1'leri getirsin)
    if (availableScenarios.isEmpty) {
      availableScenarios = _allScenarios
          .where((s) => s["level"] == "A1")
          .toList();
    }

    // 2. Filtrelenmiş ve seviyesine uygun havuzun içinden rastgele bir tane seç!
    final random = Random();
    final selectedScenario =
        availableScenarios[random.nextInt(availableScenarios.length)];

    _screens = [
      PathScreen(
        username: widget.username,
        selectedLanguage: widget.targetLanguage,
        displayLevel: widget.minLevel,
        nativeLanguage: widget.nativeLanguage,
      ),

      // 🤖 YENİ AKILLI ROLEPLAY EKRANI
      AiTeacherCorrectionScreen(
        username: widget.username,
        targetLanguage: widget
            .targetLanguage, // AI İspanyolca/İngilizce konuşacağını buradan bilecek
        minLevel: widget.minLevel,
        lessonId: 999,
        lessonTitle: selectedScenario["title"]!, // Ekrana yazılacak şık başlık
        topic: selectedScenario["topic"]!, // AI'a gizlice verilecek Prompt
        targetWordsStr: "",
        sectionIndex: 0,
      ),

      ReadingScreen(
        username: widget.username,
        targetLanguage: widget.targetLanguage,
      ),

      ProfileScreen(
        username: widget.username,
        targetLanguage: widget.targetLanguage,
        userLevel: widget.minLevel,
        nativeLanguage: widget.nativeLanguage,
      ),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;

      // 🌟 EĞER PROFİL SEKMESİNE TIKLANDIYSA (İndeks 2)
      if (index == 3) {
        // Profil ekranını listede yeni bir Key ile eziyoruz, böylece verileri baştan çekiyor!
        _screens[3] = ProfileScreen(
          key: UniqueKey(),
          username: widget.username,
          targetLanguage: widget.targetLanguage,
          userLevel: widget.minLevel,
          nativeLanguage: widget.nativeLanguage,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            backgroundColor: Colors.white,
            selectedItemColor: Colors.deepPurpleAccent,
            unselectedItemColor: Colors.grey.shade400,
            showSelectedLabels: true,
            showUnselectedLabels: false,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.map_rounded),
                activeIcon: Icon(Icons.map),
                label: 'Harita',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.theater_comedy_outlined,
                ), // 🎭 Roleplay ikonuna çevirdik!
                activeIcon: Icon(Icons.theater_comedy),
                label: 'Roleplay',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.document_scanner_outlined),
                activeIcon: Icon(Icons.document_scanner),
                label: 'Kelime Avı',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
