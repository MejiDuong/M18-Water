import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../mainScene/water_controller.dart';
import '../reminder/reminder_controller.dart';
import 'profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryCyan = Color(0xFF00B9CA);
    const lightBg = Color(0xFFEBECF0);

    return Scaffold(
      backgroundColor: lightBg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 24),
              _buildHeader(context, primaryCyan),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildStatisticsRow(),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildSettingsSections(),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  "Version 0.0.1",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color primaryCyan) {
    return Center(
      child: Column(
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 50, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          Obx(() {
            if (!controller.isLoggedIn.value) {
              return InkWell(
                onTap: () => controller.login(),
                child: Text(
                  "Synchronize Data >",
                  style: TextStyle(color: primaryCyan, fontWeight: FontWeight.bold),
                ),
              );
            }

            return Column(
              children: [
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'logout') controller.logout();
                  },
                  offset: const Offset(0, 40),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      enabled: false,
                      child: Text(controller.email.value, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    ),
                    const PopupMenuItem(
                      value: 'logout',
                      child: Text("Log out", style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500)),
                    ),
                  ],
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        controller.userName.value,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
                Text(
                  "Last Sync: ${controller.lastSyncTime.value}",
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 36,
                  child: ElevatedButton(
                    onPressed: () => controller.toggleSync(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryCyan,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: Obx(() => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (controller.isSyncing.value)
                          const Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            ),
                          )
                        else
                          const Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: Icon(Icons.sync, size: 18, color: Colors.white),
                          ),
                        Text(
                          controller.isSyncing.value ? "Synchronizing..." : "Sync Data",
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ],
                    )),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatisticsRow() {
    // Gọi WaterController từ màn hình chính sang
    final waterController = Get.isRegistered<WaterController>()
        ? Get.find<WaterController>()
        : Get.put(WaterController());

    return Row(
      children: [
        Expanded(
          // Bọc Obx để khi historyLogs thay đổi, con số này tự nhảy
          child: Obx(() => _buildStatCard(
            "Total Drinking",
            Icons.water_drop_outlined,
            waterController.totalDrinkingInLiters.toStringAsFixed(2), // Làm tròn 2 chữ số
            "L",
          )),
        ),
        const SizedBox(width: 16),
        Expanded(
          // Bọc Obx để tự động cập nhật số ngày đạt mục tiêu
          child: Obx(() => _buildStatCard(
            "Total Achieved",
            Icons.calendar_month_outlined,
            waterController.totalAchievedDays.toString(),
            "Days",
          )),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, IconData icon, String value, String unit) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: Colors.black54),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(color: Colors.black54, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold),
              children: [
                TextSpan(text: value),
                TextSpan(
                  text: " $unit",
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSections() {
    // 1. "Triệu hồi" ReminderController an toàn
    final reminderController = Get.isRegistered<ReminderController>()
        ? Get.find<ReminderController>()
        : Get.put(ReminderController());

    return Column(
      children: [
        _buildSettingsBlock([
          // Bọc Obx để tự động cập nhật On/Off khi đổi công tắc ở màn Reminder
          Obx(() => _buildSettingsTile(
              icon: Icons.notifications_none,
              title: "Reminders",
              trailingText: reminderController.isMasterOn.value ? "On" : "Off",
              onTap: () {
                // Lưu ý: Sửa '/reminder' thành đúng tên route của bạn
                Get.toNamed('/reminder');
              }
          )),
          _buildSettingsTile(icon: Icons.opacity, title: "Daily Goal", trailingText: "1.45 L"),
          _buildSettingsTile(icon: Icons.vibration, title: "Sounds & Vibration"),
          _buildSettingsTile(icon: Icons.straighten, title: "Units", trailingText: "L, kg", isLast: true),
        ]),
        _buildSettingsBlock([
          _buildSettingsTile(icon: Icons.person_outline, title: "Gender & Weight"),
          _buildSettingsTile(icon: Icons.language, title: "Language", trailingText: "English"),
          _buildSettingsTile(icon: Icons.calendar_today, title: "First Day Of Week", trailingText: "Sunday"),
          _buildSettingsTile(icon: Icons.access_time, title: "A day Starts At", trailingText: "00:00"),
          _buildSettingsTile(icon: Icons.history_toggle_off, title: "Time Format", trailingText: "Follow system", isLast: true),
        ]),
        _buildSettingsBlock([
          _buildSettingsTile(icon: Icons.block, title: "Remove ads"),
          _buildSettingsTile(icon: Icons.feedback_outlined, title: "Feedback"),
          _buildSettingsTile(icon: Icons.star_border, title: "Rate Us"),
          _buildSettingsTile(icon: Icons.privacy_tip_outlined, title: "Privacy Policy", isLast: true),
        ]),
      ],
    );
  }

  Widget _buildSettingsBlock(List<Widget> children) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      // Bọc ClipRRect để hiệu ứng bấm không bị tràn ra ngoài bo góc
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(children: children),
      ),
    );
  }

  // [ĐÃ SỬA LỖI] THÊM THAM SỐ onTap VÀ BỌC INKWELL
  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? trailingText,
    bool isLast = false,
    VoidCallback? onTap, // THAM SỐ NÀY ĐỂ NHẬN LỆNH BẤM CHUYỂN TRANG
  }) {
    return Material(
      color: Colors.transparent, // Nền trong suốt để thấy nút trắng ở dưới
      child: InkWell(
        onTap: onTap, // Gọi lệnh khi bấm
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(icon, size: 22, color: Colors.black87),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  if (trailingText != null)
                    Text(
                      trailingText,
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                ],
              ),
            ),
            if (!isLast)
              const Divider(height: 1, color: Color(0xFFF2F2F7), indent: 16, endIndent: 16),
          ],
        ),
      ),
    );
  }
}