class AppConfigs {
  AppConfigs._();

  static const String appName = "Circle App";

  ///API
  static String get baseUrl => Get.find<MainProvider>().flavorSettings.apiBaseUrl;

  ///instagram
  static const String clientID = '429323860205914';
  static const String appSecret = 'd96083584e6da68f5fe4666f78fa07d5';
  ///Business insta
  // static const String appSecret = '1105876567568128';
  // static const String appSecret = '743c06a7813af2b445f41e496de25f30';
  static const String redirectUri = 'https://www.ekspar.com.tr/';
  static const String scope = 'user_profile';
  static const String responseType = 'code';
  final String url =
      'https://api.instagram.com/oauth/authorize?client_id=$clientID&redirect_uri=$redirectUri&scope=user_profile,user_media&response_type=$responseType';

  ///Paging
  static const pageSize = 20;
  static const pageSizeMax = 1000;

  ///Cache extent
  static var cacheExtent = Get.height;

  ///DateFormat
  static const dateDisplayFormat = 'yyyy-MM-dd';
  static const dateTimeDisplayFormat = 'dd/MM/yyyy HH:mm';

  static const dateTimeAPIFormat = "YYYY-MM-DDThh:mm:ssTZD";
  static const dateAPIFormat = 'dd/MM/yyyy';

  ///Date range
  static final identityMinDate = DateTime(1900, 1, 1);
  static final identityMaxDate = DateTime.now();
  static final birthMinDate = DateTime(1900, 1, 1);
  static final birthMaxDate = DateTime.now();

  ///Max file
  static const maxAttachFile = 5;

  static const scrollThreshold = 500.0;

  static String getName0sType() {
    if (Platform.isAndroid) {
      return "android";
    }
    if (Platform.isIOS) {
      return "apple";
    }
    return "";
  }
}
