import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../theme/app_color.dart';
import '../theme/app_font.dart';
import '../widgets/app_button.dart';
import 'base_controller.dart';

class BaseScaffold<T extends BaseController> extends StatelessWidget {
  const BaseScaffold({
    Key? key,
    required this.body,
    this.fab,
    this.fabLocation,
    this.tag,
    this.backgroundColor,
    this.appbarBackgroundColor,
    this.safeAreaBottom = true,
    this.safeAreaTop = true,
    this.hasAppBar = false,
    this.automaticallyImplyLeading = true,
    this.leading,
    this.elevation,
    this.title,
    this.titleWidget,
    this.actionButtons,
    this.customAppBar,
    this.bottomAppBar,
    this.onPop,
    this.canPop = true,
    this.showBellIcon = false,
    this.bellIconRoute,
    this.resize = true,
    this.showBackIcon = true,
    this.hasDivider = false,
    this.showDeleteButton = false,
    this.showRightButton = false,
    this.rightButtonTitle = '',
    this.onRightButton,
    this.onDelete,
  }) : super(key: key);

  final String? tag;
  final Widget body;
  final Widget? fab;
  final Color? backgroundColor;
  final Color? appbarBackgroundColor;
  final FloatingActionButtonLocation? fabLocation;
  final bool safeAreaBottom;
  final bool safeAreaTop;
  final bool hasAppBar;
  final bool canPop;
  final Function()? onPop;
  final bool automaticallyImplyLeading;
  final String? title;
  final List<Widget>? actionButtons;
  final PreferredSizeWidget? customAppBar;
  final Widget? leading;
  final Widget? titleWidget;
  final PreferredSize? bottomAppBar;
  final bool showBellIcon;
  final double? elevation;
  final String? bellIconRoute;
  final bool? resize;
  final bool showBackIcon;
  final bool hasDivider;
  final bool showDeleteButton;
  final bool showRightButton;
  final String rightButtonTitle;
  final Function()? onDelete;
  final Function()? onRightButton;

  T get controller => GetInstance().find<T>(tag: tag);

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: const TextScaler.linear(1)),
      child: WillPopScope(
        onWillPop: () async {
          return canPop;
        },
        child: Scaffold(
          resizeToAvoidBottomInset: resize,
          backgroundColor: backgroundColor ?? AppColor.BACKGROUND,
          appBar: hasAppBar ? (customAppBar ?? buildAppBar()) : null,
          body: SafeArea(
            bottom: safeAreaBottom,
            top: safeAreaTop,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => controller.hideKeyboard(),
              child: Stack(
                children: [
                  Positioned.fill(child: body),
                  if (hasDivider)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 1,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: AppColor.DIVIDER.withOpacity(1),
                              blurRadius: 1,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          floatingActionButton: fab,
          floatingActionButtonLocation: fabLocation,
        ),
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
      elevation: elevation ?? 0.0,
      leading: showBackIcon
          ? Padding(
        padding: const EdgeInsets.only(left: 16, top: 20),
        child: InkWell(
          highlightColor: Colors.transparent,
          onTap: onPop ?? () => Get.back(),
          child: SvgPicture.asset(
            'assets/vectors/ic_back.svg',
            width: 24,
            height: 24,
            color: AppColor.TEXT_COLOR,
          ),
        ),
      )
          : null,
      titleSpacing: 0,
      bottom: bottomAppBar,
      iconTheme: const IconThemeData(color: AppColor.BACKGROUND),
      backgroundColor: appbarBackgroundColor ?? Colors.white,
      surfaceTintColor: Colors.white,
      title: (title != null)
          ? titleWidget ??
          Text(
            title ?? "",
            style: AppFont.textSize16.copyWith(
                color: AppColor.TEXT_BLACK, fontWeight: FontWeight.w700),
          )
          : const SizedBox(),
      actions: [
        if (actionButtons != null) ...actionButtons!,
        if (showDeleteButton)
          Padding(
            padding: const EdgeInsets.only(right: 16, bottom: 0),
            child: AppButton(
              height: 28,
              width: 76,
              backgroundColor: AppColor.TEXT_WARNING,
              onPressed: onDelete,
              // x),
              title: 'キャンセル',
              textStyle: AppFont.textSize18.copyWith(
                color: Colors.white,
                fontSize: 12,
              ),
              cornerRadius: 6,
            ),
          ),
        if (showRightButton)
          Padding(
            padding: const EdgeInsets.only(right: 16, bottom: 0),
            child: AppButton(
              height: 28,
              width: 76,
              backgroundColor: AppColor.BACKGROUND,
              onPressed: onRightButton,
              // x),
              title: rightButtonTitle ?? '',
              textStyle: AppFont.textSize14.copyWith(
                  color: AppColor.TEXT_GREY_2, fontWeight: FontWeight.w500),
              cornerRadius: 6,
            ),
          ),
        if (showBellIcon)
          Padding(
            padding: const EdgeInsets.only(right: 13, bottom: 8),
            child: IconButton(
              icon: const Icon(Icons.notifications, color: AppColor.BACKGROUND),
              onPressed: () {
                if (bellIconRoute != null) {
                  Get.toNamed(bellIconRoute!);
                }
              },
            ),
          ),
      ],
    );
  }
}
