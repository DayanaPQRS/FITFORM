import 'package:flutter/material.dart';

/// Logo resmi Google "G" 4-Warna (Official Google Identity Asset)
/// Dibangun menggunakan representasi vektor presisi dari standar resmi Google.
/// 100% akurat membentuk huruf "G", tajam di segala resolusi, dan bekerja offline.
class GoogleLogo extends StatelessWidget {
  final double size;

  const GoogleLogo({super.key, this.size = 20.0});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        size: Size(size, size),
        painter: _OfficialGoogleGPainter(),
      ),
    );
  }
}

class _OfficialGoogleGPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double scale = size.width / 48.0;
    canvas.save();
    canvas.scale(scale, scale);

    // 1. Jalur Merah (Bagian Atas Huruf "G")
    final Path redPath = Path();
    redPath.moveTo(24.0, 9.5);
    redPath.cubicTo(27.54, 9.5, 30.71, 10.72, 33.21, 13.1);
    redPath.lineTo(40.06, 6.25);
    redPath.cubicTo(35.9, 2.38, 30.47, 0.0, 24.0, 0.0);
    redPath.cubicTo(14.62, 0.0, 6.51, 5.38, 2.56, 13.22);
    redPath.lineTo(10.54, 19.41);
    redPath.cubicTo(12.43, 13.72, 17.74, 9.5, 24.0, 9.5);
    redPath.close();

    final Paint redPaint = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.fill;
    canvas.drawPath(redPath, redPaint);

    // 2. Jalur Biru (Batang Horizontal & Sudut Kanan Huruf "G")
    final Path bluePath = Path();
    bluePath.moveTo(46.98, 24.55);
    bluePath.cubicTo(46.98, 22.98, 46.83, 21.46, 46.6, 20.0);
    bluePath.lineTo(24.0, 20.0);
    bluePath.lineTo(24.0, 29.02);
    bluePath.lineTo(36.94, 29.02);
    bluePath.cubicTo(36.36, 31.98, 34.68, 34.5, 32.16, 36.2);
    bluePath.lineTo(39.89, 42.2);
    bluePath.cubicTo(44.4, 38.02, 46.98, 31.84, 46.98, 24.55);
    bluePath.close();

    final Paint bluePaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;
    canvas.drawPath(bluePath, bluePaint);

    // 3. Jalur Kuning (Lengkungan Kiri Bawah Huruf "G")
    final Path yellowPath = Path();
    yellowPath.moveTo(10.53, 28.59);
    yellowPath.cubicTo(10.05, 27.14, 9.77, 25.6, 9.77, 24.0);
    yellowPath.cubicTo(9.77, 22.4, 10.04, 20.86, 10.53, 19.41);
    yellowPath.lineTo(2.55, 13.22);
    yellowPath.cubicTo(0.92, 16.46, 0.0, 20.12, 0.0, 24.0);
    yellowPath.cubicTo(0.0, 27.88, 0.92, 31.54, 2.56, 34.78);
    yellowPath.lineTo(10.53, 28.59);
    yellowPath.close();

    final Paint yellowPaint = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.fill;
    canvas.drawPath(yellowPath, yellowPaint);

    // 4. Jalur Hijau (Lengkungan Bawah Huruf "G")
    final Path greenPath = Path();
    greenPath.moveTo(24.0, 48.0);
    greenPath.cubicTo(30.48, 48.0, 35.93, 45.87, 39.89, 42.19);
    greenPath.lineTo(32.16, 36.19);
    greenPath.cubicTo(30.01, 37.64, 27.24, 38.5, 24.0, 38.5);
    greenPath.cubicTo(17.74, 38.5, 12.43, 34.28, 10.53, 28.59);
    greenPath.lineTo(2.56, 34.78);
    greenPath.cubicTo(6.51, 42.62, 14.62, 48.0, 24.0, 48.0);
    greenPath.close();

    final Paint greenPaint = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.fill;
    canvas.drawPath(greenPath, greenPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
