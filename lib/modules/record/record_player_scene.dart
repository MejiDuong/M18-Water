import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:untitled/modules/record/record_player_controller.dart';

class RecordPlayerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RecordPlayerController>(() => RecordPlayerController());
  }
}

class RecordPlayerScene extends GetView<RecordPlayerController> {
  const RecordPlayerScene({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
      onPressed: () async  {
        controller.isRecording.value = !controller.isRecording.value;
      },
      child: Obx(
          () => Icon(controller.isRecording.value ? Icons.stop : Icons.mic)),
    ));
  }
}
