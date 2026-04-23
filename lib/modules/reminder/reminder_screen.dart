import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../bottom_sheet/reminder_mode.dart'; // Đảm bảo import đúng file BottomSheet của bạn
import 'reminder_controller.dart';

class ReminderScreen extends StatelessWidget {
  const ReminderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ReminderController>();
    const primaryCyan = Color(0xFF00B9CA);
    const lightBg = Color(0xFFEBECF0);
    const mainText = Colors.black;
    const subText = Colors.grey;

    return Scaffold(
      backgroundColor: lightBg, // Nền xám tổng thể
      appBar: AppBar(
        backgroundColor: lightBg,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: mainText, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Reminder",
              style: TextStyle(color: mainText, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            // Đã xóa Obx, chỉ để lại Text tĩnh
            Text(
              "Next: 06:00 PM (4h32 min left)",
              style: TextStyle(color: mainText, fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          Obx(() => Switch(
            value: controller.isMasterOn.value,
            onChanged: (val) => controller.isMasterOn.value = val,
            activeTrackColor: primaryCyan,
          )),
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(() {
        final isOn = controller.isMasterOn.value;
        return Opacity(
          opacity: isOn ? 1.0 : 0.5,
          child: AbsorbPointer(
            absorbing: !isOn,
            child: SingleChildScrollView(
              // Bỏ padding ở đây để các khối trắng tràn viền trái phải
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // 1. Khối Reminder Mode (Nền trắng)
                  _buildWhiteBlock(
                    child: _buildModeSelector(context, controller, primaryCyan, mainText),
                  ),
                  const SizedBox(height: 16),

                  // 2. Khối Nội dung (Danh sách giờ Standard/Interval/Custom - Nền trắng)
                  _buildWhiteBlock(
                    child: _buildModeContent(context, controller, primaryCyan, mainText, subText),
                  ),
                  const SizedBox(height: 16),

                  // 3. Khối Weekend Mode (Nền trắng)
                  _buildWhiteBlock(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: _buildSwitchRow("Weekend Reminder Mode", controller.isWeekendModeOn, primaryCyan, mainText),
                    ),
                  ),

                  // 4. Khối Skip & Stop
                  _buildFooter(context, controller, primaryCyan, mainText, subText),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  // Hàm bọc các phần tử bằng khối nền Trắng
  Widget _buildWhiteBlock({required Widget child}) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: child,
    );
  }

  Widget _buildModeSelector(BuildContext context, ReminderController controller, Color primaryCyan, Color mainText) {
    return InkWell(
      onTap: () => ReminderModeBottomSheet.show(controller),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Reminder Mode", style: TextStyle(color: mainText, fontSize: 16, fontWeight: FontWeight.w500)),
            Row(
              children: [
                Obx(() => Text(
                  controller.currentModeTitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                )),
                const SizedBox(width: 8),
                const Icon(Icons.edit, color: Colors.grey, size: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeContent(BuildContext context, ReminderController controller, Color primaryCyan, Color mainText, Color subText) {
    switch (controller.currentMode.value) {
      case 0:
        return _buildStandardMode(context, controller, primaryCyan, mainText);
      case 1:
        return _buildIntervalMode(context, controller, primaryCyan, mainText, subText);
      case 2:
        return _buildCustomMode(context, controller, primaryCyan, mainText, subText);
      default:
        return const SizedBox();
    }
  }

  // --- STANDARD MODE UI ---
  Widget _buildStandardMode(BuildContext context, ReminderController controller, Color primaryCyan, Color mainText) {
    return Column(
      children: controller.standardReminders.asMap().entries.map((entry) {
        int index = entry.key;
        var reminder = entry.value;
        bool isLast = index == controller.standardReminders.length - 1;

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            // Chỉ vẽ vạch ngang cho các item, trừ item cuối cùng
            border: isLast ? null : Border(bottom: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  reminder.name,
                  style: TextStyle(color: mainText, fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
              GestureDetector(
                onTap: () => controller.pickTime(context, reminder.time),
                child: Row(
                  children: [
                    Obx(() => Text(
                      reminder.time.value,
                      style: const TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w500),
                    )),
                    const SizedBox(width: 6),
                    const Icon(Icons.edit, color: Colors.grey, size: 16),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // VẠCH KẺ DỌC MÀU XÁM MỜ
              Container(width: 1, height: 24, color: Colors.grey.shade300),
              const SizedBox(width: 12),
              Obx(() => Switch(
                value: reminder.isEnabled.value,
                onChanged: (val) => reminder.isEnabled.value = val,
                activeTrackColor: primaryCyan,
              )),
            ],
          ),
        );
      }).toList(),
    );
  }

  // --- INTERVAL MODE UI ---
  Widget _buildIntervalMode(BuildContext context, ReminderController controller, Color primaryCyan, Color mainText, Color subText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Interval", style: TextStyle(color: mainText, fontSize: 16, fontWeight: FontWeight.w500)),
              Row(
                children: [
                  Obx(() => Text(controller.intervalDuration.value, style: const TextStyle(color: Colors.grey, fontSize: 16))),
                  const SizedBox(width: 8),
                  const Icon(Icons.edit, color: Colors.grey, size: 16),
                ],
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Color(0xFFEEEEEE)),
          ),
          Row(
            children: [
              Expanded(child: Text("Bedtime", style: TextStyle(color: mainText, fontSize: 16, fontWeight: FontWeight.w500))),
              GestureDetector(
                onTap: () => controller.pickTime(context, controller.bedtimeStart),
                child: Row(
                  children: [
                    Obx(() => Text(controller.bedtimeStart.value, style: const TextStyle(color: Colors.grey, fontSize: 15))),
                    const SizedBox(width: 4),
                    const Icon(Icons.edit, color: Colors.grey, size: 14),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text("to", style: TextStyle(color: Colors.grey)),
              ),
              GestureDetector(
                onTap: () => controller.pickTime(context, controller.bedtimeEnd),
                child: Row(
                  children: [
                    Obx(() => Text(controller.bedtimeEnd.value, style: const TextStyle(color: Colors.grey, fontSize: 15))),
                    const SizedBox(width: 4),
                    const Icon(Icons.edit, color: Colors.grey, size: 14),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() => Text(
            "We'll remind you every ${controller.intervalDuration.value} during your active time:\n08:00 AM, 09:30 AM, 11:00 AM, 12:30 PM, 02:00 PM, 03:30 PM, 05:00 PM, 06:30 PM, 08:00 PM, 09:30 PM, 11:00 PM",
            style: TextStyle(color: subText, fontSize: 13, height: 1.5),
          )),
        ],
      ),
    );
  }

  // --- CUSTOM MODE UI ---
  Widget _buildCustomMode(BuildContext context, ReminderController controller, Color primaryCyan, Color mainText, Color subText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Time (12/30)", style: TextStyle(color: mainText, fontSize: 14, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text("Hold the tag to edit", style: TextStyle(color: subText, fontSize: 12)),
                ],
              ),
              Obx(() {
                int selectedCount = controller.customTimes.where((e) => e.isEnabled.value).length;
                return Text("$selectedCount Selected", style: TextStyle(color: subText, fontSize: 14));
              }),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() => Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ...controller.customTimes.map((item) {
                return Obx(() => GestureDetector(
                  onTap: () => item.isEnabled.value = !item.isEnabled.value,
                  onLongPress: () => controller.pickTime(context, item.time),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: item.isEnabled.value ? primaryCyan : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: item.isEnabled.value ? primaryCyan : Colors.grey.shade300),
                    ),
                    child: Text(
                      item.time.value,
                      style: TextStyle(
                        color: item.isEnabled.value ? Colors.white : Colors.grey.shade600,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ));
              }),
              GestureDetector(
                onTap: () => controller.addCustomTime(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: const Icon(Icons.add, color: Colors.grey, size: 18),
                ),
              ),
            ],
          )),
        ],
      ),
    );
  }

  // --- FOOTER UI (Skip & Stop) ---
  Widget _buildFooter(BuildContext context, ReminderController controller, Color primaryCyan, Color mainText, Color subText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tiêu đề Skip & Stop màu Cyan nằm trên nền Xám
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
          child: Text(
            "Skip & Stop",
            style: TextStyle(color: primaryCyan, fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),

        // Khối trắng chứa 2 tuỳ chọn
        _buildWhiteBlock(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: _buildSwitchRow("Stop when goal achieved", controller.stopWhenGoalAchieved, primaryCyan, mainText),
              ),
              const Divider(height: 1, color: Color(0xFFEEEEEE)), // Vạch ngang phân cách
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(child: Text("Smart Skip", style: TextStyle(color: mainText, fontSize: 16, fontWeight: FontWeight.w500))),
                    GestureDetector(
                      onTap: () {},
                      child: Row(
                        children: [
                          Obx(() => Text(controller.smartSkipDuration.value, style: const TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w500))),
                          const SizedBox(width: 6),
                          const Icon(Icons.edit, color: Colors.grey, size: 16),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // VẠCH DỌC
                    Container(width: 1, height: 24, color: Colors.grey.shade300),
                    const SizedBox(width: 12),
                    Obx(() => Switch(
                      value: controller.isSmartSkipOn.value,
                      onChanged: (val) => controller.isSmartSkipOn.value = val,
                      activeTrackColor: primaryCyan,
                    )),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Đoạn Text mô tả bên dưới khối trắng
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 12),
          child: Obx(() => RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13, height: 1.5),
              children: [
                const TextSpan(text: "After recording a drink, the next "),
                TextSpan(
                  text: "${controller.smartSkipDuration.value} reminder",
                  style: TextStyle(color: primaryCyan, fontWeight: FontWeight.w500), // Tô màu Cyan
                ),
                const TextSpan(text: " will be canceled."),
              ],
            ),
          )),
        ),
      ],
    );
  }

  // --- HELPER WIDGETS ---
  Widget _buildSwitchRow(String title, RxBool obsValue, Color primaryCyan, Color mainText) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(color: mainText, fontSize: 16, fontWeight: FontWeight.w500)),
        Obx(() => Switch(
          value: obsValue.value,
          onChanged: (val) => obsValue.value = val,
          activeTrackColor: primaryCyan,
        )),
      ],
    );
  }
}