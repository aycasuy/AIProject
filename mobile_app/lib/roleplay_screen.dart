/*import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';*/
/*
// ---------------- VERİ KALIPLARIMIZ ----------------
class ChatMessage {
  final String role; // "user" veya "model"
  final String text;
  final String?
  correction; // Sadece kullanıcı mesajlarında dolu olabilir (Hibrit Düzeltme)

  ChatMessage({required this.role, required this.text, this.correction});
}

class ChatRoleplayScreen extends StatefulWidget {
  final String username;
  final String targetLanguage;
  final String userLevel;
  final String scenario; // Eğer "AUTO" gelirse AI kendi uyduracak!

  const ChatRoleplayScreen({
    super.key,
    required this.username,
    required this.targetLanguage,
    required this.userLevel,
    required this.scenario,
  });

  @override
  State<ChatRoleplayScreen> createState() => _ChatRoleplayScreenState();
}

class _ChatRoleplayScreenState extends State<ChatRoleplayScreen> {
  final List<ChatMessage> _messages = [];

  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;

  bool _isListening = false;
  bool _isAIThinking = true;
  String _currentWords = ""; // Mikrofondan o an dökülen kelimeler

  // 🌟 DİNAMİK BAŞLIK: Ekran açıldığında bu yazacak, AI senaryoyu bulunca değişecek!
  String _dynamicScenarioTitle = "Senaryo Yaratılıyor... ⏳";

  @override
  void initState() {
    super.initState();

    // Eğer AUTO değilse, doğrudan gelen senaryo adını yaz
    if (widget.scenario != "AUTO") {
      _dynamicScenarioTitle = widget.scenario;
    }

    _speech = stt.SpeechToText();
    _initTts();
    _initSpeech();

    // Ekran açılır açılmaz Yapay Zeka'ya "Sohbeti Başlat" diyoruz! (Kullanıcıya gözükmez)
    _sendMessageToAI(
      "Senaryoyu başlat ve bana ilk cümleyi söyle.",
      isHiddenStart: true,
    );
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _speech.stop();
    super.dispose();
  }

  // 1. SES MOTORUNU (TTS) BAŞLAT
  void _initTts() {
    _flutterTts = FlutterTts();

    // Seçilen dile göre TTS aksanını ayarla
    String languageCode = "en-US";
    if (widget.targetLanguage == "Fransızca") languageCode = "fr-FR";
    if (widget.targetLanguage == "İspanyolca") languageCode = "es-ES";
    if (widget.targetLanguage == "Almanca") languageCode = "de-DE";

    _flutterTts.setLanguage(languageCode);
    _flutterTts.setSpeechRate(0.45); // Gerçekçi ve anlaşılır bir hız
    _flutterTts.setPitch(1.0);
  }

  // 2. MİKROFONU (STT) BAŞLAT
  void _initSpeech() async {
    await _speech.initialize();
    if (mounted) setState(() {});
  }

  // 3. MİKROFONA BASILI TUTMA/DİNLEME MANTIĞI
  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);

        String locale = "en-US";
        if (widget.targetLanguage == "Fransızca") locale = "fr-FR";
        if (widget.targetLanguage == "İspanyolca") locale = "es-ES";
        if (widget.targetLanguage == "Almanca") locale = "de-DE";

        _speech.listen(
          onResult: (val) {
            setState(() {
              _currentWords = val.recognizedWords;
            });
          },
          localeId: locale,
        );
      }
    } else {
      // Mikrofonu kapattığında mesajı AI'a gönder!
      setState(() => _isListening = false);
      _speech.stop();
      if (_currentWords.isNotEmpty) {
        _sendMessageToAI(_currentWords);
        _currentWords = ""; // Geçici metni temizle
      }
    }
  }

  // ❌ 3.5 SESİ İPTAL ETME VE ÇÖPE ATMA MANTIĞI
  void _cancelListening() {
    _speech.stop(); // Mikrofonu sustur
    setState(() {
      _isListening = false;
      _currentWords = ""; // Söylenenleri temizle ki AI'a gitmesin!
    });
  }

  // 🧠 4. BEYNE (PYTHON'A) MESAJ GÖNDERME VE HAFIZA YÖNETİMİ
  Future<void> _sendMessageToAI(
    String message, {
    bool isHiddenStart = false,
  }) async {
    if (!isHiddenStart) {
      setState(() {
        _messages.add(ChatMessage(role: "user", text: message));
        _isAIThinking = true;
      });
    }

    try {
      // Python'un anlayacağı formata çevir
      List<Map<String, String>> chatHistory = _messages.map((m) {
        return {"role": m.role, "text": m.text};
      }).toList();

      final url = Uri.parse('http://10.0.2.2:8000/chat_roleplay');
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": widget.username,
          "target_language": widget.targetLanguage,
          "user_level": widget.userLevel,
          "scenario": widget.scenario, // AUTO gidebilir
          "chat_history": chatHistory,
          "user_message": message,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes))['data'];

        // 🌟 İŞTE DİNAMİK VERİLER
        String scenarioName = data['scenario_name'] ?? _dynamicScenarioTitle;
        String aiResponse = data['ai_response'] ?? "";
        String correction = data['correction_for_user'] ?? "";
        bool isOver = data['is_conversation_over'] ?? false;

        if (!mounted) return;

        setState(() {
          _isAIThinking = false;
          _dynamicScenarioTitle =
              scenarioName; // BAŞLIĞI YAPAY ZEKANIN UYDURDUĞU İSİMLE DEĞİŞTİR!

          // EĞER DÜZELTME VARSA, son kullanıcı mesajının altına iliştir! (Hibrit Modelimiz)
          if (correction.isNotEmpty && _messages.isNotEmpty && !isHiddenStart) {
            int lastUserIndex = _messages.lastIndexWhere(
              (m) => m.role == "user",
            );
            if (lastUserIndex != -1) {
              String oldText = _messages[lastUserIndex].text;
              _messages[lastUserIndex] = ChatMessage(
                role: "user",
                text: oldText,
                correction: correction,
              );
            }
          }

          // Yapay Zekanın cevabını ekrana ekle ve sesli oku!
          if (aiResponse.isNotEmpty) {
            _messages.add(ChatMessage(role: "model", text: aiResponse));
            _flutterTts.speak(aiResponse);
          }
        });

        // EĞER SOHBET BİTTİYSE (İleride buraya +150 XP Pop-up'ı ekleyeceğiz)
        if (isOver) {
          _showEndGameDialog();
        }
      } else {
        if (mounted) setState(() => _isAIThinking = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isAIThinking = false);
      print("Sohbet Hatası: $e");
    }
  }

  // 🏆 SOHBET BİTİŞ POP-UP'I
  void _showEndGameDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E2235),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Senaryo Tamamlandı! 🎉",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Harika bir iş çıkardın. Gerçek hayatta bu senaryoyla karşılaşırsan ne yapacağını artık biliyorsun!",
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF06D6A0),
            ),
            onPressed: () {
              Navigator.pop(context); // Diyaloğu kapat
              Navigator.pop(context); // Ana ekrana dön
            },
            child: const Text(
              "Muhteşem! 🚀",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21), // Siber koyu tema
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E2235),
        title: Text(
          _dynamicScenarioTitle,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 💬 SOHBET BALONLARI ALANI
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                bool isUser = msg.role == "user";

                return Column(
                  crossAxisAlignment: isUser
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    // Balonun Kendisi
                    Container(
                      margin: const EdgeInsets.only(bottom: 8, top: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: isUser
                            ? const Color(0xFFC77DFF)
                            : const Color(0xFF1E2235),
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(20),
                          topRight: const Radius.circular(20),
                          bottomLeft: Radius.circular(isUser ? 20 : 0),
                          bottomRight: Radius.circular(isUser ? 0 : 20),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        msg.text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          height: 1.3,
                        ),
                      ),
                    ),

                    // 💡 İŞTE O SİHİRLİ HİBRİT MODEL: GİZLİ DÜZELTME!
                    if (isUser &&
                        msg.correction != null &&
                        msg.correction!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: 12,
                          right: 10,
                          left: 40,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.lightbulb_outline,
                              color: Color(0xFFFFD166),
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                msg.correction!,
                                style: const TextStyle(
                                  color: Color(0xFFFFD166),
                                  fontSize: 13,
                                  fontStyle: FontStyle.italic,
                                  height: 1.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
          ),

          // 🤖 YAPAY ZEKA DÜŞÜNÜYOR ANİMASYONU
          if (_isAIThinking)
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Color(0xFF06D6A0),
                  strokeWidth: 3,
                ),
              ),
            ),

          // 🗣️ KULLANICI KONUŞURKEN GEÇİCİ OLARAK EKRANDA GÖZÜKEN METİN
          if (_currentWords.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                "Sen: $_currentWords",
                style: const TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                  fontSize: 16,
                ),
              ),
            ),

          // 🎙️ DEVASA MİKROFON BUTONU
          // 🎙️ ALT KONTROL PANELİ (Mikrofon ve İptal Butonu)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1E2235),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ❌ İPTAL BUTONU (Sadece dinlerken görünür, zarifçe belirir)
                AnimatedOpacity(
                  opacity: _isListening ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: GestureDetector(
                    onTap: _isListening
                        ? _cancelListening
                        : null, // Sadece görünürken tıklanabilir
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFFF6B6B).withOpacity(0.3),
                        ),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Color(0xFFFF6B6B),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 20), // Butonlar arası boşluk
                // 🎙️ ANA MİKROFON BUTONU
                GestureDetector(
                  onTap: _listen, // Dokun başla, dokun GÖNDER!
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: _isListening ? 90 : 80,
                    height: _isListening ? 90 : 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isListening
                          ? const Color(0xFFFF6B6B)
                          : const Color(0xFF06D6A0),
                      boxShadow: _isListening
                          ? [
                              BoxShadow(
                                color: const Color(0xFFFF6B6B).withOpacity(0.6),
                                blurRadius: 30,
                                spreadRadius: 10,
                              ),
                            ]
                          : [
                              BoxShadow(
                                color: const Color(0xFF06D6A0).withOpacity(0.3),
                                blurRadius: 15,
                                spreadRadius: 5,
                              ),
                            ],
                    ),
                    child: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),

                const SizedBox(
                  width: 70,
                ), // ⚖️ Mikrofonu tam ortada tutmak için sağ tarafa görünmez bir dengeleyici boşluk
              ],
            ),
          ),
        ],
      ),
    );
  }
}
*/
