import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../../providers/auth_provider.dart";
import "../../providers/realtime_provider.dart";

import "../../widgets/common/app_loader.dart";
import "../../widgets/common/app_logo.dart";

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
  });

  @override
  State<SplashScreen> createState() =>
      _SplashScreenState();
}

class _SplashScreenState
    extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => checkSession(),
    );
  }

  Future<void> checkSession() async {
    final auth =
        context.read<AuthProvider>();

    final realtime =
        context.read<RealtimeProvider>();

    final loggedIn =
        await auth.restoreSession(
      realtime,
    );

    if (!mounted) {
      return;
    }

    if (loggedIn) {
      Navigator.pushReplacementNamed(
        context,
        "/dashboard",
      );
    } else {
      Navigator.pushReplacementNamed(
        context,
        "/login",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              AppLogo(),
              SizedBox(height: 48),
              AppLoader(
                message: "Loading...",
              ),
            ],
          ),
        ),
      ),
    );
  }
}