import 'package:get/get.dart';
import 'package:untitled/base/base_controller.dart';

import '../../models/account.dart';

class MainController extends BaseController {
  RxString facebookAccount = ''.obs;
  RxString userName = ''.obs;

  RxList<Account> socialAccounts = <Account>[
    Account(social: 'Facebook', name: 'hoanganh.fb', password: 'passFB123'),
    Account(social: 'Instagram', name: 'hoanganh.ig', password: 'insta456'),
    Account(social: 'Instagram', name: 'hoanganh.ig', password: 'insta456'),
    Account(social: 'Instagram', name: 'hoanganh.ig', password: 'insta456'),
    Account(social: 'Instagram', name: 'hoanganh.ig', password: 'insta456'),
    Account(social: 'Instagram', name: 'hoanganh.ig', password: 'insta456'),
    Account(social: 'Instagram', name: 'hoanganh.ig', password: 'insta456'),
    Account(social: 'Instagram', name: 'hoanganh.ig', password: 'insta456'),
    Account(social: 'Instagram', name: 'hoanganh.ig', password: 'insta456'),
  ].obs;}