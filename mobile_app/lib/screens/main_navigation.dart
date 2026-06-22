import 'dart:math';

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'ai_teacher_correction_screen.dart';
import 'path_screen.dart';
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

  late String _selectedScenarioId;
  Key _profileRefreshKey = UniqueKey();

  static const List<Map<String, String>> _scenarioDefinitions = [
    {'id': 'firstMeeting', 'level': 'A1'},
    {'id': 'cafeOrder', 'level': 'A1'},
    {'id': 'taxiDriver', 'level': 'A2'},
    {'id': 'clothingStore', 'level': 'A2'},
    {'id': 'passportControl', 'level': 'B1'},
    {'id': 'hotelProblem', 'level': 'B1'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedScenarioId = _chooseScenarioForLevel(widget.minLevel);
  }

  @override
  void didUpdateWidget(covariant MainNavigationScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.minLevel != widget.minLevel) {
      _selectedScenarioId = _chooseScenarioForLevel(widget.minLevel);
    }

    if (oldWidget.targetLanguage != widget.targetLanguage ||
        oldWidget.nativeLanguage != widget.nativeLanguage ||
        oldWidget.minLevel != widget.minLevel) {
      _profileRefreshKey = UniqueKey();
    }
  }

  String _chooseScenarioForLevel(String level) {
    final String normalizedLevel = level.trim().toUpperCase();

    List<Map<String, String>> availableScenarios = _scenarioDefinitions
        .where((scenario) => scenario['level'] == normalizedLevel)
        .toList();

    if (availableScenarios.isEmpty) {
      availableScenarios = _scenarioDefinitions
          .where((scenario) => scenario['level'] == 'A1')
          .toList();
    }

    final Random random = Random();
    final Map<String, String> selectedScenario =
        availableScenarios[random.nextInt(availableScenarios.length)];

    return selectedScenario['id']!;
  }

  Map<String, String> _getLocalizedScenario(AppLocalizations l10n) {
    switch (_selectedScenarioId) {
      case 'firstMeeting':
        return {
          'title': l10n.roleplayFirstMeetingTitle,
          'topic': l10n.roleplayFirstMeetingTopic,
        };

      case 'cafeOrder':
        return {
          'title': l10n.roleplayCafeOrderTitle,
          'topic': l10n.roleplayCafeOrderTopic,
        };

      case 'taxiDriver':
        return {
          'title': l10n.roleplayTaxiDriverTitle,
          'topic': l10n.roleplayTaxiDriverTopic,
        };

      case 'clothingStore':
        return {
          'title': l10n.roleplayClothingStoreTitle,
          'topic': l10n.roleplayClothingStoreTopic,
        };

      case 'passportControl':
        return {
          'title': l10n.roleplayPassportControlTitle,
          'topic': l10n.roleplayPassportControlTopic,
        };

      case 'hotelProblem':
        return {
          'title': l10n.roleplayHotelProblemTitle,
          'topic': l10n.roleplayHotelProblemTopic,
        };

      default:
        return {
          'title': l10n.roleplayFirstMeetingTitle,
          'topic': l10n.roleplayFirstMeetingTopic,
        };
    }
  }

  List<Widget> _buildScreens(AppLocalizations l10n) {
    final Map<String, String> scenario = _getLocalizedScenario(l10n);

    return [
      PathScreen(
        username: widget.username,
        selectedLanguage: widget.targetLanguage,
        displayLevel: widget.minLevel,
        nativeLanguage: widget.nativeLanguage,
      ),
      AiTeacherCorrectionScreen(
        username: widget.username,
        targetLanguage: widget.targetLanguage,
        minLevel: widget.minLevel,
        lessonId: 999,
        lessonTitle: scenario['title']!,
        topic: scenario['topic']!,
        targetWordsStr: '',
        sectionIndex: 0,
        nativeLanguage: widget.nativeLanguage,
      ),
      ReadingScreen(
        username: widget.username,
        targetLanguage: widget.targetLanguage,
        nativeLanguage: widget.nativeLanguage,
      ),
      ProfileScreen(
        key: _profileRefreshKey,
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

      // Profil sekmesine her girişte veriler
      // yeniden yüklensin.
      if (index == 3) {
        _profileRefreshKey = UniqueKey();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _buildScreens(l10n)),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
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
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.map_rounded),
                activeIcon: const Icon(Icons.map),
                label: l10n.navMap,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.theater_comedy_outlined),
                activeIcon: const Icon(Icons.theater_comedy),
                label: l10n.navRoleplay,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.document_scanner_outlined),
                activeIcon: const Icon(Icons.document_scanner),
                label: l10n.navWordHunt,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.person_outline),
                activeIcon: const Icon(Icons.person),
                label: l10n.navProfile,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
