import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_color.dart';
import '../../theme/app_font.dart';
import '../../ultils/constant.dart';

class CustomFormField extends StatefulWidget {
  const CustomFormField({
    super.key,
    this.hintText,
    this.keyboardType,
    this.suffixIcon,
    this.isReadOnly,
    this.onTap,
    this.onTapOutside,
    this.onChanged,
    this.onSubmitted,
    this.controller,
    this.focusNode,
    this.showCounter = false,
    this.maxLength,
    this.maxLines = 1,
    this.minLines = 1,
    this.inputFormatters,
    this.validator,
    this.autovalidateMode,
    this.enabledBorderColor,
    this.focusedBorderColor,
    this.focusedErrorBorderColor,
    this.errorBorderColor,
    this.textColor,
    this.textAlign,
    this.hintColor,
    this.borderRadius,
    this.textInputAction,
    this.prefixIcon,
    this.fillColor,
    this.textDirection,
    this.contentPadding,
    this.formKey,
    this.disableErrorText = false,
    this.textfieldHeight,
    this.initialValue,
  });

  final VoidCallback? onTap;
  final void Function(PointerDownEvent)? onTapOutside;
  final void Function(String text)? onSubmitted;
  final void Function(String text)? onChanged;
  final String? Function(String? value)? validator;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final List<TextInputFormatter>? inputFormatters;
  final AutovalidateMode? autovalidateMode;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final String? hintText;
  final TextAlign? textAlign;
  final TextInputType? keyboardType;
  final bool? isReadOnly;
  final bool showCounter;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final Color? enabledBorderColor;
  final Color? focusedBorderColor;
  final Color? focusedErrorBorderColor;
  final Color? errorBorderColor;
  final Color? textColor;
  final Color? hintColor;
  final Color? fillColor;
  final BorderRadius? borderRadius;
  final TextInputAction? textInputAction;
  final TextDirection? textDirection;
  final EdgeInsets? contentPadding;
  final Key? formKey;
  final bool disableErrorText;
  final double? textfieldHeight;
  final String? initialValue;

  @override
  State<CustomFormField> createState() => _CustomFormFieldState();
}

class _CustomFormFieldState extends State<CustomFormField> {
  final TextEditingController _defaultController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _defaultController.text = widget.initialValue ?? "";
    widget.controller?.addListener(() {
      if (!mounted) return;
      setState(() {});
    });
    _defaultController.addListener(() {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    _defaultController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: widget.formKey,
      textDirection: widget.textDirection,
      textInputAction: widget.textInputAction,
      validator: widget.validator,
      autovalidateMode: widget.autovalidateMode,
      buildCounter: _counterBuilder,
      maxLength: widget.maxLength ?? 1000,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      textAlign: widget.textAlign ?? TextAlign.start,
      focusNode: widget.focusNode,
      controller: widget.controller ?? _defaultController,
      onChanged: widget.onChanged,
      onTapOutside: widget.onTapOutside,
      onTap: widget.onTap,
      onFieldSubmitted: widget.onSubmitted,
      readOnly: widget.isReadOnly ?? false,
      style: AppFont.textSize14.copyWith(color: widget.textColor),
      decoration: InputDecoration(
        filled: true,
        fillColor: widget.fillColor ?? AppColor.BG_SEARCH,
        suffixIcon: widget.suffixIcon,
        prefixIcon: widget.prefixIcon,
        contentPadding: widget.contentPadding ?? PAD_SYM_H16_V14,
        hintText: widget.hintText,
        errorMaxLines: 3,
        hintStyle: AppFont.textSize14.copyWith(
            color: widget.hintColor ?? AppColor.DIVIDER),
        errorStyle: widget.disableErrorText
            ? const TextStyle(color: Colors.transparent, fontSize: 0, height: 0)
            : AppFont.textSize14.copyWith(color: AppColor.ERROR, height: 0),
        enabledBorder: OutlineInputBorder(
          borderRadius: widget.borderRadius ?? BOR_RAD08,
          borderSide: BorderSide(
            width: 1,
            color: widget.enabledBorderColor ?? AppColor.DIVIDER,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: widget.borderRadius ?? BOR_RAD08,
          borderSide: BorderSide(
            width: 1,
            color: widget.focusedBorderColor ?? AppColor.DIVIDER,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: widget.borderRadius ?? BOR_RAD08,
          borderSide: BorderSide(
            width: 1,
            color: widget.focusedErrorBorderColor ?? AppColor.DIVIDER,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: widget.borderRadius ?? BOR_RAD08,
          borderSide: BorderSide(
            width: 1,
            color: widget.errorBorderColor ?? Colors.transparent,
          ),
        ),
      ),
      keyboardType: widget.keyboardType,
      inputFormatters: [
        LengthLimitingTextInputFormatter(
          widget.maxLength,
        ),
        if (widget.inputFormatters?.isNotEmpty ?? false)
          ...widget.inputFormatters!,
      ],
    );
  }

  Widget? _counterBuilder(context,
      {required currentLength, required isFocused, required maxLength}) {
    return widget.showCounter
        ? Text(
            "$currentLength / $maxLength",
            style: AppFont.textSize12.copyWith(
                height: 0,
                color: AppColor.OUTER_BORDER,
                fontFamily: "SVN-Gilroy"),
          )
        : null;
  }
}