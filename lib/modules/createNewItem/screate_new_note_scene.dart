import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled/theme/app_font.dart';
import 'create_new_note_controller.dart';

class CreateNewNoteBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreateNewNoteController>(() => CreateNewNoteController());
  }
}


class CreateNewNote extends GetView<CreateNewNoteController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900], // Dark background for premium look
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Create New Note',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            // Title Section
            Text(
              'Note Title',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: controller.titleController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Enter note title...',
                hintStyle: TextStyle(color: Colors.white60),
                filled: true,
                fillColor: Colors.black.withOpacity(0.7),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 20),

            // Content Section
            Text(
              'Content',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: controller.contentController,
              style: TextStyle(color: Colors.white),
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Enter note content...',
                hintStyle: TextStyle(color: Colors.white60),
                filled: true,
                fillColor: Colors.black.withOpacity(0.7),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 20),

            // Image Picker Section
            GestureDetector(
              onTap: () {
                // Trigger the image picker dialog
                controller.showImagePickerDialog();
              },
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white.withOpacity(0.1),
                  border: Border.all(color: Colors.white, width: 1),
                ),
                child: Center(
                  child: Icon(
                    Icons.photo_camera,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Display Image Preview
            Obx(() {
              if (controller.pickedImage.value == null) {
                return SizedBox.shrink();
              }
              return Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: FileImage(File(controller.pickedImage.value!.path)),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            }),
            SizedBox(height: 20),

            // Save Button Section
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  // Save note logic
                  controller.saveNote();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amberAccent, // Gold color
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 8,
                ),
                child: Text(
                  'Save',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
