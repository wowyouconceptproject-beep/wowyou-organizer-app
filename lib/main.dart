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

import "theme/app_theme.dart";

void main() {
  runApp(
    MultiProvider(
      providers: [

        ChangeNotifierProvider(
          create: (_) =>
              AuthProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) =>
              ScanProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) =>
              ActivityProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) =>
              AnnouncementProvider(),
        ),

        ChangeNotifierProxyProvider2<
            ActivityProvider,
            AnnouncementProvider,
            RealtimeProvider>(
          create: (_) =>
              RealtimeProvider(),

          update: (
            context,
            activity,
            announcements,
            realtime,
          ) {
            realtime ??=
                RealtimeProvider();

            realtime.bindActivity(
              activity,
            );

            realtime.bindAnnouncements(
              announcements,
            );

            return realtime;
          },
        ),
      ],

      child:
          const OrganizerOpsApp(),
    ),
  );
}

class OrganizerOpsApp
    extends StatelessWidget {
  const OrganizerOpsApp({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return MaterialApp(
      debugShowCheckedModeBanner:
          false,

      title:
          "WowYou Operations",

      theme:
          AppTheme.light,

      initialRoute:
          "/",

      routes: {
        "/": (_) =>
            const SplashScreen(),

        "/login": (_) =>
            const AccessCodeScreen(),

        "/dashboard": (_) =>
            const DashboardScreen(),

        "/scan": (_) =>
            const ScanScreen(),

        "/activity": (_) =>
            const ActivityScreen(),

        "/announcements": (_) =>
            const AnnouncementScreen(),
      },
    );
  }
}