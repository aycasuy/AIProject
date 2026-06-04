/*import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'chat_screen.dart';
import 'reading_screen.dart';
import 'vocabulary_screen.dart';
import 'placement_test_screen.dart';
import 'dart:ui';
import 'package:lottie/lottie.dart';
import 'pronunciation_screen.dart';
import 'listenspeak_screen.dart';
//import 'package:mobile_app/roleplay_screen.dart';

// ─────────────────────────────────────────
//  RENK SABİTLERİ
// ─────────────────────────────────────────
class AppColors {
  AppColors._();

  static const background = Color(0xFFFDF6EE);
  static const textDark = Color(0xFF2D1A08);
  static const textMid = Color(0xFFB07850);
  static const textLight = Color(0xFFC09878);
  static const orange = Color(0xFFF97316);
  static const orangeMid = Color(0xFFFB923C);
  static const amber = Color(0xFFFBBF24);
  static const streakOrange = Color(0xFFE06820);
  static const cardBg = Color(0x85FFFFFF);
  static const cardBorder = Color(0xD9FFFFFF);

  // Blob renkleri
  static const blob1 = Color(0xFFFBBF8A);
  static const blob2 = Color(0xFFF9A35A);
  static const blob3 = Color(0xFFFDE0C0);
  static const blob4 = Color(0xFFFFD4A8);

  // Bento ikon renkleri
  static const bentoBlue = Color(0xFF4ECBFF);
  static const bentoYellow = Color(0xFFFFD166);
  static const bentoPurple = Color(0xFFC77DFF);
  static const bentoGreen = Color(0xFF06D6A0);
  static const bentoRed = Color(0xFFFF6B6B);
}

class S {
  S._();
  static late double _scale;
  static late double _textScale;

  static void init(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    _scale = (w / 360).clamp(0.85, 1.25);
    _textScale = (w / 360).clamp(0.85, 1.15);
  }

  static double dp(double v) => v * _scale;
  static double sp(double v) => v * _textScale;
}

class HomeScreen extends StatefulWidget {
  final String username;
  final String selectedLanguage;

  const HomeScreen({
    super.key,
    required this.username,
    required this.selectedLanguage,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  // ── Veritabanı değişkenleri ──
  String _level = '...';
  int _xp = 0;
  int _streak = 0;
  bool _isLoading = true;

  // ── Sayfa açılınca otomatik çalışır ──
  @override
  void initState() {
    super.initState();
    _fetchUserStats();
  }

  // ── Python API'den gerçek verileri çeker ──
  Future<void> _fetchUserStats() async {
    try {
      // DİKKAT: Buradaki URL'yi kendi Python API adresine göre düzenle
      // Örn: 'http://10.0.2.2:8000/get_user_stats/${widget.username}'
      final url = Uri.parse(
        'http://10.0.2.2:8000/get_user_stats/${widget.username}',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));

        if (mounted) {
          setState(() {
            // Veritabanından gelen GERÇEK değerleri değişkenlere ata!
            _level = data['level'] ?? 'A1';
            _xp = data['xp_score'] ?? 0;
            _streak = data['streak'] ?? 0;
            _isLoading = false; // Yükleme bitti!
          });
        }
      }
    } catch (e) {
      print("Veri çekme hatası: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    S.init(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: Stack(
        children: [
          // Katman 1: Arka plan
          const _MeshBackground(),

          // Katman 2: Ana içerik
          SafeArea(
            bottom: false,
            child: _isLoading
                ? const _LoadingView()
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: S.dp(24)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: S.dp(12)),
                        _buildHeader(),
                        SizedBox(height: S.dp(24)),
                        _buildMascotAndStats(),
                        SizedBox(height: S.dp(32)),
                        _buildHeroLessonCard(),
                        SizedBox(height: 32),
                        Text(
                          'Bugün ne öğreniyoruz?',
                          style: TextStyle(
                            fontSize: S.sp(20),
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                            letterSpacing: -.5,
                          ),
                        ),
                        SizedBox(height: S.dp(16)),
                        _buildBentoGrid(context),
                        SizedBox(height: S.dp(100)),
                      ],
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: const _BottomNav(),
    );
  }

  // ── Üst başlık: kullanıcı adı + bildirim ──
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hoş geldin,',
              style: TextStyle(
                fontSize: S.sp(13),
                color: AppColors.textMid,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: S.dp(2)),
            Text(
              widget.username,
              style: TextStyle(
                fontSize: S.sp(26),
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
                height: 1.1,
              ),
            ),
          ],
        ),

        ClipRRect(
          borderRadius: BorderRadius.circular(S.dp(16)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: EdgeInsets.all(S.dp(12)),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.55),
                borderRadius: BorderRadius.circular(S.dp(16)),
                border: Border.all(
                  color: AppColors.orange.withOpacity(.25),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.notifications_outlined,
                color: AppColors.textDark,
                size: S.dp(22),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Maskot + XP kartı ──
  Widget _buildMascotAndStats() {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: SizedBox(
            height: S.dp(160),
            child: Center(child: Lottie.asset('assets/lottie/airobot.json')),
          ),
        ),
        SizedBox(width: S.dp(16)),

        Expanded(
          flex: 5,
          child: _GlassCard(
            padding: EdgeInsets.all(S.dp(18)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Streak
                Row(
                  children: [
                    Text('🔥', style: TextStyle(fontSize: S.sp(22))),
                    SizedBox(width: S.dp(6)),
                    Text(
                      '$_streak Gün',
                      style: TextStyle(
                        fontSize: S.sp(17),
                        fontWeight: FontWeight.w800,
                        color: AppColors.streakOrange,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: S.dp(14)),
                // Seviye etiketi
                Text(
                  'Seviye $_level',
                  style: TextStyle(
                    fontSize: S.sp(13),
                    fontWeight: FontWeight.w600,
                    color: AppColors.orange,
                  ),
                ),
                SizedBox(height: S.dp(4)),
                // XP değeri
                Text(
                  '$_xp / 1000 XP',
                  style: TextStyle(
                    fontSize: S.sp(22),
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                  ),
                ),
                SizedBox(height: S.dp(10)),
                // Animasyonlu XP bar
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: ((_xp % 1000) / 1000.0)),
                  duration: const Duration(milliseconds: 1400),
                  curve: Curves.easeOutCubic,
                  builder: (_, val, __) => ClipRRect(
                    borderRadius: BorderRadius.circular(S.dp(10)),
                    child: LinearProgressIndicator(
                      value: val,
                      minHeight: S.dp(8),
                      backgroundColor: AppColors.orange.withOpacity(.12),
                      valueColor: const AlwaysStoppedAnimation(
                        AppColors.orange,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: S.dp(4)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Bugünkü ders hero kartı ──
  Widget _buildHeroLessonCard() {
    return _GlassCard(
      padding: EdgeInsets.all(S.dp(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _LiveTag(label: 'Bugünkü Ders'),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: S.dp(12),
                  vertical: S.dp(5),
                ),
                decoration: BoxDecoration(
                  color: AppColors.amber.withOpacity(.15),
                  borderRadius: BorderRadius.circular(S.dp(22)),
                  border: Border.all(
                    color: AppColors.amber.withOpacity(.35),
                    width: 1,
                  ),
                ),
                child: Text(
                  '+80 XP',
                  style: TextStyle(
                    fontSize: S.sp(12),
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFB45309),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: S.dp(16)),
          // Dil bayrağı + başlık
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('🇹🇷', style: TextStyle(fontSize: S.sp(34))),
              SizedBox(width: S.dp(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Café & Restoran',
                      style: TextStyle(
                        fontSize: S.sp(22),
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                        height: 1.15,
                      ),
                    ),
                    SizedBox(height: S.dp(6)),
                    Text(
                      'Sipariş ver · Tavsiye iste · Ödeme yap',
                      style: TextStyle(
                        fontSize: S.sp(12),
                        color: AppColors.textMid,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: S.dp(16)),
          // Meta pill'ler: süre + seviye
          Wrap(
            spacing: S.dp(8),
            runSpacing: S.dp(8),
            children: [
              _MetaPill(label: '⏱ 12 dakika'),
              _MetaPill(label: '🎯 Başlangıç Seviye'),
            ],
          ),
          SizedBox(height: S.dp(18)),
          // Derse Başla butonu
          GestureDetector(
            onTap: () async {
              // ALT MENÜ YOK! DOĞRUDAN YAPAY ZEKANIN KUCAĞINA ATLIYORUZ!
              /* await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatRoleplayScreen(
                    username: widget.username,
                    targetLanguage: widget.selectedLanguage,
                    userLevel: _level,
                    scenario: "AUTO", // 👈 SİHİRLİ KELİME: AUTO!
                  ),
                ),
              );
             */
              _fetchUserStats();
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: S.dp(15)),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(S.dp(18)),
                gradient: const LinearGradient(
                  colors: [
                    AppColors.orange,
                    AppColors.orangeMid,
                    AppColors.amber,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.orange.withOpacity(.35),
                    blurRadius: S.dp(24),
                    offset: Offset(0, S.dp(8)),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'Derse Başla →',
                  style: TextStyle(
                    fontSize: S.sp(15),
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: .3,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Bento grid: özellikler ──
  Widget _buildBentoGrid(BuildContext context) {
    return Column(
      children: [
        // Üst ikili
        Row(
          children: [
            Expanded(
              child: _BentoItem(
                title: 'AI Öğretmen',
                subtitle: 'Sohbet Et',
                icon: '🤖',
                color: AppColors.bentoBlue,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ChatScreen(targetLanguage: widget.selectedLanguage),
                    ),
                  );
                  _fetchUserStats();
                },
              ),
            ),
            SizedBox(width: S.dp(14)),
            Expanded(
              child: _BentoItem(
                title: 'Seviye Analizi',
                subtitle: 'Test Çöz',
                icon: '📊',
                color: AppColors.bentoYellow,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PlacementTestScreen(
                        username: widget.username,
                        targetLanguage: widget.selectedLanguage,
                      ),
                    ),
                  );
                  _fetchUserStats();
                },
              ),
            ),
          ],
        ),
        SizedBox(height: S.dp(14)),
        _BentoItem(
          title: 'Kelime Avı',
          subtitle: 'Gerçek metinler oku ve test çöz',
          icon: '🦊',
          color: AppColors.bentoPurple,
          isWide: true,
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ReadingScreen(
                  username: widget.username,
                  targetLanguage: widget.selectedLanguage,
                ),
              ),
            );
            _fetchUserStats();
          },
        ),
        SizedBox(height: S.dp(14)),
        _BentoItem(
          title: 'Kelime Kumbaram',
          subtitle: 'Öğrendiklerini tekrar et',
          icon: '💎',
          color: AppColors.bentoGreen,
          isWide: true,
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => VocabularyScreen(username: widget.username),
              ),
            );
            _fetchUserStats();
          },
        ),
        SizedBox(height: S.dp(14)),
        _BentoItem(
          title: 'Telaffuz Koçu',
          subtitle: 'Yapay zeka ile konuşma pratiği yap',
          icon: '🎙️',
          color: AppColors.bentoRed,
          isWide: true,
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PronunciationScreen(
                  username: widget.username,
                  targetLanguage: widget.selectedLanguage,
                  userLevel: _level,
                  targetWords: widget.targetWords,
                ),
              ),
            );
            _fetchUserStats();
          },
        ),
        SizedBox(height: S.dp(14)),
        _BentoItem(
          title: 'Dinleme Koçu',
          subtitle: 'Duyduğunu anlama ve yazma',
          icon: '🎧',
          color: AppColors.bentoBlue,
          isWide: true,
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ListeningScreen(
                  username: widget.username,
                  targetLanguage: widget.selectedLanguage,
                  userLevel: _level,
                ),
              ),
            );
            _fetchUserStats();
          },
        ),
      ],
    );
  }
}

