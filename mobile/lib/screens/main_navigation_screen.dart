import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/fitform_logo.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'settings_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final UserModel user;
  final int initialIndex;

  const MainNavigationScreen({
    super.key,
    required this.user,
    this.initialIndex = 0,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;
  late UserModel _currentUser;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _currentUser = widget.user;
  }

  void _onUserUpdated(UserModel updated) {
    setState(() {
      _currentUser = updated;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeScreen(user: _currentUser),
      _HistoryTab(user: _currentUser),
      _StatisticsTab(user: _currentUser),
      _DevicesTab(user: _currentUser),
      _ProfileTab(
        user: _currentUser,
        onUserUpdated: _onUserUpdated,
        onNavigateToTab: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.charcoalBg,
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.charcoalSurface,
          border: Border(
            top: BorderSide(color: AppColors.charcoalBorder, width: 1.0),
          ),
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            backgroundColor: AppColors.charcoalSurface,
            indicatorColor: AppColors.spinachGreenBg,
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppTypography.roboto(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.spinachGreenLight,
                );
              }
              return AppTypography.roboto(
                fontSize: 11,
                fontWeight: FontWeight.normal,
                color: AppColors.textDim,
              );
            }),
            iconTheme: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const IconThemeData(color: AppColors.spinachGreenLight, size: 24);
              }
              return const IconThemeData(color: AppColors.textDim, size: 22);
            }),
          ),
          child: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.fitness_center_outlined),
                selectedIcon: Icon(Icons.fitness_center_rounded),
                label: 'Latihan',
              ),
              NavigationDestination(
                icon: Icon(Icons.history_outlined),
                selectedIcon: Icon(Icons.history_rounded),
                label: 'Riwayat',
              ),
              NavigationDestination(
                icon: Icon(Icons.insights_outlined),
                selectedIcon: Icon(Icons.insights_rounded),
                label: 'Statistik',
              ),
              NavigationDestination(
                icon: Icon(Icons.bluetooth_outlined),
                selectedIcon: Icon(Icons.bluetooth_connected_rounded),
                label: 'Perangkat',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline_rounded),
                selectedIcon: Icon(Icons.person_rounded),
                label: 'Profil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// TAB 2: RIWAYAT SESI LATIHAN (History Tab)
// ==========================================
class _HistoryTab extends StatefulWidget {
  final UserModel user;
  const _HistoryTab({required this.user});

  @override
  State<_HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<_HistoryTab> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _sessions = [];

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() => _isLoading = true);
    final data = await _apiService.getWorkoutSessions();
    if (mounted) {
      setState(() {
        _sessions = data;
        _isLoading = false;
      });
    }
  }

  String _formatDuration(dynamic secs) {
    final int s = int.tryParse(secs.toString()) ?? 0;
    final m = s ~/ 60;
    final rem = s % 60;
    return '${m}m ${rem}s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.charcoalBg,
      appBar: AppBar(
        backgroundColor: AppColors.charcoalSurface,
        elevation: 0,
        title: Text(
          'Riwayat Latihan',
          style: AppTypography.heading(fontSize: 19),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.spinachGreenLight),
            onPressed: _loadSessions,
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.spinachGreen))
            : _sessions.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.fitness_center_outlined, size: 64, color: AppColors.charcoalBorder),
                          const SizedBox(height: 16),
                          Text(
                            'Belum Ada Riwayat Sesi',
                            style: AppTypography.bebasNeue(fontSize: 20, color: AppColors.textWhite),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Selesaikan latihan beban pertama Anda dengan validasi AIoT untuk melihat catatan di sini.',
                            textAlign: TextAlign.center,
                            style: AppTypography.roboto(fontSize: 12, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadSessions,
                    color: AppColors.spinachGreen,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                      itemCount: _sessions.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final s = _sessions[index];
                        final exerciseName = s['exercise']?['name'] ?? 'Latihan Dumbbell';
                        final date = s['started_at'] != null
                            ? s['started_at'].toString().split('T').first
                            : 'Hari ini';
                        final valid = s['total_reps_valid'] ?? 0;
                        final anomaly = s['total_reps_anomaly'] ?? 0;
                        final accuracy = double.tryParse(s['form_accuracy_percentage']?.toString() ?? '0') ?? 0.0;
                        final calories = double.tryParse(s['calories_burned']?.toString() ?? '0') ?? 0.0;

                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.charcoalSurface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.charcoalBorder),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    exerciseName.toString().toUpperCase(),
                                    style: AppTypography.bebasNeue(fontSize: 20, letterSpacing: 1.0),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: accuracy >= 80 ? AppColors.spinachGreenBg : AppColors.warningRedBg,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: accuracy >= 80 ? AppColors.spinachGreen : AppColors.warningRed,
                                      ),
                                    ),
                                    child: Text(
                                      '${accuracy.toStringAsFixed(0)}% AKURASI',
                                      style: AppTypography.roboto(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: accuracy >= 80 ? AppColors.spinachGreenLight : AppColors.warningRedLight,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tanggal: $date • Durasi: ${_formatDuration(s['duration_seconds'])}',
                                style: AppTypography.roboto(fontSize: 11, color: AppColors.textMuted),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildStatItem('REPETISI SAH', '$valid Reps', AppColors.spinachGreenLight),
                                  Container(width: 1, height: 20, color: AppColors.charcoalBorder),
                                  _buildStatItem('ANOMALI', '$anomaly Reps', AppColors.warningRedLight),
                                  Container(width: 1, height: 20, color: AppColors.charcoalBorder),
                                  _buildStatItem('KALORI MET', '${calories.toStringAsFixed(1)} kcal', Colors.orangeAccent),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: AppTypography.roboto(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textDim),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.bebasNeue(fontSize: 16, color: color),
        ),
      ],
    );
  }
}

