import 'package:flutter/material.dart';
import '../models/repetition_telemetry.dart';
import '../services/api_service.dart';
import '../services/workout_engine.dart';
import '../theme/app_theme.dart';

class WorkoutSummaryScreen extends StatefulWidget {
  final WorkoutEngine engine;

  const WorkoutSummaryScreen({super.key, required this.engine});

  @override
  State<WorkoutSummaryScreen> createState() => _WorkoutSummaryScreenState();
}

class _WorkoutSummaryScreenState extends State<WorkoutSummaryScreen> {
  final ApiService _apiService = ApiService();
  bool _isSaving = false;
  bool _isSaved = false;

  String _formatDuration(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<void> _handleSaveSession() async {
    if (_isSaving || _isSaved) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final payload = widget.engine.toApiPayload(
        notes: 'Sesi latihan mandiri via FITFORM Mobile (Fusi AIoT)',
      );

      final result = await _apiService.saveWorkoutSession(payload);

      if (!mounted) return;
      setState(() {
        _isSaved = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.spinachGreenDark,
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: AppColors.spinachGreenLight),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Sesi latihan berhasil disinkronkan ke server secara atomik!',
                  style: AppTypography.roboto(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.warningRedDark,
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: AppColors.warningRedLight),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Gagal simpan ke server: $e',
                  style: AppTypography.roboto(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final engine = widget.engine;
    final accuracy = engine.formAccuracyPercentage;
    final isHighAccuracy = accuracy >= 80.0;

    return Scaffold(
      backgroundColor: AppColors.charcoalBg,
      appBar: AppBar(
        backgroundColor: AppColors.charcoalSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textWhite),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Ringkasan Sesi',
          style: AppTypography.heading(fontSize: 19),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Kartu Skor Utama (Form Accuracy Score)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                decoration: BoxDecoration(
                  color: AppColors.charcoalSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isHighAccuracy
                        ? AppColors.spinachGreen.withOpacity(0.5)
                        : AppColors.warningRed.withOpacity(0.5),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'FORM ACCURACY SCORE',
                      style: AppTypography.roboto(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMuted,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${accuracy.toStringAsFixed(1)}%',
                      style: AppTypography.bebasNeue(
                        fontSize: 72,
                        color: isHighAccuracy ? AppColors.spinachGreenLight : AppColors.warningRedLight,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: isHighAccuracy ? AppColors.spinachGreenBg : AppColors.warningRedBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isHighAccuracy ? AppColors.spinachGreen : AppColors.warningRed,
                        ),
                      ),
                      child: Text(
                        isHighAccuracy ? 'KONSISTENSI BENTUK GERAKAN BAIK' : 'PERLU PERBAIKAN TEKNIK LATIHAN',
                        style: AppTypography.roboto(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isHighAccuracy ? AppColors.spinachGreenLight : AppColors.warningRedLight,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Grid 4 Metrik Inti (Bebas Neue)
              Row(
                children: [
                  Expanded(
                    child: _buildMetricTile(
                      label: 'REPETISI SAH',
                      value: engine.validReps.toString(),
                      valueColor: AppColors.spinachGreenLight,
                      borderColor: AppColors.spinachGreen.withOpacity(0.4),
                      icon: Icons.check_circle_outline,
                      iconColor: AppColors.spinachGreen,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricTile(
                      label: 'ANOMALI',
                      value: engine.anomalyReps.toString(),
                      valueColor: AppColors.warningRedLight,
                      borderColor: AppColors.warningRed.withOpacity(0.4),
                      icon: Icons.warning_amber_rounded,
                      iconColor: AppColors.warningRed,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildMetricTile(
                      label: 'DURASI',
                      value: _formatDuration(engine.durationSeconds),
                      valueColor: AppColors.textWhite,
                      borderColor: AppColors.charcoalBorder,
                      icon: Icons.timer_outlined,
                      iconColor: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricTile(
                      label: 'KALORI TERBAKAR',
                      value: '${engine.caloriesBurned.toStringAsFixed(1)} kcal',
                      valueColor: AppColors.textWhite,
                      borderColor: AppColors.charcoalBorder,
                      icon: Icons.local_fire_department_outlined,
                      iconColor: Colors.orangeAccent,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Rincian Riwayat Repetisi
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'RINCIAN LOG PER REPETISI',
                    style: AppTypography.bebasNeue(
                      fontSize: 18,
                      color: AppColors.textWhite,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    'Total ${engine.totalReps} Reps',
                    style: AppTypography.roboto(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              if (engine.repetitions.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.charcoalSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.charcoalBorder),
                  ),
                  child: Center(
                    child: Text(
                      'Tidak ada repetisi yang tercatat pada sesi ini.',
                      style: AppTypography.roboto(color: AppColors.textMuted),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: engine.repetitions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final rep = engine.repetitions[index];
                    return _buildRepetitionRow(rep);
                  },
                ),

              const SizedBox(height: 32),

              // Tombol Simpan ke Server & Selesai
              ElevatedButton.icon(
                onPressed: _isSaved || _isSaving ? null : _handleSaveSession,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isSaved ? AppColors.charcoalElevated : AppColors.spinachGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: _isSaved ? AppColors.charcoalBorder : AppColors.spinachGreenLight,
                    ),
                  ),
                  elevation: 0,
                ),
                icon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Icon(_isSaved ? Icons.cloud_done : Icons.cloud_upload_outlined),
                label: Text(
                  _isSaved
                      ? 'Sudah Tersimpan di Server'
                      : _isSaving
                          ? 'Menyimpan...'
                          : 'Simpan ke Riwayat Sesi',
                  style: AppTypography.roboto(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 12),

              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textWhite,
                  side: const BorderSide(color: AppColors.charcoalBorder),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Selesai & Kembali ke Beranda',
                  style: AppTypography.roboto(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required Color valueColor,
    required Color borderColor,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.charcoalSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.roboto(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMuted,
                    letterSpacing: 0.8,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTypography.bebasNeue(
              fontSize: 28,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRepetitionRow(RepetitionTelemetry rep) {
    final isValid = rep.isValid;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.charcoalSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isValid ? AppColors.charcoalBorder : AppColors.warningRed.withOpacity(0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isValid ? AppColors.spinachGreenBg : AppColors.warningRedBg,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '#${rep.repNumber}',
                style: AppTypography.bebasNeue(
                  fontSize: 14,
                  color: isValid ? AppColors.spinachGreenLight : AppColors.warningRedLight,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      isValid ? 'REPETISI SAH' : 'ANOMALI TERDETEKSI',
                      style: AppTypography.roboto(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isValid ? AppColors.spinachGreenLight : AppColors.warningRedLight,
                      ),
                    ),
                    const Spacer(),
                    if (rep.durationSeconds != null)
                      Text(
                        '${rep.durationSeconds!.toStringAsFixed(1)}s',
                        style: AppTypography.roboto(
                          fontSize: 11,
                          color: AppColors.textDim,
                        ),
                      ),
                  ],
                ),
                if (!isValid && rep.anomalyReason != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    rep.anomalyReason!,
                    style: AppTypography.roboto(
                      fontSize: 11,
                      color: AppColors.warningRedLight,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (rep.peakJointAngle != null)
                      Text(
                        'Sudut: ${rep.peakJointAngle!.toStringAsFixed(0)}°  ',
                        style: AppTypography.roboto(fontSize: 10, color: AppColors.textMuted),
                      ),
                    if (rep.bodySwayAngle != null)
                      Text(
                        'Sway: ${rep.bodySwayAngle!.toStringAsFixed(1)}°  ',
                        style: AppTypography.roboto(fontSize: 10, color: AppColors.textMuted),
                      ),
                    if (rep.peakAcceleration != null)
                      Text(
                        'Accel: ${rep.peakAcceleration!.toStringAsFixed(1)}m/s²',
                        style: AppTypography.roboto(fontSize: 10, color: AppColors.textMuted),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            isValid ? Icons.check_circle : Icons.warning_rounded,
            color: isValid ? AppColors.spinachGreen : AppColors.warningRed,
            size: 20,
          ),
        ],
      ),
    );
  }
}
