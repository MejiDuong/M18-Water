import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/wave.dart';
import 'water_controller.dart';
import 'main_controller.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainController>(() => MainController());
    Get.lazyPut<WaterController>(() => WaterController());
  }
}

class MainScene extends StatelessWidget {
  const MainScene({super.key});

  @override
  Widget build(BuildContext context) {
    final WaterController controller = Get.find<WaterController>();

    return Scaffold(
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

          // 3. Current Progress Tag
          Obx(() => _buildCurrentProgressTag(context, controller.percentage)),

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

          // 5. Bottom Nav
          _buildBottomNav(),
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
              color: Colors.white.withOpacity(0.5),
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

  Widget _buildReminderStatus(WaterController controller) {
    return Obx(() {
      if (!controller.notificationPermissionGranted.value) {
        return GestureDetector(
          onTap: () => controller.requestNotificationPermission(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.notifications_off,
                size: 18,
                color: Color(0xFF0A0C11),
              ),
              const SizedBox(width: 6),
              Text(
                'Reminder Permission Needed',
                style: GoogleFonts.workSans(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: const Color(0xFF0A0C11),
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        );
      }

      final isGoalReached = controller.percentage >= 1.0;
      final timeStr = controller.reminderTime.value.format(Get.context!);
      final dayStr = controller.nextReminderDay.value.isNotEmpty
          ? " ${controller.nextReminderDay.value}"
          : "";

      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                controller.isReminderOn.value
                    ? 'Next Reminder: $timeStr$dayStr'
                    : 'Reminder: Off',
                style: GoogleFonts.workSans(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: const Color(0xFF0A0C11),
                ),
              ),
              const SizedBox(width: 4),
              _buildEditButton(controller),
            ],
          ),
          const SizedBox(height: 2),
          if (isGoalReached)
            Text(
              "Great job! You've reached your goal today!",
              style: GoogleFonts.workSans(
                fontSize: 11,
                color: Colors.black45,
                fontWeight: FontWeight.w500,
              ),
            )
          else if (controller.isReminderOn.value)
            Text(
              controller.timeLeftString.value,
              style: GoogleFonts.workSans(fontSize: 11, color: Colors.black45),
            ),
        ],
      );
    });
  }

  Widget _buildEditButton(WaterController controller) {
    return InkWell(
      onTap: () async {
        TimeOfDay? pickedTime = await showTimePicker(
          context: Get.context!,
          initialTime: controller.reminderTime.value,
        );
        if (pickedTime != null) controller.updateReminderTime(pickedTime);
      },
      borderRadius: BorderRadius.circular(4),
      child: const Padding(
        padding: EdgeInsets.all(2.0),
        child: Icon(Icons.edit_outlined, size: 16, color: Colors.black45),
      ),
    );
  }

  Widget _buildDrinkLogs(BuildContext context, WaterController controller) {
    final double screenWidth = MediaQuery.of(context).size.width;
    const double totalItemWidth = 96.0; // 90 width + 3*2 padding
    final double paddingHorizontal = (screenWidth / 2) - 48;

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
      return SizedBox(
        height:
            180, // Tăng chiều cao để chứa cả Menu và Cốc chung một khối Column
        child: ListView.builder(
          controller: controller.scrollController,
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: paddingHorizontal),
          itemCount: controller.dailyLogs.length,
          itemBuilder: (context, index) {
            final log = controller.dailyLogs[index];
            return Obx(() {
              final isSelected = controller.selectedLogIndex.value == index;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Menu (Xóa & +Drink) - Luôn nằm trên cốc trong cùng Column
                    SizedBox(
                      height: 50,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 250),
                        opacity: isSelected ? 1.0 : 0.0,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          // Dùng IgnorePointer để khi ẩn đi (opacity 0) thì không bấm nhầm được
                          children: isSelected
                              ? [
                                  // NÚT XÓA
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () => controller.removeLog(index),
                                      borderRadius: BorderRadius.circular(12),
                                      child: Ink(
                                        // Dùng Ink thay cho Container
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
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
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        controller.addWater(log.amount);
                                        controller.selectedLogIndex.value = -1;
                                      },
                                      borderRadius: BorderRadius.circular(12),
                                      child: Ink(
                                        // Dùng Ink để hiệu ứng Ripple hiện trên nền xanh
                                        height: 48,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF4DB64D),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.add,
                                              color: Colors.white,
                                              size: 20,
                                            ),
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
                                            const Icon(
                                              Icons.chevron_right,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ]
                              : [], // Khi không chọn thì mảng rỗng
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    InkWell(
                      onTap: () => controller.selectLog(index, screenWidth),
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 90,
                            height: 100,
                            decoration: BoxDecoration(
                              color: const Color(0xFFB2EBF2),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF00CDE0)
                                    : Colors.transparent,
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
                                  '+${log.amount.toInt()} ml',
                                  style: GoogleFonts.workSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF0A0C11),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Positioned(
                              top: -8,
                              right: -8,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFFC107),
                                  shape: BoxShape.circle,
                                ),
                                child: const Text(
                                  '2',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            });
          },
        ),
      );
    });
  }

  Widget _buildDrinkButton(BuildContext context, WaterController controller) {
    return InkWell(
      onTap: () => _showDrinkOptions(context, controller),
      borderRadius: BorderRadius.circular(35),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
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
                      controller.addWater(amount);
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

  Widget _buildBottomNav() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 85,
        color: const Color(0xFF00ACC1),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              svgPath: 'assets/vectors/waterdrops.svg',
              label: 'Today',
              isSelected: true,
              onTap: () {},
            ),
            _NavItem(
              svgPath: 'assets/vectors/ic_history.svg',
              label: 'History',
              onTap: () {},
            ),
            _NavItem(
              svgPath: 'assets/vectors/ic_document.svg',
              label: 'Insights',
              onTap: () {},
            ),
          ],
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              svgPath,
              colorFilter: ColorFilter.mode(
                isSelected ? Colors.white : Colors.white60,
                BlendMode.srcIn,
              ),
              width: 28,
              height: 28,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.workSans(
                color: isSelected ? Colors.white : Colors.white60,
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
