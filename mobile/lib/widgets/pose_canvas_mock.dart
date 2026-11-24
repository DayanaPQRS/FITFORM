import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PoseCanvasMock extends StatelessWidget {
  final double elbowAngle;
  final double torsoSwayAngle;
  final bool isGoodForm;
  final bool showGrid;

  const PoseCanvasMock({
    super.key,
    required this.elbowAngle,
    required this.torsoSwayAngle,
    required this.isGoodForm,
    this.showGrid = true,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        color: const Color(0xFF0A0A0C), // Viewfinder gelap
        child: Stack(
          children: [
            // Frame Panduan Kamera Viewfinder
            CustomPaint(
              size: Size.infinite,
              painter: _CameraViewfinderPainter(),
            ),

            // Skeleton Kerangka Tubuh Dinamis (MediaPipe Style)
            CustomPaint(
              size: Size.infinite,
              painter: _PoseSkeletonPainter(
                elbowAngle: elbowAngle,
                torsoSwayAngle: torsoSwayAngle,
                isGoodForm: isGoodForm,
              ),
            ),

            // Tag status deteksi kamera on-device
            Positioned(
              top: 14,
              left: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.charcoalBg.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.charcoalBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isGoodForm ? AppColors.spinachGreenLight : AppColors.warningRedLight,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Pelacakan Postur Aktif',
                      style: AppTypography.roboto(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Overlay Sudut Siku Live (Bebas Neue)
            Positioned(
              top: 14,
              right: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isGoodForm ? AppColors.spinachGreenBg : AppColors.warningRedBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isGoodForm ? AppColors.spinachGreen : AppColors.warningRed,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'SUDUT SIKU',
                      style: AppTypography.roboto(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: isGoodForm ? AppColors.spinachGreenLight : AppColors.warningRedLight,
                        letterSpacing: 0.8,
                      ),
                    ),
                    Text(
                      '${elbowAngle.toStringAsFixed(0)}°',
                      style: AppTypography.bebasNeue(
                        fontSize: 24,
                        color: isGoodForm ? AppColors.spinachGreenLight : AppColors.warningRedLight,
                        letterSpacing: 1.0,
                      ),
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
}

class _CameraViewfinderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final borderPaint = Paint()
      ..color = AppColors.charcoalBorder.withOpacity(0.5)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Grid garis tipis
    const int divisions = 3;
    for (int i = 1; i < divisions; i++) {
      final x = size.width * (i / divisions);
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), borderPaint);

      final y = size.height * (i / divisions);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), borderPaint);
    }

    // Sudut kurung viewfinder (Corner brackets)
    final cornerPaint = Paint()
      ..color = AppColors.spinachGreen.withOpacity(0.7)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    const cornerLength = 20.0;
    const padding = 12.0;

    // Top-Left
    canvas.drawLine(const Offset(padding, padding + cornerLength), const Offset(padding, padding), cornerPaint);
    canvas.drawLine(const Offset(padding, padding), const Offset(padding + cornerLength, padding), cornerPaint);

    // Top-Right
    canvas.drawLine(Offset(size.width - padding - cornerLength, padding), Offset(size.width - padding, padding), cornerPaint);
    canvas.drawLine(Offset(size.width - padding, padding), Offset(size.width - padding, padding + cornerLength), cornerPaint);

    // Bottom-Left
    canvas.drawLine(Offset(padding, size.height - padding - cornerLength), Offset(padding, size.height - padding), cornerPaint);
    canvas.drawLine(Offset(padding, size.height - padding), Offset(padding + cornerLength, size.height - padding), cornerPaint);

    // Bottom-Right
    canvas.drawLine(Offset(size.width - padding - cornerLength, size.height - padding), Offset(size.width - padding, size.height - padding), cornerPaint);
    canvas.drawLine(Offset(size.width - padding, size.height - padding - cornerLength), Offset(size.width - padding, size.height - padding), cornerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PoseSkeletonPainter extends CustomPainter {
  final double elbowAngle;
  final double torsoSwayAngle;
  final bool isGoodForm;

  _PoseSkeletonPainter({
    required this.elbowAngle,
    required this.torsoSwayAngle,
    required this.isGoodForm,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Warna persendian dinamis: Hijau Bayam saat normal, Merah saat anomali
    final activeJointColor = isGoodForm ? AppColors.spinachGreenLight : AppColors.warningRedLight;
    final boneColor = isGoodForm
        ? AppColors.spinachGreen.withOpacity(0.65)
        : AppColors.warningRed.withOpacity(0.65);

    final bonePaint = Paint()
      ..color = boneColor
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    final jointPaint = Paint()
      ..color = activeJointColor
      ..style = PaintingStyle.fill;

    final jointBorderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Menghitung kemiringan tubuh berdasarkan torsoSwayAngle
    final swayRadians = (torsoSwayAngle * math.pi / 180.0) * (torsoSwayAngle > 10 ? 1 : 0.4);
    final swayOffset = math.sin(swayRadians) * 35.0;

    // Titik kerangka tubuh (Head, Shoulders, Elbows, Wrists, Torso, Hips)
    final head = Offset(centerX + swayOffset * 1.3, centerY - 110);
    final neck = Offset(centerX + swayOffset, centerY - 65);
    final leftShoulder = Offset(centerX - 50 + swayOffset, centerY - 50);
    final rightShoulder = Offset(centerX + 50 + swayOffset, centerY - 50);
    final hipCenter = Offset(centerX, centerY + 80);

    // Lengan kanan memegang dumbbell (lengan aktif bicep curl)
    // Siku kanan tetap terkunci di dekat torso
    final rightElbow = Offset(rightShoulder.dx + 15, rightShoulder.dy + 60);

    // Sudut fleksi siku (elbowAngle: 40° = terlipat ke atas, 160° = lurus ke bawah)
    final rad = (elbowAngle * math.pi / 180.0);
    const forearmLength = 55.0;
    // Saat sudut 160 (lurus): wrist ke arah bawah; saat 40 (fleksi): wrist ke arah bahu
    final wristDx = rightElbow.dx + forearmLength * math.sin(rad - math.pi / 2);
    final wristDy = rightElbow.dy + forearmLength * math.cos(rad - math.pi / 2);
    final rightWrist = Offset(wristDx, wristDy);

    // Lengan kiri (stabil)
    final leftElbow = Offset(leftShoulder.dx - 15, leftShoulder.dy + 60);
    final leftWrist = Offset(leftShoulder.dx - 15, leftShoulder.dy + 115);

    // Gambar Tulang Kerangka (Bones)
    canvas.drawLine(head, neck, bonePaint);
    canvas.drawLine(neck, leftShoulder, bonePaint);
    canvas.drawLine(neck, rightShoulder, bonePaint);
    canvas.drawLine(neck, hipCenter, bonePaint); // Garis Torso Utama

    // Lengan Kiri
    canvas.drawLine(leftShoulder, leftElbow, bonePaint);
    canvas.drawLine(leftElbow, leftWrist, bonePaint);

    // Lengan Kanan (Aktif)
    canvas.drawLine(rightShoulder, rightElbow, bonePaint);
    canvas.drawLine(rightElbow, rightWrist, bonePaint);

    // Visual Dumbbell di tangan kanan
    final dumbbellPaint = Paint()
      ..color = activeJointColor
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.square;
    canvas.drawLine(
      Offset(rightWrist.dx - 12, rightWrist.dy),
      Offset(rightWrist.dx + 12, rightWrist.dy),
      dumbbellPaint,
    );

    // Gambar Sendi (Joints)
    void drawJoint(Offset point, {double radius = 6.0, bool highlight = false}) {
      if (highlight) {
        // Lingkaran luar berdenyut
        final pulsePaint = Paint()
          ..color = activeJointColor.withOpacity(0.3)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(point, radius + 5, pulsePaint);
      }
      canvas.drawCircle(point, radius, jointPaint);
      canvas.drawCircle(point, radius, jointBorderPaint);
    }

    drawJoint(head, radius: 16.0);
    drawJoint(neck, radius: 5.0);
    drawJoint(leftShoulder, radius: 6.0);
    drawJoint(rightShoulder, radius: 7.0, highlight: true);
    drawJoint(leftElbow, radius: 5.0);
    drawJoint(rightElbow, radius: 8.0, highlight: true); // Sendi Siku Kritis
    drawJoint(leftWrist, radius: 5.0);
    drawJoint(rightWrist, radius: 6.0);
    drawJoint(hipCenter, radius: 7.0);

    // Jika terjadi anomali ayunan badan, gambar garis vertikal referensi merah
    if (!isGoodForm && torsoSwayAngle > 10) {
      final refLinePaint = Paint()
        ..color = AppColors.warningRed.withOpacity(0.7)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;

      canvas.drawLine(
        Offset(centerX, centerY - 120),
        Offset(centerX, centerY + 100),
        refLinePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PoseSkeletonPainter oldDelegate) {
    return oldDelegate.elbowAngle != elbowAngle ||
        oldDelegate.torsoSwayAngle != torsoSwayAngle ||
        oldDelegate.isGoodForm != isGoodForm;
  }
}