// ==========================================
// TAB 3: STATISTIK & ANALITIK (Statistics Tab)
// ==========================================
class _StatisticsTab extends StatefulWidget {
  final UserModel user;
  const _StatisticsTab({required this.user});

  @override
  State<_StatisticsTab> createState() => _StatisticsTabState();
}

class _StatisticsTabState extends State<_StatisticsTab> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  Map<String, dynamic>? _stats;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    final data = await _apiService.getStatistics();
    if (mounted) {
      setState(() {
        _stats = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalSessions = _stats?['total_sessions'] ?? 0;
    final totalValidReps = _stats?['total_valid_reps'] ?? 0;
    final avgAccuracy = double.tryParse(_stats?['average_accuracy']?.toString() ?? '0') ?? 0.0;
    final totalCalories = double.tryParse(_stats?['total_calories_burned']?.toString() ?? '0') ?? 0.0;

    return Scaffold(
      backgroundColor: AppColors.charcoalBg,
      appBar: AppBar(
        backgroundColor: AppColors.charcoalSurface,
        elevation: 0,
        title: Text(
          'Statistik & Analitik',
          style: AppTypography.heading(fontSize: 19),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.spinachGreenLight),
            onPressed: _loadStats,
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.spinachGreen))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Kartu Rata-rata Akurasi Postur
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.charcoalSurface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.spinachGreen.withOpacity(0.5)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'RATA-RATA FORM ACCURACY SCORE',
                            style: AppTypography.roboto(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textMuted,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${avgAccuracy.toStringAsFixed(1)}%',
                            style: AppTypography.bebasNeue(
                              fontSize: 64,
                              color: AppColors.spinachGreenLight,
                            ),
                          ),
                          Text(
                            'Evaluasi stabilitas sudut siku dan ayunan torso secara kumulatif',
                            textAlign: TextAlign.center,
                            style: AppTypography.roboto(fontSize: 11, color: AppColors.textDim),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Grid 3 Kartu Metrik
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricCard(
                            label: 'TOTAL SESI',
                            value: '$totalSessions Sesi',
                            icon: Icons.fitness_center_rounded,
                            iconColor: AppColors.spinachGreenLight,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMetricCard(
                            label: 'REPETISI SAH',
                            value: '$totalValidReps Reps',
                            icon: Icons.check_circle_outline,
                            iconColor: AppColors.spinachGreenLight,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    _buildMetricCard(
                      label: 'TOTAL PENGELUARAN ENERGI (MET)',
                      value: '${totalCalories.toStringAsFixed(1)} kkal Terbakar',
                      icon: Icons.local_fire_department_rounded,
                      iconColor: Colors.orangeAccent,
                    ),

                    const SizedBox(height: 24),

                    // Kemitraan Popeye Gym
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.charcoalSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.charcoalBorder),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.verified_rounded, color: AppColors.spinachGreenLight, size: 28),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'POPEYE GYM SUBANG STANDARD',
                                  style: AppTypography.bebasNeue(fontSize: 16, letterSpacing: 1.0),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Data divalidasi dengan standar biomekanika bicep curl & shoulder press instruktur mitra.',
                                  style: AppTypography.roboto(fontSize: 11, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.charcoalSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.charcoalBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTypography.roboto(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDim,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTypography.bebasNeue(fontSize: 24, color: AppColors.textWhite),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// TAB 4: PERANGKAT SMART DUMBBELL (Devices Tab)
// ==========================================
class _DevicesTab extends StatefulWidget {
  final UserModel user;
  const _DevicesTab({required this.user});

  @override
  State<_DevicesTab> createState() => _DevicesTabState();
}

class _DevicesTabState extends State<_DevicesTab> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _devices = [];

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    setState(() => _isLoading = true);
    final data = await _apiService.getDevices();
    if (mounted) {
      setState(() {
        _devices = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.charcoalBg,
      appBar: AppBar(
        backgroundColor: AppColors.charcoalSurface,
        elevation: 0,
        title: Text(
          'Smart Dumbbell',
          style: AppTypography.heading(fontSize: 19),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.spinachGreenLight),
            onPressed: _loadDevices,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Kartu Status Koneksi Hardware Aktif
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.charcoalSurface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.spinachGreen.withOpacity(0.6), width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: AppColors.spinachGreenLight,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'ESP32-S3 BLE READY',
                              style: AppTypography.bebasNeue(
                                fontSize: 18,
                                color: AppColors.spinachGreenLight,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.spinachGreenBg,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.spinachGreen),
                          ),
                          child: Text(
                            'TERHUBUNG',
                            style: AppTypography.roboto(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.spinachGreenLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Smart Dumbbell Berbasis IMU MPU6050 & ESP32-S3 BLE 5.0 aktif mentransmisikan data 6-DOF (20–50 Hz).',
                      style: AppTypography.roboto(fontSize: 12, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildDeviceInfoItem('BATERAI', '88% (Li-Po 3.7V)', Icons.battery_charging_full_rounded),
                        _buildDeviceInfoItem('FIRMWARE', 'v1.0.4-AIoT', Icons.memory_rounded),
                        _buildDeviceInfoItem('SAMPLING', '50 Hz Stream', Icons.speed_rounded),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'DAFTAR PERANGKAT TERDAFTAR (SERVER)',
                style: AppTypography.bebasNeue(fontSize: 18, letterSpacing: 1.5),
              ),
              const SizedBox(height: 12),

              if (_isLoading)
                const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator(color: AppColors.spinachGreen)))
              else if (_devices.isEmpty)
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.charcoalSurface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.charcoalBorder),
                  ),
                  child: Center(
                    child: Text(
                      'Dumbbell fisik terhubung via simulasi lokal. Belum ada MAC address server permanen.',
                      textAlign: TextAlign.center,
                      style: AppTypography.roboto(fontSize: 12, color: AppColors.textMuted),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _devices.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final d = _devices[index];
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.charcoalSurface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.charcoalBorder),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.fitness_center, color: AppColors.spinachGreenLight),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  d['device_code'] ?? 'Dumbbell-01',
                                  style: AppTypography.roboto(fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'MAC: ${d['mac_address'] ?? 'N/A'} • FW: ${d['firmware_version'] ?? 'v1.0'}',
                                  style: AppTypography.roboto(fontSize: 11, color: AppColors.textDim),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.charcoalElevated,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              (d['status'] ?? 'active').toString().toUpperCase(),
                              style: AppTypography.roboto(fontSize: 10, color: AppColors.spinachGreenLight),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceInfoItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: AppColors.spinachGreenLight),
            const SizedBox(width: 4),
            Text(label, style: AppTypography.roboto(fontSize: 10, color: AppColors.textDim)),
          ],
        ),
        const SizedBox(height: 2),
        Text(value, style: AppTypography.roboto(fontSize: 11, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

// ==========================================
// TAB 5: PROFIL PENGGUNA (Profile Tab)
// ==========================================
class _ProfileTab extends StatefulWidget {
  final UserModel user;
  final ValueChanged<UserModel> onUserUpdated;
  final ValueChanged<int> onNavigateToTab;

  const _ProfileTab({
    required this.user,
    required this.onUserUpdated,
    required this.onNavigateToTab,
  });

  @override
  State<_ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<_ProfileTab> {
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();
  bool _isLoggingOut = false;
  bool _isDeleting = false;

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return 'U';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  // Modal Informasi Akun (Melihat & Mengubah Nama Akun)
  void _showAccountInfoModal() {
    final nameCtrl = TextEditingController(text: widget.user.name);
    final emailCtrl = TextEditingController(text: widget.user.email);
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.charcoalSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    'Informasi Akun',
                    style: AppTypography.heading(fontSize: 18),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildModalTextField(
                controller: nameCtrl,
                label: 'Nama Lengkap',
                icon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: 14),
              _buildModalTextField(
                controller: emailCtrl,
                label: 'Alamat Email',
                icon: Icons.alternate_email_rounded,
                enabled: false,
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.spinachGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: isSaving
                      ? null
                      : () async {
                          final newName = nameCtrl.text.trim();
                          if (newName.isEmpty) return;

                          setModalState(() => isSaving = true);
                          try {
                            await _apiService.updateProfile({'name': newName});
                            final updated = UserModel(
                              id: widget.user.id,
                              name: newName,
                              email: widget.user.email,
                              role: widget.user.role,
                              avatar: widget.user.avatar,
                              heightCm: widget.user.heightCm,
                              weightKg: widget.user.weightKg,
                            );
                            widget.onUserUpdated(updated);
                            if (!mounted) return;
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Informasi akun berhasil disimpan')),
                            );
                          } catch (e) {
                            setModalState(() => isSaving = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        },
                  child: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          'Simpan Perubahan',
                          style: AppTypography.roboto(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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

  // Modal Ganti Password
  void _showChangePasswordModal() {
    final currentPasswordCtrl = TextEditingController();
    final newPasswordCtrl = TextEditingController();
    final confirmPasswordCtrl = TextEditingController();
    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;
    bool isSaving = false;
    String? modalError;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.charcoalSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    'Ubah Kata Sandi',
                    style: AppTypography.heading(fontSize: 18),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              if (modalError != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.warningRedBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.warningRed),
                  ),
                  child: Text(
                    modalError!,
                    style: AppTypography.roboto(fontSize: 12, color: AppColors.warningRedLight),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              _buildModalTextField(
                controller: currentPasswordCtrl,
                label: 'Kata Sandi Saat Ini',
                icon: Icons.lock_outline_rounded,
                obscureText: obscureCurrent,
                suffixIcon: IconButton(
                  icon: Icon(
                    obscureCurrent ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                  onPressed: () => setModalState(() => obscureCurrent = !obscureCurrent),
                ),
              ),
              const SizedBox(height: 14),
              _buildModalTextField(
                controller: newPasswordCtrl,
                label: 'Kata Sandi Baru (Min. 8 Karakter)',
                icon: Icons.lock_reset_rounded,
                obscureText: obscureNew,
                suffixIcon: IconButton(
                  icon: Icon(
                    obscureNew ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                  onPressed: () => setModalState(() => obscureNew = !obscureNew),
                ),
              ),
              const SizedBox(height: 14),
              _buildModalTextField(
                controller: confirmPasswordCtrl,
                label: 'Konfirmasi Kata Sandi Baru',
                icon: Icons.check_circle_outline_rounded,
                obscureText: obscureConfirm,
                suffixIcon: IconButton(
                  icon: Icon(
                    obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                  onPressed: () => setModalState(() => obscureConfirm = !obscureConfirm),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.spinachGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: isSaving
                      ? null
                      : () async {
                          final current = currentPasswordCtrl.text;
                          final newPass = newPasswordCtrl.text;
                          final confirm = confirmPasswordCtrl.text;

                          if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
                            setModalState(() => modalError = 'Semua field wajib diisi.');
                            return;
                          }
                          if (newPass.length < 8) {
                            setModalState(() => modalError = 'Kata sandi baru minimal 8 karakter.');
                            return;
                          }
                          if (newPass != confirm) {
                            setModalState(() => modalError = 'Konfirmasi kata sandi tidak cocok.');
                            return;
                          }

                          setModalState(() {
                            isSaving = true;
                            modalError = null;
                          });

                          try {
                            await _apiService.changePassword(
                              currentPassword: current,
                              newPassword: newPass,
                              newPasswordConfirmation: confirm,
                            );
                            if (!mounted) return;
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: AppColors.spinachGreenDark,
                                content: Text('Kata sandi berhasil diperbarui'),
                              ),
                            );
                          } catch (e) {
                            setModalState(() {
                              isSaving = false;
                              modalError = e.toString().replaceAll('Exception: ', '');
                            });
                          }
                        },
                  child: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          'Perbarui Kata Sandi',
                          style: AppTypography.roboto(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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

  // Dialog Ubah Data Fisik (Tinggi & Berat Badan)
  void _showEditPhysicalStatsDialog() {
    final heightCtrl = TextEditingController(text: widget.user.heightCm?.toStringAsFixed(0) ?? '170');
    final weightCtrl = TextEditingController(text: widget.user.weightKg?.toStringAsFixed(0) ?? '68');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.charcoalSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  'Perbarui Data Fisik',
                  style: AppTypography.heading(fontSize: 18),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Parameter ini digunakan untuk kalkulasi akurat pembakaran kalori (formula MET).',
              style: AppTypography.subhead(fontSize: 12),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _buildModalTextField(
                    controller: heightCtrl,
                    label: 'Tinggi Badan (cm)',
                    icon: Icons.height_rounded,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildModalTextField(
                    controller: weightCtrl,
                    label: 'Berat Badan (kg)',
                    icon: Icons.monitor_weight_outlined,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.spinachGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async {
                  final h = double.tryParse(heightCtrl.text);
                  final w = double.tryParse(weightCtrl.text);
                  Navigator.pop(ctx);

                  try {
                    await _apiService.updateProfile({
                      if (h != null) 'height_cm': h,
                      if (w != null) 'weight_kg': w,
                    });
                    final updated = UserModel(
                      id: widget.user.id,
                      name: widget.user.name,
                      email: widget.user.email,
                      role: widget.user.role,
                      avatar: widget.user.avatar,
                      heightCm: h ?? widget.user.heightCm,
                      weightKg: w ?? widget.user.weightKg,
                    );
                    widget.onUserUpdated(updated);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Data fisik berhasil diperbarui')),
                    );
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                },
                child: Text(
                  'Simpan Perubahan',
                  style: AppTypography.roboto(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Dialog Konfirmasi Hapus Akun
  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.charcoalSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.warningRedLight, size: 24),
            const SizedBox(width: 10),
            Text(
              'Hapus Akun?',
              style: AppTypography.heading(fontSize: 18),
            ),
          ],
        ),
        content: Text(
          'Tindakan ini permanen. Seluruh data akun, riwayat sesi latihan, dan telemetri repetisi Anda akan dihapus selamanya dari server FITFORM.',
          style: AppTypography.roboto(fontSize: 13, color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Batal',
              style: AppTypography.roboto(color: AppColors.textMuted, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warningRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _isDeleting = true);
              try {
                await _apiService.deleteAccount();
                if (!mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              } catch (e) {
                if (!mounted) return;
                setState(() => _isDeleting = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Gagal menghapus akun: $e')),
                );
              }
            },
            child: const Text('Ya, Hapus Akun'),
          ),
        ],
      ),
    );
  }

  // Logout
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

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final initials = _getInitials(user.name);

    return Scaffold(
      backgroundColor: AppColors.charcoalBg,
      appBar: AppBar(
        backgroundColor: AppColors.charcoalSurface,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Profil Saya',
          style: AppTypography.heading(fontSize: 20),
        ),
        // Icon gear di pojok kanan sudah dihapus sesuai permintaan
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ==========================================
              // 1. TOP IDENTITY (Avatar Inisial, Nama, Email)
              // ==========================================
              Center(
                child: Container(
                  width: 86,
                  height: 86,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E2633),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.spinachGreen.withOpacity(0.5),
                      width: 2.0,
                    ),
                  ),
                  child: ClipOval(
                    child: user.avatar != null && user.avatar!.isNotEmpty
                        ? Image.network(
                            user.avatar!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Center(
                              child: Text(
                                initials,
                                style: AppTypography.heading(
                                  fontSize: 26,
                                  color: AppColors.textWhite,
                                ),
                              ),
                            ),
                          )
                        : Center(
                            child: Text(
                              initials,
                              style: AppTypography.heading(
                                fontSize: 26,
                                color: AppColors.textWhite,
                              ),
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              Text(
                user.name,
                textAlign: TextAlign.center,
                style: AppTypography.heading(fontSize: 22),
              ),
              const SizedBox(height: 3),
              Text(
                user.email,
                textAlign: TextAlign.center,
                style: AppTypography.subhead(fontSize: 13, color: AppColors.textMuted),
              ),

              const SizedBox(height: 24),

              // ==========================================
              // 2. SECTION: AKUN & KEAMANAN (Menyatu Termasuk Data Fisik)
              // ==========================================
              Text(
                'AKUN & KEAMANAN',
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
                    _buildSettingsTile(
                      icon: Icons.person_outline_rounded,
                      title: 'Informasi Akun',
                      subtitle: 'Detail nama lengkap & alamat email',
                      onTap: _showAccountInfoModal,
                    ),
                    const Divider(color: AppColors.charcoalBorder, height: 1, indent: 56),
                    _buildSettingsTile(
                      icon: Icons.monitor_weight_outlined,
                      title: 'Data Fisik Pengguna',
                      subtitle: '${user.heightCm?.toStringAsFixed(0) ?? "170"} cm • ${user.weightKg?.toStringAsFixed(0) ?? "68"} kg (Estimasi Kalori MET)',
                      onTap: _showEditPhysicalStatsDialog,
                    ),
                    const Divider(color: AppColors.charcoalBorder, height: 1, indent: 56),
                    _buildSettingsTile(
                      icon: Icons.lock_outline_rounded,
                      title: 'Ubah Kata Sandi',
                      subtitle: 'Perbarui kata sandi keamanan Anda',
                      onTap: _showChangePasswordModal,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ==========================================
              // 3. SECTION: PENGALAMAN TERHUBUNG
              // ==========================================
              Text(
                'PENGALAMAN TERHUBUNG',
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
                    _buildSettingsTile(
                      icon: Icons.bluetooth_rounded,
                      title: 'Smart Dumbbell',
                      subtitle: 'ESP32-S3 BLE • Sensor IMU 6-DOF',
                      onTap: () => widget.onNavigateToTab(3), // Berpindah ke tab Perangkat
                    ),
                    const Divider(color: AppColors.charcoalBorder, height: 1, indent: 56),
                    _buildSettingsTile(
                      icon: Icons.settings_outlined,
                      title: 'Pengaturan',
                      subtitle: 'Notifikasi, izin perangkat & info sistem',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ==========================================
              // 4. TOMBOL KELUAR & HAPUS AKUN
              // ==========================================
              // Tombol Logout Elegan Box
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

              const SizedBox(height: 14),

              // Tombol Hapus Akun Permanen
              Center(
                child: TextButton.icon(
                  onPressed: _isDeleting ? null : _confirmDeleteAccount,
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.textDim, size: 16),
                  label: Text(
                    'Hapus Akun Permanen',
                    style: AppTypography.roboto(
                      fontSize: 12,
                      color: AppColors.textDim,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 36),

              // ==========================================
              // 5. BRAND FOOTER (FITFORM. Tanpa Icon Dumbbell)
              // ==========================================
              Center(
                child: Column(
                  children: [
                    const FitformLogo(
                      fontSize: 22,
                      letterSpacing: 2.0,
                      showIcon: false,
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

  Widget _buildSettingsTile({
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

  Widget _buildModalTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    bool enabled = true,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.roboto(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscureText,
          enabled: enabled,
          keyboardType: keyboardType,
          style: AppTypography.roboto(
            color: enabled ? AppColors.textWhite : AppColors.textDim,
            fontSize: 13,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.textMuted, size: 18),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: AppColors.charcoalElevated,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.charcoalBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.charcoalBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.spinachGreen, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

