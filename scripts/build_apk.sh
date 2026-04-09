cd ..
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs

#change flavor correct
flutter build apk --release --flavor dev -t lib/main.dart

open ./build/app/outputs/flutter-apk