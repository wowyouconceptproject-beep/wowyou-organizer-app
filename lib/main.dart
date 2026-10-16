import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "providers/auth_provider.dart";
import "providers/scan_provider.dart";
import "providers/activity_provider.dart";
import "providers/announcement_provider.dart";
import "providers/realtime_provider.dart";

import "screens/auth/access_code_screen.dart";
import "screens/auth/splash_screen.dart";

import "screens/dashboard/dashboard_screen.dart";
import "screens/scan/scan_screen.dart";
import "screens/activity/activity_screen.dart";
import "screens/announcements/announcement_screen.dart";

// Operations screens
import "screens/passes/pass_verification_screen.dart";
import "screens/attendees/attendee_search_screen.dart";
import "screens/reports/reports_screen.dart";
import "screens/pulse/event_pulse_screen.dart";

import "theme/app_theme.dart";

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ScanProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ActivityProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => AnnouncementProvider(),
        ),
        ChangeNotifierProxyProvider2<
            ActivityProvider,
            AnnouncementProvider,
            RealtimeProvider>(
          create: (_) => RealtimeProvider(),
          update: (
            context,
            activity,
            announcements,
            realtime,
          ) {
            final provider = realtime ?? RealtimeProvider();

            provider.bindActivity(activity);
            provider.bindAnnouncements(announcements);

            return provider;
          },
        ),
      ],
      child: const OrganizerOpsApp(),
    ),
  );
}

class OrganizerOpsApp extends StatelessWidget {
  const OrganizerOpsApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "WowYou Operations",
      theme: AppTheme.light,
      initialRoute: "/",
      routes: {
        "/": (_) => const SplashScreen(),
        "/login": (_) => const AccessCodeScreen(),
        "/dashboard": (_) => const DashboardScreen(),
        "/scan": (_) => const ScanScreen(),
        "/verify-pass": (_) => const PassVerificationScreen(),
        "/search-attendee": (_) => const AttendeeSearchScreen(),
        "/reports": (_) => const ReportsScreen(),
        "/activity": (_) => const ActivityScreen(),
        "/announcements": (_) => const AnnouncementScreen(),
        "/event-pulse": (_) => const EventPulseScreen(),
      },
    );
  }
}