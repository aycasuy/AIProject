import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart'; // 🌟 EKLENDİ
import 'package:lottie/lottie.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt; // 🌟 EKLENDİ
import '../services/api_service.dart';

class AiTeacherCorrectionScreen extends StatefulWidget {
  final int lessonId;
  final String lessonTitle;
  final String topic;
  final String minLevel;
  final String targetWordsStr;
  final String username;
  final String targetLanguage;
  final int sectionIndex;
  final String nativeLanguage;

  const AiTeacherCorrectionScreen({
    super.key,
    required this.lessonId,
    required this.lessonTitle,
    required this.topic,
    required this.minLevel,
    required this.targetWordsStr,
    required this.username,
    required this.targetLanguage,
    required this.sectionIndex,
    required this.nativeLanguage,
  });

  @override
  State<AiTeacherCorrectionScreen> createState() =>
      _AiTeacherCorrectionScreenState();
}

class _AiTeacherCorrectionScreenState extends State<AiTeacherCorrectionScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _textController = TextEditingController();

  String? submittedText;
  Map<String, dynamic>? realAiResponse;
  bool isLoading = false;
  bool isLessonFinished = false;
  int successfulAttempts = 0;
  final int requiredAttempts = 3;
  List<Map<String, dynamic>> chatMessages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLocked = false;
  bool _isLockChecking = true;

  // 🌟 YENİ: Ses ve İpucu Değişkenleri
  late FlutterTts _flutterTts;
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _isHintLoading = false;
  String? _currentHint;

  // 🌟 YENİ: Lottie ve Animasyon Değişkenleri
  late final AnimationController _lottieController;
  bool _isAiSpeaking = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 1);

    // 🌟 YENİ: Lottie kontrolcüsünü başlat
    _lottieController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3), // Animasyonun kendi uzunluğuna göre
    );

    if (widget.lessonId == 999) {
      _checkDailyLock();
    } else {
      _isLockChecking = false;
    }

    _initAudioTools(); // 🌟 Ses motorlarını başlat
  }

  // 🌟 YENİ: Ses Motorlarını Başlatma
  void _initAudioTools() async {
    _flutterTts = FlutterTts();
    _speech = stt.SpeechToText();
    await _speech.initialize();

    // Dil kodunu targetLanguage'a göre dinamik yapabilirsin, şimdilik en-US
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.45);

    _flutterTts.setStartHandler(() {
      if (mounted) {
        setState(() => _isAiSpeaking = true);
        _lottieController.repeat(); // Animasyonu döngüye sok
      }
    });

    _flutterTts.setCompletionHandler(() {
      if (mounted) {
        setState(() => _isAiSpeaking = false);
        _lottieController.stop(); // Animasyonu durdur
      }
    });
  }

  // 🌟 YENİ: Sesli Okuma Fonksiyonu
  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }

  Future<void> _checkDailyLock() async {
    bool locked = await ApiService.isRoleplayLocked(
      widget.username,
      widget.targetLanguage,
    );
    if (mounted) {
      setState(() {
        _isLocked = locked;
        _isLockChecking = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    _textController.dispose();
    _lottieController.dispose(); // 🌟 Lottie'yi temizle
    _flutterTts.stop(); // 🌟 Bellek temizliği
    super.dispose();
  }

  void _sendTextToAi() async {
    if (_textController.text.trim().isEmpty) return;

    String userText = _textController.text;

    setState(() {
      chatMessages.add({"role": "user", "text": userText});
      isLoading = true;
      _currentHint = null; // 🌟 YENİ: Mesaj atınca eski ipucunu temizle
    });

    _textController.clear();

    try {
      final response = await ApiService.getAiCorrection(
        widget.topic,
        userText,
        widget.minLevel,
        widget.targetWordsStr,
        chatMessages.map((m) {
          if (m["role"] == "user") {
            return {"role": "user", "content": m["text"].toString()};
          } else {
            String aiContent = "${m['ai_message']} ${m['next_step'] ?? ''}";
            return {"role": "model", "content": aiContent.trim()};
          }
        }).toList(),
        widget.targetLanguage,
      );

      setState(() {
        isLoading = false;

        chatMessages.add({
          "role": "ai",
          "ai_message": response["ai_message"],
          "corrections": response["corrections"],
          "next_step": response["next_step"],
        });

        // 🌟 YENİ: AI cevap verince otomatik sesli okusun
        _speak(response["ai_message"] ?? "");

        Future.delayed(const Duration(milliseconds: 100), () {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });

        if (response["corrections"] != null &&
            (response["corrections"] as List).isEmpty) {
          successfulAttempts++;
          if (successfulAttempts >= requiredAttempts) isLessonFinished = true;
        }
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLockChecking) {
      return const Scaffold(
        backgroundColor: Color(0xFFF4F7FE),
        body: Center(
          child: CircularProgressIndicator(color: Colors.blueAccent),
        ),
      );
    }

    if (_isLocked) {
      return Scaffold(
        backgroundColor: const Color(0xFFF4F7FE),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("⏳", style: TextStyle(fontSize: 80)),
                const SizedBox(height: 20),
                const Text(
                  "Bugünlük Yeter!",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Günlük ücretsiz yapay zeka roleplay hakkını doldurdun. Harika iş çıkardın! Yeni bir senaryo için yarın tekrar gel veya sınırsız sohbet için Premium'u keşfet.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Text(
                    "👇 Başka etkinlikler için alt menüyü kullan",
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: widget.lessonId == 999
            ? const SizedBox.shrink()
            : IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
                onPressed: () => Navigator.pop(context),
              ),
        title: Text(
          widget.lessonTitle,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blueAccent.shade700,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blueAccent.shade700,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          tabs: const [
            Tab(text: "Öğren"),
            Tab(text: "Kullan"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const Center(
            child: Text(
              "📖 Öğrenme modülü buraya gelecek",
              style: TextStyle(color: Colors.grey),
            ),
          ),
          // 2. SEKME: KULLAN (Ana Yapay Zeka Etkileşim Alanı)
          Column(
            children: [
              // 🌟 1. AVATARI LİSTENİN DIŞINA, EN TEPEYE SABİTLEDİK! 🌟
              Padding(
                padding: const EdgeInsets.only(
                  top: 20.0,
                ), // Yukarıdan biraz boşluk
                child: Center(child: _buildAiAvatar()),
              ),

              // 🌟 2. MESAJLARIN KAYACAĞI ALAN BURADAN BAŞLIYOR 🌟
              Expanded(
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  children: [
                    // GÜNÜN KELİMELERİ (Burası kayabilir sorun yok)
                    _buildDailyWords(),
                    const SizedBox(height: 16),

                    // İLERLEME DURUMU SAYACI (Hedef 1/3)
                    if (!isLessonFinished)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.flag,
                                color: Colors.blueAccent,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Hedef: $successfulAttempts / $requiredAttempts doğru cümle",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),

                    // AI GİRİŞ MESAJI (Sabit)
                    _buildAiMessage(
                      "Senaryo: ${widget.lessonTitle} 🎭\n\nHedefin bu senaryoya uygun, ${widget.targetLanguage} dilinde $requiredAttempts hatasız cümle kurmak. Hazırsan ilk mesajını yazarak sohbeti başlat! 😊",
                      isHighlight: true,
                    ),

                    // SOHBET GEÇMİŞİ
                    ...chatMessages.map((msg) {
                      if (msg["role"] == "user") {
                        return _buildUserMessage(msg["text"]);
                      } else {
                        return Column(
                          children: [
                            _buildAiMessage(
                              msg["ai_message"] ?? "İşte sonuçların:",
                            ),
                            _buildCorrectionCard(msg["corrections"] ?? []),
                            if (!isLessonFinished &&
                                msg == chatMessages.last &&
                                msg["next_step"] != null &&
                                msg["next_step"].toString().trim().isNotEmpty)
                              _buildAiMessage(msg["next_step"]),
                          ],
                        );
                      }
                    }).toList(),

                    // YÜKLENİYOR (KOÇ DÜŞÜNÜYOR) BALONCUĞU
                    if (isLoading)
                      TweenAnimationBuilder(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                        tween: Tween<double>(begin: 0, end: 1),
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.scale(
                              scale: 0.8 + (value * 0.2),
                              child: child,
                            ),
                          );
                        },
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(
                              bottom: 12,
                              right: 100,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                                bottomLeft: Radius.circular(4),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.blueAccent,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  "Koç düşünüyor...",
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontStyle: FontStyle.italic,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    // DERSİ BİTİR BUTONU
                    if (isLessonFinished) _buildFinishButton(),
                  ],
                ),
              ),

              // 🌟 3. ALT MESAJ KUTUSU
              if (!isLessonFinished) _buildBottomInput(),
            ],
          ),
        ],
      ),
    );
  }

  // --- 🌟 TASARIM: HAREKETLİ AI ÖĞRETMEN AVATARI ---
  Widget _buildAiAvatar() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _isAiSpeaking
            ? Colors.greenAccent.shade100
            : Colors.blueAccent.withOpacity(0.1),
        boxShadow: _isAiSpeaking
            ? [
                BoxShadow(
                  color: Colors.greenAccent.withOpacity(0.6),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ]
            : [],
      ),
      child: CircleAvatar(
        radius: 60, // Avatarın büyüklüğü
        backgroundColor: Colors.white,
        child: ClipOval(
          child: Transform.scale(
            scale: 1.5, // Animasyon küçükse buradan büyütebilirsin
            child: Lottie.asset(
              'assets/lottie/talkingcharacter.json', // 🌟 Dinleme modülündeki dosya yolun
              controller: _lottieController,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDailyWords() {
    List<String> targetWords = widget.targetWordsStr.isEmpty
        ? []
        : widget.targetWordsStr.split(',').map((e) => e.trim()).toList();

    if (targetWords.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Günün Kelimeleri",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: targetWords
              .map(
                (word) => Chip(
                  label: Text(
                    word,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.blueAccent,
                    ),
                  ),
                  backgroundColor: Colors.blueAccent.withOpacity(0.1),
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildFinishButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 4,
          minimumSize: const Size(double.infinity, 50),
        ),
        onPressed: () async {
          setState(() => isLoading = true);

          if (widget.lessonId == 999) {
            // 🌟 1. GÜNLÜK ROLEPLAY (HARİTA DIŞI)
            // Önce görevi yapıldı olarak kilitle
            await ApiService.markRoleplayDone(
              widget.username,
              widget.targetLanguage,
            );

            // Sonra GÜVENLİ motorumuzla 50 XP ver!
            // (Haritayı yanlışlıkla ilerletmemek için kullanıcının mevcut konumunu yolluyoruz)
            try {
              final progress = await ApiService.fetchUserProgress(
                widget.username,
                widget.targetLanguage,
              );

              await ApiService.addXp(
                widget.username,
                widget.targetLanguage,
                50,
                progress.currentSection,
                progress.currentLesson,
              );
            } catch (e) {
              print("Günlük görev XP hatası: $e");
            }
          }
          // 🌟 2. HARİTA MODUNDA (Burada XP vermiyoruz, haritaya dönünce harita kendisi verecek!)

          if (!mounted) return;
          setState(() => isLoading = false);

          if (widget.lessonId == 999) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: const Text("🎉 Harika İş!"),
                content: const Text(
                  "Senaryoyu başarıyla tamamladın ve +50 XP kazandın!",
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        _isLocked = true; // Ekranı kilitli duruma getir
                      });
                    },
                    child: const Text(
                      "Tamam",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            // Haritadan gelindiyse haritaya başarıyla dön
            Navigator.pop(context, true);
          }
        },
        child: const Text(
          "✅ Dersi Bitir (+50 XP)",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // 🌟 YENİ: BASILI TUTUNCA ÇEVİRİ YAPAN AI MESAJ BALONU
  Widget _buildAiMessage(String text, {bool isHighlight = false}) {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset((value - 1) * 100, 0),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Align(
        alignment: Alignment.centerLeft,
        child: GestureDetector(
          onLongPress: () async {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              builder: (context) => const SizedBox(
                height: 150,
                child: Center(child: CircularProgressIndicator()),
              ),
            );

            String translation = await ApiService.translateText(
              text,
              nativeLanguage: widget.targetLanguage,
            );

            if (context.mounted) {
              Navigator.pop(context); // Yükleniyor'u kapat
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                builder: (context) => Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.g_translate, color: Colors.blueAccent),
                          SizedBox(width: 10),
                          Text(
                            "Çeviri",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        translation,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              );
            }
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12, right: 60),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
                bottomLeft: Radius.circular(4),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 15,
                    fontWeight: isHighlight
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Çeviri için basılı tut",
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserMessage(String text) {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset((1 - value) * 100, 0),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16, left: 60),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blueAccent.shade400,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(4),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.blueAccent.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildCorrectionCard(List<dynamic> corrections) {
    if (corrections.isEmpty) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16, right: 40),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          border: Border.all(color: Colors.green.shade200, width: 1.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Text("🎉", style: TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              "Harika! Hiç hata bulunmadı.",
              style: TextStyle(
                color: Colors.green.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16, right: 40),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.red.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text("🏷️", style: TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Text(
                "${corrections.length} hata bulundu",
                style: const TextStyle(
                  color: Color(0xFFD32F2F),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const Divider(height: 24, color: Colors.black12),
          ...corrections.map((item) {
            if (item is String) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  "💡 $item",
                  style: const TextStyle(
                    color: Color(0xFFD32F2F),
                    fontSize: 15,
                  ),
                ),
              );
            }
            if (item is Map) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: item["wrong"]?.toString() ?? "",
                            style: const TextStyle(
                              color: Color(0xFFD32F2F),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          const TextSpan(
                            text: "  ➔  ",
                            style: TextStyle(
                              color: Colors.black45,
                              fontSize: 16,
                            ),
                          ),
                          TextSpan(
                            text: item["correct"]?.toString() ?? "",
                            style: const TextStyle(
                              color: Color(0xFF2E7D32),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "(${item["explanation"]?.toString() ?? ""})",
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.5),
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }).toList(),
        ],
      ),
    );
  }

  // 🌟 YENİ: İPUCU VE MİKROFON İÇEREN ALT GİRDİ ALANI
  Widget _buildBottomInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // İPUCU ALANI
            if (_isHintLoading)
              const Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: LinearProgressIndicator(color: Colors.blueAccent),
              )
            else if (_currentHint != null)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb, color: Colors.amber),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _currentHint!,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, color: Colors.amber),
                      onPressed: () {
                        _textController.text = _currentHint!;
                      },
                    ),
                  ],
                ),
              )
            else
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () async {
                    setState(() => _isHintLoading = true);

                    List<Map<String, String>> formattedHistory = chatMessages
                        .map((m) {
                          return {
                            "role": m["role"] == "user" ? "user" : "model",
                            "content": (m["text"] ?? m["ai_message"])
                                .toString(),
                          };
                        })
                        .toList();

                    String hint = await ApiService.getChatHint(
                      widget.topic,
                      widget.targetLanguage,
                      formattedHistory,
                      widget.nativeLanguage,
                    );

                    setState(() {
                      _currentHint = hint;
                      _isHintLoading = false;
                    });
                  },
                  icon: const Icon(
                    Icons.lightbulb_outline,
                    color: Colors.amber,
                    size: 18,
                  ),
                  label: const Text(
                    "Tıkandım, İpucu ver",
                    style: TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            // MESAJ KUTUSU VE BUTONLAR
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D2D2D),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _textController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: realAiResponse == null
                            ? "Cevabını yaz..."
                            : "Düzeltilmiş halini yaz...",
                        hintStyle: const TextStyle(color: Colors.white54),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // MİKROFON BUTONU
                GestureDetector(
                  onTap: () async {
                    if (!_isListening) {
                      bool available = await _speech.initialize();
                      if (available) {
                        setState(() => _isListening = true);
                        _speech.listen(
                          onResult: (val) => setState(() {
                            _textController.text = val.recognizedWords;
                          }),
                        );
                      }
                    } else {
                      setState(() => _isListening = false);
                      _speech.stop();
                    }
                  },
                  child: CircleAvatar(
                    backgroundColor: _isListening
                        ? Colors.redAccent
                        : Colors.blueAccent.shade100,
                    child: Icon(
                      _isListening ? Icons.mic_off : Icons.mic,
                      color: _isListening ? Colors.white : Colors.blueAccent,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // GÖNDER BUTONU
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.shade700,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendTextToAi,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
