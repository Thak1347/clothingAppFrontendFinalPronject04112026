// lib/main_staging.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/app.dart';
import 'core/storage/prefs_storage.dart';
import 'firebase.dart';
import 'flavors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  F.appFlavor = Flavor.staging;
  await initializeFirebaseApp();
  final prefs = await PrefsStorage.init();
  Get.put<PrefsStorage>(prefs, permanent: true);
  runApp(const MainApp());
}
