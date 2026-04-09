import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';

import 'package:untitled/base/base_scaffold.dart';
import 'package:untitled/routes/routes.dart';
import 'package:untitled/theme/app_font.dart';
import 'package:untitled/ultils/constant.dart';

class SignInBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SignInController>(() => SignInController());
  }
}

class SignInController extends GetxController {
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var isLoading = false.obs;
  var isRemember = false.obs;

// void signIn() async {
//   isLoading.value = true;
//   try {
//     await FirebaseAuth.instance.signInWithEmailAndPassword(
//       email: emailController.text.trim(),
//       password: passwordController.text.trim(),
//     );
//     Get.snackbar("Thành công", "Đăng nhập thành công!",
//         snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green);
//   } catch (e) {
//     Get.snackbar("Lỗi", "Email hoặc mật khẩu không đúng!",
//         snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
//   } finally {
//     isLoading.value = false;
//   }
// }
}

class SignInScene extends GetView<SignInController> {
  const SignInScene({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      hasAppBar: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SIZED_BOX_H20,
                SizedBox(
                    height: 150,
                    width: 150,
                    child: Image.asset('assets/images/ic_login.png')),

                const SizedBox(height: 20),

                Text("Login",
                    style: AppFont.textSize24
                        .copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 20),

                // Email
                TextField(
                  controller: controller.emailController,
                  decoration: InputDecoration(
                      labelText: "Email", border: OutlineInputBorder()),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 10),

                TextField(
                  controller: controller.passwordController,
                  decoration: InputDecoration(
                      labelText: "Password", border: OutlineInputBorder()),
                  obscureText: true,
                ),
                Obx(() => Row(
                      children: [
                        Checkbox(
                          value: controller.isRemember.value,
                          onChanged: (bool? value) {
                            controller.isRemember.value = value ?? false;
                          },
                        ),
                        const Text('Remember me'),
                      ],
                    )),
                // InkWell(onTap: () {}, child: Text('Forgot password')),
                const SizedBox(height: 20),

                Obx(() => SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.toNamed(Routes.topScreen);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigoAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              vertical: 16),
                        ),
                        child: controller.isLoading.value
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text("Login"),
                      ),
                    )),

                SizedBox(height: 20),

                Row(
                  children: [
                    Text("Don't have an account?"),
                    InkWell(
                      child: Text(
                        " Register",
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.indigoAccent),
                      ),
                      onTap: () {
                        Get.toNamed(Routes.signUpEmail);
                      },
                    ),
                  ],
                ),

                SIZED_BOX_H20,

                Align(
                  alignment: Alignment.center,
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Colors.grey.shade400,
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          'or',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Colors.grey.shade400,
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                ),

                SIZED_BOX_H20,

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/ic_google.png',
                      height: 35,
                      width: 35,
                    ),
                    SIZED_BOX_W16,
                    Image.asset(
                      'assets/images/ic_facebook.png',
                      height: 35,
                      width: 35,
                    ),
                    if (Platform.isIOS) ...[
                      SIZED_BOX_W16,
                      Image.asset(
                        'assets/images/ic_apple.png',
                        height: 35,
                        width: 35,
                      ),
                    ],
                  ],
                )

                // SizedBox(
                //   width: double.infinity,
                //   child: GestureDetector(
                //     onTap: () {},
                //     child: Container(
                //       padding: const EdgeInsets.symmetric(vertical: 10),
                //       decoration: BoxDecoration(
                //         color: Colors.white,
                //         borderRadius: BorderRadius.circular(24),
                //         boxShadow: [
                //           BoxShadow(
                //             color: Colors.black12,
                //             blurRadius: 4,
                //             offset: Offset(0, 2),
                //           ),
                //         ],
                //       ),
                //       child: Row(
                //         mainAxisAlignment: MainAxisAlignment.center,
                //         children: [
                //           Image.asset(
                //             'assets/images/ic_google.png',
                //             height: 24,
                //             width: 24,
                //           ),
                //           const SizedBox(width: 12),
                //           const Text(
                //             'Sign in with Google',
                //             style: TextStyle(
                //               color: Colors.black87,
                //               fontSize: 16,
                //               fontWeight: FontWeight.w500,
                //             ),
                //           ),
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
                //
                // SIZED_BOX_H08,
                //
                // SizedBox(
                //   width: double.infinity,
                //   child: GestureDetector(
                //     onTap: () {},
                //     child: Container(
                //       padding: const EdgeInsets.symmetric(vertical: 10),
                //       decoration: BoxDecoration(
                //         color: Colors.white,
                //         borderRadius: BorderRadius.circular(24),
                //         boxShadow: [
                //           BoxShadow(
                //             color: Colors.black12,
                //             blurRadius: 4,
                //             offset: Offset(0, 2),
                //           ),
                //         ],
                //       ),
                //       child: Row(
                //         mainAxisAlignment: MainAxisAlignment.center,
                //         children: [
                //           Image.asset(
                //             'assets/images/ic_facebook.png',
                //             height: 24,
                //             width: 24,
                //           ),
                //           const SizedBox(width: 12),
                //           const Text(
                //             'Sign in with Facebook',
                //             style: TextStyle(
                //               color: Colors.black87,
                //               fontSize: 16,
                //               fontWeight: FontWeight.w500,
                //             ),
                //           ),
                //         ],
                //       ),
                //     ),
                //   ),
                // ),

                // Row(
                //   children: [
                //     Text('Nếu bạn chưa có tài khoản, đăng ký'),
                //     InkWell(
                //       onTap: () => Get.toNamed(Routes.signUnEmail),
                //       child: Text(
                //         ' tại đây',
                //         style: AppFont.textSize14.copyWith(
                //             color: AppColor.DARK_BLUE,
                //             fontWeight: FontWeight.w700),
                //       ),
                //     )
                //   ],
                // )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
