import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

// --- 1. KHAI BÁO STATEFUL WIDGET ---
class InsightDetailScreen extends StatefulWidget {
  final String title;
  final Color bgColor;

  const InsightDetailScreen({
    super.key,
    required this.title,
    required this.bgColor,
  });

  @override
  State<InsightDetailScreen> createState() => _InsightDetailScreenState();
}

// --- 2. KHAI BÁO STATE ---
class _InsightDetailScreenState extends State<InsightDetailScreen> {
  final PageController _pageController = PageController();

  // Biến theo dõi để ẩn/hiện tiêu đề trên AppBar
  bool _showTitleOnAppBar = false;

  @override
  Widget build(BuildContext context) {
    // Tự động tính toán màu chữ đậm từ màu nền nhạt
    final HSLColor hsl = HSLColor.fromColor(widget.bgColor);
    final Color darkTextColor = hsl.withLightness((hsl.lightness - 0.6).clamp(0.1, 0.3)).toColor();

    return Scaffold(
      backgroundColor: widget.bgColor,
      appBar: AppBar(
        backgroundColor: widget.bgColor,
        elevation: 0,
        scrolledUnderElevation: 0, // Chống lệch màu Material 3
        surfaceTintColor: Colors.transparent, // Chống lệch màu Material 3
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: darkTextColor, size: 28),
          onPressed: () => Get.back(),
        ),
        // Hiện tiêu đề nếu đang ở trang 2 trở đi
        title: _showTitleOnAppBar
            ? Text(
          widget.title,
          style: GoogleFonts.workSans(
            color: darkTextColor,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        )
            : null,
      ),
      body: PageView(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        // Lắng nghe sự kiện vuốt để cập nhật AppBar
        onPageChanged: (index) {
          setState(() {
            _showTitleOnAppBar = index > 0;
          });
        },
        children: [
          _buildFirstPage(darkTextColor),
          _buildSecondPage(darkTextColor),
        ],
      ),
    );
  }

  // --- TRANG 1: MỞ ĐẦU ---
  Widget _buildFirstPage(Color darkTextColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text(
            widget.title,
            style: GoogleFonts.workSans(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: darkTextColor,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Did you know that even when you drink water, you can make some mistakes to affect your health?\n\nLet's explore the most common water-drinking mistakes and how you can avoid them.",
            style: GoogleFonts.workSans(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF164F0D),
              height: 1.6,
            ),
          ),
          const Spacer(),
          Center(
            child: Column(
              children: [
                Icon(Icons.keyboard_double_arrow_down, color: Color(0xFF164F0D)),
                const SizedBox(height: 4),
                Text(
                  "Swipe to continue",
                  style: GoogleFonts.workSans(
                    fontWeight: FontWeight.w600,
                      color: Color(0xFF164F0D),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- TRANG 2: NỘI DUNG CHI TIẾT ---
  Widget _buildSecondPage(Color darkTextColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 136.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),

          // 1. Hình tròn số 1
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: darkTextColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text("1", style: GoogleFonts.workSans(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),

          const SizedBox(height: 18),
          // 2. Tiêu đề nội dung
          Text(
            "Not Drinking Enough Water",
            style: GoogleFonts.workSans(fontSize: 28, fontWeight: FontWeight.w700, color: Color(0xFF164F0D)),
          ),
          const SizedBox(height: 16),
          // 3. Phần chữ chi tiết
          Container(
            child: Text(
              "Dehydration can lead to a range of health problems, including headaches, fatigue, and constipation.\n\nYour specific water needs may vary depending on many factors. Therefore, you can use our app to get your personal daily intake target and reminders to help you stay hydrated.",
              style: GoogleFonts.workSans(fontSize: 16, fontWeight: FontWeight.w400, color: Color(0xFF164F0D), height: 1.6),
            ),
          ),
        ],
      ),
    );
  }
}

