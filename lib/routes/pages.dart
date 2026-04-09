import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:untitled/modules/authen/sign_in_email_scene.dart';
import 'package:untitled/modules/authen/sign_up_scene.dart';
import 'package:untitled/modules/createNewItem/screate_new_note_scene.dart';
import 'package:untitled/modules/mainScene/main_scene.dart';
import 'package:untitled/modules/notePen/note_pen_scene.dart';
import 'package:untitled/modules/profile/profile_scene.dart';
import 'package:untitled/modules/record/record_player_scene.dart';
import 'package:untitled/modules/top/top_scene.dart';
import 'package:untitled/routes/routes.dart';

class Pages {
  static var pages = <GetPage>[
    GetPage(
      name: Routes.signInEmail,
      binding: SignInBinding(),
      page: () => const SignInScene(),
    ),

    GetPage(
      name: Routes.signUpEmail,
      binding: SignUpBinding(),
      page: () => const SignUpEmailScene(),
    ),

    GetPage(
      name: Routes.mainScene,
      binding: MainBinding(),
      page: () => const MainScene(),
    ),

    GetPage(
      name: Routes.createNote,
      binding: CreateNewNoteBinding(),
      page: () => CreateNewNote(),
    ),

    GetPage(
      name: Routes.notePen,
      binding: NotePenBinding(),
      page: () => NotePenScene(),
    ),

    GetPage(
      name: Routes.record,
      binding: RecordPlayerBinding(),
      page: () => RecordPlayerScene(),
    ),

    GetPage(
      name: Routes.topScreen,
      binding: TopBinding(),
      page: () => TopScene(),
    ),

    GetPage(
      name: Routes.profile,
      binding: ProfileBinding(),
      page: () => ProfileScene(),
    ),
  ];
}
