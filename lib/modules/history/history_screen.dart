import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../mainScene/water_controller.dart';
import '../../routes/routes.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int selectedTab = 0; // 0: DAY, 1: WEEK, 2: MONTH
  DateTime focusedDate = DateTime.now();
  int? selectedDotIndex; // Index của dấu chấm đang được chọn trên biểu đồ

  void _updateDate(int delta) {
    setState(() {
      selectedDotIndex = null; // Reset tooltip khi đổi ngày
      if (selectedTab == 0) {
        focusedDate = focusedDate.add(Duration(days: delta));
      } else if (selectedTab == 1) {
        focusedDate = focusedDate.add(Duration(days: delta * 7));
      } else {
        focusedDate = DateTime(focusedDate.year, focusedDate.month + delta, 1);
      }
    });
  }

  String _getFormattedDate() {
    if (selectedTab == 0) {
      final now = DateTime.now();
      if (DateFormat('yyyy-MM-dd').format(focusedDate) == DateFormat('yyyy-MM-dd').format(now)) {
        return "Today";
      }
      return DateFormat('MMM d, yyyy').format(focusedDate);
    } else if (selectedTab == 1) {
      DateTime start = focusedDate.subtract(Duration(days: focusedDate.weekday - 1));
      DateTime end = start.add(const Duration(days: 6));
      return "${DateFormat('MMM d').format(start)} - ${DateFormat('MMM d, yyyy').format(end)}";
    } else {
      return DateFormat('MMM yyyy').format(focusedDate);
    }
  }

  List<DrinkLog> _getFilteredLogs(List<DrinkLog> logs) {
    return logs.where((log) {
      if (selectedTab == 0) {
        return log.time.year == focusedDate.year &&
               log.time.month == focusedDate.month &&
               log.time.day == focusedDate.day;
      } else if (selectedTab == 1) {
        DateTime start = focusedDate.subtract(Duration(days: focusedDate.weekday - 1));
        DateTime end = start.add(const Duration(days: 7));
        DateTime s = DateTime(start.year, start.month, start.day);
        DateTime e = DateTime(end.year, end.month, end.day);
        return log.time.isAfter(s.subtract(const Duration(seconds: 1))) &&
               log.time.isBefore(e);
      } else {
        return log.time.year == focusedDate.year &&
               log.time.month == focusedDate.month;
      }
    }).toList();
  }

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
                child: Obx(() {
                  final filteredLogs = _getFilteredLogs(controller.dailyLogs);
                  return Column(
                    children: [
                      _buildSummary(filteredLogs, controller.goalWater.value),
                      _buildChartCard(filteredLogs, controller.goalWater.value),
                      _buildRecordsHeader(context, controller),
                      _buildRecordsList(filteredLogs, controller),
                    ],
                  );
                }),
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
        onTap: () => setState(() {
          selectedTab = index;
          focusedDate = DateTime.now();
          selectedDotIndex = null;
        }),
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
          IconButton(
            onPressed: () => _updateDate(-1),
            icon: const Icon(Icons.chevron_left, color: Colors.black),
          ),
          Text(
            _getFormattedDate(),
            style: GoogleFonts.workSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0A0C11),
            ),
          ),
          IconButton(
            onPressed: () => _updateDate(1),
            icon: const Icon(Icons.chevron_right, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(List<DrinkLog> logs, double goal) {
    double total = logs.fold(0, (sum, item) => sum + item.amount);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Total", style: GoogleFonts.workSans(color: const Color(0xFF003D43), fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text(
                "${total.toInt()} ml",
                style: GoogleFonts.workSans(fontSize: 26, fontWeight: FontWeight.w700, color: const Color(0xFF003D43)),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("Goal", style: GoogleFonts.workSans(color: const Color(0xFF003D43), fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text(
                "${goal.toInt()} ml",
                style: GoogleFonts.workSans(fontSize: 20, fontWeight: FontWeight.w700, color: const Color(0xFF003D43)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(List<DrinkLog> logs, double goal) {
    return Container(
      height: 280,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Unit(ml)", style: GoogleFonts.workSans(fontSize: 10, color: const Color(0xFF003D43), fontWeight: FontWeight.w500)),
          const SizedBox(height: 10),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return GestureDetector(
                  onTapDown: (details) {
                    _handleChartTap(details.localPosition, constraints.biggest, logs, goal);
                  },
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: FlowChartPainter(
                      goal: goal,
                      logs: logs,
                      selectedDotIndex: selectedDotIndex,
                    ),
                  ),
                );
              }
            ),
          ),
        ],
      ),
    );
  }

  void _handleChartTap(Offset localPosition, Size size, List<DrinkLog> logs, double goal) {
    if (logs.isEmpty) return;

    const double leftMargin = 40.0;
    const double bottomPadding = 30.0;
    final double w = size.width - leftMargin;
    final double h = size.height - bottomPadding;
    final double maxVal = 2450.0;
    final double xStep = w / 24;

    List<DrinkLog> sortedLogs = List.from(logs)..sort((a, b) => a.time.compareTo(b.time));

    int? closestIndex;
    double minDistance = double.infinity;
    const double touchThreshold = 40.0;

    double currentSum = 0;
    for (int i = 0; i < sortedLogs.length; i++) {
      currentSum += sortedLogs[i].amount;
      double x = leftMargin + (sortedLogs[i].time.hour + sortedLogs[i].time.minute / 60.0) * xStep;
      double y = h - (currentSum / maxVal * h);

      double distance = math.sqrt(math.pow(localPosition.dx - x, 2) + math.pow(localPosition.dy - y, 2));
      if (distance < minDistance) {
        minDistance = distance;
        closestIndex = i;
      }
    }

    if (closestIndex != null && minDistance < touchThreshold) {
      setState(() {
        selectedDotIndex = (selectedDotIndex == closestIndex) ? null : closestIndex;
      });
      HapticFeedback.selectionClick();
    }
  }

  Widget _buildRecordsHeader(BuildContext context, WaterController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Records", style: GoogleFonts.workSans(fontSize: 18, fontWeight: FontWeight.w700)),
          IconButton(
            onPressed: () => _showAddRecordDialog(context, controller),
            icon: const Icon(Icons.add, color: Color(0xFF0A0C11)),
          ),
        ],
      ),
    );
  }

  void _showAddRecordDialog(BuildContext context, WaterController controller) {
    final textController = TextEditingController(text: "190");
    
    // Logic ngày linh hoạt theo focusedDate: +/- 5 ngày quanh ngày đang xét
    final baseDate = focusedDate;
    final List<DateTime> dateRange = List.generate(11, (index) => baseDate.add(Duration(days: index - 5)));
    final List<String> daysLabels = dateRange.map((d) {
      final now = DateTime.now();
      if (DateFormat('yyyy-MM-dd').format(d) == DateFormat('yyyy-MM-dd').format(now)) return "Today";
      return DateFormat('MMM d').format(d);
    }).toList();

    final List<String> hours = List.generate(12, (i) => (i + 1).toString().padLeft(2, '0'));
    final List<String> minutes = List.generate(60, (i) => i.toString().padLeft(2, '0'));
    final List<String> periods = ["AM", "PM"];

    int selectedDayIdx = 5; // Mặc định dừng ở focusedDate (vị trí giữa)
    int sHour = (DateTime.now().hour % 12 == 0 ? 12 : DateTime.now().hour % 12) - 1;
    int sMin = DateTime.now().minute;
    int sPeriod = DateTime.now().hour >= 12 ? 1 : 0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          content: Container(
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. ML INPUT SECTION (KHÔI PHỤC UI SỐ TO, GẠCH CHÂN HỒNG ĐỎ)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    IntrinsicWidth(
                      child: TextField(
                        controller: textController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.workSans(
                          fontSize: 64,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "ml",
                      style: GoogleFonts.workSans(
                        fontSize: 32,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 140,
                  height: 3,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF9A9A), // Màu hồng đỏ gạch chân
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "*You should drink 100-3000ml at once.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.workSans(
                    color: Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
                
                // 2. TIME PICKER WHEEL (CHỌN LÀ BOLD)
                SizedBox(
                  height: 120,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: 35,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      Row(
                        children: [
                          _buildWheelColumn(daysLabels, selectedDayIdx, (v) => setDialogState(() => selectedDayIdx = v)),
                          _buildWheelColumn(hours, sHour, (v) => setDialogState(() => sHour = v)),
                          Text(":", style: GoogleFonts.workSans(fontSize: 20, fontWeight: FontWeight.bold)),
                          _buildWheelColumn(minutes, sMin, (v) => setDialogState(() => sMin = v), isLooping: true),
                          _buildWheelColumn(periods, sPeriod, (v) => setDialogState(() => sPeriod = v)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                // 3. BUTTONS (Cancel / Save)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF00B9CA), width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: Text(
                          "Cancel",
                          style: GoogleFonts.workSans(
                            color: const Color(0xFF00B9CA),
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final amount = double.tryParse(textController.text);
                          if (amount != null) {
                            final date = dateRange[selectedDayIdx];
                            int h = int.parse(hours[sHour]);
                            if (sPeriod == 1 && h < 12) h += 12;
                            if (sPeriod == 0 && h == 12) h = 0;
                            final drinkTime = DateTime(date.year, date.month, date.day, h, sMin);
                            controller.dailyLogs.add(DrinkLog(amount: amount, time: drinkTime));
                            controller.totalWater.value += amount;
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00B9CA),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          elevation: 0,
                        ),
                        child: Text(
                          "Save",
                          style: GoogleFonts.workSans(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
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
    );
  }

  Widget _buildWheelColumn(List<String> items, int selectedIndex, ValueChanged<int> onChanged, {bool isLooping = false}) {
    return Expanded(
      child: ListWheelScrollView.useDelegate(
        itemExtent: 35,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: onChanged,
        // Rendering lại List mỗi khi selectedIndex thay đổi để cập nhật trạng thái Bold
        childDelegate: isLooping 
          ? ListWheelChildLoopingListDelegate(
              children: List.generate(items.length, (i) => _buildWheelItem(items[i], i == selectedIndex)),
            )
          : ListWheelChildListDelegate(
              children: List.generate(items.length, (i) => _buildWheelItem(items[i], i == selectedIndex)),
            ),
      ),
    );
  }

  Widget _buildWheelItem(String text, bool isSelected) {
    return Center(
      child: Text(text,
        style: GoogleFonts.workSans(
          fontSize: isSelected ? 18 : 15,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.black : Colors.grey.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildRecordsList(List<DrinkLog> logs, WaterController controller) {
    if (logs.isEmpty) {
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
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index];
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
                onTap: () => controller.removeLog(controller.dailyLogs.indexOf(log)),
                child: const Icon(Icons.delete_outline, size: 20, color: Colors.grey),
              ),
            ],
          ),
        );
      },
    );
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
  final double goal;
  final List<DrinkLog> logs;
  final int? selectedDotIndex;

  FlowChartPainter({required this.goal, required this.logs, this.selectedDotIndex});

  @override
  void paint(Canvas canvas, Size size) {
    const double leftMargin = 40.0;
    const double bottomPadding = 30.0;
    final double w = size.width - leftMargin;
    final double h = size.height - bottomPadding;
    final double maxVal = 2450.0;

    canvas.save();
    canvas.translate(leftMargin, 0);

    final Paint gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.1)
      ..strokeWidth = 1;

    // 1. Draw Grid Lines and Y labels
    final List<double> yTicks = [0, 612, 1225, 1837, 2450];
    for (var tick in yTicks) {
      double y = h - (tick / maxVal * h);
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
      
      final textPainter = TextPainter(
        text: TextSpan(
          text: tick.toInt().toString(),
          style: GoogleFonts.workSans(color: Colors.grey, fontSize: 12),
        ),
        textDirection: ui.TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(-leftMargin, y - 8));
    }

    // 2. Draw Goal Line (Dashed)
    final Paint goalPaint = Paint()
      ..color = const Color(0xFF00B0C0)
      ..strokeWidth = 1
      ..style = ui.PaintingStyle.stroke;
    
    double goalY = h - (goal / maxVal * h);
    _drawDashedLine(canvas, Offset(0, goalY), Offset(w, goalY), goalPaint);

    // 3. Process Data (Cumulative Rising Path)
    if (logs.isNotEmpty) {
      // Sort logs by time
      List<DrinkLog> sortedLogs = List.from(logs);
      sortedLogs.sort((a, b) => a.time.compareTo(b.time));

      // Group by exact time and calculate cumulative
      List<Offset> points = [];
      double sum = 0;
      final double xStep = w / 24;

      for (var log in sortedLogs) {
        double x = (log.time.hour + log.time.minute / 60.0) * xStep;
        
        // To make it rise, we add a baseline point at the very first drink time
        if (points.isEmpty) {
          points.add(Offset(x, h));
        }
        
        sum += log.amount;
        double y = h - (sum / maxVal * h);
        points.add(Offset(x, y));
      }

      if (points.length >= 2) {
        final Path path = Path();
        path.moveTo(points[0].dx, points[0].dy);
        for (int i = 1; i < points.length; i++) {
          path.lineTo(points[i].dx, points[i].dy);
        }

        // Draw Area
        final Path areaPath = Path.from(path);
        areaPath.lineTo(points.last.dx, h);
        areaPath.lineTo(points.first.dx, h);
        areaPath.close();

        final Paint fillPaint = Paint()
          ..shader = ui.Gradient.linear(
            Offset(w / 2, 0),
            Offset(w / 2, h),
            [const Color(0xFF00CDE0).withOpacity(0.6), const Color(0xFF00CDE0).withOpacity(0.0)],
          );
        canvas.drawPath(areaPath, fillPaint);

        final Paint linePaint = Paint()
          ..color = const Color(0xFF00CDE0)
          ..strokeWidth = 3
          ..style = ui.PaintingStyle.stroke;
        canvas.drawPath(path, linePaint);

        // 4. Draw Dots and Tooltip
        final Paint dotPaint = Paint()
          ..color = const Color(0xFF00CDE0)
          ..style = ui.PaintingStyle.fill;
        final Paint dotOutline = Paint()
          ..color = Colors.white
          ..strokeWidth = 2
          ..style = ui.PaintingStyle.stroke;

        for (int i = 1; i < points.length; i++) {
          canvas.drawCircle(points[i], 4, dotPaint);
          canvas.drawCircle(points[i], 4, dotOutline);

          // Tooltip KHI ĐƯỢC CHỌN
          if (selectedDotIndex == i - 1) {
            _drawTooltip(canvas, points[i], "+${sortedLogs[i-1].amount.toInt()} ml");
          }
        }
      }
    }

    // 5. Draw X-axis labels
    final List<int> xTicks = [0, 4, 8, 12, 16, 20, 24];
    for (var hour in xTicks) {
      double x = (hour / 24) * w;
      final textPainter = TextPainter(
        text: TextSpan(
          text: hour.toString(),
          style: GoogleFonts.workSans(color: Colors.grey, fontSize: 12),
        ),
        textDirection: ui.TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(x - (textPainter.width / 2), h + 10));
    }
    canvas.restore();
  }

  void _drawTooltip(Canvas canvas, Offset position, String text) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
      ),
      textDirection: ui.TextDirection.ltr,
    )..layout();

    final double tooltipWidth = textPainter.width + 16;
    final double tooltipHeight = textPainter.height + 10;
    final Rect rect = Rect.fromCenter(
      center: Offset(position.dx, position.dy - 25),
      width: tooltipWidth,
      height: tooltipHeight,
    );

    final RRect rrect = ui.RRect.fromRectAndRadius(rect, const Radius.circular(8));
    final Paint paint = Paint()..color = const Color(0xFF00838F);
    
    canvas.drawRRect(rrect, paint);
    
    final Path arrowPath = Path();
    arrowPath.moveTo(position.dx - 5, position.dy - 25 + tooltipHeight / 2);
    arrowPath.lineTo(position.dx + 5, position.dy - 25 + tooltipHeight / 2);
    arrowPath.lineTo(position.dx, position.dy - 15);
    arrowPath.close();
    canvas.drawPath(arrowPath, paint);

    textPainter.paint(canvas, Offset(rect.left + 8, rect.top + 5));
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    double dashWidth = 5, dashSpace = 3;
    double startX = p1.dx;
    while (startX < p2.dx) {
      canvas.drawLine(Offset(startX, p1.dy), Offset(startX + math.min(dashWidth, p2.dx - startX), p1.dy), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) => false;

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
                color: isSelected ? Colors.white : Colors.white,
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

class _TagClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(size.width - 15, 0);
    path.lineTo(size.width, size.height / 2);
    path.lineTo(size.width - 15, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
