import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../../providers/announcement_provider.dart";

class BroadcastAnnouncementScreen extends StatefulWidget {
  const BroadcastAnnouncementScreen({
    super.key,
  });

  @override
  State<BroadcastAnnouncementScreen> createState() =>
      _BroadcastAnnouncementScreenState();
}

class _BroadcastAnnouncementScreenState
    extends State<BroadcastAnnouncementScreen> {
  final title = TextEditingController();

  final message = TextEditingController();

  String type = "INFO";

  String priority = "NORMAL";

  String audience = "ALL";

  bool pinned = false;

  @override
  void dispose() {
    title.dispose();
    message.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider =
        context.read<AnnouncementProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Broadcast",
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(
          20,
        ),
        children: [
          /*
          |--------------------------------------------------------------------------
          | Title
          |--------------------------------------------------------------------------
          */

          TextField(
            controller: title,
            decoration:
                const InputDecoration(
              labelText: "Title",
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
            maxLines: 5,
            decoration:
                const InputDecoration(
              labelText: "Message",
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
              labelText: "Type",
            ),
            child:
                DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: type,
                isExpanded: true,
                items: const [
                  DropdownMenuItem<String>(
                    value: "INFO",
                    child: Text(
                      "Info",
                    ),
                  ),
                  DropdownMenuItem<String>(
                    value: "SUCCESS",
                    child: Text(
                      "Success",
                    ),
                  ),
                  DropdownMenuItem<String>(
                    value: "WARNING",
                    child: Text(
                      "Warning",
                    ),
                  ),
                  DropdownMenuItem<String>(
                    value: "EMERGENCY",
                    child: Text(
                      "Emergency",
                    ),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }

                  setState(() {
                    type = value;
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
              labelText: "Priority",
            ),
            child:
                DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: priority,
                isExpanded: true,
                items: const [
                  DropdownMenuItem<String>(
                    value: "LOW",
                    child: Text(
                      "Low",
                    ),
                  ),
                  DropdownMenuItem<String>(
                    value: "NORMAL",
                    child: Text(
                      "Normal",
                    ),
                  ),
                  DropdownMenuItem<String>(
                    value: "HIGH",
                    child: Text(
                      "High",
                    ),
                  ),
                  DropdownMenuItem<String>(
                    value: "CRITICAL",
                    child: Text(
                      "Critical",
                    ),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }

                  setState(() {
                    priority = value;
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
              labelText: "Audience",
            ),
            child:
                DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: audience,
                isExpanded: true,
                items: const [
                  DropdownMenuItem<String>(
                    value: "ALL",
                    child: Text(
                      "Everyone",
                    ),
                  ),
                  DropdownMenuItem<String>(
                    value: "ATTENDEES",
                    child: Text(
                      "Attendees",
                    ),
                  ),
                  DropdownMenuItem<String>(
                    value: "STAFF",
                    child: Text(
                      "Staff",
                    ),
                  ),
                  DropdownMenuItem<String>(
                    value: "ORGANIZERS",
                    child: Text(
                      "Organizers",
                    ),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }

                  setState(() {
                    audience = value;
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
            title: const Text(
              "Pin Announcement",
            ),
            value: pinned,
            onChanged: (value) {
              setState(() {
                pinned = value;
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

          FilledButton(
            onPressed: () async {
              final navigator =
                  Navigator.of(context);

              await provider.create(
                title:
                    title.text.trim(),
                message:
                    message.text.trim(),
                type: type,
                priority: priority,
                audience: audience,
                isPinned: pinned,
              );

              if (!mounted) {
                return;
              }

              navigator.pop();
            },
            child: const Text(
              "Broadcast",
            ),
          ),
        ],
      ),
    );
  }
}