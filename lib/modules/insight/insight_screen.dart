import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../mainScene/water_controller.dart';
import '../../routes/routes.dart';
import 'insight_detail_screen.dart';

class InsightScreen extends StatefulWidget {
  const InsightScreen({super.key});

  @override
  State<InsightScreen> createState() => _InsightScreenState();
}

class _InsightScreenState extends State<InsightScreen> {
  int _selectedCategoryIndex = 0;

  final List<Map<String, dynamic>> _categories = [
    {
      "name": "Water Drinking",
      "color": const Color(0xFFD4F7CF), // Light Green
      "items": [
        "Avoid these water drinking mistakes",
        "Replacing beverages with water for health",
        "Best times to drink water",
        "Best times to drink water",
        "Best times to drink water",
        "Best times to drink water",
      ]
    },
    {
      "name": "Beauty & Skincare",
      "color": const Color(0xFFF9B3B3), // Light Red/Pink
      "items": [
        "How Drinking Water Improves Skin Health",
        "Hydration Plan for Smooth Skin",
        "Juices for Radiant and Glowing Skin",
        "Drink Water on an Empty Stomach?",
        "Best times to drink water",
        "Best times to drink water",
      ]
    },
    {
      "name": "Self-care",
      "color": const Color(0xFFFEE59A), // Light Yellow
      "items": [
        "Avoid those water drinking mistakes",
        "Replacing beverages with water for health",
        "Best times to drink water",
        "Best times to drink water",
        "Best times to drink water",
        "Best times to drink water",
      ]
    },
    {
      "name": "Health Lifestyle",
      "color": const Color(0xFFFFCCFA), // Light Purple/Pink
      "items": [
        "Avoid those water drinking mistakes",
        "Replacing beverages with water for health",
        "Best times to drink water",
        "Best times to drink water",
        "Best times to drink water",
        "Best times to drink water",
      ]
    },
    {
      "name": "Cardiovascular Health",
      "color": const Color(0xFFBCDFFA), // Light Blue
      "items": [
        "Avoid those water drinking mistakes",
        "Replacing beverages with water for health",
        "Best times to drink water",
        "Best times to drink water",
        "Best times to drink water",
        "Best times to drink water",
      ]
    },
  ];

  @override
  Widget build(BuildContext context) {
    final WaterController controller = Get.find<WaterController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'INSIGHTS',
          style: GoogleFonts.workSans(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 28,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: InkWell(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFF4F4F6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.settings_outlined,
                  size: 22,
                  color: Color(0xFF5B616D),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCategoryTabs(),
          Expanded(
            child: _buildInsightGrid(),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(controller),
    );
  }

  Widget _buildCategoryTabs() {
    return Stack(
      children: [
        // 1. Đường kẻ mờ chạy xuyên suốt màn hình (Nằm bên dưới)
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 1,
            color: const Color(0xFF00CDE0).withOpacity(0.3),
          ),
        ),

        // 2. Danh sách các Tab cuộn ngang (Nằm bên trên)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: List.generate(_categories.length, (index) {
              final isSelected = _selectedCategoryIndex == index;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategoryIndex = index;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 24),
                  padding: const EdgeInsets.only(top: 8, bottom: 12), // Tạo khoảng trống đẩy chữ lên
                  decoration: BoxDecoration(
                    // Kẻ đè đường Cyan đậm nếu Tab được chọn
                    border: Border(
                      bottom: BorderSide(
                        color: isSelected ? const Color(0xFF00CDE0) : Colors.transparent,
                        width: 2.5,
                      ),
                    ),
                  ),
                  child: Text(
                    _categories[index]["name"],
                    style: GoogleFonts.workSans(
                      fontSize: 14,
                      fontWeight: FontWeight.bold, // Chữ in đậm toàn bộ
                      color: isSelected ? const Color(0xFF0A0C11) : const Color(0xFF6B7280),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildInsightGrid() {
    final category = _categories[_selectedCategoryIndex];
    final color = category["color"];
    final items = category["items"] as List<String>;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 24,
        childAspectRatio: 0.75,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            // SỬ DỤNG Get.toNamed VÀ GỬI DATA VÀO ARGUMENTS
            Get.toNamed(
              Routes.insightDetail,
              arguments: {
                'title': items[index],
                'bgColor': color,
              },
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                items[index],
                style: GoogleFonts.workSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF5B616D),
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
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
