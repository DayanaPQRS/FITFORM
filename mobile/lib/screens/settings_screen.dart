import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/fitform_logo.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService();
  bool _isLoggingOut = false;

  // State Preferensi Notifikasi & Izin
  bool _pushNotifications = true;
  bool _workoutReminders = true;
  bool _bluetoothEnabled = true;
  bool _cameraPermission = true;

  Future<void> _handleLogout() async {
    setState(() => _isLoggingOut = true);
    try {
      await _authService.logout();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } finally {
      if (mounted) setState(() => _isLoggingOut = false);
    }
  }

  void _showPrivacyModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.charcoalSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.charcoalBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Privasi & Keamanan Data',
                  style: AppTypography.heading(fontSize: 18),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Privasi Anda adalah prioritas utama kami. Sesuai prinsip kerja FITFORM-AIoT:',
              style: AppTypography.subhead(fontSize: 13),
            ),
            const SizedBox(height: 14),
            _buildInfoBullet(
              'Pemrosesan Kamera On-Device',
              'Kamera ponsel hanya digunakan untuk inferensi MediaPipe Pose secara lokal di perangkat. Rekaman video mentah tidak pernah disimpan permanen atau diunggah ke server.',
            ),
            const SizedBox(height: 10),
            _buildInfoBullet(
              'Telemetri Sensor Terenkripsi',
              'Hanya hasil fusi ringkasan repetisi (sudut sendi, skor anomali, kalori) yang dikirim ke backend Laravel menggunakan protokol aman HTTPS.',
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showHelpModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.charcoalSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.charcoalBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bantuan & Dukungan',
                  style: AppTypography.heading(fontSize: 18),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoBullet(
              'Jarak Ideal Kamera',
              'Letakkan smartphone Anda pada jarak 1.5 hingga 3 meter dengan sudut pandang tubuh bagian atas terlihat jelas tanpa terhalang objek.',
            ),
            const SizedBox(height: 10),
            _buildInfoBullet(
              'Koneksi Smart Dumbbell',
              'Pastikan Bluetooth ponsel menyala dan modul ESP32-S3 dalam keadaan aktif sebelum memulai sesi latihan.',
            ),
            const SizedBox(height: 10),
            _buildInfoBullet(
              'Pusat Kebugaran Mitra',
              'Popeye Gym, Subang — Konsultasikan panduan teknik gerakan dengan instruktur bersertifikasi.',
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showAboutModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.charcoalSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.charcoalBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tentang FITFORM.',
                  style: AppTypography.heading(fontSize: 18),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'FITFORM adalah ekosistem kebugaran cerdas berbasis Fusi Sensor Wearable IMU (ESP32-S3 BLE) dan Estimasi Postur Tubuh (MediaPipe Pose) untuk validasi repetisi latihan angkat beban mandiri.',
              style: AppTypography.subhead(fontSize: 13),
            ),
            const SizedBox(height: 14),
            _buildInfoBullet('Pengembang', 'Kinetic Motion Team'),
            const SizedBox(height: 6),
            _buildInfoBullet('Mitra Pengujian', 'Popeye Gym, Subang'),
            const SizedBox(height: 6),
            _buildInfoBullet('Versi Sistem', 'FITFORM v1.0.0 (Release Candidate)'),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBullet(String title, String desc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.roboto(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.spinachGreenLight,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          desc,
          style: AppTypography.roboto(fontSize: 12, color: AppColors.textMuted, height: 1.4),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.charcoalBg,
      appBar: AppBar(
        backgroundColor: AppColors.charcoalSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textWhite, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pengaturan',
              style: AppTypography.heading(fontSize: 19),
            ),
            Text(
              'Sesuaikan FITFORM dengan kenyamanan Anda.',
              style: AppTypography.subhead(fontSize: 11, color: AppColors.textDim),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==========================================
              // 1. SECTION NOTIFIKASI
              // ==========================================
              Text(
                'NOTIFIKASI',
                style: AppTypography.roboto(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDim,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.charcoalSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.charcoalBorder),
                ),
                child: Column(
                  children: [
                    _buildSwitchTile(
                      icon: Icons.notifications_none_rounded,
                      title: 'Notifikasi Aplikasi',
                      subtitle: 'Pembaruan sesi latihan & ringkasan performa',
                      value: _pushNotifications,
                      onChanged: (val) => setState(() => _pushNotifications = val),
                    ),
                    const Divider(color: AppColors.charcoalBorder, height: 1, indent: 56),
                    _buildSwitchTile(
                      icon: Icons.calendar_today_outlined,
                      title: 'Pengingat Jadwal Latihan',
                      subtitle: 'Senin, Rabu, dan Jumat (17:00)',
                      value: _workoutReminders,
                      onChanged: (val) => setState(() => _workoutReminders = val),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ==========================================
              // 2. SECTION PERANGKAT & IZIN AKSES
              // ==========================================
              Text(
                'PERANGKAT & IZIN AKSES',
                style: AppTypography.roboto(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDim,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.charcoalSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.charcoalBorder),
                ),
                child: Column(
                  children: [
                    _buildSwitchTile(
                      icon: Icons.bluetooth_rounded,
                      title: 'Koneksi Bluetooth (BLE)',
                      subtitle: 'Sinkronisasi nirkabel ke Smart Dumbbell',
                      value: _bluetoothEnabled,
                      onChanged: (val) => setState(() => _bluetoothEnabled = val),
                    ),
                    const Divider(color: AppColors.charcoalBorder, height: 1, indent: 56),
                    _buildSwitchTile(
                      icon: Icons.camera_alt_outlined,
                      title: 'Izin Akses Kamera',
                      subtitle: 'Pelacakan 33 titik kerangka postur tubuh MediaPipe',
                      value: _cameraPermission,
                      onChanged: (val) => setState(() => _cameraPermission = val),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ==========================================
              // 3. SECTION TENTANG PENGALAMAN ANDA
              // ==========================================
              Text(
                'TENTANG PENGALAMAN ANDA',
                style: AppTypography.roboto(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDim,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.charcoalSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.charcoalBorder),
                ),
                child: Column(
                  children: [
                    _buildNavTile(
                      icon: Icons.security_outlined,
                      title: 'Privasi & Keamanan Data',
                      subtitle: 'Pemrosesan kamera lokal & kebijakan privasi',
                      onTap: _showPrivacyModal,
                    ),
                    const Divider(color: AppColors.charcoalBorder, height: 1, indent: 56),
                    _buildNavTile(
                      icon: Icons.help_outline_rounded,
                      title: 'Bantuan & Dukungan',
                      subtitle: 'Panduan penggunaan & kontak Popeye Gym',
                      onTap: _showHelpModal,
                    ),
                    const Divider(color: AppColors.charcoalBorder, height: 1, indent: 56),
                    _buildNavTile(
                      icon: Icons.info_outline_rounded,
                      title: 'Tentang FITFORM.',
                      subtitle: 'Ekosistem Smart Dumbbell & AIoT Pose',
                      onTap: _showAboutModal,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ==========================================
              // 4. TOMBOL KELUAR DARI AKUN (Logout)
              // ==========================================
              InkWell(
                onTap: _isLoggingOut ? null : _handleLogout,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF241618),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.warningRed.withOpacity(0.35),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _isLoggingOut
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.warningRedLight),
                            )
                          : const Icon(Icons.logout_rounded, color: AppColors.warningRedLight, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        'Keluar dari Akun',
                        style: AppTypography.roboto(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.warningRedLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 36),

              // ==========================================
              // 5. BRAND FOOTER (Sama persis dengan Profil)
              // ==========================================
              Center(
                child: Column(
                  children: [
                    const FitformLogo(
                      fontSize: 22,
                      letterSpacing: 2.0,
                      showIcon: false, // Tanpa icon dumbbell
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Latihan Lebih Cerdas. Gerakan Lebih Baik.',
                      style: AppTypography.roboto(
                        fontSize: 12,
                        color: AppColors.textDim,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'FITFORM 1.0.0 • AIoT Smart Dumbbell',
                      style: AppTypography.roboto(
                        fontSize: 11,
                        color: AppColors.textDim.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.charcoalElevated,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.spinachGreenLight, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.roboto(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textWhite,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.roboto(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: AppColors.spinachGreenLight,
            activeTrackColor: AppColors.spinachGreenBg,
            inactiveThumbColor: AppColors.textDim,
            inactiveTrackColor: AppColors.charcoalElevated,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildNavTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.charcoalElevated,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.spinachGreenLight, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.roboto(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textWhite,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.roboto(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textDim, size: 22),
          ],
        ),
      ),
    );
  }
}
