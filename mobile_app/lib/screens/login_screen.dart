import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../painters/bubble_painter.dart';
//import 'home_screen.dart';
import 'language_selection_screen.dart';
// 🌟 ÇEVİRİ KÜTÜPHANESİ EKLENDİ
import '../l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  late AnimationController _bgController;
  late AnimationController _logoController;
  late AnimationController _slideController;

  late Animation<double> _logoFloat;
  late Animation<double> _logoScale;
  late Animation<double> _slideAnim;

  // ── State ──
  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePass = true;

  // ── Form ──
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _logoFloat = Tween<double>(begin: -6, end: 6).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );
    _logoScale = Tween<double>(begin: 1.0, end: 1.07).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _slideAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void dispose() {
    _bgController.dispose();
    _logoController.dispose();
    _slideController.dispose();
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _toggle() async {
    await _slideController.forward();
    setState(() => _isLogin = !_isLogin);
    await _slideController.reverse();
  }

  void _handleSubmit() async {
    final l10n = AppLocalizations.of(
      context,
    )!; // 🌟 Hata mesajları için eklendi

    final username = _usernameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final password = _passCtrl.text.trim();

    if (username.isEmpty || password.isEmpty || (!_isLogin && email.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.fillAllFields)), // 🌟 DİNAMİK YAPILDI
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        // --- GİRİŞ YAP (LOGIN) ---
        final url = Uri.parse('http://10.0.2.2:8000/login');
        final response = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"username": username, "password": password}),
        );

        if (response.statusCode == 200) {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => LanguageSelectionScreen(username: username),
            ),
          );
        } else {
          final errorData = jsonDecode(utf8.decode(response.bodyBytes));
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Hata: ${errorData['detail']}")),
          );
        }
      } else {
        // --- KAYIT OL (REGISTER) ---
        final url = Uri.parse('http://10.0.2.2:8000/register');
        final response = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "username": username,
            "email": email,
            "password": password,
          }),
        );

        if (response.statusCode == 200) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.registerSuccess),
              backgroundColor: Colors.teal,
            ),
          );
          _toggle(); // Başarılıysa otomatik giriş ekranına kaydır
          _passCtrl.clear();
        } else {
          final errorData = jsonDecode(utf8.decode(response.bodyBytes));
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Hata: ${errorData['detail']}")),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.connectionError)));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showComingSoon(String provider) {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n.comingSoon(provider),
        ), // 🌟 DİNAMİK YAPILDI (Parametreli)
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF073B4C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _bgController,
          _logoController,
          _slideController,
        ]),
        builder: (context, _) {
          return Stack(
            children: [
              CustomPaint(
                painter: BubblePainter(_bgController.value),
                size: MediaQuery.of(context).size,
              ),
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFF8F9FF), Color(0xFFEEF2FF)],
                  ),
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 28),
                    Transform.translate(
                      offset: Offset(0, _logoFloat.value),
                      child: Transform.scale(
                        scale: _logoScale.value,
                        child: _buildLogo(),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Expanded(
                      child: _isLoading
                          ? _buildShimmerCard()
                          : _buildFormCard(),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLogo() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF118AB2).withValues(alpha: 0.22),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Center(
            child: Text('🌍', style: TextStyle(fontSize: 40)),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Lingua',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: Color(0xFF073B4C),
            letterSpacing: -1,
          ),
        ),
        Text(
          l10n.loginSubtitle,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF6C757D),
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF073B4C).withValues(alpha: 0.07),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Shimmer.fromColors(
        baseColor: const Color(0xFFE9ECEF),
        highlightColor: const Color(0xFFF8F9FF),
        period: const Duration(milliseconds: 1200),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sBox(double.infinity, 48, r: 16),
            const SizedBox(height: 28),
            _sBox(60, 12, r: 4),
            const SizedBox(height: 8),
            _sBox(double.infinity, 52, r: 14),
            const SizedBox(height: 20),
            _sBox(70, 12, r: 4),
            const SizedBox(height: 8),
            _sBox(double.infinity, 52, r: 14),
            const SizedBox(height: 24),
            _sBox(double.infinity, 56, r: 18),
          ],
        ),
      ),
    );
  }

  Widget _sBox(double w, double h, {double r = 8}) {
    return Container(
      width: w == double.infinity ? double.infinity : w,
      height: h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(r),
      ),
    );
  }

  Widget _buildFormCard() {
    final l10n = AppLocalizations.of(context)!;

    return AnimatedOpacity(
      opacity: _slideAnim.value < 0.5
          ? 1 - _slideAnim.value * 2
          : (_slideAnim.value - 0.5) * 2,
      duration: Duration.zero,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF073B4C).withValues(alpha: 0.07),
              blurRadius: 40,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTabSwitcher(),
              const SizedBox(height: 24),

              // Username her iki durumda da görünür
              _buildTextField(
                ctrl: _usernameCtrl,
                label: l10n.username,
                icon: Icons.person_outline_rounded,
                hint: 'username',
              ),
              const SizedBox(height: 14),

              // Sadece Register (Kayıt) durumunda Email görünür
              AnimatedSize(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOutCubic,
                child: _isLogin
                    ? const SizedBox.shrink()
                    : Column(
                        children: [
                          _buildTextField(
                            ctrl: _emailCtrl,
                            label: l10n.email,
                            icon: Icons.email_outlined,
                            hint: 'your@email.com',
                            type: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 14),
                        ],
                      ),
              ),

              _buildTextField(
                ctrl: _passCtrl,
                label: l10n.password,
                icon: Icons.lock_outline_rounded,
                hint: '••••••••',
                obscure: _obscurePass,
                suffix: IconButton(
                  icon: Icon(
                    _obscurePass
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: const Color(0xFF6C757D),
                    size: 19,
                  ),
                  onPressed: () => setState(() => _obscurePass = !_obscurePass),
                ),
              ),

              if (_isLogin)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      l10n.forgotPassword,
                      style: TextStyle(
                        color: Color(0xFF118AB2),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
              else
                const SizedBox(height: 20),

              GestureDetector(
                onTap: _handleSubmit,
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF118AB2), Color(0xFF06D6A0)],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF118AB2).withValues(alpha: 0.38),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      _isLogin ? l10n.signInBtn : l10n.signUpBtn,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  const Expanded(child: Divider(color: Color(0xFFE9ECEF))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      l10n.or,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFADB5BD),
                      ),
                    ),
                  ),
                  const Expanded(child: Divider(color: Color(0xFFE9ECEF))),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  _socialBtn(
                    label: 'G',
                    foregroundColor: const Color(0xFFEA4335),
                    backgroundColor: const Color(0xFFFFF4F2),
                    borderColor: const Color(0xFFFFD7D0),
                    onTap: () => _showComingSoon("Google"),
                  ),
                  const SizedBox(width: 10),
                  _socialBtn(
                    label: 'in',
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFF0A66C2),
                    borderColor: const Color(0xFF0A66C2),
                    onTap: () => _showComingSoon("LinkedIn"),
                  ),
                  const SizedBox(width: 10),
                  _socialBtn(
                    label: '',
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.black,
                    borderColor: Colors.black,
                    onTap: () => _showComingSoon("Apple"),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              Center(
                child: GestureDetector(
                  onTap: _toggle,
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6C757D),
                      ),
                      children: [
                        TextSpan(
                          text: _isLogin ? l10n.noAccount : l10n.haveAccount,
                        ),
                        TextSpan(
                          text: _isLogin ? l10n.signUp : l10n.signIn,
                          style: const TextStyle(
                            color: Color(0xFF118AB2),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabSwitcher() {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F5),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOutCubic,
            alignment: _isLogin ? Alignment.centerLeft : Alignment.centerRight,
            child: Container(
              width: (MediaQuery.of(context).size.width - 40 - 56) / 2,
              height: 38,
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.07),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _isLogin ? null : _toggle,
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 250),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: _isLogin
                            ? const Color(0xFF073B4C)
                            : const Color(0xFF6C757D),
                      ),
                      child: Text(l10n.signIn),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: _isLogin ? _toggle : null,
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 250),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: !_isLogin
                            ? const Color(0xFF073B4C)
                            : const Color(0xFF6C757D),
                      ),
                      child: Text(l10n.signUp),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController ctrl,
    required String label,
    required IconData icon,
    required String hint,
    TextInputType type = TextInputType.text,
    bool obscure = false,
    Widget? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFF073B4C),
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FF),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: const Color(0xFFE9ECEF)),
          ),
          child: TextField(
            controller: ctrl,
            keyboardType: type,
            obscureText: obscure,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF073B4C),
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: Color(0xFFADB5BD),
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Icon(icon, color: const Color(0xFF118AB2), size: 19),
              suffixIcon: suffix,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ),
      ],
    );
  }

  Widget _socialBtn({
    required String label,
    required Color foregroundColor,
    required Color backgroundColor,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 48,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: borderColor, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: backgroundColor.withValues(alpha: 0.22),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: foregroundColor,
                fontWeight: FontWeight.w900,
                fontSize: label == '' ? 23 : 15,
                letterSpacing: label == 'in' ? -0.4 : 0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
