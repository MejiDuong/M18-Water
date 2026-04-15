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

  bool _canGoNext() {
    final now = DateTime.now();

    if (selectedTab == 0) { // TAB DAY
      DateTime focusedDay = DateTime(focusedDate.year, focusedDate.month, focusedDate.day);
      DateTime today = DateTime(now.year, now.month, now.day);
      return focusedDay.isBefore(today); // Chỉ cho đi tiếp nếu ngày đang xem nhỏ hơn hôm nay

    } else if (selectedTab == 1) { // TAB WEEK
      DateTime focusedWeekStart = focusedDate.subtract(Duration(days: focusedDate.weekday - 1));
      DateTime currentWeekStart = now.subtract(Duration(days: now.weekday - 1));
      DateTime fWS = DateTime(focusedWeekStart.year, focusedWeekStart.month, focusedWeekStart.day);
      DateTime cWS = DateTime(currentWeekStart.year, currentWeekStart.month, currentWeekStart.day);
      return fWS.isBefore(cWS); // Chỉ cho đi tiếp nếu tuần đang xem nhỏ hơn tuần hiện tại

    } else { // TAB MONTH
      DateTime focusedMonth = DateTime(focusedDate.year, focusedDate.month);
      DateTime currentMonth = DateTime(now.year, now.month);
      return focusedMonth.isBefore(currentMonth); // Chỉ cho đi tiếp nếu tháng đang xem nhỏ hơn tháng hiện tại
    }
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
                      _buildOverviewCard(filteredLogs, controller.goalWater.value),
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
          // NÚT LÙI LẠI QUÁ KHỨ (Luôn bấm được)
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

          // NÚT TIẾN TỚI (Bị khóa nếu đang ở hiện tại)
          IconButton(
            onPressed: _canGoNext() ? () => _updateDate(1) : null,
            icon: Icon(
              Icons.chevron_right,
              // Đổi màu xám nhạt nếu nút bị khóa
              color: _canGoNext() ? Colors.black : Colors.grey.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard(List<DrinkLog> logs, double goal) {
    double total = logs.fold(0, (sum, item) => sum + item.amount);
    double average = 0;
    if (logs.isNotEmpty) {
      int recordedDays = logs.map((log) => log.time.day).toSet().length;
      average = total / recordedDays;
    }

    int daysInMonth = DateUtils.getDaysInMonth(focusedDate.year, focusedDate.month);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Total", style: GoogleFonts.workSans(color: const Color(0xFF003D43), fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(
                    selectedTab == 0 ? "${total.toInt()} ml" : "${(total / 1000).toStringAsFixed(2)} L",
                    style: GoogleFonts.workSans(fontSize: 26, fontWeight: FontWeight.w700, color: const Color(0xFF003D43)),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(selectedTab == 0 ? "Goal" : "Average", style: GoogleFonts.workSans(color: const Color(0xFF003D43), fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(
                    selectedTab == 0 ? "${goal.toInt()} ml" : "${(average / 1000).toStringAsFixed(2)} L",
                    style: GoogleFonts.workSans(fontSize: 20, fontWeight: FontWeight.w700, color: const Color(0xFF003D43)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text("Unit(ml)", style: GoogleFonts.workSans(fontSize: 10, color: const Color(0xFF003D43), fontWeight: FontWeight.w500)),
          const SizedBox(height: 10),
          SizedBox(
            height: 200,
            child: LayoutBuilder(
                builder: (context, constraints) {
                  return GestureDetector( // CHUYỂN VỀ GESTURE DETECTOR
                    // CHÌA KHÓA Ở ĐÂY: Ép nhận diện cảm ứng trên toàn bộ bề mặt biểu đồ
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (details) {
                      _handleChartTap(details.localPosition, constraints.biggest, logs, goal);
                    },
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: FlowChartPainter(
                        goal: goal,
                        logs: logs,
                        selectedDotIndex: selectedDotIndex,
                        selectedTab: selectedTab,
                        daysInMonth: daysInMonth,
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
    final double maxVal = selectedTab == 0 ? 2450.0 : 1.81;

    int daysInMonth = DateUtils.getDaysInMonth(focusedDate.year, focusedDate.month);
    final double xStep = w / (selectedTab == 0 ? 24 : (selectedTab == 1 ? 6 : (daysInMonth - 1)));

    int? closestIndex;
    double minDistance = double.infinity;

    if (selectedTab == 0) {
      List<DrinkLog> sortedLogs = List.from(logs)..sort((a, b) => a.time.compareTo(b.time));
      double currentSum = 0;
      for (int i = 0; i < sortedLogs.length; i++) {
        currentSum += sortedLogs[i].amount;
        double x = leftMargin + (sortedLogs[i].time.hour + sortedLogs[i].time.minute / 60.0) * xStep;
        double y = h - (currentSum / maxVal * h);

        // Tính khoảng cách chuẩn Pythagore
        double distance = math.sqrt(math.pow(localPosition.dx - x, 2) + math.pow(localPosition.dy - y, 2));
        if (distance < minDistance) {
          minDistance = distance;
          closestIndex = i;
        }
      }
    } else {
      Map<int, double> dailyTotals = {};
      for (var log in logs) {
        int key = selectedTab == 1 ? (log.time.weekday % 7) : (log.time.day - 1);
        dailyTotals[key] = (dailyTotals[key] ?? 0) + log.amount;
      }

      dailyTotals.forEach((key, amount) {
        double x = leftMargin + key * xStep;
        double y = h - ((amount / 1000.0) / maxVal * h);

        double distance = math.sqrt(math.pow(localPosition.dx - x, 2) + math.pow(localPosition.dy - y, 2));
        if (distance < minDistance) {
          minDistance = distance;
          closestIndex = key;
        }
      });
    }

    // Bán kính nhạy cảm ứng đã được tăng lên 50.0 (Dễ bấm hơn cực nhiều)
    if (closestIndex != null && minDistance < 50.0) {
      setState(() {
        selectedDotIndex = (selectedDotIndex == closestIndex) ? null : closestIndex;
      });
      HapticFeedback.selectionClick();
    } else {
      // Bấm vô chỗ trống thì tự động đóng Tooltip
      setState(() {
        selectedDotIndex = null;
      });
    }
  }


  Widget _buildRecordsHeader(BuildContext context, WaterController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 20, 12),
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

  // THÊM 2 THAM SỐ OPTIONAL: logToEdit (cốc nước cần sửa) và editIndex (vị trí của nó)
  void _showAddRecordDialog(BuildContext context, WaterController controller, {DrinkLog? logToEdit, int? editIndex}) {
    // Nếu đang sửa: Gắn lượng nước cũ vào. Nếu thêm mới: Để trống
    final textController = TextEditingController(text: logToEdit != null ? logToEdit.amount.toInt().toString() : "");
    bool isValidAmount = logToEdit != null ? true : false; // Nút save sẽ khóa nếu thêm mới mà chưa nhập gì

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

    // MẶC ĐỊNH LÀ THÊM MỚI (Lấy giờ hiện tại)
    int selectedDayIdx = 5;
    int sHour = (DateTime.now().hour % 12 == 0 ? 12 : DateTime.now().hour % 12) - 1;
    int sMin = DateTime.now().minute;
    int sPeriod = DateTime.now().hour >= 12 ? 1 : 0;

    // NẾU LÀ CHẾ ĐỘ SỬA: Đưa bánh xe về đúng giờ/phút/ngày của cốc nước cũ
    if (logToEdit != null) {
      int foundIdx = dateRange.indexWhere((d) => d.year == logToEdit.time.year && d.month == logToEdit.time.month && d.day == logToEdit.time.day);
      if (foundIdx != -1) selectedDayIdx = foundIdx;

      int h = logToEdit.time.hour;
      sHour = (h % 12 == 0 ? 12 : h % 12) - 1;
      sMin = logToEdit.time.minute;
      sPeriod = h >= 12 ? 1 : 0;
    }

    final dayScrollController = FixedExtentScrollController(initialItem: selectedDayIdx);
    final hourScrollController = FixedExtentScrollController(initialItem: sHour);
    final minScrollController = FixedExtentScrollController(initialItem: sMin);
    final periodScrollController = FixedExtentScrollController(initialItem: sPeriod);

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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Flexible(
                      child: IntrinsicWidth(
                        child: TextField(
                          controller: textController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.end,
                          style: GoogleFonts.workSans(fontSize: 64, fontWeight: FontWeight.w400, color: Colors.black),
                          decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero, hintText: "0", hintStyle: TextStyle(color: Colors.grey)),
                          onChanged: (value) {
                            final amount = double.tryParse(value) ?? 0;
                            setDialogState(() => isValidAmount = (amount >= 100 && amount <= 3000));
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text("ml", style: GoogleFonts.workSans(fontSize: 32, fontWeight: FontWeight.w400, color: Colors.black)),
                  ],
                ),
                Container(
                  width: 140,
                  height: 3,
                  decoration: BoxDecoration(
                    color: isValidAmount ? const Color(0xFF00B9CA) : const Color(0xFFEF9A9A),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                Text("*You should drink 100-3000ml at once.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.workSans(color: isValidAmount ? Colors.transparent : Colors.red, fontSize: 12, fontWeight: FontWeight.w500)),
                const SizedBox(height: 24),

                SizedBox(
                  height: 120,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(height: 35, width: double.infinity, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.05), borderRadius: BorderRadius.circular(8))),
                      Row(
                        children: [
                          _buildWheelColumn(daysLabels, selectedDayIdx, dayScrollController, (v) => setDialogState(() => selectedDayIdx = v)),
                          _buildWheelColumn(hours, sHour, hourScrollController, (v) => setDialogState(() => sHour = v)),
                          Text(":", style: GoogleFonts.workSans(fontSize: 20, fontWeight: FontWeight.bold)),
                          _buildWheelColumn(minutes, sMin, minScrollController, (v) => setDialogState(() => sMin = v), isLooping: true),
                          _buildWheelColumn(periods, sPeriod, periodScrollController, (v) => setDialogState(() => sPeriod = v)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFF00B9CA), width: 1.5), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                        child: Text("Cancel", style: GoogleFonts.workSans(color: const Color(0xFF00B9CA), fontSize: 18, fontWeight: FontWeight.w600)))),
                    const SizedBox(width: 16),
                    Expanded(child: ElevatedButton(
                        onPressed: isValidAmount ? () {
                          final amount = double.tryParse(textController.text);
                          if (amount != null) {
                            final date = dateRange[selectedDayIdx];
                            int h = int.parse(hours[sHour]);
                            if (sPeriod == 1 && h < 12) h += 12;
                            if (sPeriod == 0 && h == 12) h = 0;
                            final drinkTime = DateTime(date.year, date.month, date.day, h, sMin);

                            // === LOGIC XỬ LÝ LƯU: KIỂM TRA XEM LÀ THÊM HAY SỬA ===
                            if (logToEdit != null && editIndex != null) {
                              // Chế độ Sửa: Trừ đi lượng nước cũ, cộng lượng nước mới vào tổng
                              controller.totalWater.value += (amount - logToEdit.amount);
                              // Ghi đè vào cốc nước cũ trong mảng
                              controller.dailyLogs[editIndex] = DrinkLog(amount: amount, time: drinkTime);
                            } else {
                              // Chế độ Thêm Mới:
                              controller.dailyLogs.add(DrinkLog(amount: amount, time: drinkTime));
                              controller.totalWater.value += amount;
                            }

                            Navigator.pop(context);
                          }
                        } : null,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00B9CA),
                            disabledBackgroundColor: Colors.grey.withOpacity(0.3),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            elevation: 0),
                        child: Text("Save", style: GoogleFonts.workSans(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)))),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWheelColumn(List<String> items, int selectedIndex, FixedExtentScrollController scrollController, ValueChanged<int> onChanged, {bool isLooping = false}) {
    return Expanded(
      child: ListWheelScrollView.useDelegate(
        controller: scrollController, // Gắn Controller để bánh xe mở ra đúng vị trí
        itemExtent: 35,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: onChanged,
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
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 150), // Hiệu ứng chuyển font mượt khi vuốt
        style: GoogleFonts.workSans(
          fontSize: isSelected ? 18 : 15,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.black : Colors.grey.withOpacity(0.5),
        ),
        child: Text(text),
      ),
    );
  }

  Widget _buildRecordsList(List<DrinkLog> logs, WaterController controller) {
    if (logs.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFF4F4F6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset('assets/vectors/cup_his.svg'),
            const SizedBox(height: 8),
            Text("Track your drink history here.", style: GoogleFonts.workSans(color: const Color(0xFF00ACC1))),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: logs.length,
        itemBuilder: (context, index) {
          final log = logs[index];
          return Container(
            margin: EdgeInsets.only(bottom: index == logs.length - 1 ? 0 : 12),
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
                InkWell(
                  onTap: () => controller.removeLog(controller.dailyLogs.indexOf(log)),
                  child: const Icon(Icons.delete_outline, size: 20, color: Colors.grey),
                ),
                const SizedBox(width: 16),
                InkWell(
                  // KHI BẤM NÚT SỬA: Phải báo cho Dialog biết là tôi đang sửa cái cốc nước nào
                  onTap: () => _showAddRecordDialog(
                      context,
                      controller,
                      logToEdit: log, // Truyền data cũ vào
                      editIndex: controller.dailyLogs.indexOf(log) // Truyền vị trí của nó
                  ),
                  child: const Icon(Icons.edit_outlined, size: 20, color: Colors.grey),
                ),
              ],
            ),
          );
        },
      ),
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
  final int selectedTab;
  final int daysInMonth; // THÊM BIẾN NHẬN SỐ NGÀY TỪ BÊN NGOÀI

  FlowChartPainter({
    required this.goal,
    required this.logs,
    this.selectedDotIndex,
    required this.selectedTab,
    required this.daysInMonth // Yêu cầu biến này
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double leftMargin = 40.0;
    const double bottomPadding = 30.0;
    final double w = size.width - leftMargin;
    final double h = size.height - bottomPadding;
    final double maxVal = selectedTab == 0 ? 2450.0 : 1.81;

    canvas.save();
    canvas.translate(leftMargin, 0);

    final Paint gridPaint = Paint()..color = Colors.grey.withOpacity(0.15)..strokeWidth = 1;

    final List<double> yTicks = selectedTab == 0 ? [0, 612, 1225, 1837, 2450] : [0, 0.45, 0.9, 1.36, 1.81];
    for (var tick in yTicks) {
      double y = h - (tick / maxVal * h);
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
      final textPainter = TextPainter(text: TextSpan(text: selectedTab == 0 ? tick.toInt().toString() : tick.toString(), style: GoogleFonts.workSans(color: const Color(0xFF003D43), fontSize: 12, fontWeight: FontWeight.w500)), textDirection: ui.TextDirection.ltr)..layout();
      textPainter.paint(canvas, Offset(-leftMargin, y - 8));
    }

    final Paint goalPaint = Paint()..color = const Color(0xFF00CDE0)..strokeWidth = 1.5..style = ui.PaintingStyle.stroke;
    double goalY = h - ((selectedTab == 0 ? goal : goal / 1000) / maxVal * h);
    _drawDashedLine(canvas, Offset(0, goalY), Offset(w, goalY), goalPaint);

    if (logs.isNotEmpty) {
      // TÍNH xStep ĐỘNG THEO SỐ NGÀY
      final double xStep = w / (selectedTab == 0 ? 24 : (selectedTab == 1 ? 6 : (daysInMonth - 1)));

      final Paint dotPaint = Paint()..color = const Color(0xFF00CDE0)..style = ui.PaintingStyle.fill;
      final Paint dotOutline = Paint()..color = Colors.white..strokeWidth = 2.5..style = ui.PaintingStyle.stroke;

      if (selectedTab == 0) {
        List<DrinkLog> sortedLogs = List.from(logs)..sort((a, b) => a.time.compareTo(b.time));
        List<Offset> points = [];
        double sum = 0;

        for (var log in sortedLogs) {
          double x = (log.time.hour + log.time.minute / 60.0) * xStep;
          if (points.isEmpty) points.add(Offset(x, h));

          sum += log.amount;
          double y = h - (sum / maxVal * h);
          points.add(Offset(x, y));
        }

        if (points.length >= 2) {
          final Path path = Path();
          path.moveTo(points[1].dx, points[1].dy);
          for (int i = 2; i < points.length; i++) path.lineTo(points[i].dx, points[i].dy);

          final Path areaPath = Path.from(path)..lineTo(points.last.dx, h)..lineTo(points[1].dx, h)..close();
          final Paint fillPaint = Paint()..shader = ui.Gradient.linear(Offset(0, h - (sum / maxVal * h)), Offset(0, h), [const Color(0xFF00CDE0).withOpacity(0.6), const Color(0xFF00CDE0).withOpacity(0.0)]);
          canvas.drawPath(areaPath, fillPaint);

          final Paint linePaint = Paint()..color = const Color(0xFF00CDE0)..strokeWidth = 3.5..style = ui.PaintingStyle.stroke;
          canvas.drawPath(path, linePaint);

          for (int i = 1; i < points.length; i++) {
            canvas.drawCircle(points[i], 5, dotOutline);
            canvas.drawCircle(points[i], 5, dotPaint);
            if (selectedDotIndex == i - 1) {
              _drawTooltip(canvas, points[i], "+${sortedLogs[i-1].amount.toInt()} ml");
            }
          }
        }
      } else {
        Map<int, double> dailyTotals = {};
        for (var log in logs) {
          int key = selectedTab == 1 ? (log.time.weekday % 7) : (log.time.day - 1);
          dailyTotals[key] = (dailyTotals[key] ?? 0) + log.amount;
        }

        dailyTotals.forEach((key, amount) {
          double x = key * xStep;
          double amountL = amount / 1000.0;
          double y = h - (amountL / maxVal * h);

          final Rect rect = Rect.fromLTRB(x - 6, y, x + 6, h);
          final RRect rrect = RRect.fromRectAndCorners(rect, topLeft: const Radius.circular(6), topRight: const Radius.circular(6));
          final Paint barPaint = Paint()..shader = ui.Gradient.linear(Offset(0, y), Offset(0, h), [const Color(0xFF00CDE0).withOpacity(0.8), const Color(0xFF00CDE0).withOpacity(0.1)]);
          canvas.drawRRect(rrect, barPaint);

          canvas.drawCircle(Offset(x, y), 5, dotOutline);
          canvas.drawCircle(Offset(x, y), 5, dotPaint);

          if (selectedDotIndex == key) {
            String txt = selectedTab == 1 ? "+${amountL.toStringAsFixed(2)} L" : "Day ${key+1}\n${amountL.toStringAsFixed(2)} L";
            _drawTooltip(canvas, Offset(x, y), txt);
          }
        });
      }
    }

    // TẠO NHÃN TRỤC X ĐỘNG (Sinh ra số cuối cùng là 28, 29, 30 hoặc 31)
    List<String> xLabels;
    if (selectedTab == 0) {
      xLabels = ["0", "4", "8", "12", "16", "20", "24"];
    } else if (selectedTab == 1) {
      xLabels = ["S", "M", "T", "W", "T", "F", "S"];
    } else {
      // Tháng có bao nhiêu ngày thì in nhãn cuối cùng bấy nhiêu
      xLabels = ["1", "6", "11", "16", "21", "26", daysInMonth.toString()];
    }

    for (int i = 0; i < xLabels.length; i++) {
      double x;
      if (selectedTab == 0) {
        x = (int.parse(xLabels[i]) / 24) * w;
      } else if (selectedTab == 1) {
        x = i * (w / 6);
      } else {
        x = (int.parse(xLabels[i]) - 1) * (w / (daysInMonth - 1)); // Lưới tháng cũng chia theo số ngày
      }
      final textPainter = TextPainter(text: TextSpan(text: xLabels[i], style: GoogleFonts.workSans(color: const Color(0xFF003D43), fontSize: 12, fontWeight: FontWeight.w500)), textDirection: ui.TextDirection.ltr)..layout();
      textPainter.paint(canvas, Offset(x - (textPainter.width / 2), h + 12));
    }
    canvas.restore();
  }

  void _drawTooltip(Canvas canvas, Offset position, String text) {
    final textPainter = TextPainter(text: TextSpan(text: text, style: GoogleFonts.workSans(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)), textDirection: ui.TextDirection.ltr)..layout();
    final double tooltipWidth = textPainter.width + 20;
    final double tooltipHeight = textPainter.height + 12;

    final double yOffset = text.contains('\n') ? 35 : 30;

    final Rect rect = Rect.fromCenter(center: Offset(position.dx, position.dy - yOffset), width: tooltipWidth, height: tooltipHeight);
    final RRect rrect = RRect.fromRectAndRadius(rect, const Radius.circular(6));
    final Paint paint = Paint()..color = const Color(0xFF008B99);
    canvas.drawRRect(rrect, paint);

    final Path arrowPath = Path()..moveTo(position.dx - 6, position.dy - yOffset + tooltipHeight / 2)..lineTo(position.dx + 6, position.dy - yOffset + tooltipHeight / 2)..lineTo(position.dx, position.dy - 12)..close();
    canvas.drawPath(arrowPath, paint);
    textPainter.paint(canvas, Offset(rect.left + 10, rect.top + 6));
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    double dashWidth = 4, dashSpace = 4;
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
