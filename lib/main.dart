import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/services/notification_service.dart';
import 'core/services/reminder_preferences_service.dart';
import 'core/theme/app_theme.dart';
import 'features/home/main_navigation_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://wcgjdpxgajidhcqnaium.supabase.co',
    publishableKey: 'sb_publishable_zQyMCUny3P2l39Iqvg5pjw_OePYBFqq',
  );

  await NotificationService.init();
  final reminderSettings = await ReminderPreferencesService.getSettings();
  await NotificationService.applySchedule(reminderSettings);

  final launchDetails = await NotificationService.getLaunchDetails();
  final didNotificationLaunch =
      launchDetails?.didNotificationLaunchApp ?? false;
  final initialIndex = didNotificationLaunch ? 2 : 0;

  runApp(ProviderScope(child: MyApp(initialIndex: initialIndex)));
}

class MyApp extends StatelessWidget {
  final int initialIndex;

  const MyApp({super.key, this.initialIndex = 0});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: NotificationService.navigatorKey,
      title: 'MindTrack',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: MainNavigationScreen(
        key: MainNavigationScreen.navKey,
        initialIndex: initialIndex,
      ),
    );
  }
}
