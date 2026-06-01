import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:oulta/features/home/community_controller.dart';
import 'package:oulta/features/presentation/account/controller/account_controller.dart';
import 'package:oulta/features/presentation/social/controller/social_controller.dart';
import 'package:oulta/features/search/search_controller.dart';

import 'features/data/social/services/firebase_service.dart';
import 'app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  // Set preferred orientations to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Supabase.initialize(
    url: 'https://ogqimqvcbnndjmufpaaj.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9ncWltcXZjYm5uZGptdWZwYWFqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjYxNTA3NzAsImV4cCI6MjA4MTcyNjc3MH0.HqAnfuXhcsehhVRiL__OGuDHJv5cUWV5ZZSidcrT0IY',
  );

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize core controllers globally so they are always available.
  Get.put(NameController());
  Get.put(FirebaseService());
  Get.put(CommunityController());
  Get.put(SocialController());
  Get.put(UserSearchController());

  final prefs = await SharedPreferences.getInstance();
  final hasSeenWelcome = prefs.getBool('hasSeenWelcome') ?? false;

  runApp(MyApp(hasSeenWelcome: hasSeenWelcome));
}
