import 'package:flutter/material.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:untitled/theme/app_color.dart';

import '../../base/base_controller.dart';

class NotePenController extends BaseController {
  final drawingController = DrawingController();

  void clear() {
    drawingController.clear();
  }

  @override
  void onClose() {
    drawingController.dispose();
    super.onClose();
  }
}

class NotePenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotePenController>(() => NotePenController());
  }
}

class NotePenScene extends GetView<NotePenController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Note Pen"),
        actions: [
          IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              controller.clear();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: DrawingBoard(
          controller: controller.drawingController,
          background: Container(
            height: context.height,
            width: context.width,
            color: AppColor.PRIMARY, //
        ),
          showDefaultActions: true, // Hiển thị các hành động mặc định như hoàn tác, làm lại
          showDefaultTools: true,   // Hiển thị thanh công cụ mặc định
        ),
      ),
    );
  }
}