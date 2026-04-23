import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class CongratulationSuccess {
  // Dùng static để có thể gọi hàm này ở bất kỳ đâu mà không cần khởi tạo class
  static void show() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFFE8F8F9),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Nhớ sửa lại đường dẫn ảnh cho đúng với file của bạn nhé
            Image.asset('assets/images/success.png',height: 80,width: 80,),
            const SizedBox(height: 20),
            Text(
              "Congratulations",
              style: GoogleFonts.workSans(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0A0C11),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "You've successfully achieved\nyour drink goal today!",
              textAlign: TextAlign.center,
              style: GoogleFonts.workSans(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF0A0C11),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.back(); // Đóng Bottom Sheet
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00B9CA),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  "Great",
                  style: GoogleFonts.workSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}