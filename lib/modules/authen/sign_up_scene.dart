import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled/base/base_scaffold.dart';
import 'package:untitled/modules/authen/sign_up_controller.dart';
import 'package:untitled/theme/app_color.dart';
import 'package:untitled/ultils/app_validate.dart';
import 'package:untitled/ultils/constant.dart';
import 'package:untitled/widgets/text_field/custom_form_field.dart';
import 'package:untitled/widgets/text_field/custom_password_form_field.dart';
import '../../theme/app_font.dart';

class SignUpBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SignUpController>(() => SignUpController());
  }
}

class SignUpEmailScene extends GetView<SignUpController> {
  const SignUpEmailScene({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      hasAppBar: true,
      showBackIcon: true,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                    height: 200,
                    width: 200,
                    child: Image.asset('assets/images/ic_sign_up.png')),
                const SizedBox(height: 20),
                Text("Sign up",
                    style: AppFont.textSize24
                        .copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 20),
                CustomFormField(
                  formKey: controller.emailKey,
                  validator: AppValidator.validateEmail,
                  hintText: "Email",
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (text) {
                    controller.changeEmail(value: text);
                    if (controller.emailKey.currentState?.hasError ?? false) {
                      controller.emailKey.currentState?.validate();
                    }
                  },
                ),
                SIZED_BOX_H16,
                Container(
                  padding: PAD_SYM_H08_V06,
                  decoration: BoxDecoration(
                      color: AppColor.BG_SEARCH,
                      borderRadius: BOR_RAD08,
                      border: Border.all(color: AppColor.DIVIDER)),
                  child: Column(
                    children: [
                      CustomPasswordTextField(
                        formKey: controller.passwordKey,
                        obscureTextController:
                            controller.obscurePasswordController,
                        validator: AppValidator.validatePassword,
                        disableErrorText: true,
                        hintText: "Password",
                        onChanged: (value) {
                          controller.changePassword(value: value);
                          if (controller.passwordKey.currentState?.hasError ??
                              false) {
                            controller.passwordKey.currentState?.validate();
                          }
                          if (value != controller.confirmPassword.value &&
                              controller.confirmPassword.value.isNotEmpty) {
                            controller.confirmPasswordKey.currentState
                                ?.validate();
                          }
                        },
                      ),
                      const Padding(
                        padding: PAD_SYM_H16_V04,
                        child: Divider(
                          color: AppColor.GRAY_A4,
                          height: 1,
                        ),
                      ),
                      CustomPasswordTextField(
                        formKey: controller.confirmPasswordKey,
                        obscureTextController:
                            controller.obscureConfirmPasswordController,
                        disableErrorText: true,
                        hintText: "Confirm Password",
                        onChanged: (value) {
                          controller.changeConfirmPassword(value: value);
                          if (controller
                                  .confirmPasswordKey.currentState?.hasError ??
                              false) {
                            controller.confirmPasswordKey.currentState
                                ?.validate();
                          }
                        },
                        validator: (text) {
                          return null;
                        },
                      ),
                    ],
                  ),

                ),
                SIZED_BOX_H16,
                // Obx(() => Opacity(
                //   opacity: controller.invalidText != '' ? 1 : 0.5,
                //   child: AppButton(
                //     backgroundColor: AppColor.PRIMARY,
                //     title: 'Đăng ký',
                //   ),
                // )),
              ],
            ),
          ),
        ),
      ),
    );
  }

}
