import 'dart:math';
import 'package:flutter/material.dart';

class WaterWave extends StatefulWidget {
  final double progress; // 0.0 to 1.0
  final double topOffset;    // Khoảng cách từ đỉnh màn hình đến vạch 100%
  final double bottomOffset; // Khoảng cách từ đáy màn hình đến vạch 0%

  const WaterWave({
    super.key, 
    required this.progress,
    this.topOffset = 60,
    this.bottomOffset = 205,
  });

  @override
  State<WaterWave> createState() => _WaterWaveState();
}

class _WaterWaveState extends State<WaterWave> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: WavePainter(
            progress: widget.progress,
            wavePhase: _controller.value * 2 * pi,
            topOffset: widget.topOffset,
            bottomOffset: widget.bottomOffset,
          ),
          child: Container(),
        );
      },
    );
  }
}

class WavePainter extends CustomPainter {
  final double progress;
  final double wavePhase;
  final double topOffset;
  final double bottomOffset;

  WavePainter({
    required this.progress,
    required this.wavePhase,
    required this.topOffset,
    required this.bottomOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Tọa độ dâng nước chuẩn
    final startY = size.height - bottomOffset;
    final endY = topOffset;
    final currentY = startY - (startY - endY) * progress;

    // Lớp sóng chính (Foreground) - Phối 3 màu chuẩn Figma
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF66E1EC), // Sáng ở mặt sóng
          const Color(0xFF00CDE0),
          const Color(0xFF003D43), // Đậm dần xuống đáy
        ],
        // Ép màu đậm xuống sâu hơn để mặt sóng luôn trong trẻo
        stops: const [0.0, 0.4, 1.0],
      ).createShader(Rect.fromLTWH(0, currentY - 20, size.width, size.height - currentY + 20))
      ..style = PaintingStyle.fill;

    // Lớp sóng phụ (Background) - Dùng Opacity để tạo độ mờ ảo
    final paintLight = Paint()
      ..color = const Color(0xFFB2EBF2).withOpacity(0.4) // Dùng màu nhạt và trong suốt
      ..style = PaintingStyle.fill;

    // Vẽ lớp phụ trước (lệch pha pi và biên độ nhỏ hơn)
    _drawWave(canvas, size, paintLight, wavePhase + pi, 12, currentY);

    // Vẽ lớp chính đè lên
    _drawWave(canvas, size, paint, wavePhase, 18, currentY);
  }

  void _drawWave(Canvas canvas, Size size, Paint paint, double phase, double amplitude, double yCenter) {
    final path = Path();

    path.moveTo(0, yCenter);

    // Vẽ đường cong sóng Sin
    for (double x = 0; x <= size.width; x++) {
      final y = yCenter + amplitude * sin(phase + (x / size.width) * 1.5 * pi);
      path.lineTo(x, y);
    }

    // Đóng vùng xuống tận đáy màn hình để Gradient trải đều
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.wavePhase != wavePhase;
  }
}
