import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:untitled/modules/bottom_sheet/congratulation_success.dart';
import '../../widgets/wave.dart';
import '../bottom_sheet/first_drink.dart';
import '../reminder/reminder_controller.dart';
import 'water_controller.dart';
import '../../routes/routes.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    // Get.lazyPut<MainController>(() => MainController());
    Get.lazyPut<WaterController>(() => WaterController());
    Get.put(ReminderController());
  }
}

class MainScene extends StatelessWidget {
  const MainScene({super.key});

  @override
  Widget build(BuildContext context) {
    final WaterController controller = Get.find<WaterController>();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFFE6FAFC),
      body: Stack(
        children: [
          // 1. Water Wave Background
          Obx(
            () => WaterWave(
              progress: controller.percentage,
              topOffset: 60,
              bottomOffset: 205,
            ),
          ),

          // 2. Static Percentage Markers
          _buildStaticMarkers(),

          // 4. Main Content
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 40),
                _buildWaterAmount(controller),
                const SizedBox(height: 12),
                _buildReminderStatus(controller),
                const Spacer(),
                _buildDrinkLogs(context, controller),
                const SizedBox(height: 20),
                _buildDrinkButton(context, controller),
                const SizedBox(height: 100),
              ],
            ),
          ),
          // 3. Current Progress Tag
          Obx(() => _buildCurrentProgressTag(context, controller.percentage)),

          // 5. Bottom Nav
          _buildBottomNav(controller),
        ],
      ),
    );
  }

  Widget _buildStaticMarkers() {
    return Positioned(
      left: 16,
      top: 0,
      bottom: 85,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 60),
            child: Text(
              '-100%',
              style: GoogleFonts.workSans(
                color: const Color(0xFF5B616D),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            '-50%',
            style: GoogleFonts.workSans(
              color: const Color(0xFF5B616D),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Padding(padding: EdgeInsets.only(bottom: 120)),
        ],
      ),
    );
  }

  Widget _buildCurrentProgressTag(BuildContext context, double percentage) {
    final screenHeight = MediaQuery.of(context).size.height;
    const bottom0 = 205.0;
    final bottom100 = screenHeight - 60.0;
    final clampedPercentage = percentage.clamp(0.0, 1.0);
    final bottomPos = bottom0 + (bottom100 - bottom0) * clampedPercentage;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutSine,
      left: 0,
      bottom: bottomPos - 15,
      child: PhysicalShape(
        clipper: _TagClipper(),
        color: Colors.white,
        elevation: 2,
        child: Container(
          width: 73,
          height: 30,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 16),
          child: Text(
            '${(percentage * 100).toInt()}%',
            style: GoogleFonts.workSans(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF0A0C11),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.settings_outlined,
              size: 22,
              color: Colors.black45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaterAmount(WaterController controller) {
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            '${controller.totalWater.toInt()}',
            style: GoogleFonts.workSans(
              fontSize: 88,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF0A0C11),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'ml',
            style: GoogleFonts.workSans(
              fontSize: 32,
              color: const Color(0xFF0A0C11),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderStatus(WaterController waterController) {
    // Gọi ReminderController để lấy data báo thức
    final ReminderController reminderController = Get.find<ReminderController>();
    final Color mainTextColor = const Color(0xFF0A0C11);
    final Color subTextColor = Colors.grey;

    return Obx(() {
      // Ưu tiên 1 - Công tắc tổng đang tắt
      if (reminderController.isMasterOn.value == false) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Reminder: Off",
              style: GoogleFonts.workSans(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: mainTextColor,
              ),
            ),
            _buildEditButton(),
          ],
        );
      }

      // Ưu tiên 2 - Đã hoàn thành mục tiêu (Lấy % từ WaterController, check Stop từ ReminderController)
      if (waterController.percentage >= 1.0 && reminderController.stopWhenGoalAchieved.value == true) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Next Reminder: Tomorrow", // Bạn có thể update logic lấy ngày mai vào đây sau
                  style: GoogleFonts.workSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: mainTextColor,
                  ),
                ),
                _buildEditButton(),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              "Great job! You've reached your goal today!",
              style: GoogleFonts.workSans(
                fontSize: 12,
                color: Color(0xFF5B616D)
              ),
            ),
          ],
        );
      }

      // Ưu tiên 3 - Trạng thái bình thường
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Next Reminder: 11:00 AM", // Chỗ này sau sẽ nối với logic đếm giờ thực tế của ReminderController
                style: GoogleFonts.workSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: mainTextColor,
                ),
              ),
              _buildEditButton(),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            "(4h32 min left)", // Chỗ này sau sẽ nối với logic đếm ngược thực tế
            style: GoogleFonts.workSans(
              fontSize: 12,
              color: subTextColor,
            ),
          ),
        ],
      );
    });
  }

  // Chỉnh lại nút Edit không cần truyền controller nữa
  Widget _buildEditButton() {
    return InkWell(
      onTap: () => Get.toNamed(Routes.reminder),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child:  Container(
          height: 32,
          width: 32,
          decoration: BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: Color(0xFFEBECF0),
              width: 1,
            ),
          ),
          child: const Center(
            child: Icon(
              Icons.edit,
              size: 14,
              color: Colors.black,
            ),
          ),
        )
      ),
    );
  }

  Widget _buildDrinkLogs(BuildContext context, WaterController controller) {
    final double screenWidth = MediaQuery.of(context).size.width;
    const double cupWidth = 90.0; // Rộng của 1 cốc
    // Tính padding để cốc đầu và cốc cuối có thể cuộn ra giữa
    final double paddingHorizontal = (screenWidth / 2) - (cupWidth / 2);

    return Obx(() {
      if (controller.dailyLogs.isEmpty) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Text(
            'Tap here to record your first drink today!',
            style: GoogleFonts.workSans(
              color: const Color(0xFF0A0C11),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }

      // =========================================================
      // LÓGIC GỘP CỐC (Gộp tất cả các cốc có cùng số ml lại với nhau)
      // =========================================================
      List<Map<String, dynamic>> groupedLogs = [];

      for (int i = 0; i < controller.dailyLogs.length; i++) {
        final log = controller.dailyLogs[i];
        // Tìm xem lượng nước này đã có nhóm nào chưa
        final indexInGroup = groupedLogs.indexWhere((g) => g['amount'] == log.amount);

        if (indexInGroup != -1) {
          // Nếu có rồi thì nhét index của nó vào nhóm đó (để tăng số lượng)
          groupedLogs[indexInGroup]['indices'].add(i);
        } else {
          // Nếu chưa có thì tạo nhóm mới
          groupedLogs.add({
            'amount': log.amount,
            'indices': [i], // Lưu mảng các index gốc của nó
          });
        }
      }

      // Lấy trạng thái của Menu
      final selectedIndex = controller.selectedLogIndex.value;
      final hasSelection = selectedIndex != -1 && selectedIndex < controller.dailyLogs.length;
      final selectedAmount = hasSelection ? controller.dailyLogs[selectedIndex].amount : 0.0;

      return SizedBox(
        height: 180, // Chiều cao tổng của Column
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // 1. TẦNG MENU (Luôn cố định ở giữa màn hình)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: hasSelection ? 60 : 0,
              alignment: Alignment.bottomCenter,
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: hasSelection ? 1.0 : 0.0,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // NÚT XÓA
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              if (hasSelection) controller.removeLog(selectedIndex);
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Ink(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.delete_outline,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // NÚT DRINK
                        // NÚT + DRINK XANH LÁ
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              if (hasSelection) {
                                // 1. Chụp lại mức nước hiện tại
                                double currentTotal = controller.totalWater.value;
                                double goal = controller.goalWater.value;

                                // 2. Cộng nước và tắt chọn (để menu xanh thụt xuống)
                                controller.addWater(selectedAmount);
                                controller.selectedLogIndex.value = -1;

                                // 3. Kiểm tra xem có vừa chạm mốc không
                                if (currentTotal < goal && controller.totalWater.value >= goal) {
                                  // QUAN TRỌNG: Đợi 0.3 giây cho cái menu xanh thụt xuống biến mất hẳn
                                  // rồi mới bắn cái Bottom Sheet chúc mừng lên cho mượt!
                                  Future.delayed(const Duration(milliseconds: 300), () {
                                    CongratulationSuccess.show();
                                  });
                                }
                              }
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Ink(
                              height: 48,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4DB64D), // Nền xanh lá
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.add, color: Colors.white, size: 20),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Drink',
                                    style: GoogleFonts.workSans(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.chevron_right, color: Colors.white, size: 20),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 2. TẦNG CỐC NƯỚC (Giờ sẽ build theo danh sách đã gộp - groupedLogs)
            SizedBox(
              height: 100,
              child: ListView.builder(
                controller: controller.scrollController,
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: paddingHorizontal),
                itemCount: groupedLogs.length, // Dùng số lượng nhóm
                clipBehavior: Clip.none,
                itemBuilder: (context, index) {
                  // Lấy dữ liệu của nhóm hiện tại
                  final group = groupedLogs[index];
                  final amount = group['amount'] as double;
                  final indices = group['indices'] as List<int>;
                  final count = indices.length; // Đếm số lượng cốc trong nhóm này

                  // Sáng lên nếu 1 trong các cốc của nhóm này đang được chọn
                  final isSelected = indices.contains(controller.selectedLogIndex.value);

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Center(
                      // THÊM STACK Ở ĐÂY ĐỂ VẼ CỤC MÀU VÀNG NỔI LÊN TRÊN
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // THÂN CỐC
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              // Khi bấm, ta chọn cái index gốc cuối cùng (mới nhất) trong nhóm
                              onTap: () => controller.selectLog(indices.last, screenWidth),
                              borderRadius: BorderRadius.circular(16),
                              child: Ink(
                                width: 90,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFB2EBF2),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected ? const Color(0xFF00CDE0) : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      'assets/vectors/cup.svg',
                                      width: 28,
                                      height: 40,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '+${amount.toInt()} ml',
                                      style: GoogleFonts.workSans(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF0A0C11),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // CỤC BADGE MÀU VÀNG (Chỉ hiện khi đếm > 1)
                          if (count > 1)
                            Positioned(
                              top: -8, // Kéo lên trên viền
                              right: -8, // Kéo lấn ra ngoài viền
                              child: Container(
                                width: 26,
                                height: 26,
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFFB300), // Màu vàng cam giống ảnh
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '$count',
                                  style: GoogleFonts.workSans(
                                    color: const Color(0xFF0A0C11),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildDrinkButton(BuildContext context, WaterController controller) {
    return InkWell(
      onTap: () => _showDrinkOptions(context, controller),
      borderRadius: BorderRadius.circular(35),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add, color: Color(0xFF00ACC1), size: 28),
            const SizedBox(width: 8),
            Text(
              'DRINK',
              style: GoogleFonts.workSans(
                color: const Color(0xFF00B9CA),
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDrinkOptions(BuildContext context, WaterController controller) {
    final textController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'How much did you drink?',
                style: GoogleFonts.workSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: textController,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Nhập số ml...',
                  suffixText: 'ml',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF00ACC1),
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final amount = double.tryParse(textController.text);
                    if (amount != null && amount > 0) {
                      // 1. Lưu lại thông tin TRƯỚC KHI uống
                      double currentTotal = controller.totalWater.value;
                      double goal = controller.goalWater.value;
                      int oldLogCount = controller.dailyLogs.length;

                      // 2. Bơm nước vào người
                      controller.addWater(amount);

                      // 3. LOGIC XUẤT HIỆN Ở ĐÂY:
                      // Ưu tiên 1: Uống ly này xong là đạt target 2000ml -> Cúp vàng
                      if (currentTotal < goal && controller.totalWater.value >= goal) {
                        Future.delayed(const Duration(milliseconds: 300), () => CongratulationSuccess.show());
                      }
                      // Ưu tiên 2: Lúc nãy chưa có ly nào, đây là ly đầu tiên -> Ly có tick xanh
                      else if (oldLogCount == 0) {
                        Future.delayed(const Duration(milliseconds: 300), () => FirstDrinkBottomSheet.show());
                      }

                      // Đóng cái bảng nhập số ml lại
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00ACC1),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'XÁC NHẬN',
                    style: GoogleFonts.workSans(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav(WaterController controller) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 85,
        color: const Color(0xFF00B9CA),
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
      ),
    );
  }
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
                // Sáng trắng nếu chọn, trắng mờ nếu chưa chọn
                isSelected ? Colors.white : Colors.white54,
                BlendMode.srcIn,
              ),
              width: 28,
              height: 28,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.workSans(
                // Sáng trắng nếu chọn, trắng mờ nếu chưa chọn
                color: isSelected ? Colors.white : Colors.white54,
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
