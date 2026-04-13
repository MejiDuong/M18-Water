import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class CreateNewNoteController extends GetxController {
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final quillController = quill.QuillController.basic();
  final editorFocusNode = FocusNode();
  final ScrollController editorScrollController = ScrollController();

  final Rx<Color> selectedColor = Colors.white.obs;
  final availableColors = [
    Colors.white,
    Colors.yellow.shade100,
    Colors.blue.shade100,
    Colors.green.shade100,
    Colors.pink.shade100,
    Colors.grey.shade200,
  ];

  final Rx<XFile?> pickedImage = Rx<XFile?>(null);

  final Rx<Offset> imagePosition = Offset(0, 0).obs;
  final RxDouble imageScale = 1.0.obs;


  void selectColor(Color color) {
    selectedColor.value = color;
  }

  void showImagePickerDialog() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      pickedImage.value = picked;
    }
  }

  void saveNote() {
    print('Title: ${titleController.text}');
    print('Content: ${quillController.document.toPlainText()}');
  }
}
