import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_color.dart';
import '../../ultils/app_validate.dart';
import '../../ultils/constant.dart';

class PasswordValidationWidget extends StatefulWidget {
  final Function(bool, String, String) onValidationChanged;

  const PasswordValidationWidget({Key? key, required this.onValidationChanged})
      : super(key: key);

  @override
  _PasswordValidationWidgetState createState() =>
      _PasswordValidationWidgetState();
}

class _PasswordValidationWidgetState extends State<PasswordValidationWidget> {
  final FocusNode _focusNode1 = FocusNode();
  final FocusNode _focusNode2 = FocusNode();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final RxBool _isPasswordValid = true.obs;
  final RxBool _obscurePassword = true.obs;
  final RxBool _obscureConfirmPassword = true.obs;
  final RxBool _hasInput = false.obs;
  final RxString _errorMessage = ''.obs;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_validatePassword);
    _confirmPasswordController.addListener(_validatePassword);
  }

  void _validatePassword() {
    _hasInput.value =
        _passwordController.text.isNotEmpty || _confirmPasswordController.text.isNotEmpty;

    final passwordError = AppValidator.validatePassword(_passwordController.text);
    final passwordsMatch = _passwordController.text == _confirmPasswordController.text;

    if (_hasInput.value) {
      if (passwordError != null) {
        _isPasswordValid.value = false;
        _errorMessage.value = 'パスワードは、少なくとも1つの小文字、1つの大文字、1つの数字を含む必要があり、8文字以上でなければなりません。';
      } else if (!passwordsMatch) {
        _isPasswordValid.value = false;
        _errorMessage.value = 'パスワードと確認用パスワードが一致しません。';
      } else {
        _isPasswordValid.value = true;
        _errorMessage.value = '';
      }
    } else {
      _isPasswordValid.value = true;
      _errorMessage.value = '';
    }

    widget.onValidationChanged(
      _isPasswordValid.value,
      _passwordController.text,
      _confirmPasswordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() => Container(
            padding: const EdgeInsets.only(left: 16.0, top: 6.0, right: 16.0),
            decoration: BoxDecoration(
              color: AppColor.BG_SEARCH,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                TextFormField(
                  focusNode: _focusNode1,
                  controller: _passwordController,
                  obscureText: _obscurePassword.value,
                  decoration: InputDecoration(
                    hintText: 'パスワード',
                    fillColor: AppColor.BG_SEARCH,
                    hintStyle: const TextStyle(color: AppColor.TEXT_GREY),
                    labelStyle: const TextStyle(color: AppColor.GRAY_A4),
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword.value
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppColor.TEXT_GREY_2,
                      ),
                      onPressed: () {
                        _obscurePassword.value = !_obscurePassword.value;
                      },
                    ),
                  ),
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_focusNode2);
                  },
                ),
                const Divider(color: AppColor.GRAY_A4, thickness: 1.0),
                TextFormField(
                  focusNode: _focusNode2,
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword.value,
                  decoration: InputDecoration(
                    hintText: 'パスワードの確認',
                    fillColor: AppColor.BG_SEARCH,
                    hintStyle: const TextStyle(color: AppColor.TEXT_GREY),
                    labelStyle: const TextStyle(color: AppColor.GRAY_A4),
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword.value
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppColor.TEXT_GREY_2,
                      ),
                      onPressed: () {
                        _obscureConfirmPassword.value =
                        !_obscureConfirmPassword.value;
                      },
                    ),
                  ),
                ),
              ],
            ),
          )),
          SIZED_BOX_H04,
          Obx(() => !_isPasswordValid.value && _hasInput.value
              ? Text(
            _errorMessage.value,
            style: const TextStyle(color: AppColor.ERROR, fontSize: 12),
          )
              : Container()),
        ],
      ),
    );
  }
}
