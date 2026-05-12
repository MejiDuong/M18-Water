import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../reminder/reminder_controller.dart';

class ReminderModeBottomSheet {
  static void show(ReminderController controller) {
    const primaryCyan = Color(0xFF00B9CA);
    controller.tempSelectedMode.value = controller.currentMode.value;
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // --- HEADER ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Reminder Mode",
                  style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w700),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.black),
                  onPressed: () => Get.back(),
                )
              ],
            ),
            const SizedBox(height: 24),
            // --- CÁC LỰA CHỌN ---
            _buildModeOption(0, "Standard", "Based on your sleep and meals", controller, primaryCyan),
            const SizedBox(height: 20),
            _buildModeOption(1, "Interval", "Notify you at set intervals", controller, primaryCyan),
            const SizedBox(height: 20),
            _buildModeOption(2, "Custom", "Personalize all reminders", controller, primaryCyan),
            const SizedBox(height: 22),

            // --- NÚT SAVE ---
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  controller.saveMode();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryCyan,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  elevation: 0,
                ),
                child: const Text("Save", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  // Hàm build từng cái Card lựa chọn
  static Widget _buildModeOption(int index, String title, String subtitle, ReminderController controller, Color primaryCyan) {
    return Obx(() {
      final isSelected = controller.tempSelectedMode.value == index;
      return InkWell(
        onTap: () => controller.tempSelectedMode.value = index,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? primaryCyan : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isSelected ? primaryCyan : Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}