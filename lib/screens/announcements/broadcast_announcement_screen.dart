import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../../providers/announcement_provider.dart";
import "../../providers/auth_provider.dart";

class BroadcastAnnouncementScreen
    extends StatefulWidget {
  const BroadcastAnnouncementScreen({
    super.key,
  });

  @override
  State<BroadcastAnnouncementScreen>
      createState() =>
          _BroadcastAnnouncementScreenState();
}

class _BroadcastAnnouncementScreenState
    extends State<
        BroadcastAnnouncementScreen> {
  final title =
      TextEditingController();

  final message =
      TextEditingController();

  String type = "INFO";

  String priority = "NORMAL";

  String audience = "ALL";

  bool pinned = false;

  bool submitting = false;

  @override
  void dispose() {
    title.dispose();
    message.dispose();

    super.dispose();
  }

  Future<void> _broadcast() async {
    final auth =
        context.read<AuthProvider>();

    /*
    |--------------------------------------------------------------------------
    | Permission Guard
    |--------------------------------------------------------------------------
    */

    if (!auth.canSendAnnouncement) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            "You do not have permission to send announcements.",
          ),
        ),
      );

      return;
    }

    /*
    |--------------------------------------------------------------------------
    | Validation
    |--------------------------------------------------------------------------
    */

    final titleText =
        title.text.trim();

    final messageText =
        message.text.trim();

    if (titleText.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            "Please enter an announcement title.",
          ),
        ),
      );

      return;
    }

    if (messageText.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            "Please enter an announcement message.",
          ),
        ),
      );

      return;
    }

    if (submitting) {
      return;
    }

    setState(() {
      submitting = true;
    });

    try {
      final provider =
          context.read<
              AnnouncementProvider>();

      await provider.create(
  title: titleText,
  message: messageText,
  type: type,
  priority: priority,
  audience: audience,
  isPinned: pinned,
  auth: context.read<AuthProvider>(),
);

      if (!mounted) {
        return;
      }

      Navigator.of(
        context,
      ).pop();
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            error
                .toString()
                .replaceFirst(
                  "Exception: ",
                  "",
                ),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          submitting = false;
        });
      }
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final auth =
        context.watch<AuthProvider>();

    /*
    |--------------------------------------------------------------------------
    | Permission Guard
    |--------------------------------------------------------------------------
    */

    if (!auth.canSendAnnouncement) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Broadcast",
          ),
        ),
        body: const Center(
          child: Padding(
            padding:
                EdgeInsets.all(24),
            child: Text(
              "You do not have permission to send announcements.",
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color:
                    Colors.black54,
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Broadcast",
        ),
      ),

      body: ListView(
        padding:
            const EdgeInsets.all(20),

        children: [
          /*
          |--------------------------------------------------------------------------
          | Title
          |--------------------------------------------------------------------------
          */

          TextField(
            controller: title,

            enabled:
                !submitting,

            decoration:
                const InputDecoration(
              labelText:
                  "Title",
            ),
          ),

          const SizedBox(
            height: 16,
          ),

          /*
          |--------------------------------------------------------------------------
          | Message
          |--------------------------------------------------------------------------
          */

          TextField(
            controller: message,

            enabled:
                !submitting,

            maxLines: 5,

            decoration:
                const InputDecoration(
              labelText:
                  "Message",
            ),
          ),

          const SizedBox(
            height: 20,
          ),

          /*
          |--------------------------------------------------------------------------
          | Type
          |--------------------------------------------------------------------------
          */

          InputDecorator(
            decoration:
                const InputDecoration(
              labelText:
                  "Type",
            ),

            child:
                DropdownButtonHideUnderline(
              child:
                  DropdownButton<String>(
                value: type,

                isExpanded:
                    true,

                items:
                    const [
                  DropdownMenuItem<
                      String>(
                    value:
                        "INFO",
                    child:
                        Text(
                      "Info",
                    ),
                  ),
                  DropdownMenuItem<
                      String>(
                    value:
                        "SUCCESS",
                    child:
                        Text(
                      "Success",
                    ),
                  ),
                  DropdownMenuItem<
                      String>(
                    value:
                        "WARNING",
                    child:
                        Text(
                      "Warning",
                    ),
                  ),
                  DropdownMenuItem<
                      String>(
                    value:
                        "EMERGENCY",
                    child:
                        Text(
                      "Emergency",
                    ),
                  ),
                ],

                onChanged:
                    submitting
                        ? null
                        : (value) {
                            if (value ==
                                null) {
                              return;
                            }

                            setState(() {
                              type =
                                  value;
                            });
                          },
              ),
            ),
          ),

          const SizedBox(
            height: 16,
          ),

          /*
          |--------------------------------------------------------------------------
          | Priority
          |--------------------------------------------------------------------------
          */

          InputDecorator(
            decoration:
                const InputDecoration(
              labelText:
                  "Priority",
            ),

            child:
                DropdownButtonHideUnderline(
              child:
                  DropdownButton<String>(
                value:
                    priority,

                isExpanded:
                    true,

                items:
                    const [
                  DropdownMenuItem<
                      String>(
                    value:
                        "LOW",
                    child:
                        Text(
                      "Low",
                    ),
                  ),
                  DropdownMenuItem<
                      String>(
                    value:
                        "NORMAL",
                    child:
                        Text(
                      "Normal",
                    ),
                  ),
                  DropdownMenuItem<
                      String>(
                    value:
                        "HIGH",
                    child:
                        Text(
                      "High",
                    ),
                  ),
                  DropdownMenuItem<
                      String>(
                    value:
                        "CRITICAL",
                    child:
                        Text(
                      "Critical",
                    ),
                  ),
                ],

                onChanged:
                    submitting
                        ? null
                        : (value) {
                            if (value ==
                                null) {
                              return;
                            }

                            setState(() {
                              priority =
                                  value;
                            });
                          },
              ),
            ),
          ),

          const SizedBox(
            height: 16,
          ),

          /*
          |--------------------------------------------------------------------------
          | Audience
          |--------------------------------------------------------------------------
          */

          InputDecorator(
            decoration:
                const InputDecoration(
              labelText:
                  "Audience",
            ),

            child:
                DropdownButtonHideUnderline(
              child:
                  DropdownButton<String>(
                value:
                    audience,

                isExpanded:
                    true,

                items:
                    const [
                  DropdownMenuItem<
                      String>(
                    value:
                        "ALL",
                    child:
                        Text(
                      "Everyone",
                    ),
                  ),
                  DropdownMenuItem<
                      String>(
                    value:
                        "ATTENDEES",
                    child:
                        Text(
                      "Attendees",
                    ),
                  ),
                  DropdownMenuItem<
                      String>(
                    value:
                        "STAFF",
                    child:
                        Text(
                      "Staff",
                    ),
                  ),
                  DropdownMenuItem<
                      String>(
                    value:
                        "ORGANIZERS",
                    child:
                        Text(
                      "Organizers",
                    ),
                  ),
                ],

                onChanged:
                    submitting
                        ? null
                        : (value) {
                            if (value ==
                                null) {
                              return;
                            }

                            setState(() {
                              audience =
                                  value;
                            });
                          },
              ),
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          /*
          |--------------------------------------------------------------------------
          | Pin
          |--------------------------------------------------------------------------
          */

          SwitchListTile(
            title:
                const Text(
              "Pin Announcement",
            ),

            value:
                pinned,

            onChanged:
                submitting
                    ? null
                    : (value) {
                        setState(() {
                          pinned =
                              value;
                        });
                      },
          ),

          const SizedBox(
            height: 24,
          ),

          /*
          |--------------------------------------------------------------------------
          | Submit
          |--------------------------------------------------------------------------
          */

          SizedBox(
            height: 52,

            child:
                FilledButton(
              onPressed:
                  submitting
                      ? null
                      : _broadcast,

              child:
                  submitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child:
                              CircularProgressIndicator(
                            strokeWidth:
                                2,
                          ),
                        )
                      : const Text(
                          "Broadcast",
                        ),
            ),
          ),
        ],
      ),
    );
  }
}