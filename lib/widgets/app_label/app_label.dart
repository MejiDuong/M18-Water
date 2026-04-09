import 'package:flutter/material.dart';

import '../../theme/app_font.dart';
import '../../ultils/constant.dart';

class AppLabel extends StatelessWidget {
  final String label;
  final TextStyle? style;
  final bool showRequired;

  const AppLabel({
    super.key,
    required this.label,
    this.showRequired = false,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: style ??
                AppFont.textSize14.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          SIZED_BOX_W04,
          showRequired
              ? Text(
            "*",
            style: AppFont.textSize14.copyWith(
              color: Colors.red,
              fontWeight: FontWeight.w700,
            ),
          )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}
