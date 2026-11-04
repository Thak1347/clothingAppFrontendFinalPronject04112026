// lib/firebase.dart
//
// Flavor-aware Firebase initialization.
// Picks the correct DefaultFirebaseOptions based on the active Flavor set
// in main_*.dart via F.appFlavor.
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options_dev.dart' as dev;
import 'firebase_options_staging.dart' as stg;
import 'firebase_options_production.dart' as prod;
import 'flavors.dart';

Future<void> initializeFirebaseApp() async {
  final FirebaseOptions options;
  switch (F.appFlavor) {
    case Flavor.dev:
      options = dev.DefaultFirebaseOptions.currentPlatform;
      break;
    case Flavor.staging:
      options = stg.DefaultFirebaseOptions.currentPlatform;
      break;
    case Flavor.prod:
      options = prod.DefaultFirebaseOptions.currentPlatform;
      break;
  }

  await Firebase.initializeApp(options: options);
}
