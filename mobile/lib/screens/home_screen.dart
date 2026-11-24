import 'package:flutter/material.dart';
import '../models/exercise_model.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/fitform_logo.dart';
import 'workout_screen.dart';

class HomeScreen extends StatefulWidget {
  final UserModel user;

  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _exerciseSectionKey = GlobalKey();
  final TextEditingController _searchController = TextEditingController();

  List<ExerciseModel> _exercises = ExerciseModel.defaultExercises;
  bool _isLoadingExercises = true;
  String _selectedCategory = 'Semua';
  String _searchQuery = '';

  final List<String> _categories = const [
    'Semua',
    'Lengan',
    'Bahu',
    'Punggung',
    'Dada',
  ];

  @override
  void initState() {
    super.initState();
    _fetchExercises();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchExercises() async {
    try {
      final list = await _apiService.getExercises();
      if (mounted) {
        setState(() {
          if (list.isNotEmpty) {
            _exercises = list;
          }
          _isLoadingExercises = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingExercises = false;
        });
      }
    }
  }

  void _scrollToExerciseSection() {
    final targetContext = _exerciseSectionKey.currentContext;
    if (targetContext != null) {
      Scrollable.ensureVisible(
        targetContext,
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _scrollController.animateTo(
        340,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _startWorkout(ExerciseModel exercise) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WorkoutScreen(
          exercise: exercise,
          user: widget.user,
        ),
      ),
    );
  }

  String _getFirstName(String fullName) {
    if (fullName.isEmpty) return 'Pengguna';
    return fullName.trim().split(' ').first;
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    const days = [
      'SENIN',
      'SELASA',
      'RABU',
      'KAMIS',
      'JUMAT',
      'SABTU',
      'MINGGU',
    ];
    const months = [
      'JANUARI',
      'FEBRUARI',
      'MARET',
      'APRIL',
      'MEI',
      'JUNI',
      'JULI',
      'AGUSTUS',
      'SEPTEMBER',
      'OKTOBER',
      'NOVEMBER',
      'DESEMBER',
    ];
    final dayName = days[now.weekday - 1];
    final monthName = months[now.month - 1];
    return '$dayName, ${now.day} $monthName';
  }

  List<ExerciseModel> get _filteredExercises {
    return _exercises.where((ex) {
      // Filter berdasarkan kategori
      final matchCat = _selectedCategory == 'Semua' ||
          ex.category.toLowerCase() == _selectedCategory.toLowerCase() ||
          (ex.targetMuscle != null &&
              ex.targetMuscle!.toLowerCase().contains(_selectedCategory.toLowerCase()));

      // Filter berdasarkan pencarian
      final query = _searchQuery.trim().toLowerCase();
      if (query.isEmpty) return matchCat;

      final matchQuery = ex.name.toLowerCase().contains(query) ||
          (ex.targetMuscle != null && ex.targetMuscle!.toLowerCase().contains(query)) ||
          ex.category.toLowerCase().contains(query) ||
          (ex.description != null && ex.description!.toLowerCase().contains(query));

      return matchCat && matchQuery;
    }).toList();
  }

  // ==========================================
  // DETAIL MODAL LATIHAN SEBELUM MEMULAI
  // ==========================================
  void _showExerciseDetailModal(ExerciseModel exercise) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.charcoalSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollSheetController) => SingleChildScrollView(
          controller: scrollSheetController,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle Bar
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.charcoalBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Gambar Latihan Header (Foto Atlet Nyata)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    SizedBox(
                      height: 200,
                      width: double.infinity,
                      child: _buildExerciseImage(exercise, fit: BoxFit.cover),
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.15),
                              Colors.black.withOpacity(0.85),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.charcoalSurface.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.charcoalBorder),
                        ),
                        child: Text(
                          exercise.level.toUpperCase(),
                          style: AppTypography.roboto(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.spinachGreenLight,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.white, size: 24),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ),
                    Positioned(
                      bottom: 14,
                      left: 16,
                      right: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exercise.name,
                            style: AppTypography.heading(fontSize: 24),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Target: ${exercise.targetMuscle ?? exercise.category}',
                            style: AppTypography.roboto(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.spinachGreenLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Deskripsi Singkat
              Text(
                'TENTANG LATIHAN',
                style: AppTypography.roboto(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDim,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                exercise.description ??
                    'Latihan dumbel dengan fokus biomekanika siku dan stabilitas postur tubuh.',
                style: AppTypography.roboto(
                  fontSize: 13,
                  color: AppColors.textMuted,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 20),

              // Parameter Sensor AIoT yang Dinilai
              Text(
                'VALIDASI POSTUR & SENSOR (AIoT)',
                style: AppTypography.roboto(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDim,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.charcoalElevated,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.charcoalBorder),
                ),
                child: Column(
                  children: [
                    _buildModalParamRow(
                      icon: Icons.rotate_right_rounded,
                      title: 'Rentang Sudut Siku (ROM)',
                      value: '${exercise.minElbowAngle.toInt()}° - ${exercise.maxElbowAngle.toInt()}°',
                      desc: 'Diverifikasi via titik landmark MediaPipe Pose',
                    ),
                    const Divider(color: AppColors.charcoalBorder, height: 20),
                    _buildModalParamRow(
                      icon: Icons.straighten_rounded,
                      title: 'Batas Ayunan Tubuh (Torso)',
                      value: '≤ ${exercise.maxTorsoSwayAngle.toInt()}°',
                      desc: 'Sensor IMU ESP32-S3 mendeteksi kestabilan ayunan badan',
                    ),
                    const Divider(color: AppColors.charcoalBorder, height: 20),
                    _buildModalParamRow(
                      icon: Icons.repeat_rounded,
                      title: 'Rekomendasi Set & Repetisi',
                      value: '3 Set • 10-12 Reps',
                      desc: 'Standar biomekanika instruktur Popeye Gym',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Panduan Singkat Eksekusi
              Text(
                'PANDUAN EKSEKUSI TEKNIK',
                style: AppTypography.roboto(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDim,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 10),
              _buildStepRow(1, 'Posisikan kamera ponsel sejajar tubuh pada jarak 1.5 - 3 meter.'),
              _buildStepRow(2, 'Pastikan Smart Dumbbell ESP32-S3 menyala dan terhubung Bluetooth.'),
              _buildStepRow(3, 'Lakukan gerakan dengan tempo terkontrol (2 detik naik, 2 detik turun).'),

              const SizedBox(height: 28),

              // Tombol Mulai Latihan Sekarang
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _startWorkout(exercise);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.spinachGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.play_arrow_rounded, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Mulai Sesi Latihan Sekarang',
                        style: AppTypography.roboto(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModalParamRow({
    required IconData icon,
    required String title,
    required String value,
    required String desc,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.charcoalSurface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.spinachGreenLight, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.roboto(fontSize: 12, color: AppColors.textDim),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTypography.roboto(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textWhite,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                desc,
                style: AppTypography.roboto(fontSize: 11, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepRow(int number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: AppColors.spinachGreenBg,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.spinachGreen),
            ),
            child: Center(
              child: Text(
                '$number',
                style: AppTypography.roboto(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.spinachGreenLight,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: AppTypography.roboto(fontSize: 12, color: AppColors.textMuted, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final firstName = _getFirstName(user.name);
    final formattedDate = _getFormattedDate();
    final exercises = _filteredExercises;

    return Scaffold(
      backgroundColor: AppColors.charcoalBg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchExercises,
          color: AppColors.spinachGreen,
          backgroundColor: AppColors.charcoalSurface,
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==========================================
                // 1. TOP HEADER (Gambar 1 Referensi Pengguna)
                // Logo FITFORM dipindah ke kanan atas agar seimbang
                // ==========================================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      formattedDate,
                      style: AppTypography.roboto(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.spinachGreenLight,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const FitformLogo(
                      fontSize: 18,
                      letterSpacing: 1.5,
                      showIcon: false,
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Mari berkembang lebih kuat,\n',
                        style: AppTypography.heading(fontSize: 26, height: 1.2),
                      ),
                      TextSpan(
                        text: '$firstName.',
                        style: AppTypography.heading(
                          fontSize: 26,
                          height: 1.2,
                          color: AppColors.spinachGreenLight,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),

                Text(
                  'Repetisi terbaikmu dimulai di sini.',
                  style: AppTypography.subhead(fontSize: 13, color: AppColors.textMuted),
                ),

                const SizedBox(height: 24),

                // ==========================================
                // 2. HERO CARD (Foto Sinematik & Tanpa Tag AIoT)
                // Tombol Mulai Latihan bergulir ke Pilih Latihan
                // ==========================================
                _buildHeroCard(),

                const SizedBox(height: 36),

                // ==========================================
                // 3. PILIH LATIHAN
                // Header section sebelum kotak search
                // ==========================================
                Container(
                  key: _exerciseSectionKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Pilih Latihan untuk Memberikan Space
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pilih Latihan',
                                style: AppTypography.heading(fontSize: 20),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Pilih gerakan untuk panduan sensor & AI',
                                style: AppTypography.subhead(fontSize: 12),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.spinachGreenBg,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.spinachGreen.withOpacity(0.5),
                              ),
                            ),
                            child: Text(
                              '${exercises.length} GERAKAN',
                              style: AppTypography.roboto(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.spinachGreenLight,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Search Bar
                      Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.charcoalSurface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.charcoalBorder),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.search_rounded,
                              color: AppColors.textDim,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                style: AppTypography.roboto(
                                  fontSize: 13,
                                  color: AppColors.textWhite,
                                ),
                                decoration: const InputDecoration(
                                  hintText: 'Cari latihan atau kelompok otot...',
                                  hintStyle: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textDim,
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                                onChanged: (val) {
                                  setState(() {
                                    _searchQuery = val;
                                  });
                                },
                              ),
                            ),
                            if (_searchQuery.isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                                child: const Icon(
                                  Icons.close_rounded,
                                  color: AppColors.textMuted,
                                  size: 18,
                                ),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Kategori Filter Chips (Semua, Lengan, Bahu, Punggung, Dada)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _categories.map((cat) {
                            final isSelected = _selectedCategory == cat;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(cat),
                                labelStyle: AppTypography.roboto(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected ? Colors.white : AppColors.textMuted,
                                ),
                                selected: isSelected,
                                selectedColor: AppColors.spinachGreen,
                                backgroundColor: AppColors.charcoalSurface,
                                side: BorderSide(
                                  color: isSelected ? AppColors.spinachGreen : AppColors.charcoalBorder,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                onSelected: (sel) {
                                  if (sel) {
                                    setState(() => _selectedCategory = cat);
                                  }
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Section Header Count
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${exercises.length} gerakan untuk performa optimal',
                            style: AppTypography.roboto(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMuted,
                            ),
                          ),
                          Text(
                            'Koleksi Dumbbell',
                            style: AppTypography.roboto(
                              fontSize: 11,
                              color: AppColors.textDim,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Grid Kartu Latihan (2 Kolom Seperti Gambar 3)
                      if (_isLoadingExercises)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(40.0),
                            child: CircularProgressIndicator(color: AppColors.spinachGreen),
                          ),
                        )
                      else if (exercises.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: AppColors.charcoalSurface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.charcoalBorder),
                          ),
                          child: Center(
                            child: Column(
                              children: [
                                const Icon(Icons.search_off_rounded, size: 36, color: AppColors.textDim),
                                const SizedBox(height: 10),
                                Text(
                                  'Tidak ada latihan yang cocok',
                                  style: AppTypography.roboto(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textWhite,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Coba gunakan kata kunci atau kategori filter yang lain.',
                                  textAlign: TextAlign.center,
                                  style: AppTypography.roboto(fontSize: 12, color: AppColors.textDim),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: exercises.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.62,
                          ),
                          itemBuilder: (context, index) {
                            final exercise = exercises[index];
                            return _buildGridExerciseCard(exercise);
                          },
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // HERO CARD (Foto Sinematik & Tanpa Tag AIoT)
  // ==========================================
  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.charcoalBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            offset: const Offset(0, 8),
            blurRadius: 20,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // 1. Background Gambar Latihan Gym / Dumbbell Sinematik
            Positioned.fill(
              child: Image.network(
                'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?auto=format&fit=crop&w=800&q=80',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.charcoalSurface,
                ),
              ),
            ),

            // 2. Overlay Gradien Gelap untuk Kontras Maksimal
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      const Color(0xFF0F0F12).withOpacity(0.96),
                      const Color(0xFF14171C).withOpacity(0.85),
                      const Color(0xFF1A1F26).withOpacity(0.55),
                    ],
                  ),
                ),
              ),
            ),

            // 3. Konten Teks dan Tombol Mulai Latihan
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Headline (AIoT FORM CORRECTION dihapus sesuai permintaan)
                  Text(
                    'Gerakan Presisi.\nPerforma Maksimal.',
                    style: AppTypography.heading(fontSize: 22, height: 1.2),
                  ),
                  const SizedBox(height: 8),

                  // Subtitle
                  Text(
                    'Tubuh bagian atas • 3 set • 10-12 repetisi',
                    style: AppTypography.roboto(
                      fontSize: 12,
                      color: AppColors.textWhite.withOpacity(0.85),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Tombol Start Workout (Mulai Latihan) di bawah Card
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _scrollToExerciseSection,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.spinachGreen,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.play_arrow_rounded, size: 22, color: Colors.white),
                              const SizedBox(width: 8),
                              Text(
                                'Mulai Latihan',
                                style: AppTypography.roboto(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // KARTU GRID LATIHAN (Foto Atlet Nyata, Bukan Kerangka)
  // Tidak langsung mulai latihan, tapi Lihat Detail
  // ==========================================
  Widget _buildGridExerciseCard(ExerciseModel exercise) {
    return InkWell(
      onTap: () => _showExerciseDetailModal(exercise),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.charcoalSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.charcoalBorder),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bagian Gambar Latihan (Foto Asli Gerakan Latihan)
            Expanded(
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildExerciseImage(exercise, fit: BoxFit.cover),
                  // Dark gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.1),
                          Colors.black.withOpacity(0.75),
                        ],
                      ),
                    ),
                  ),
                  // Level Badge (PEMULA / MENENGAH)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.charcoalSurface.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: AppColors.charcoalBorder.withOpacity(0.6),
                        ),
                      ),
                      child: Text(
                        exercise.level.toUpperCase(),
                        style: AppTypography.roboto(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: AppColors.spinachGreenLight,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Informasi Latihan & Tombol Lihat Detail
            Expanded(
              flex: 6,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      style: AppTypography.heading(fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),

                    // Target Muscle with Dot
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.spinachGreenLight,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            exercise.targetMuscle ?? exercise.category,
                            style: AppTypography.roboto(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.spinachGreenLight,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Deskripsi Latihan Singkat
                    Expanded(
                      child: Text(
                        exercise.description ?? 'Latihan terfokus otot dengan dumbel.',
                        style: AppTypography.roboto(
                          fontSize: 11,
                          color: AppColors.textMuted,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Action: Lihat Detail -> (Bukan langsung mulai latihan)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Lihat detail',
                          style: AppTypography.roboto(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.spinachGreenLight,
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 14,
                          color: AppColors.spinachGreenLight,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Pembuat Gambar Latihan (Foto Asli Atlet, Bukan Icon!)
  Widget _buildExerciseImage(ExerciseModel exercise, {BoxFit fit = BoxFit.cover}) {
    final imgUrl = ExerciseModel.resolveThumbnail(exercise.name, exercise.thumbnailUrl);
    return Image.network(
      imgUrl,
      fit: fit,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          color: AppColors.charcoalElevated,
          child: const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.spinachGreen,
              ),
            ),
          ),
        );
      },
      errorBuilder: (_, __, ___) => _buildFallbackPhoto(exercise),
    );
  }

  Widget _buildFallbackPhoto(ExerciseModel exercise) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.charcoalElevated,
        image: DecorationImage(
          image: NetworkImage(
            'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?auto=format&fit=crop&w=600&q=80',
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        color: Colors.black.withOpacity(0.35),
      ),
    );
  }
}
