# evolv_mobile

Home Mobile application to monitor the medication and Health data.

## Getting Started

Build steps:
- `flutter clean` - removes the build files
- `flutter pub get` - sync up the dependencies
- `flutter run` - runs flutter application locally (flutter web/ connected devices)
- `flutter build apk --flavor dev --release --dart-define=ENV=dev` - Will generate release apk / optional local, dev, prod
- `adb install .\build\app\outputs\flutter-apk\app-dev-release.apk`

Debug Steps:
1. `setx PUB_CACHE D:\PubCache` if this and base files have different roots issue arises
