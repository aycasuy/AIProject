import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
// 🌟 DİNAMİK DİL KÜTÜPHANESİ EKLENDİ
import '../l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  final String username;
  final String currentLanguage;
  final String currentLevel; // Örn: "A2"

  const SettingsScreen({
    super.key,
    required this.username,
    required this.currentLanguage,
    required this.currentLevel,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late String _selectedLanguage;
  late String _selectedLevel; // 🌟 YENİ: Seçilen pratik seviyesi
  bool _notificationsEnabled = true;
  bool _isLoading = false;

  List<String> _activeLanguages = [];
  List<String> _availableLevels = []; // 🌟 YENİ: Ulaşılan seviyeler listesi

  // Tüm CEFR seviyeleri (Sıralamayı bilmek için)
  final List<String> _allCEFRLevels = ["A1", "A2", "B1", "B2", "C1", "C2"];

  @override
  void initState() {
    super.initState();
    _selectedLanguage = widget.currentLanguage;
    _selectedLevel = widget.currentLevel;
    _activeLanguages = [widget.currentLanguage];

    _generateAvailableLevels(); // 🌟 Seviye listesini oluştur
    _loadActiveLanguages();
  }

  // 🌟 YENİ: Kullanıcının maksimum seviyesine kadar olan listeyi oluşturur
  void _generateAvailableLevels() {
    int maxIndex = _allCEFRLevels.indexOf(widget.currentLevel);

    // Eğer garip bir seviye geldiyse (Örn: "Belirlenmedi") en azından kendini göstersin
    if (maxIndex == -1) {
      _availableLevels = [widget.currentLevel];
      return;
    }

    // A1'den mevcut seviyeye (Örn: A2) kadar olan dilimi alıp listeye çevir
    _availableLevels = _allCEFRLevels.sublist(0, maxIndex + 1);
  }

  Future<void> _loadActiveLanguages() async {
    final languages = await ApiService.fetchUserLanguages(widget.username);
    if (mounted && languages.isNotEmpty) {
      setState(() {
        _activeLanguages = languages;
      });
    }
  }

  Future<void> _saveSettings() async {
    setState(() => _isLoading = true);

    try {
      // Dil değişikliğini API'ye bildir
      await ApiService.updateUserPreferences(
        username: widget.username,
        targetLanguage: _selectedLanguage,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Ayarlar başarıyla kaydedildi! 🎉"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // 🌟 DEĞİŞİKLİK: Sadece dili değil, seçtiği pratik seviyesini de geri döndürüyoruz!
        // Sözlük (Map) olarak döndürüyoruz ki MainNavigationScreen ikisini de alabilsin.
        Navigator.pop(context, {
          "language": _selectedLanguage,
          "level": _selectedLevel,
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Hata: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🌟 Çevirileri kullanmak için localizations nesnesini oluşturuyoruz
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text(
          l10n.settingsTitle, // 🌟 DİNAMİK YAPILDI
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF118AB2)),
            )
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _buildSectionHeader(
                  l10n.learningPreferences,
                ), // 🌟 DİNAMİK YAPILDI
                const SizedBox(height: 10),

                // 1. DİL SEÇİMİ
                _buildDropdownCard(
                  icon: Icons.language,
                  title: l10n.learnedLanguage, // 🌟 DİNAMİK YAPILDI
                  value: _selectedLanguage,
                  items: _activeLanguages,
                  iconColor: const Color(0xFF118AB2),
                  onChanged: (val) => setState(() => _selectedLanguage = val!),
                ),

                const SizedBox(height: 16),

                // 🌟 2. PRATİK SEVİYESİ SEÇİMİ (ZAMAN YOLCULUĞU) 🌟
                _buildDropdownCard(
                  icon: Icons.military_tech_rounded,
                  title: l10n.practiceLevel, // 🌟 DİNAMİK YAPILDI
                  value: _selectedLevel,
                  items: _availableLevels,
                  iconColor: Colors.green,
                  onChanged: (val) => setState(() => _selectedLevel = val!),
                ),

                const Padding(
                  padding: EdgeInsets.only(top: 8, left: 10),
                  child: Text(
                    "Geçmiş seviyelere dönüp pratik yapabilirsin. Maksimum ulaştığın seviye kilitlidir.",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),

                const SizedBox(height: 30),
                _buildSectionHeader(l10n.appSettings), // 🌟 DİNAMİK YAPILDI
                const SizedBox(height: 10),

                // BİLDİRİM AYARLARI
                _buildSwitchCard(
                  icon: Icons.notifications_active_rounded,
                  title: l10n.dailyReminders, // 🌟 DİNAMİK YAPILDI
                  value: _notificationsEnabled,
                  onChanged: (val) =>
                      setState(() => _notificationsEnabled = val),
                ),

                const SizedBox(height: 40),

                // KAYDET BUTONU
                ElevatedButton(
                  onPressed: _saveSettings,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF118AB2),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 5,
                  ),
                  child: Text(
                    l10n.saveChanges, // 🌟 DİNAMİK YAPILDI
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ÇIKIŞ YAP BUTONU
                TextButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        title: const Text(
                          "Çıkış Yap",
                        ), // Demo olduğu için popup'ı sabit bıraktık
                        content: const Text(
                          "Hesabınızdan çıkmak istediğinize emin misiniz?",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              "İptal",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                                (Route<dynamic> route) => false,
                              );
                            },
                            child: Text(
                              l10n.logout, // 🌟 DİNAMİK YAPILDI
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: Colors.redAccent,
                  ),
                  label: Text(
                    l10n.logout, // 🌟 DİNAMİK YAPILDI
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Colors.grey.shade600,
          fontWeight: FontWeight.bold,
          fontSize: 13,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildDropdownCard({
    required IconData icon,
    required String title,
    required String value,
    required List<String> items,
    required Color iconColor,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D2D2D),
              ),
            ),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              icon: const Icon(
                Icons.arrow_drop_down_rounded,
                color: Colors.grey,
              ),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: iconColor,
              ),
              items: items.map((String item) {
                return DropdownMenuItem<String>(value: item, child: Text(item));
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchCard({
    required IconData icon,
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.orange),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D2D2D),
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF118AB2),
          ),
        ],
      ),
    );
  }
}
