import 'package:flutter/material.dart';
import '../models/exercise_model.dart';
import '../models/user_model.dart';
import '../services/workout_engine.dart';
import '../theme/app_theme.dart';
import '../widgets/pose_canvas_mock.dart';
import 'workout_summary_screen.dart';

class WorkoutScreen extends StatefulWidget {
  final ExerciseModel exercise;
  final UserModel? user;

  const WorkoutScreen({
    super.key,
    required this.exercise,
    this.user,
  });

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  late WorkoutEngine _engine;
  bool _showSimulatorControls = true;

  @override
  void initState() {
    super.initState();
    _engine = WorkoutEngine(
      exercise: widget.exercise,
      user: widget.user,
    );
    _engine.addListener(_onEngineUpdate);

    // Otomatis mulai sesi latihan
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _engine.start();
    });
  }

  void _onEngineUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _engine.removeListener(_onEngineUpdate);
    _engine.dispose();
    super.dispose();
  }

  String _formatTimer(int totalSeconds) {
    final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _handleFinishWorkout() async {
    _engine.stop();
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => WorkoutSummaryScreen(engine: _engine),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.charcoalSurface,
        title: Text(
          'HENTIKAN LATIHAN?',
          style: AppTypography.bebasNeue(fontSize: 22, color: AppColors.textWhite),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghentikan sesi latihan ini sekarang?',
          style: AppTypography.roboto(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'LANJUTKAN',
              style: AppTypography.roboto(
                color: AppColors.spinachGreenLight,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warningRed,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'AKHIRI',
              style: AppTypography.roboto(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    return shouldLeave ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final isGood = _engine.formStatus == FormStatus.good;
    final isAnomaly = _engine.formStatus == FormStatus.anomaly;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldLeave = await _onWillPop();
        if (shouldLeave && mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.charcoalBg,
        body: SafeArea(
          child: Column(
            children: [
              // ==========================================
              // 1. TOP HEADER (Nama Latihan, BLE Status, Timer)
              // ==========================================
              _buildTopHeader(),

              // ==========================================
              // 2. CENTER STAGE (Kamera & Pose Skeleton Viewfinder)
              // ==========================================
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Stack(
                    children: [
                      // Viewfinder Pose Skeleton
                      Positioned.fill(
                        child: PoseCanvasMock(
                          elbowAngle: _engine.currentElbowAngle,
                          torsoSwayAngle: _engine.currentTorsoSwayAngle,
                          isGoodForm: !isAnomaly,
                        ),
                      ),

                      // Live Corrective Feedback Banner (Hands-Free Roboto Text)
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: _buildCorrectiveFeedbackBanner(isAnomaly),
                      ),
                    ],
                  ),
                ),
              ),

              // ==========================================
              // 3. METRICS PANEL (Valid vs Anomali vs Akurasi)
              // ==========================================
              _buildMetricCardsRow(),

              // ==========================================
              // 4. SIMULATOR & WORKOUT CONTROLS (Bottom Bar)
              // ==========================================
              _buildControlsBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.charcoalSurface,
        border: Border(bottom: BorderSide(color: AppColors.charcoalBorder)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textWhite, size: 20),
            onPressed: () async {
              if (await _onWillPop() && mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.exercise.name,
                  style: AppTypography.heading(fontSize: 18),
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: AppColors.spinachGreenLight,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Smart Dumbbell Terhubung',
                      style: AppTypography.roboto(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Timer Sesi Latihan (Bebas Neue)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.charcoalElevated,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.charcoalBorder),
            ),
            child: Row(
              children: [
                const Icon(Icons.timer_outlined, size: 18, color: AppColors.spinachGreenLight),
                const SizedBox(width: 6),
                Text(
                  _formatTimer(_engine.durationSeconds),
                  style: AppTypography.bebasNeue(
                    fontSize: 22,
                    color: AppColors.textWhite,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorrectiveFeedbackBanner(bool isAnomaly) {
    final bgColor = isAnomaly ? AppColors.warningRedBg : AppColors.spinachGreenBg;
    final borderColor = isAnomaly ? AppColors.warningRed : AppColors.spinachGreen;
    final iconColor = isAnomaly ? AppColors.warningRedLight : AppColors.spinachGreenLight;
    final textColor = isAnomaly ? AppColors.warningRedLight : AppColors.textWhite;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.8),
        boxShadow: [
          BoxShadow(
            color: borderColor.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            isAnomaly ? Icons.warning_amber_rounded : Icons.check_circle_rounded,
            color: iconColor,
            size: 26,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _engine.feedbackMessage,
              style: AppTypography.roboto(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: textColor,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCardsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          // Kartu Repetisi Sah (Aksen Hijau Bayam)
          Expanded(
            flex: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.charcoalSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.spinachGreen.withOpacity(0.6), width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'REPETISI SAH',
                    style: AppTypography.roboto(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.spinachGreenLight,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_engine.validReps}',
                    style: AppTypography.bebasNeue(
                      fontSize: 48,
                      color: AppColors.spinachGreenLight,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Kartu Anomali (Aksen Merah Peringatan)
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.charcoalSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.warningRed.withOpacity(0.6), width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'ANOMALI',
                    style: AppTypography.roboto(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.warningRedLight,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_engine.anomalyReps}',
                    style: AppTypography.bebasNeue(
                      fontSize: 48,
                      color: AppColors.warningRedLight,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Kartu Akurasi Form & Kalori
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              decoration: BoxDecoration(
                color: AppColors.charcoalSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.charcoalBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'AKURASI',
                    style: AppTypography.roboto(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMuted,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_engine.formAccuracyPercentage.toStringAsFixed(0)}%',
                    style: AppTypography.bebasNeue(
                      fontSize: 32,
                      color: AppColors.textWhite,
                    ),
                  ),
                  Text(
                    '${_engine.caloriesBurned.toStringAsFixed(0)} kcal',
                    style: AppTypography.roboto(
                      fontSize: 10,
                      color: AppColors.textDim,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlsBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.charcoalSurface,
        border: Border(top: BorderSide(color: AppColors.charcoalBorder)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Toggle Panel Simulator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SIMULATOR FUSI AIoT (INTERAKTIF)',
                style: AppTypography.roboto(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDim,
                  letterSpacing: 1.0,
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showSimulatorControls = !_showSimulatorControls;
                  });
                },
                child: Text(
                  _showSimulatorControls ? 'SEMBUNYIKAN ▲' : 'TAMPILKAN SIMULATOR ▼',
                  style: AppTypography.roboto(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.spinachGreenLight,
                  ),
                ),
              ),
            ],
          ),

          if (_showSimulatorControls) ...[
            const SizedBox(height: 8),
            // Tombol-tombol Cepat Simulasi Gerakan
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _engine.simulateValidRepetition(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.spinachGreenLight,
                      side: const BorderSide(color: AppColors.spinachGreen),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(
                      '+ REP SAH',
                      style: AppTypography.bebasNeue(fontSize: 15, color: AppColors.spinachGreenLight),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _engine.simulateAnomalyBodySway(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.warningRedLight,
                      side: const BorderSide(color: AppColors.warningRed),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(
                      'ANOMALI: SWAY',
                      style: AppTypography.bebasNeue(fontSize: 15, color: AppColors.warningRedLight),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _engine.simulateAnomalyIncompleteROM(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orangeAccent,
                      side: const BorderSide(color: Colors.orangeAccent),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(
                      'ANOMALI: ROM',
                      style: AppTypography.bebasNeue(fontSize: 15, color: Colors.orangeAccent),
                    ),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 12),

          // Tombol Utama: Jeda & Selesai Latihan
          Row(
            children: [
              // Tombol Jeda / Lanjutkan
              Expanded(
                flex: 1,
                child: OutlinedButton.icon(
                  onPressed: () {
                    if (_engine.state == WorkoutState.active) {
                      _engine.pause();
                    } else if (_engine.state == WorkoutState.paused) {
                      _engine.resume();
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textWhite,
                    side: const BorderSide(color: AppColors.charcoalBorder),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: Icon(
                    _engine.state == WorkoutState.paused ? Icons.play_arrow : Icons.pause,
                    size: 20,
                  ),
                  label: Text(
                    _engine.state == WorkoutState.paused ? 'LANJUT' : 'JEDA',
                    style: AppTypography.bebasNeue(fontSize: 16, letterSpacing: 1.0),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Tombol Selesai Latihan (Hijau Bayam Menonjol)
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _handleFinishWorkout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.spinachGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.check_circle_outline, size: 22),
                  label: Text(
                    'SELESAI LATIHAN',
                    style: AppTypography.bebasNeue(fontSize: 18, letterSpacing: 1.5),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
