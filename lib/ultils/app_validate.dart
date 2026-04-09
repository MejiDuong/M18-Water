
import 'const_string.dart';

class AppValidator {
  AppValidator._();

  static String? validateEmpty(String? input) {
    if (input == null || input.isEmpty) {
      return StringCst.emptyValidate;
    }
    return null;
  }

  static String? validateEmail(String? input) {
    if (input == null || input.isEmpty) return StringCst.emptyValidate;
    RegExp regex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    bool isValid = regex.hasMatch(input);
    if (!isValid) {
      return StringCst.emailValidate;
    }
    return null;
  }

  static String? validatePassword(String? input) {
    if (input == null || input.isEmpty) return StringCst.emptyValidate;
    RegExp regex = RegExp(r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)\S{8,}$");
    bool isValid = regex.hasMatch(input);
    if (!isValid) {
      return StringCst.passwordValidate;
    }
    return null;
  }

  static String? validateNickname(String? input) {
    if (input == null || input.isEmpty) return StringCst.emptyValidate;
    RegExp regex = RegExp(r"^[\S\s]+$");
    bool isValid = regex.hasMatch(input);
    if (!isValid) {
      return StringCst.nameValidate;
    }
    return null;
  }

  static String? validatePhone(String? input) {
    if (input == null || input.isEmpty) return StringCst.emptyValidate;
    RegExp regex = RegExp(r"^\d{10,}$");
    bool isValid = regex.hasMatch(input);
    if (!isValid) {
      return StringCst.phoneValidate;
    }
    return null;
  }

  static String? validatePhoneNotEmpty(String? input) {
    if (input == null || input.isEmpty) return null;
    RegExp regex = RegExp(r"^\d{10,}$");
    bool isValid = regex.hasMatch(input);
    if (!isValid) {
      return StringCst.phoneValidate;
    }
    return null;
  }

  static String? validateDateOfBirth(String? input) {
    if (input == null || input.isEmpty) {
      return StringCst.emptyValidate;
    }

    RegExp regex = RegExp(r"^\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$");
    if (!regex.hasMatch(input)) {
      return StringCst.dateOfBirthValidate;
    }

    DateTime? parsedDate;
    try {
      parsedDate = DateTime.parse(input);
    } catch (e) {
      return StringCst.dateOfBirthValidate;
    }
    if (parsedDate.isAfter(DateTime.now())) {
      return StringCst.futureDateValidate;
    }

    return null;
  }

  static String? validateMsg(String? input) {
    if (input == null || input.trim().isEmpty) {
      return "メールアドレスを入力してください。";
    }
    if (input.length > 500) {
      return "メールアドレスは500文字以内で入力してください。";
    }
    return null;
  }
}

