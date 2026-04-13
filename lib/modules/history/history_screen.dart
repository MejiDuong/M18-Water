import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../mainScene/water_controller.dart';
import '../../routes/routes.dart';
import 'dart:ui' as ui;

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int selectedTab = 0; // 0: DAY, 1: WEEK, 2: MONTH

  @override
  Widget build(BuildContext context) {
    final WaterController controller = Get.find<WaterController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FEFF),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopTabs(),
            _buildDateSelector(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildSummary(controller),
                    _buildChart(controller),
                    _buildRecordsHeader(),
                    _buildRecordsList(controller),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(controller),
    );
  }

  Widget _buildTopTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          _tabItem("DAY", 0),
          _tabItem("WEEK", 1),
          _tabItem("MONTH", 2),
        ],
      ),
    );
  }

  Widget _tabItem(String title, int index) {
    bool isSelected = selectedTab == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => selectedTab = index),
        child: Column(
          children: [
            Text(
              title,
              style: GoogleFonts.workSans(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.black : Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              height: 2,
              width: 40,
              color: isSelected ? const Color(0xFF00CDE0) : Colors.transparent,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(Icons.chevron_left, color: Colors.black.withOpacity(0.5)),
          Text(
            selectedTab == 0 ? "Today" : (selectedTab == 1 ? "Dec 29 - Jan 4, 2024" : "Dec 2024"),
            style: GoogleFonts.workSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.black.withOpacity(0.5)),
        ],
      ),
    );
  }

  Widget _buildSummary(WaterController controller) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Total", style: GoogleFonts.workSans(color: Colors.grey, fontSize: 14)),
              Text(
                selectedTab == 0 
                  ? "${controller.totalWater.toInt()} ml" 
                  : "0.36 L",
                style: GoogleFonts.workSans(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(selectedTab == 0 ? "Goal" : "Average", style: GoogleFonts.workSans(color: Colors.grey, fontSize: 14)),
              Text(
                selectedTab == 0 
                  ? "${controller.goalWater.toInt()} ml" 
                  : "0.36 L",
                style: GoogleFonts.workSans(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChart(WaterController controller) {
    return Container(
      height: 220,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Unit(ml)", style: GoogleFonts.workSans(fontSize: 10, color: Colors.grey)),
          const SizedBox(height: 10),
          Expanded(
            child: Obx(() => CustomPaint(
              size: Size.infinite,
              painter: FlowChartPainter(
                data: controller.dayChartData,
                goal: controller.goalWater.value,
              ),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordsHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Records", style: GoogleFonts.workSans(fontSize: 18, fontWeight: FontWeight.bold)),
          const Icon(Icons.add, color: Colors.black54),
        ],
      ),
    );
  }

  Widget _buildRecordsList(WaterController controller) {
    return Obx(() {
      if (controller.dailyLogs.isEmpty) {
        return Container(
          margin: const EdgeInsets.all(20),
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.local_drink_outlined, size: 40, color: Color(0xFFB2EBF2)),
              const SizedBox(height: 8),
              Text("Track your drink history here.", style: GoogleFonts.workSans(color: const Color(0xFF00ACC1))),
            ],
          ),
        );
      }
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: controller.dailyLogs.length,
        itemBuilder: (context, index) {
          final log = controller.dailyLogs[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${(log.amount / 1000).toStringAsFixed(2)} L", style: GoogleFonts.workSans(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(DateFormat('hh:mm a').format(log.time), style: GoogleFonts.workSans(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                const Icon(Icons.edit_outlined, size: 20, color: Colors.grey),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () => controller.removeLog(index),
                  child: const Icon(Icons.delete_outline, size: 20, color: Colors.grey),
                ),
              ],
            ),
          );
        },
      );
    });
  }

  Widget _buildBottomNav(WaterController controller) {
    return Container(
      height: 85,
      color: const Color(0xFF00ACC1),
      child: Obx(
        () => Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              svgPath: 'assets/vectors/waterdrops.svg',
              label: 'Today',
              isSelected: controller.currentTab.value == 0,
              onTap: () {
                controller.changeTab(0);
                Get.offAllNamed(Routes.mainScene);
              },
            ),
            _NavItem(
              svgPath: 'assets/vectors/ic_history.svg',
              label: 'History',
              isSelected: controller.currentTab.value == 1,
              onTap: () {
                controller.changeTab(1);
                Get.offAllNamed(Routes.history);
              },
            ),
            _NavItem(
              svgPath: 'assets/vectors/ic_document.svg',
              label: 'Insights',
              isSelected: controller.currentTab.value == 2,
              onTap: () {
                controller.changeTab(2);
                Get.offAllNamed(Routes.insight);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class FlowChartPainter extends CustomPainter {
  final List<double> data; // 25 values (0h - 24h)
  final double goal;

  FlowChartPainter({required this.data, required this.goal});

  @override
  void paint(Canvas canvas, Size size) {
    final double maxVal = 2450.0;
    final double w = size.width;
    final double h = size.height;

    final Paint gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.1)
      ..strokeWidth = 1;

    final List<double> yTicks = [0, 612, 1225, 1837, 2450];
    for (var tick in yTicks) {
      double y = h - (tick / maxVal * h);
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
      
      final textPainter = TextPainter(
        text: TextSpan(
          text: tick.toInt().toString(),
          style: const TextStyle(color: Colors.grey, fontSize: 10),
        ),
        textDirection: ui.TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(-25, y - 6));
    }

    final Paint goalPaint = Paint()
      ..color = const Color(0xFF00CDE0).withOpacity(0.5)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    
    double goalY = h - (goal / maxVal * h);
    _drawDashedLine(canvas, Offset(0, goalY), Offset(w, goalY), goalPaint);

    if (data.isNotEmpty) {
      final Path path = Path();
      final double xStep = w / 24;

      path.moveTo(0, h - (data[0] / maxVal * h));
      for (int i = 1; i < data.length; i++) {
        path.lineTo(i * xStep, h - (data[i] / maxVal * h));
      }

      final Path areaPath = Path.from(path);
      areaPath.lineTo(w, h);
      areaPath.lineTo(0, h);
      areaPath.close();

      final Paint fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [const Color(0xFF00CDE0).withOpacity(0.4), const Color(0xFF00CDE0).withOpacity(0.0)],
        ).createShader(Rect.fromLTWH(0, 0, w, h));
      
      canvas.drawPath(areaPath, fillPaint);

      final Paint linePaint = Paint()
        ..color = const Color(0xFF00CDE0)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      
      canvas.drawPath(path, linePaint);
    }

    final List<int> xTicks = [0, 8, 12, 16, 20, 24];
    for (var hour in xTicks) {
      double x = (hour / 24) * w;
      final textPainter = TextPainter(
        text: TextSpan(
          text: hour.toString(),
          style: const TextStyle(color: Colors.grey, fontSize: 10),
        ),
        textDirection: ui.TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(x - (textPainter.width / 2), h + 8));
    }
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    double dashWidth = 5, dashSpace = 3;
    double startX = p1.dx;
    while (startX < p2.dx) {
      canvas.drawLine(Offset(startX, p1.dy), Offset(startX + dashWidth, p1.dy), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _NavItem extends StatelessWidget {
  final String svgPath;
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const _NavItem({
    required this.svgPath,
    required this.label,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              svgPath,
              colorFilter: ColorFilter.mode(
                isSelected ? Colors.white : Colors.white.withOpacity(0.6),
                BlendMode.srcIn,
              ),
              width: 28,
              height: 28,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.workSans(
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
