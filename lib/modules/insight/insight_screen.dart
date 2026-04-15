import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../mainScene/water_controller.dart';
import '../../routes/routes.dart';

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
      "color": const Color(0xFFE1F5E1), // Light Green
      "items": [
        "Avoid these water drinking mistakes",
        "Replacing beverages with water for health",
        "Best times to drink water",
        "How much water should you drink?",
        "Signs of dehydration",
        "Hydration and exercise",
      ]
    },
    {
      "name": "Beauty & Skincare",
      "color": const Color(0xFFFFDADA), // Light Red/Pink
      "items": [
        "How Drinking Water Improves Skin Health",
        "Hydration Plan for Smooth Skin",
        "Juices for Radiant and Glowing Skin",
        "Drink Water on an Empty Stomach?",
        "Anti-aging benefits of water",
        "Detox water recipes",
      ]
    },
    {
      "name": "Self-care",
      "color": const Color(0xFFFFF4CC), // Light Yellow
      "items": [
        "Avoid those water drinking mistakes",
        "Replacing beverages with water for health",
        "Best times to drink water",
        "Mental clarity and hydration",
        "Morning routines for wellness",
        "Stress relief through water",
      ]
    },
    {
      "name": "Health Lifestyle",
      "color": const Color(0xFFFFE1F5), // Light Purple/Pink
      "items": [
        "Avoid those water drinking mistakes",
        "Replacing beverages with water for health",
        "Best times to drink water",
        "Weight loss and water intake",
        "Boosting metabolism with water",
        "Improving sleep with hydration",
      ]
    },
    {
      "name": "Cardiovascular Health",
      "color": const Color(0xFFE1F0FF), // Light Blue
      "items": [
        "Avoid those water drinking mistakes",
        "Replacing beverages with water for health",
        "Best times to drink water",
        "Heart health and hydration",
        "Lowering blood pressure naturally",
        "Cholesterol and water intake",
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
                decoration: BoxDecoration(
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _categories[index]["name"],
                    style: GoogleFonts.workSans(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? Colors.black : Colors.grey,
                    ),
                  ),
                  if (isSelected)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      height: 2,
                      width: 24,
                      color: const Color(0xFF00ACC1),
                    )
                ],
              ),
            ),
          );
        }),
      ),
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
        return Column(
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
                color: Color(0xFF5B616D),
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
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
