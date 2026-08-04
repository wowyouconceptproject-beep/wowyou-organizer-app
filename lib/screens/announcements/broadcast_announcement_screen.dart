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
  Widget build(
    BuildContext context,
  ) {
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
          TextField(
            controller: title,
            decoration: const InputDecoration(
              labelText: "Title",
            ),
          ),

          const SizedBox(
            height: 16,
          ),

          TextField(
            controller: message,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: "Message",
            ),
          ),

          const SizedBox(
            height: 20,
          ),

          DropdownButtonFormField<String>(
            initialValue: type,
            items: const [
              DropdownMenuItem(
                value: "INFO",
                child: Text("Info"),
              ),
              DropdownMenuItem(
                value: "SUCCESS",
                child: Text("Success"),
              ),
              DropdownMenuItem(
                value: "WARNING",
                child: Text("Warning"),
              ),
              DropdownMenuItem(
                value: "EMERGENCY",
                child: Text("Emergency"),
              ),
            ],
            onChanged: (v) {
              if (v == null) return;

              setState(() {
                type = v;
              });
            },
          ),

          const SizedBox(
            height: 16,
          ),

          DropdownButtonFormField<String>(
            initialValue: priority,
            items: const [
              DropdownMenuItem(
                value: "LOW",
                child: Text("Low"),
              ),
              DropdownMenuItem(
                value: "NORMAL",
                child: Text("Normal"),
              ),
              DropdownMenuItem(
                value: "HIGH",
                child: Text("High"),
              ),
              DropdownMenuItem(
                value: "CRITICAL",
                child: Text("Critical"),
              ),
            ],
            onChanged: (v) {
              if (v == null) return;

              setState(() {
                priority = v;
              });
            },
          ),

          const SizedBox(
            height: 16,
          ),

          DropdownButtonFormField<String>(
            initialValue: audience,
            items: const [
              DropdownMenuItem(
                value: "ALL",
                child: Text("Everyone"),
              ),
              DropdownMenuItem(
                value: "ATTENDEES",
                child: Text("Attendees"),
              ),
              DropdownMenuItem(
                value: "STAFF",
                child: Text("Staff"),
              ),
              DropdownMenuItem(
                value: "ORGANIZERS",
                child: Text("Organizers"),
              ),
            ],
            onChanged: (v) {
              if (v == null) return;

              setState(() {
                audience = v;
              });
            },
          ),

          SwitchListTile(
            title: const Text(
              "Pin Announcement",
            ),
            value: pinned,
            onChanged: (v) {
              setState(() {
                pinned = v;
              });
            },
          ),

          const SizedBox(
            height: 24,
          ),

          FilledButton(
            onPressed: () async {
              final navigator =
                  Navigator.of(context);

              await provider.create(
                title: title.text,
                message: message.text,
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