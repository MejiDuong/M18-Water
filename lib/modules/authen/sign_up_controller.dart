// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled/routes/routes.dart';
import 'package:untitled/ultils/const_string.dart';
import 'package:untitled/widgets/text_field/custom_password_form_field.dart';

import '../../service/auth_service.dart';

class SignUpController extends GetxController {
  final GlobalKey<FormFieldState> emailKey = GlobalKey();
  final GlobalKey<FormFieldState> passwordKey = GlobalKey();
  final GlobalKey<FormFieldState> confirmPasswordKey = GlobalKey();

  final TextEditingController emailController = TextEditingController();
  ObscureTextController obscurePasswordController =
      ObscureTextController(obscureText: true);
  ObscureTextController obscureConfirmPasswordController =
      ObscureTextController(obscureText: true);

  final email = ''.obs;
  final password = ''.obs;
  final confirmPassword = ''.obs;
  var isRemember = false;

  Rx<String> invalidText = "".obs;
  RxBool isValidate = false.obs;


  void changeEmail({required value}) {
    email.value = value;
  }

  void changePassword({required value}) {
    password.value = value;
  }

  void changeConfirmPassword({required value}) {
    confirmPassword.value = value;
  }

  void register() async {
    String email = "test@example.com";
    String password = "123456";
    
    Get.toNamed(Routes.signInEmail);
    // AuthService authService = AuthService();
    // User? user = await authService.signUpWithEmail(email, password);

    // if (user != null) {
    //   print("Đăng ký thành công! UID: ${user.uid}");
    // } else {
    //   print("Đăng ký thất bại!");
    // }
  }


  void isPasswordInvalid() {
    emailKey.currentState!.validate();
    passwordKey.currentState!.validate();
    confirmPasswordKey.currentState!.validate();
    if ((confirmPassword.value.isEmpty) ||
        confirmPassword.value != password.value) {
      invalidText.value = StringCst.passwordUnMatch;
      return;
    }
    if ((emailKey.currentState?.hasError ?? false)) {
      emailKey.currentState?.validate();
      return;
    }
    if ((passwordKey.currentState?.hasError ?? false)) {
      passwordKey.currentState?.validate();
      invalidText.value = StringCst.passwordValidate;
    } else {
      invalidText.value = "";
    }
  }

  // Future<UserCredential?> signUp(String email, String password) async {
  //   try {
  //     UserCredential userCredential =
  //         await FirebaseAuth.instance.createUserWithEmailAndPassword(
  //       email: email,
  //       password: password,
  //     );
  //     return userCredential;
  //   } on FirebaseAuthException catch (e) {
  //     print('Lỗi: ${e.message}');
  //     return null;
  //   }
  // }
}