class _MeshBackground extends StatelessWidget {
  const _MeshBackground();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          Container(color: AppColors.background),
          _Blob(
            color: AppColors.blob1,
            size: S.dp(260),
            top: S.dp(-70),
            left: S.dp(-70),
            opacity: .55,
          ),
          _Blob(
            color: AppColors.blob2,
            size: S.dp(200),
            top: S.dp(100),
            right: S.dp(-60),
            opacity: .35,
          ),
          _Blob(
            color: AppColors.blob3,
            size: S.dp(220),
            bottom: S.dp(120),
            left: S.dp(-50),
            opacity: .60,
          ),
          _Blob(
            color: AppColors.blob4,
            size: S.dp(150),
            bottom: S.dp(240),
            right: S.dp(-25),
            opacity: .50,
          ),
          Container(color: AppColors.background.withOpacity(.42)),
        ],
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  final Color color;
  final double size;
  final double? top, left, right, bottom;
  final double opacity;

  const _Blob({
    required this.color,
    required this.size,
    this.top,
    this.left,
    this.right,
    this.bottom,
    this.opacity = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 55, sigmaY: 55),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(opacity),
          ),
        ),
      ),
    );
  }
}

class _BentoItem extends StatelessWidget {
  final String title, subtitle, icon;
  final Color color;
  final bool isWide;
  final VoidCallback onTap;

