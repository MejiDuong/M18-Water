import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../theme/app_color.dart';
import '../../theme/app_font.dart';
import '../../ultils/constant.dart';

class ObscureTextController extends ValueNotifier<bool> {
  ObscureTextController({bool obscureText = true}) : super(obscureText);

  bool get obscureText => value;

  set obscureText(bool value) {
    this.value = value;
  }
}

class CustomPasswordTextField extends StatelessWidget {
  final TextEditingController? controller;
  final ObscureTextController obscureTextController;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final String? Function(String?)? validator;
  final String? hintText;
  final FocusNode? focusNode;
  final TextStyle? style;
  final EdgeInsets? padding;
  final TextStyle? hintStyle;
  final TextStyle? errorStyle;
  final BorderRadius? borderRadius;
  final AutovalidateMode? autovalidateMode;
  final Color? enabledBorderColor;
  final Color? focusedBorderColor;
  final Color? focusedErrorBorderColor;
  final Color? errorBorderColor;
  final Key? formKey;
  final Color? fillColor;
  final Color? visibilityColor;
  final bool disableErrorText;

  const CustomPasswordTextField({
    super.key,
    this.controller,
    required this.obscureTextController,
    this.onFieldSubmitted,
    this.validator,
    this.onChanged,
    this.hintText,
    this.focusNode,
    this.style,
    this.padding,
    this.hintStyle,
    this.borderRadius,
    this.errorStyle,
    this.autovalidateMode,
    this.enabledBorderColor,
    this.focusedBorderColor,
    this.focusedErrorBorderColor,
    this.errorBorderColor,
    this.formKey,
    this.fillColor,
    this.visibilityColor,
    this.disableErrorText = false,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: obscureTextController,
      builder: (context, bool obscureText, child) {
        return TextFormField(
          key: formKey,
          controller: controller,
          focusNode: focusNode,
          style: style ?? AppFont.textSize14,
          autovalidateMode: autovalidateMode,
          decoration: InputDecoration(
            contentPadding: padding ?? PAD_SYM_H16_V14,
            hintText: hintText,
            hintStyle: hintStyle ??
                AppFont.textSize14.copyWith(color: AppColor.DIVIDER),
            errorMaxLines: 3,
            errorStyle: disableErrorText
                ? const TextStyle(color: Colors.transparent, fontSize: 0, height: 0)
                : AppFont.textSize14.copyWith(color: AppColor.ERROR),
            filled: true,
            fillColor: fillColor ?? AppColor.BG_SEARCH,
            enabledBorder: OutlineInputBorder(
              borderRadius: borderRadius ?? BOR_RAD08,
              borderSide: BorderSide(
                width: 1,
                color: enabledBorderColor ?? Colors.transparent,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: borderRadius ?? BOR_RAD08,
              borderSide: BorderSide(
                width: 1,
                color: focusedBorderColor ?? Colors.transparent,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: borderRadius ?? BOR_RAD08,
              borderSide: BorderSide(
                width: 1,
                color: focusedErrorBorderColor ?? Colors.transparent,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: borderRadius ?? BOR_RAD08,
              borderSide: BorderSide(
                width: 1,
                color: errorBorderColor ?? Colors.transparent,
              ),
            ),
            // Inside your widget's build method
            suffixIcon: IconButton(
              splashRadius: 24,
              onPressed: () {
                obscureTextController.obscureText = !obscureText;
              },
              icon: obscureText
                  ? SvgPicture.asset(
                'assets/vectors/ic_vision.svg',
                color: AppColor.TEXT_GREY_2,
              )
                  : SvgPicture.asset(
                'assets/vectors/ic_vision_off.svg',
                color: visibilityColor ?? AppColor.TEXT_GREY_2,
              ),
            ),
          ),
          keyboardType: TextInputType.visiblePassword,
          onChanged: onChanged,
          obscureText: obscureText,
          validator: validator,
          onFieldSubmitted: onFieldSubmitted,
        );
      },
    );
  }
}
