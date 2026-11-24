import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/fitform_logo.dart';
import '../widgets/google_logo.dart';
import 'main_navigation_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController(text: 'user@fitform.com');
  final TextEditingController _passwordController = TextEditingController();

  bool _isGoogleLoading = false;
  bool _isEmailLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Email dan password wajib diisi.';
      });
      return;
    }

    setState(() {
      _isEmailLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await _authService.loginWithEmail(email, password);
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => MainNavigationScreen(user: user),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isEmailLoading = false;
        });
      }
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() {
      _isGoogleLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await _authService.loginWithGoogle();
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => MainNavigationScreen(user: user),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      String message = e.toString().replaceAll('Exception: ', '');
      if (message.contains('User cancelled flow') || message.contains('UserCancelled')) {
        message = 'Autentikasi Google ditutup sebelum selesai.';
      }
      setState(() {
        _errorMessage = message;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
        });
      }
    }
  }

  void _showConfigDialog() async {
    final currentUrl = await _authService.getBackendUrl();
    final currentClientId = await _authService.getGoogleClientId();

    final urlController = TextEditingController(text: currentUrl);
    final clientIdController = TextEditingController(text: currentClientId);

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.charcoalSurface,
        title: Text(
          'PENGATURAN KONEKSI BACKEND & SSO',
          style: AppTypography.bebasNeue(fontSize: 18, color: AppColors.textWhite),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: urlController,
                style: AppTypography.roboto(fontSize: 13, color: AppColors.textWhite),
                decoration: InputDecoration(
                  labelText: 'Backend URL (Laravel)',
                  labelStyle: AppTypography.roboto(color: AppColors.textMuted),
                  hintText: 'http://192.168.1.47:8000',
                  hintStyle: AppTypography.roboto(color: AppColors.textDim),
                  helperText: 'Wi-Fi: 192.168.1.47:8000 | Emulator: 10.0.2.2:8000',
                  helperStyle: AppTypography.roboto(color: AppColors.textDim, fontSize: 11),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: clientIdController,
                style: AppTypography.roboto(fontSize: 13, color: AppColors.textWhite),
                decoration: InputDecoration(
                  labelText: 'Google Client ID',
                  labelStyle: AppTypography.roboto(color: AppColors.textMuted),
                  hintText: 'xxxx.apps.googleusercontent.com',
                  hintStyle: AppTypography.roboto(color: AppColors.textDim),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('BATAL', style: AppTypography.roboto(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.spinachGreen,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              await _authService.saveBackendUrl(urlController.text.trim());
              await _authService.saveGoogleClientId(clientIdController.text.trim());
              if (!ctx.mounted) return;
              Navigator.pop(ctx);
              scaffoldMessenger.showSnackBar(
                const SnackBar(content: Text('Pengaturan berhasil disimpan')),
              );
            },
            child: Text('SIMPAN', style: AppTypography.roboto(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isAnyLoading = _isEmailLoading || _isGoogleLoading;

    return Scaffold(
      backgroundColor: AppColors.charcoalBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.textMuted),
            tooltip: 'Pengaturan Koneksi',
            onPressed: _showConfigDialog,
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 16.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Brand Logo FITFORM. (Dengan titik)
                  const FitformLogo(
                    fontSize: 44,
                    letterSpacing: 4.0,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Smart Dumbbell & AI Pose Form Correction',
                    style: AppTypography.roboto(
                      fontSize: 12,
                      color: AppColors.textMuted,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Error Message Banner (Warning Red)
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.warningRedBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.warningRed),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: AppColors.warningRedLight, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: AppTypography.roboto(
                                color: AppColors.warningRedLight,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // 1. Email Field
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: AppTypography.roboto(color: AppColors.textWhite, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Email atau username',
                      hintStyle: AppTypography.roboto(color: AppColors.textDim),
                      prefixIcon: const Icon(Icons.person_outline, color: AppColors.textMuted, size: 20),
                      filled: true,
                      fillColor: AppColors.charcoalSurface,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.charcoalBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.charcoalBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.spinachGreen, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 2. Password Field
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: AppTypography.roboto(color: AppColors.textWhite, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Password',
                      hintStyle: AppTypography.roboto(color: AppColors.textDim),
                      prefixIcon: const Icon(Icons.key_outlined, color: AppColors.textMuted, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: AppColors.textMuted,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: AppColors.charcoalSurface,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.charcoalBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.charcoalBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.spinachGreen, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 3. Tombol "Masuk" (Natural Primary CTA)
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: isAnyLoading ? null : _handleEmailLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.spinachGreen,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isEmailLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              'Masuk',
                              style: AppTypography.roboto(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Divider "atau"
                  Row(
                    children: [
                      const Expanded(child: Divider(color: AppColors.charcoalBorder)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          'atau',
                          style: AppTypography.roboto(
                            fontSize: 12,
                            color: AppColors.textDim,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider(color: AppColors.charcoalBorder)),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // 4. "Masuk dengan Google" Button (Dengan Logo Resmi Google 4-Warna)
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: isAnyLoading ? null : _handleGoogleLogin,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textWhite,
                        side: const BorderSide(color: AppColors.charcoalBorder),
                        backgroundColor: AppColors.charcoalSurface,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isGoogleLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.spinachGreen),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const GoogleLogo(size: 20),
                                const SizedBox(width: 12),
                                Text(
                                  'Masuk dengan Google',
                                  style: AppTypography.roboto(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textWhite,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 5. Link Menuju Registrasi Akun Baru
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Belum memiliki akun? ',
                        style: AppTypography.roboto(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Daftar sekarang',
                          style: AppTypography.roboto(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.spinachGreenLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Helper footnote
                  Text(
                    'Akun Demo: user@fitform.com / user123 atau budi@example.com / password123',
                    textAlign: TextAlign.center,
                    style: AppTypography.roboto(
                      fontSize: 11,
                      color: AppColors.textDim,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
