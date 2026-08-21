import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'l10n/generated/app_localizations.dart';
import 'splash_screen.dart';
import 'alarm_service.dart';
import 'app_theme.dart';
import 'database_helper.dart';

final ValueNotifier<bool> darkModeNotifier = ValueNotifier(false);
final ValueNotifier<Locale> localeNotifier = ValueNotifier(const Locale('en'));

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await AlarmService.initialise();

  // Load dark mode and language settings
  final settings = await DatabaseHelper.instance.getUserSettings();
  AppTheme.isDark = settings.isDarkMode;
  darkModeNotifier.value = settings.isDarkMode;

  // Set initial locale from saved language
  if (settings.language == 'Hindi') {
    localeNotifier.value = const Locale('hi');
  }

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
    darkModeNotifier.addListener(_onChanged);
    localeNotifier.addListener(_onChanged);
  }

  @override
  void dispose() {
    darkModeNotifier.removeListener(_onChanged);
    localeNotifier.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: darkModeNotifier,
      builder: (context, isDark, _) {
        AppTheme.isDark = isDark;
        return ValueListenableBuilder<Locale>(
          valueListenable: localeNotifier,
          builder: (context, locale, _) {
            return MaterialApp(
              title: 'Mediaro',
              debugShowCheckedModeBanner: false,
              navigatorKey: appNavigatorKey,
              theme: AppTheme.theme,
              locale: locale,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              home: const SplashScreen(),
            );
          },
        );
      },
    );
  }
}
