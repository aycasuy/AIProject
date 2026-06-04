import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'level_decision_screen.dart';
import 'main_navigation.dart';
import '../main.dart';
// 🌟 ÇEVİRİ KÜTÜPHANESİ EKLENDİ
import '../l10n/app_localizations.dart';

class LanguageSelectionScreen extends StatefulWidget {
  final String username;

  const LanguageSelectionScreen({super.key, required this.username});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  int _currentStep = 1; // 1: Hedef Dil, 2: Ana Dil
  bool _isLoading = false;

  String _selectedTargetLanguage = "";
  String _selectedNativeLanguage = "";

  bool _isReturningUser = false;

  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _checkUserStatus();
  }

  Future<void> _checkUserStatus() async {
    try {
      final url = Uri.parse(
        'http://10.0.2.2:8000/get_user_stats/${widget.username}',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (mounted) {
          setState(() {
            final gelenSeviye = data['level'];

            if (gelenSeviye != null &&
                gelenSeviye.toString().trim() != "" &&
                gelenSeviye.toString().trim() != "Belirlenmedi") {
              _isReturningUser = true;
              _selectedNativeLanguage = data['native_language'] ?? "Turkish";
            } else {
              _isReturningUser = false;
            }
            _isLoadingStats = false;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingStats = false);
    }
  }

  // 🌟 DİNAMİK YAPILDI: "name" alanını çıkardık, çeviriyi db_value'dan UI'da anlık yapacağız.
  final List<Map<String, dynamic>> _targetLanguages = [
    {"db_value": "English", "flag": "🇬🇧", "available": true},
    {"db_value": "Spanish", "flag": "🇪🇸", "available": true},
    {"db_value": "German", "flag": "🇩🇪", "available": false},
    {"db_value": "French", "flag": "🇫🇷", "available": false},
  ];

  final List<Map<String, dynamic>> _nativeLanguages = [
    {"db_value": "Turkish", "flag": "🇹🇷", "available": true},
    {"db_value": "English", "flag": "🇺🇸", "available": true},
  ];

  // 🌟 YARDIMCI FONKSİYON: Veritabanı değerine göre anlık çevrilmiş dil adını döndürür
  String _getLocalizedLangName(String dbValue, AppLocalizations l10n) {
    switch (dbValue) {
      case "English":
        return l10n.langEnglish;
      case "Spanish":
        return l10n.langSpanish;
      case "German":
        return l10n.langGerman;
      case "French":
        return l10n.langFrench;
      case "Turkish":
        return l10n.langTurkish;
      default:
        return dbValue;
    }
  }

  Future<void> _saveLanguagesToDatabase() async {
    final l10n = AppLocalizations.of(context)!;

    setState(() => _isLoading = true);

    try {
      // 1. Önce kullanıcının dil tercihlerini veritabanına kaydet/güncelle
      final url = Uri.parse('http://10.0.2.2:8000/update_languages');
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": widget.username,
          "native_language": _selectedNativeLanguage,
          "target_language": _selectedTargetLanguage,
        }),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;

        if (_selectedNativeLanguage == "Turkish") {
          LinguaApp.localeNotifier.value = const Locale('tr', '');
        } else if (_selectedNativeLanguage == "English") {
          LinguaApp.localeNotifier.value = const Locale('en', '');
        }
        // 🌟 MÜKEMMEL DOKUNUŞ: Kullanıcı dili seçtiğine göre,
        // ŞİMDİ gidip o dildeki GERÇEK seviyesini soralım!
        final statsUrl = Uri.parse(
          'http://10.0.2.2:8000/get_user_stats/${widget.username}?target_language=$_selectedTargetLanguage',
        );
        final statsResponse = await http.get(statsUrl);

        String realLevel = "";
        if (statsResponse.statusCode == 200) {
          final statsData = jsonDecode(utf8.decode(statsResponse.bodyBytes));
          realLevel = statsData['level'] ?? "";
        }

        if (realLevel.isNotEmpty && realLevel != "Belirlenmedi") {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => MainNavigationScreen(
                username: widget.username,
                targetLanguage: _selectedTargetLanguage,
                nativeLanguage: _selectedNativeLanguage,
                minLevel: realLevel,
              ),
            ),
            (Route<dynamic> route) => false,
          );
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => LevelDecisionScreen(
                username: widget.username,
                selectedLanguage: _selectedTargetLanguage,
                nativeLanguage: _selectedNativeLanguage,
              ),
            ),
            (Route<dynamic> route) => false,
          );
        }
      }
    } catch (e) {
      _showError(l10n.connectionErrorServer); // 🌟 DİNAMİK YAPILDI
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
    );
  }

  void _onLanguageSelected(Map<String, dynamic> lang) {
    final l10n = AppLocalizations.of(context)!;

    if (lang["available"] == false) {
      final langName = _getLocalizedLangName(lang["db_value"], l10n);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.languageComingSoonMsg(langName),
          ), // 🌟 DİNAMİK YAPILDI
          backgroundColor: const Color(0xFF073B4C),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    if (_currentStep == 1) {
      setState(() {
        _selectedTargetLanguage = lang["db_value"];
      });

      if (_isReturningUser && _selectedNativeLanguage.isNotEmpty) {
        _saveLanguagesToDatabase();
      } else {
        setState(() => _currentStep = 2);
      }
    } else {
      setState(() {
        _selectedNativeLanguage = lang["db_value"];
      });
      _saveLanguagesToDatabase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // 🌟 L10N ÇAĞRILDI

    final currentList = _currentStep == 1 ? _targetLanguages : _nativeLanguages;

    String titleText;
    if (_currentStep == 1) {
      if (_isReturningUser) {
        titleText = l10n.continueLearning; // 🌟 DİNAMİK YAPILDI
      } else {
        titleText = l10n.readyToLearn; // 🌟 DİNAMİK YAPILDI
      }
    } else {
      titleText = l10n.whatIsNativeLanguage; // 🌟 DİNAMİK YAPILDI
    }

    final stepText = l10n.stepProgress(_currentStep, 2); // 🌟 DİNAMİK YAPILDI

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          stepText,
          style: const TextStyle(color: Colors.grey, fontSize: 16),
        ),
        leading: _currentStep == 2
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Color(0xFF073B4C),
                ),
                onPressed: () => setState(() => _currentStep = 1),
              )
            : null,
      ),
      body: (_isLoading || _isLoadingStats)
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF118AB2)),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    titleText,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF073B4C),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.makeSelectionToPersonalize, // 🌟 DİNAMİK YAPILDI
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 40),
                  Expanded(
                    child: ListView.builder(
                      itemCount: currentList.length,
                      itemBuilder: (context, index) {
                        final lang = currentList[index];
                        final isAvailable = lang["available"];
                        final langName = _getLocalizedLangName(
                          lang["db_value"],
                          l10n,
                        ); // 🌟 DİNAMİK ÇEVİRİ

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: InkWell(
                            onTap: () => _onLanguageSelected(lang),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 20,
                              ),
                              decoration: BoxDecoration(
                                color: isAvailable
                                    ? Colors.white
                                    : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.grey.shade300),
                                boxShadow: isAvailable
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : [],
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    lang["flag"],
                                    style: const TextStyle(fontSize: 32),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: Text(
                                      langName, // 🌟 ÇEVRİLMİŞ İSİM BASILDI
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        color: isAvailable
                                            ? const Color(0xFF073B4C)
                                            : Colors.grey,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    isAvailable
                                        ? Icons.arrow_forward_ios_rounded
                                        : Icons.lock_rounded,
                                    color: isAvailable
                                        ? const Color(0xFF118AB2)
                                        : Colors.grey,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
