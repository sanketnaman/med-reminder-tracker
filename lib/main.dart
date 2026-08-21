import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'splash_screen.dart';
import 'alarm_service.dart';
import 'app_theme.dart';
import 'database_helper.dart';

final ValueNotifier<bool> darkModeNotifier = ValueNotifier(false);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await AlarmService.initialise();

  // Load dark mode setting
  final settings = await DatabaseHelper.instance.getUserSettings();
  AppTheme.isDark = settings.isDarkMode;
  darkModeNotifier.value = settings.isDarkMode;

  runApp(const MediaroApp());
}

class MediaroApp extends StatefulWidget {
  const MediaroApp({super.key});

  @override
  State<MediaroApp> createState() => _MediaroAppState();
}

class _MediaroAppState extends State<MediaroApp> {
  @override
  void initState() {
    super.initState();
    darkModeNotifier.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    darkModeNotifier.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: darkModeNotifier,
      builder: (context, isDark, _) {
        AppTheme.isDark = isDark;
        return MaterialApp(
          title: 'Mediaro',
          debugShowCheckedModeBanner: false,
          navigatorKey: appNavigatorKey,
          theme: AppTheme.theme,
          home: const SplashScreen(),
        );
      },
    );
  }
}
