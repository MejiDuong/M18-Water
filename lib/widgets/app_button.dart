import 'package:flutter/material.dart';

import '../theme/app_color.dart';
import '../theme/app_font.dart';
import 'loading/app_loading_indicator.dart';

class AppButton extends StatelessWidget {
  //Attributes
  final String title;
  final double width;
  final double height;
  final double borderWidth;
  final double cornerRadius;
  final Color? borderColor;
  final Color backgroundColor;
  final Color disableColor;
  final Color disableBackgroundColor;
  final TextStyle textStyle;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  //Child widgets
  final Widget? leadingIcon;
  final Widget? trailingIcon;

  //Status
  final bool isLoading;

  //Action & callback
  final VoidCallback? onPressed;

  final List<BoxShadow>? boxShadow;

  final bool isEnabled;

  const AppButton({
    super.key,
    this.title = "",
    this.width = double.infinity,
    this.height = 46,
    this.borderWidth = 0,
    this.cornerRadius = 8,
    this.borderColor,
    this.backgroundColor = AppColor.PRIMARY,
    this.disableColor = AppColor.DIVIDER,
    this.disableBackgroundColor = AppColor.PRIMARY,
    this.textStyle = AppFont.textSize14,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.onPressed,
    this.boxShadow,
    this.margin,
    this.padding,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(cornerRadius),
        border: borderColor != null
            ? Border.all(
          color: borderColor!,
          width: borderWidth,
        )
            : null,
        boxShadow: boxShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          cornerRadius,
        ),
        child: Material(
          color: isEnabled ? backgroundColor : disableColor,
          borderRadius: BorderRadius.circular(
            cornerRadius,
          ),
          child: InkWell(
            onTap: isEnabled ? onPressed : null,
            child: Padding(
              padding: padding ?? EdgeInsets.zero,
              child: _buildChildWidget(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChildWidget() {
    if (isLoading) {
      return const AppCircularProgressIndicator();
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          leadingIcon ?? Container(),
          Expanded(
            child: Center(
              child: title.isNotEmpty
                  ? Text(
                title,
                style: textStyle,
              )
                  : Container(),
            ),
          ),
          trailingIcon ?? Container(),
        ],
      );
    }
  }
}
