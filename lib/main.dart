import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'splash_screen.dart';
import 'alarm_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await AlarmService.initialise();
  runApp(const MediaroApp());
}

class MediaroApp extends StatelessWidget {
  const MediaroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mediaro',
      debugShowCheckedModeBanner: false,
      navigatorKey: appNavigatorKey,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF5B8DEF),
        scaffoldBackgroundColor: const Color(0xFFF3F6FF),
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5B8DEF),
          primary: const Color(0xFF5B8DEF),
          secondary: const Color(0xFF7BA7F7),
          tertiary: const Color(0xFF20C9D8),
          background: const Color(0xFFF3F6FF),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
