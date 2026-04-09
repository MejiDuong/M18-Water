
class StringCst {
  // Common text
  static const login = "ログイン";
  static const email = "email";
  static const search = "検索したいキーワードを入力、カテゴリ検索";
  static const error = "予期せぬエラーが発生しました"; //QA
  static const reset = "再設定する";

  //title
  static const myPageTitle = "マイプロフィール";
  static const adMyPageTitle = "マイページ";
  static const adminList = "管理者一覧";
  static const errorTitle = "データ読み込みに失敗しました";
  static const emptyDataTitle = "データはありません";
  static const contactTitle = "入会 / お問い合わせ";
  static const accountTitle = "アカウント";
  static const fileTitle = "プロフィール";
  static const signInTitle = "ログイン";
  static const forgotPassword = "パスワードを忘れた方はこちら";
  static const signUpTitle = "アカウントをお持ちでない方は";
  static const signUpRoute = "アカウント登録";
  static const resetPassword = "パスワードの再設定";
  static const limitedJoiner = "このイベントは申し込み上限に達しました";
  static const updateUserSuccess = "プロフィールを編集しました";
  static const userInfoNotChange = "更新事項はございません";
  static const passwordUnMatch = "パスワードが一致しません";
  static const pullToRefresh = "スクロールしてデータをリロードしてください";
  static const releaseToRefresh = "指を離してデータをリロードしてください";
  static const loading = "読み込み中";
  static const done = "完了する";
  static const pleaseTryAgain = "不明な問題が発生しました。もう一度試行してください。";
  static var permissionDialogTitle =
      "写真ライブラリまたはカメラへのアクセスができません。写真ライブラリまたはカメラへのアクセスを許可してください。";


  static String sentOtpToEmail(String email) {
    return "認証コードを$emailに送付しました。\nメールに届いた6桁の認証コードを入力してください。";
  }

  static String sentOtpToSMS(String phone) {
    return "$phone宛にSMSを送信しました。メッセージに記載された６桁の認証コードを確認し、入力してください。";
  }

  // Validator text
  static const emptyValidate = 'この項目を入力してください';
  static const emailValidate = "メールアドレスの形式で入力してください";
  static const passwordValidate =
      "英大文字、英小文字および数字の1文字以上含む8~16文字（すべて半角）で入力してください。";
  static const nameValidate =
      "ひらがな、カタカナ、漢字または英大文字、英小文字および数字（0~9）を含む1~16文字（すべて半角）で入力してください。";
  static const phoneValidate = "10～11桁の数字で入力してください";
  static const dateOfBirthValidate = '有効な生年月日をYYYY-MM-DD形式で入力してください。';
  static const futureDateValidate = '生年月日が未来の日付であってはいけません。';
  static const tooOldDateValidate = '生年月日が現実的ではありません。';
  static const UNKNOWN_ERROR = 'UNKNOWN_ERROR。 dich';
  static const SEND_MESSAGE_ERROR = 'メッセージの送信に失敗しました';
  static const SNS_VALIDATE_ERROR = 'SNSリンクの形式が正しくありません';

  static String maskPhone(String phoneNumber) {
    if (phoneNumber.length < 10) return "";
    final end =
    phoneNumber.substring(phoneNumber.length - 3, phoneNumber.length);
    if (phoneNumber.length == 10) {
      return "*******$end";
    }
    if (phoneNumber.length == 11) {
      return "********$end";
    }
    return "";
  }

  static String maskEmail(String email) {
    List<String> parts = email.split('@');

    if (parts.length == 2) {
      String start = parts[0];
      String end = parts[1];
      String replaceStart = '*' * start.length;
      return "$replaceStart@$end";
    } else {
      return email;
    }
  }
}
