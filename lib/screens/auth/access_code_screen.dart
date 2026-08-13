import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../../providers/realtime_provider.dart";

import "../../constants/app_spacing.dart";
import "../../constants/app_text.dart";

import "../../providers/auth_provider.dart";

import "../../widgets/common/app_button.dart";
import "../../widgets/common/app_error_card.dart";
import "../../widgets/common/app_logo.dart";
import "../../widgets/common/app_text_field.dart";

class AccessCodeScreen extends StatefulWidget {
  const AccessCodeScreen({
    super.key,
  });

  @override
  State<AccessCodeScreen> createState() =>
      _AccessCodeScreenState();
}

class _AccessCodeScreenState
    extends State<AccessCodeScreen> {
  final TextEditingController controller =
      TextEditingController();

  String? error;

  bool loading = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  /*
  |--------------------------------------------------------------------------
  | Login
  |--------------------------------------------------------------------------
  */

  Future<void> login() async {
    FocusScope.of(context).unfocus();

    /*
    |--------------------------------------------------------------------------
    | Normalize Access Code
    |--------------------------------------------------------------------------
    |
    | Keep the database format intact.
    |
    | Example:
    |
    | OPS-LKMQ-AFWZ
    |
    | Only remove leading/trailing whitespace and uppercase the value.
    |
    */

    final code =
        controller.text.trim().toUpperCase();

    if (code.isEmpty) {
      setState(() {
        error =
            "Please enter your access code.";
      });

      return;
    }

    setState(() {
      loading = true;
      error = null;
    });

    try {
      final auth =
          context.read<AuthProvider>();

      final realtime =
          context.read<RealtimeProvider>();

      await auth.login(
        code,
        realtime,
      );

      if (!mounted) {
        return;
      }

      Navigator.pushReplacementNamed(
        context,
        "/dashboard",
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        error =
            e.toString().replaceFirst(
                  "Exception: ",
                  "",
                );
      });
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  /*
  |--------------------------------------------------------------------------
  | Build
  |--------------------------------------------------------------------------
  */

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          Colors.white,

      body: SafeArea(
        child: Padding(
          padding:
              AppSpacing.page,

          child: Center(
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(
                maxWidth: 420,
              ),

              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,

                crossAxisAlignment:
                    CrossAxisAlignment.stretch,

                children: [
                  const AppLogo(),

                  AppSpacing.large,

                  const Text(
                    "Operations",
                    style:
                        AppText.pageTitle,
                  ),

                  AppSpacing.small,

                  const Text(
                    "Enter your staff access code to continue.",
                    style:
                        AppText.secondary,
                  ),

                  AppSpacing.section,

                  AppTextField(
                    label:
                        "Access Code",

                    hint:
                        "OPS-LKMQ-AFWZ",

                    controller:
                        controller,

                    autofocus:
                        true,

                    keyboardType:
                        TextInputType.visiblePassword,

                    textCapitalization:
                        TextCapitalization.characters,

                    textInputAction:
                        TextInputAction.done,

                    onSubmitted:
                        login,

                    onChanged:
                        (value) {
                      /*
                      |--------------------------------------------------------------------------
                      | Uppercase Only
                      |--------------------------------------------------------------------------
                      |
                      | DO NOT remove hyphens.
                      |
                      */

                      final upper =
                          value.toUpperCase();

                      if (upper != value) {
                        controller.value =
                            controller.value.copyWith(
                          text: upper,
                          selection:
                              TextSelection.collapsed(
                            offset:
                                upper.length,
                          ),
                        );
                      }

                      if (error != null) {
                        setState(() {
                          error = null;
                        });
                      }
                    },
                  ),

                  AppSpacing.item,

                  if (error != null)
                    Padding(
                      padding:
                          const EdgeInsets.only(
                        bottom: 16,
                      ),

                      child:
                          AppErrorCard(
                        title:
                            "Unable to sign in",

                        description:
                            error!,
                      ),
                    ),

                  AppButton(
                    text:
                        "Continue",

                    loading:
                        loading,

                    onPressed:
                        loading
                            ? null
                            : () {
                                login();
                              },
                  ),

                  AppSpacing.large,

                  const Center(
                    child: Text(
                      "Need help?\nContact your event organizer.",
                      textAlign:
                          TextAlign.center,
                      style:
                          AppText.secondary,
                    ),
                  ),

                  const SizedBox(
                    height: 32,
                  ),

                  const Center(
                    child: Text(
                      "Version 1.0.0",
                      style:
                          TextStyle(
                        color:
                            Colors.grey,
                        fontSize:
                            12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}