  const _BentoItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.isWide = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: _GlassCard(
        padding: EdgeInsets.all(S.dp(18)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // İkon kutusu
                Container(
                  padding: EdgeInsets.all(S.dp(12)),
                  decoration: BoxDecoration(
                    color: color.withOpacity(.15),
                    borderRadius: BorderRadius.circular(S.dp(16)),
                    border: Border.all(color: color.withOpacity(.25), width: 1),
                  ),
                  child: Text(icon, style: TextStyle(fontSize: S.sp(22))),
                ),
                Icon(
                  Icons.arrow_outward_rounded,
                  color: AppColors.textLight,
                  size: S.dp(18),
                ),
              ],
            ),
            SizedBox(height: isWide ? S.dp(14) : S.dp(24)),
            Text(
              title,
              style: TextStyle(
                fontSize: S.sp(17),
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            SizedBox(height: S.dp(4)),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: S.sp(12),
                color: AppColors.textMid,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
//  BOTTOM NAV
// ─────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  const _BottomNav();

  static const _items = [
    _NavItem(icon: '🏠', label: 'Ana Sayfa', active: true),
    _NavItem(icon: '🗺', label: 'Yolculuk'),
    _NavItem(icon: '🏆', label: 'Sıralama'),
    _NavItem(icon: '👤', label: 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.background.withOpacity(.8),
            border: Border(
              top: BorderSide(
                color: AppColors.textMid.withOpacity(.14),
                width: .5,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: S.dp(10)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _items
                    .map((item) => _NavItemWidget(item: item))
                    .toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final String icon, label;
  final bool active;
  const _NavItem({
    required this.icon,
    required this.label,
    this.active = false,
  });
}

class _NavItemWidget extends StatelessWidget {
  final _NavItem item;
  const _NavItemWidget({required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(item.icon, style: TextStyle(fontSize: S.sp(20))),
        SizedBox(height: S.dp(4)),
        Text(
          item.label,
          style: TextStyle(
            fontSize: S.sp(10),
            color: item.active ? AppColors.streakOrange : AppColors.textLight,
            fontWeight: item.active ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        if (item.active) ...[
          SizedBox(height: S.dp(4)),
          Container(
            width: S.dp(20),
            height: S.dp(3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              gradient: const LinearGradient(
                colors: [AppColors.orange, AppColors.amber],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────
//  YARDIMCI WİDGET'LAR
// ─────────────────────────────────────────

// Glassmorphism kart — tüm kartlarda kullanılır
class _GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double? borderRadius;

  const _GlassCard({
    required this.child,
    required this.padding,
    // ignore: unused_element_parameter
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final r = borderRadius ?? S.dp(24);
    return ClipRRect(
      borderRadius: BorderRadius.circular(r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(r),
            border: Border.all(color: AppColors.cardBorder, width: 1),
          ),
          child: child,
        ),
      ),
    );
  }
}

// Yükleniyor ekranı
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: AppColors.orange,
        strokeWidth: 2.5,
      ),
    );
  }
}

// Yanıp sönen "Bugünkü Ders" etiketi
class _LiveTag extends StatefulWidget {
  final String label;
  const _LiveTag({required this.label});

  @override
  State<_LiveTag> createState() => _LiveTagState();
}

class _LiveTagState extends State<_LiveTag>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _fade = Tween<double>(
      begin: 1,
      end: .2,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: S.dp(12), vertical: S.dp(5)),
      decoration: BoxDecoration(
        color: AppColors.orange.withOpacity(.1),
        borderRadius: BorderRadius.circular(S.dp(22)),
        border: Border.all(color: AppColors.orange.withOpacity(.25), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FadeTransition(
            opacity: _fade,
            child: Container(
              width: S.dp(6),
              height: S.dp(6),
              decoration: const BoxDecoration(
                color: Color(0xFFEA6010),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SizedBox(width: S.dp(6)),
          Text(
            widget.label.toUpperCase(),
            style: TextStyle(
              fontSize: S.sp(11),
              fontWeight: FontWeight.w600,
              color: const Color(0xFFEA6010),
              letterSpacing: .5,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  final String label;
  const _MetaPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: S.dp(12), vertical: S.dp(5)),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.65),
        borderRadius: BorderRadius.circular(S.dp(22)),
        border: Border.all(color: AppColors.textMid.withOpacity(.2), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: S.sp(12), color: AppColors.textMid),
      ),
    );
  }
}
*/
