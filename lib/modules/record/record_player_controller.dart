import 'package:get/get.dart';
import 'package:record/record.dart';
import 'package:untitled/base/base_controller.dart';

class RecordPlayerController extends BaseController {

  final AudioRecorder audioRecorder = AudioRecorder();
  RxBool isRecording = false.obs;

  @override
  void onInit() {
    super.onInit();
  }
}
