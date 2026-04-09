import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:untitled/modules/profile/profile_controller.dart';
import 'package:untitled/theme/app_color.dart';
import 'package:untitled/ultils/constant.dart';

import '../../routes/routes.dart';
import '../../theme/app_font.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}

class ProfileScene extends GetView<ProfileController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColor.LEFT_MENU,
        body: Stack(
          children: [
            Container(
              height: 150,
              color: AppColor.BLUE,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SIZED_BOX_H100,
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Hero(
                      tag: 'avatar',
                      child: InkWell(
                          onTap: () {
                            Get.toNamed(Routes.profile);
                          },
                          child: SizedBox(
                              height: 100, width: 100, child: CircleAvatar()))),
                ),
                SIZED_BOX_H04,
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Text(controller.mainProvider.userName ?? '',
                          style: AppFont.textSize20
                              .copyWith(fontWeight: FontWeight.w600)),
                      Spacer(),
                      InkWell(
                          onTap: () {},
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: AppColor.PRIMARY,
                            ),
                            height: 30,
                            width: 80,
                            child: Text(
                              'Edit profile',
                              style: AppFont.textSize12.copyWith(
                                  color: AppColor.BACKGROUND,
                                  fontWeight: FontWeight.w600),
                            ),
                          ))
                    ],
                  ),
                ),
                controller.isConfirmEmail.value
                    ? const SizedBox.shrink()
                    : Container(
                        width: double.infinity,
                        height: 50,
                        alignment: Alignment.centerLeft,
                        decoration: const BoxDecoration(
                          color: AppColor.BACKGROUND,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(children: [
                          const Text('Vui lòng xác minh email')]),
                      ),
                SIZED_BOX_H08,
                Container(
                  transformAlignment: Alignment.center,
                  width: double.infinity,
                  height: 80,
                  alignment: Alignment.centerLeft,
                  decoration: const BoxDecoration(
                    color: AppColor.BACKGROUND,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          InkWell(onTap: () {}, child: Text('Đơn mua')),
                          Spacer(),
                          InkWell(
                              onTap: () {},
                              child: Text('Lịch sử mua hàng >')),
                        ],
                      ),
                      SIZED_BOX_H08,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStatusItem(
                              Icons.pending_actions, 'Chờ xác nhận'),
                          _buildStatusItem(
                              Icons.local_shipping, 'Chờ lấy hàng'),
                          _buildStatusItem(
                              Icons.delivery_dining, 'Chờ giao hàng'),
                          _buildStatusItem(Icons.rate_review, 'Đánh giá'),
                        ],
                      ),
                    ],
                  ),
                ),
                SIZED_BOX_H08,
                Container(
                  decoration: BoxDecoration(color: AppColor.BACKGROUND),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Obx(() => Text(controller.eventLabel.value,
                                style: AppFont.textSize16
                                    .copyWith(fontWeight: FontWeight.w600))),
                          ],
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ],
        ));
  }

  Widget _buildStatusItem(IconData icon, String label) {
    return InkWell(
      onTap: () {
        // TODO: xử lý khi nhấn
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 28),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
