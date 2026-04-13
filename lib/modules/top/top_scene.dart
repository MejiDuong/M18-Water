import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled/base/base_scaffold.dart';
import 'package:untitled/modules/top/top_controller.dart';
import 'package:untitled/routes/routes.dart';
import 'package:untitled/theme/app_font.dart';
import 'package:untitled/ultils/constant.dart';
import 'package:untitled/widgets/app_label/app_label.dart';
import 'package:untitled/widgets/custom_widget/cart_icon.dart';

class TopBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TopController>(() => TopController());
  }
}

class TopScene extends GetView<TopController> {
  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'Top Screen',
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    Get.toNamed(Routes.profile);
                  },
                  child: Row(
                    children: [
                      Hero(tag: 'avatar', child: CircleAvatar()),
                      SIZED_BOX_W04,
                      Text(
                        controller.mainProvider.userName ?? '',
                        style: AppFont.textSize20
                            .copyWith(fontWeight: FontWeight.w700),
                      ),
                      Spacer(),
                      Obx(() =>
                          CartIcon(itemCount: controller.productCount.value)),
                      SIZED_BOX_W16
                    ],
                  ),
                ),

                SIZED_BOX_H20,
                AppLabel(label: 'News', style: AppFont.textSize16.copyWith()),
                Obx(
                  () => GridView.builder(
                    itemCount: controller.news.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 20,
                      childAspectRatio: 70 / 100,
                    ),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                    }
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

