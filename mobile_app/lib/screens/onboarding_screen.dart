import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'login_screen.dart';
// 🌟 ÇEVİRİ KÜTÜPHANESİ EKLENDİ
import '../l10n/app_localizations.dart';

class OnboardingPage {
  final String lottieAsset;
  final String title;
  final String subtitle;
  final Color accent;

  const OnboardingPage({
    required this.lottieAsset,
    required this.title,
    required this.subtitle,
    required this.accent,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 3; // Toplam sayfa sayısı

  late AnimationController _titleAnim;
  late Animation<Offset> _titleSlide;
  late Animation<double> _titleFade;

  @override
  void initState() {
    super.initState();
    _titleAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _titleAnim, curve: Curves.easeOutCubic));
    _titleFade = Tween<double>(begin: 0, end: 1).animate(_titleAnim);
    _titleAnim.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _titleAnim.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);

    _titleAnim.reset();
    _titleAnim.forward();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    } else {
      // Son sayfada → Auth ekranına geç
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, anim, __) => const LoginScreen(),
          transitionsBuilder: (_, anim, __, child) {
            return FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.05),
                  end: Offset.zero,
                ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🌟 ÇEVİRİ NESNESİNİ ÇAĞIRIYORUZ
    final l10n = AppLocalizations.of(context)!;

    // 🌟 SAYFALARI DİNAMİK OLARAK BURADA OLUŞTURUYORUZ
    final List<OnboardingPage> pages = [
      OnboardingPage(
        lottieAsset: 'assets/lottie/onboard1.json',
        title: l10n.onboard1Title,
        subtitle: l10n.onboard1Subtitle,
        accent: const Color(0xFF118AB2),
      ),
      OnboardingPage(
        lottieAsset: 'assets/lottie/onboard2.json',
        title: l10n.onboard2Title,
        subtitle: l10n.onboard2Subtitle,
        accent: const Color(0xFF06D6A0),
      ),
      OnboardingPage(
        lottieAsset: 'assets/lottie/onboard3.json',
        title: l10n.onboard3Title,
        subtitle: l10n.onboard3Subtitle,
        accent: const Color(0xFFFFD166),
      ),
    ];

    final page = pages[_currentPage];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: SafeArea(
        child: Column(
          children: [
            // ── Skip butonu ──
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _nextPage,
                child: Text(
                  l10n.skip, // 🌟 DİNAMİK YAPILDI
                  style: const TextStyle(
                    color: Color(0xFFADB5BD),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            // ── Lottie Animasyon ──
            Expanded(
              flex: 5,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: pages.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Lottie.asset(
                      pages[index].lottieAsset,
                      fit: BoxFit.contain,
                      // Hata durumunda placeholder
                      errorBuilder: (ctx, err, stack) =>
                          _lottiePlaceholder(index),
                    ),
                  );
                },
              ),
            ),

            // ── Dot Indicators ──
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(pages.length, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == i ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == i
                        ? pages[i]
                              .accent // Seçili sayfanın rengini aldık
                        : const Color(0xFFDEE2E6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),

            const SizedBox(height: 32),

            // ── Başlık & Açıklama (animasyonlu) ──
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: SlideTransition(
                  position: _titleSlide,
                  child: FadeTransition(
                    opacity: _titleFade,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          page.title, // 🌟 Zaten yukarıda dinamikleşti
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF073B4C),
                            height: 1.2,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          page.subtitle, // 🌟 Zaten yukarıda dinamikleşti
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF6C757D),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Next / Get Started Butonu ──
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: GestureDetector(
                onTap: _nextPage,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  height: 58,
                  decoration: BoxDecoration(
                    color: page.accent,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: page.accent.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      _currentPage == pages.length - 1
                          ? l10n
                                .letsStart // 🌟 DİNAMİK YAPILDI
                          : l10n.next, // 🌟 DİNAMİK YAPILDI
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Lottie dosyası yoksa gösterilen placeholder
  Widget _lottiePlaceholder(int index) {
    final icons = ['🌍', '💬', '📈'];
    return Center(
      child: Text(icons[index], style: const TextStyle(fontSize: 120)),
    );
  }
}
