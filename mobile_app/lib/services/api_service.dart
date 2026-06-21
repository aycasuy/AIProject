// lib/services/api_service.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/user_progress_model.dart';
import '../screens/speed_reading_screen.dart';

// lib/services/api_service.dart

class ApiService {
  static const String baseUrl = "http://10.0.2.2:8000/api";

  // ARTIK HEM KULLANICI ADINI HEM DE DİLİ İSTİYORUZ!

  static Future<UserProgress> fetchUserProgress(
    String username,
    String language,
  ) async {
    try {
      // 🌟 SİHİRLİ SATIR BURASI: Her isteği benzersiz yapmak için zaman damgası ekliyoruz
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      // URL'nin sonuna "?language=English" gibi bir parametre ekliyoruz
      final url = Uri.parse(
        "$baseUrl/users/$username/progress?language=$language&t=$timestamp", // 👈 '&t=...' kısmını ekledik!",
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("📦 SUNUCUDAN GELEN PAKET: ${response.body}");
        return UserProgress.fromJson(data);
      } else {
        throw Exception("Sunucu hatası: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Bağlantı hatası: $e");
    }
  }

  // // // // ///////////////////////////////////////////////////////////

  // --- YENİ EKLENEN FONKSİYON ---
  static Future<Map<String, dynamic>> getAiCorrection(
    String topic,
    String userText,
    String level,
    String targetWords,
    List<Map<String, String>> history,
    String targetLanguage,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse("$baseUrl/ai-teacher/correct"),
            headers: {"Content-Type": "application/json"},
            // Python tarafındaki Pydantic modelimize uygun JSON'u gönderiyoruz
            body: json.encode({
              "topic": topic,
              "user_text": userText,
              "level": level,
              "target_words": targetWords, // 🌟 Kelimeler AI'a gidiyor
              "history": history,
              "target_language": targetLanguage, // 🌟 Hafıza AI'a gidiyor
            }),
          )
          .timeout(const Duration(seconds: 45));

      // Terminalde ne olup bittiğini görmek için bu printleri ekle:
      print("🚀 Gönderilen Metin: $userText");
      print("📡 Sunucu Yanıt Kodu: ${response.statusCode}");

      if (response.statusCode == 200) {
        // Python'dan gelen o kusursuz JSON'u dart objesine çeviriyoruz
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        print("❌ Sunucu Hatası Detayı: ${response.body}");
        throw Exception("Sunucu hatası: ${response.statusCode}");
      }
    } catch (e) {
      print("🚨 Bağlantı Hatası: $e");
      throw Exception("Bağlantı hatası: $e");
    }
  }

  static Future<List<dynamic>> fetchAllLessons({
    String nativeLanguage = "Turkish",
  }) async {
    try {
      final uri = Uri.parse(
        "$baseUrl/lessons",
      ).replace(queryParameters: {"native_language": nativeLanguage});

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(utf8.decode(response.bodyBytes));

        if (decoded is List) {
          return decoded;
        }

        debugPrint("fetchAllLessons: Sunucudan liste dışında veri geldi.");
        return [];
      } else {
        throw Exception("Dersler yüklenemedi: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Bağlantı hatası: $e");
    }
  }

  // 🌟 YENİ: Kelimeyi veritabanına kaydetme fonksiyonu
  static Future<void> saveWordToDatabase(
    String username,
    String word,
    String translation,
    String cefrLevel,
    String targetLanguage,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/add_vocabulary'),
        headers: {"Content-Type": "application/json; charset=UTF-8"},
        body: jsonEncode({
          "username": username,
          "word": word,
          "translation": translation,
          "cefr_level": cefrLevel,
          "target_language": targetLanguage,
        }),
      );

      if (response.statusCode != 200) {
        print("Kelime kaydedilemedi: ${response.statusCode}");
      }
    } catch (e) {
      print("Kelime kaydetme hatası: $e");
    }
  }

  // 🌟 YENİ: Kullanıcının geldiği son adımı kaydetme
  // 🌟 YENİ: Hem kilidi açar hem de XP gönderir!
  static Future<void> updateProgress(
    String username,
    int section,
    int lesson,
    int addedXp,
    String targetLanguage,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(
          'http://10.0.2.2:8000/update_progress',
        ), // Yukarıda birleştirdiğimiz yeni Python kapısı
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "current_section": section,
          "current_lesson": lesson,
          "added_xp": addedXp, // Flutter'dan XP'yi gönderiyoruz
          "target_language": targetLanguage,
        }),
      );

      if (response.statusCode == 200) {
        print("Başarılı: ${jsonDecode(response.body)['mesaj']}");
      }
    } catch (e) {
      print("İlerleme güncellenemedi: $e");
    }
  }

  // api_service.dart içindeki MEVCUT fonksiyonu GÜNCELLİYORUZ
  static Future<int> decreaseLife(
    String username, {
    required String targetLanguage,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/decrease_life'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "target_language": targetLanguage,
        }),
      );

      // 🌟 YENİLİK BURADA: Sunucudan gelen kalan can sayısını alıyoruz
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Eğer sunucu "remaining_lives" diye bir şey gönderiyorsa onu al, göndermiyorsa 5 say.
        return data['remaining_lives'] ?? 5;
      } else {
        throw Exception("Can düşürme sunucu hatası: ${response.statusCode}");
      }
    } catch (e) {
      print("Can düşürme hatası: $e");
      // Hata durumunda (internet kopması vb.) oyunu durdurmamak için eksi bir değer (-1) dönüyoruz.
      return -1;
    }
  }

  // api_service.dart dosyasının içindeki sınıfına bunu ekle:

  static Future<Map<String, dynamic>> evaluateSentence({
    required String username,
    required String targetLanguage,
    required String originalSentence,
    required String correctSentence,
    required List<String> submittedWords,
    required String nativeLanguage,
  }) async {
    // Kendi baseUrl değişkenin varsa onu kullanabilirsin
    final String url = "http://10.0.2.2:8000/evaluate_sentence";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json; charset=UTF-8"},
        body: json.encode({
          "username": username,
          "target_language": targetLanguage,
          "native_language": nativeLanguage,
          "original_sentence": originalSentence,
          "correct_sentence": correctSentence,
          "submitted_words": submittedWords,
        }),
      );

      if (response.statusCode == 200) {
        // UTF-8 decode: Türkçe karakterlerin (ş, ğ, ç) bozulmaması için çok önemli!
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception("Sunucu hatası: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Bağlantı hatası: $e");
    }
  }

  // Veritabanından o derse ait cümleyi çeker
  static Future<List<Map<String, dynamic>>> fetchSentencePuzzle({
    required String targetLanguage,
    required int lessonId,
    required String nativeLanguage,
  }) async {
    final String url =
        "http://10.0.2.2:8000/fetch_sentence_puzzle"; // api takısı yoksa böyle

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json; charset=UTF-8"},
        body: json.encode({
          "target_language": targetLanguage,
          "lesson_id": lessonId, // 🌟 Filtremiz buradan gidiyor!
          "native_language": nativeLanguage,
        }),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception("Soru çekilemedi: ${response.statusCode}");
      }
    } catch (e) {
      print("API Hatası (fetchSentencePuzzles): $e");
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> fetchFlashcards(
    int lessonId,
    String targetLanguage,
  ) async {
    final response = await http.get(
      Uri.parse(
        "http://10.0.2.2:8000/fetch_flashcards/$lessonId?target_language=$targetLanguage",
      ),
    );
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(
        json.decode(utf8.decode(response.bodyBytes)),
      );
    }
    return [];
  }

  // ApiService içindeki fonksiyon:
  static Future<void> logMistake({
    required String username,
    required int puzzleId,
    required String puzzleType,
    required String targetLanguage,
  }) async {
    final String url = "http://10.0.2.2:8000/log_mistake";
    await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json; charset=UTF-8"},
      body: json.encode({
        "username": username,
        "puzzle_id": puzzleId,
        "puzzle_type": puzzleType,
        "target_language": targetLanguage, // 🌟 EKLENDİ
      }),
    );
  }

  // 🌟 BOŞLUK DOLDURMA İÇİN GÜVENLİ API KÖPRÜSÜ
  static Future<List<Map<String, dynamic>>> fetchBlankPuzzles({
    required String targetLanguage,
    required int lessonId,
    String nativeLanguage = "Turkish",
  }) async {
    const String url = "http://10.0.2.2:8000/fetch_blank_puzzles";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json; charset=UTF-8"},
        body: json.encode({
          "target_language": targetLanguage,
          "lesson_id": lessonId,
          "native_language": nativeLanguage,
        }),
      );

      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(utf8.decode(response.bodyBytes));

        if (decoded is! List) {
          debugPrint("fetchBlankPuzzles: Sunucudan liste dışında veri geldi.");
          return <Map<String, dynamic>>[];
        }

        return decoded
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
      }

      debugPrint(
        "Boşluk doldurma verisi çekilemedi. "
        "Kod: ${response.statusCode} "
        "Cevap: ${response.body}",
      );

      return <Map<String, dynamic>>[];
    } catch (e) {
      debugPrint("Bağlantı hatası (fetchBlankPuzzles): $e");
      return <Map<String, dynamic>>[];
    }
  }

  static Future<bool> startFastQuiz(
    BuildContext context,
    String username,
    String targetLanguage,
    int userWpm,
    String level,
    int lessonId,
    String nativeLanguage,
  ) async {
    bool isLoadingDialogOpen = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          const Center(child: CircularProgressIndicator(color: Colors.amber)),
    );

    void closeLoadingDialog() {
      if (isLoadingDialogOpen && context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        isLoadingDialogOpen = false;
      }
    }

    try {
      final url = Uri.parse('http://10.0.2.2:8000/generate_speed_reading')
          .replace(
            queryParameters: {
              "username": username,
              "target_language": targetLanguage,
              "native_language": nativeLanguage,
              "level": level,
              "lesson_id": lessonId.toString(),
            },
          );

      final response = await http.post(url);

      closeLoadingDialog();

      if (response.statusCode != 200) {
        if (context.mounted) {
          _showErrorSnackBar(context, "Sunucu Hatası: ${response.statusCode}");
        }
        return false;
      }

      final dynamic decoded = jsonDecode(utf8.decode(response.bodyBytes));

      if (decoded is! Map) {
        if (context.mounted) {
          _showErrorSnackBar(context, "Sunucudan geçersiz veri geldi.");
        }
        return false;
      }

      final Map<String, dynamic> responseData = Map<String, dynamic>.from(
        decoded,
      );

      // Backend cevabı {"data": {...}} şeklindeyse içteki veriyi kullanır.
      final Map<String, dynamic> payload = responseData["data"] is Map
          ? Map<String, dynamic>.from(responseData["data"])
          : responseData;

      debugPrint("SPEED READING RESPONSE: $responseData");
      debugPrint("SPEED READING PAYLOAD: $payload");
      debugPrint("PAYLOAD KEYS: ${payload.keys.toList()}");

      // Backend farklı bir ad kullanıyorsa geçici olarak onları da kontrol eder.
      final String storyText =
          (payload["story_text"] ?? payload["story"] ?? payload["text"] ?? "")
              .toString()
              .trim();

      if (storyText.isEmpty) {
        debugPrint(
          "HATA: story_text bulunamadı. Gelen anahtarlar: "
          "${payload.keys.toList()}",
        );

        if (context.mounted) {
          _showErrorSnackBar(
            context,
            "Okuma metni oluşturulamadı. Lütfen tekrar deneyin.",
          );
        }

        return false;
      }

      final List<String> incomingTargetWords = payload["target_words"] is List
          ? List<String>.from(
              payload["target_words"].map((item) => item.toString()),
            )
          : <String>[];

      final List<dynamic> comprehensionQuestions =
          payload["comprehension_questions"] is List
          ? List<dynamic>.from(payload["comprehension_questions"])
          : <dynamic>[];

      final List<dynamic> vocabularyQuestions =
          payload["vocabulary_questions"] is List
          ? List<dynamic>.from(payload["vocabulary_questions"])
          : <dynamic>[];

      if (!context.mounted) return false;

      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SpeedReadingScreen(
            storyText: storyText,
            userWpm: userWpm,
            targetWords: incomingTargetWords,
            comprehensionQuestions: comprehensionQuestions,
            vocabularyQuestions: vocabularyQuestions,
            level: level,
            username: username,
            targetLanguage: targetLanguage,
            lessonId: lessonId,
          ),
        ),
      );

      return result == true;
    } catch (e, stackTrace) {
      closeLoadingDialog();

      debugPrint("SPEED READING ERROR: $e");
      debugPrintStack(stackTrace: stackTrace);

      if (context.mounted) {
        _showErrorSnackBar(context, "Bağlantı hatası oluştu!");
      }

      return false;
    }
  }

  // Hataları göstermek için küçük bir yardımcı metod
  static void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // --- BOSS SAVAŞI SONUCUNU GÖNDERME ---
  static Future<Map<String, dynamic>?> submitBossResult({
    required String username,
    required int correctCount,
    required int totalQuestions,
    required List<String> targetWords,
    required String
    targetLanguage, // Python'un "öğrenildi" yapması gereken kelimeler
    required lessonId,
  }) async {
    try {
      // Projendeki yönlendirmeye göre /api takısını ayarla
      final url = Uri.parse('http://10.0.2.2:8000/quiz_boss_result');

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "correct_count": correctCount,
          "total_questions": totalQuestions,
          "learned_words": targetWords,
          "target_language": targetLanguage,
          "lesson_id": lessonId, // Pydantic modelindeki isimle birebir aynı
        }),
      );

      if (response.statusCode == 200) {
        // İşlem başarılı! XP ve Level bilgilerini içeren JSON'ı geri döndür
        return jsonDecode(response.body);
      } else {
        print("🚨 Sunucu Hatası: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("🚨 Bağlantı Hatası: $e");
      return null;
    }
  }

  // --- XP EKLEME FONKSİYONU ---
  static Future<void> addXp(
    String username,
    String targetLanguage,
    int xpAmount,
    int sectionIndex,
    int lessonIndex,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(
          "http://10.0.2.2:8000/add_xp",
        ), // Eğer baseUrl değişkenin varsa "$baseUrl/add_xp" kullanabilirsin
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "username": username,
          "target_language":
              targetLanguage, // Python'un beklediği kritik parametre!
          "xp_amount": xpAmount,
          "section": sectionIndex, // 🌟 EKLENDİ (Haritadaki bölüm numarası)
          "lesson": lessonIndex,
        }),
      );

      if (response.statusCode == 200) {
        print("🟢 XP BAŞARIYLA EKLENDİ: +$xpAmount XP ($targetLanguage)");
      } else {
        print(
          "❌ XP Eklenemedi Hata Kodu: ${response.statusCode} - ${response.body}",
        );
      }
    } catch (e) {
      print("🚨 XP Ekleme Bağlantı Hatası: $e");
    }
  }

  // --- GÜNLÜK ROLEPLAY KİLİDİ KONTROLÜ ---
  static Future<bool> isRoleplayLocked(
    String username,
    String targetLanguage,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
          "http://10.0.2.2:8000/roleplay/check?username=$username&target_language=$targetLanguage",
        ),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data["is_locked"] ?? false;
      }
      return false;
    } catch (e) {
      print("Kilit Kontrol Hatası: $e");
      return false;
    }
  }

  // --- ROLEPLAY'İ TAMAMLANDI OLARAK İŞARETLE (KİLİTLE) ---
  static Future<void> markRoleplayDone(
    String username,
    String targetLanguage,
  ) async {
    try {
      await http.post(
        Uri.parse("http://10.0.2.2:8000/roleplay/mark_done"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "username": username,
          "target_language": targetLanguage,
        }),
      );
    } catch (e) {
      print("Kilitleme Hatası: $e");
    }
  }

  // --- HAFTALIK XP VERİSİNİ ÇEKME ---
  static Future<List<int>> fetchWeeklyXp(String userName) async {
    try {
      // baseUrl kendi projene göre ayarlı olmalı (örn: http://10.0.2.2:8000)
      final url = Uri.parse('http://10.0.2.2:8000/users/$userName/weekly-xp');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Python'dan gelen [150, 300, 50, ...] listesini Dart listesine çeviriyoruz
        return List<int>.from(data['weekly_xp'] ?? [0, 0, 0, 0, 0, 0, 0]);
      } else {
        print("Haftalık XP çekilemedi: ${response.statusCode}");
        return [0, 0, 0, 0, 0, 0, 0];
      }
    } catch (e) {
      print("Haftalık XP Hatası: $e");
      return [0, 0, 0, 0, 0, 0, 0];
    }
  }

  // --- ÖĞRENME MERKEZİ İSTATİSTİKLERİNİ ÇEKME ---
  static Future<Map<String, int>> fetchLearningStats(
    String userName,
    String targetLanguage,
  ) async {
    try {
      final url = Uri.parse(
        'http://10.0.2.2:8000/get_learning_stats/$userName?target_language=$targetLanguage',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          "total_words": data["total_words"] ?? 0,
          "learned_words": data["learned_words"] ?? 0,
          "mistake_count": data["mistake_count"] ?? 0,
          "unlearned_words": data["unlearned_words"] ?? 0,
        };
      } else {
        print("Öğrenme istatistikleri çekilemedi: ${response.statusCode}");
        return {
          "total_words": 0,
          "learned_words": 0,
          "mistake_count": 0,
          "unlearned_words": 0,
        };
      }
    } catch (e) {
      print("Öğrenme istatistikleri hatası: $e");
      return {
        "total_words": 0,
        "learned_words": 0,
        "mistake_count": 0,
        "unlearned_words": 0,
      };
    }
  }

  // --- ZAYIF NOKTALARI (HATALARI) ÇEKME ---

  static Future<List<dynamic>> fetchMistakeDetails(
    String userName,
    String targetLanguage, {
    String nativeLanguage = 'Turkish',
  }) async {
    try {
      final url =
          Uri.parse(
            'http://10.0.2.2:8000/get_mistake_details/$userName',
          ).replace(
            queryParameters: {
              'target_language': targetLanguage,
              'native_language': nativeLanguage,
            },
          );

      debugPrint(
        'MISTAKE DETAILS REQUEST → '
        'user=$userName, '
        'target=$targetLanguage, '
        'native=$nativeLanguage, '
        'url=$url',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(utf8.decode(response.bodyBytes));

        return data is List ? List<dynamic>.from(data) : <dynamic>[];
      }

      debugPrint(
        'Hatalar çekilemedi: '
        '${response.statusCode} - ${response.body}',
      );
    } catch (e) {
      debugPrint('Hata detayları servisi çöktü: $e');
    }

    return [];
  }

  // 🌟 Pratik Modu için tek soru çeken fonksiyon

  static Future<List<dynamic>> fetchPracticePuzzle({
    required int puzzleId,
    required String puzzleType,
    required String nativeLanguage,
    required String targetLanguage,
  }) async {
    try {
      final url = Uri.parse('http://10.0.2.2:8000/get_practice_puzzle').replace(
        queryParameters: {
          'puzzle_id': puzzleId.toString(),
          'puzzle_type': puzzleType,
          'native_language': nativeLanguage,
          'target_language': targetLanguage,
        },
      );

      debugPrint(
        'PRACTICE PUZZLE REQUEST → '
        'id=$puzzleId, '
        'type=$puzzleType, '
        'native=$nativeLanguage, '
        'target=$targetLanguage, '
        'url=$url',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(utf8.decode(response.bodyBytes));

        return data is List ? List<dynamic>.from(data) : <dynamic>[];
      }

      debugPrint(
        'Pratik sorusu API hatası: '
        '${response.statusCode} - ${response.body}',
      );
    } catch (e) {
      debugPrint('Pratik sorusu çekilemedi: $e');
    }

    return [];
  }

  // 🌟 DOĞRU BİLİNEN HATAYI VERİTABANINDAN SİLER
  static Future<void> resolveMistake({
    required String username,
    required int puzzleId,
    required String puzzleType,
  }) async {
    try {
      final url = Uri.parse('http://10.0.2.2:8000/resolve_mistake');
      await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "puzzle_id": puzzleId,
          "puzzle_type": puzzleType,
        }),
      );
      print("Hata başarıyla silindi!");
    } catch (e) {
      print("Hata silinirken bir sorun oluştu: $e");
    }
  }

  static Future<void> updateUserPreferences({
    required String username,
    required String targetLanguage,
  }) async {
    final url = Uri.parse('http://10.0.2.2:8000/update_preferences');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "target_language": targetLanguage,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Ayarlar kaydedilemedi");
    }
  }

  // Kullanıcının halihazırda öğrenmekte olduğu dilleri getirir
  static Future<List<String>> fetchUserLanguages(String username) async {
    try {
      final url = Uri.parse(
        'http://10.0.2.2:8000/get_user_languages/$username',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        // Gelen listeyi Flutter'ın anlayacağı List<String> formatına çevir
        return List<String>.from(data['languages']);
      }
    } catch (e) {
      print("Aktif diller çekilemedi: $e");
    }
    return [];
  }

  // 🌟 YENİ: Seviye Atlama İsteği
  static Future<void> upgradeLevel({
    required String username,
    required String targetLanguage,
    required String newLevel,
  }) async {
    try {
      await http.post(
        Uri.parse('http://10.0.2.2:8000/upgrade_level'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "target_language": targetLanguage,
          "new_level": newLevel,
        }),
      );
      print("Seviye başarıyla $newLevel olarak güncellendi!");
    } catch (e) {
      print("Seviye atlama hatası: $e");
    }
  }

  // --- ROLEPLAY İPUCU ÇEKME ---
  static Future<String> getChatHint(
    String topic,
    String targetLanguage,
    List<Map<String, String>> history,
    String nativeLanguage,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("http://10.0.2.2:8000/get_chat_hint"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "topic": topic,
          "target_language": targetLanguage,
          "history": history,
          "native_language": nativeLanguage,
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes))["hint"];
      }
    } catch (e) {
      print("İpucu hatası: $e");
    }
    return "Maybe you can say...";
  }

  // --- ÇEVİRİ ÇEKME ---
  static Future<String> translateText(
    String text, {
    String nativeLanguage = "Turkish",
  }) async {
    try {
      final response = await http.post(
        Uri.parse("http://10.0.2.2:8000/translate_text"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"text": text, "native_language": nativeLanguage}),
      );
      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes))["translation"];
      }
    } catch (e) {
      print("Çeviri hatası: $e");
    }
    return "Çeviri yapılamadı.";
  }

  // 🌟 YENİ: CAN SATIN ALMA FONKSİYONU
  static Future<Map<String, dynamic>> buyLives(
    String username,
    String targetLanguage,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/buy_lives'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "target_language": targetLanguage,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(
          response.body,
        ); // {"success": true/false, "message": "...", "new_xp": ...}
      }
      return {"success": false, "message": "Sunucu hatası!"};
    } catch (e) {
      return {"success": false, "message": "Bağlantı hatası!"};
    }
  }
}
