import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/fitform_logo.dart';
import 'main_navigation_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService _authService = AuthService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _heightController = TextEditingController(text: '170');
  final TextEditingController _weightController = TextEditingController(text: '68');

  String _selectedGender = 'male';
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final height = double.tryParse(_heightController.text.trim());
    final weight = double.tryParse(_weightController.text.trim());

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        _errorMessage = 'Semua field wajib diisi.';
      });
      return;
    }

    if (password.length < 8) {
      setState(() {
        _errorMessage = 'Kata sandi minimal 8 karakter.';
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        _errorMessage = 'Konfirmasi kata sandi tidak cocok.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await _authService.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: confirmPassword,
        heightCm: height,
        weightKg: weight,
        gender: _selectedGender,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.spinachGreenDark,
          content: Text(
            'Selamat datang, ${user.name}! Akun berhasil dibuat.',
            style: AppTypography.roboto(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => MainNavigationScreen(user: user),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.charcoalBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textWhite, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 12.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Brand Logo FITFORM.
                  const Center(
                    child: FitformLogo(
                      fontSize: 36,
                      letterSpacing: 3.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Daftar Akun Baru',
                    textAlign: TextAlign.center,
                    style: AppTypography.heading(fontSize: 18),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Mulai latihan beban cerdas dengan validasi postur AI & Smart Dumbbell',
                    textAlign: TextAlign.center,
                    style: AppTypography.roboto(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Error Banner
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
                    const SizedBox(height: 18),
                  ],

                  // 1. Nama Lengkap
                  _buildTextField(
                    controller: _nameController,
                    label: 'Nama Lengkap',
                    hint: 'Contoh: Budi Santoso',
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 12),

                  // 2. Email
                  _buildTextField(
                    controller: _emailController,
                    label: 'Email',
                    hint: 'nama@domain.com',
                    icon: Icons.alternate_email,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),

                  // 3. Password
                  _buildTextField(
                    controller: _passwordController,
                    label: 'Kata Sandi (Min 8 Karakter)',
                    hint: '••••••••',
                    icon: Icons.lock_outline,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: AppColors.textMuted,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 4. Konfirmasi Password
                  _buildTextField(
                    controller: _confirmPasswordController,
                    label: 'Konfirmasi Kata Sandi',
                    hint: '••••••••',
                    icon: Icons.lock_reset_outlined,
                    obscureText: _obscureConfirmPassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: AppColors.textMuted,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Section Header: Parameter Antropometri
                  Text(
                    'PROFIL FISIK (UNTUK ESTIMASI KALORI MET)',
                    style: AppTypography.roboto(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDim,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Row Tinggi & Berat Badan
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _heightController,
                          label: 'Tinggi (cm)',
                          hint: '170',
                          icon: Icons.height,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          controller: _weightController,
                          label: 'Berat (kg)',
                          hint: '68',
                          icon: Icons.monitor_weight_outlined,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Jenis Kelamin Selector
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.charcoalSurface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.charcoalBorder),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Jenis Kelamin:',
                          style: AppTypography.roboto(fontSize: 12, color: AppColors.textMuted),
                        ),
                        Row(
                          children: [
                            Radio<String>(
                              value: 'male',
                              groupValue: _selectedGender,
                              activeColor: AppColors.spinachGreenLight,
                              onChanged: (val) => setState(() => _selectedGender = val!),
                            ),
                            Text('Pria', style: AppTypography.roboto(fontSize: 12)),
                            const SizedBox(width: 8),
                            Radio<String>(
                              value: 'female',
                              groupValue: _selectedGender,
                              activeColor: AppColors.spinachGreenLight,
                              onChanged: (val) => setState(() => _selectedGender = val!),
                            ),
                            Text('Wanita', style: AppTypography.roboto(fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Tombol Daftar
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleRegister,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.spinachGreen,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              'Daftar Sekarang',
                              style: AppTypography.roboto(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Navigasi Balik ke Login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Sudah memiliki akun? ',
                        style: AppTypography.roboto(fontSize: 12, color: AppColors.textMuted),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Text(
                          'Masuk di sini',
                          style: AppTypography.roboto(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.spinachGreenLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.roboto(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: AppTypography.roboto(color: AppColors.textWhite, fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.roboto(color: AppColors.textDim, fontSize: 13),
            prefixIcon: Icon(icon, color: AppColors.textMuted, size: 18),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: AppColors.charcoalSurface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
      ],
    );
  }
}
