import "package:flutter/material.dart";
import "package:intl/intl.dart";

import "../models/announcement.dart";

class AnnouncementCard extends StatelessWidget {
  final Announcement announcement;

  const AnnouncementCard({
    super.key,
    required this.announcement,
  });

  Color get _priorityColor {
    switch (announcement.priority.toUpperCase()) {
      case "CRITICAL":
        return Colors.red;
      case "HIGH":
        return Colors.orange;
      case "MEDIUM":
        return Colors.amber;
      default:
        return Colors.blueGrey;
    }
  }

  IconData get _typeIcon {
    switch (announcement.type.toUpperCase()) {
      case "ALERT":
        return Icons.warning_amber_rounded;
      case "INFO":
        return Icons.info_outline;
      case "SUCCESS":
        return Icons.check_circle_outline;
      case "UPDATE":
        return Icons.campaign_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _typeIcon,
                  color: _priorityColor,
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: Text(
                    announcement.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),

                if (announcement.isPinned)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius:
                          BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.push_pin,
                          size: 14,
                          color: Colors.white,
                        ),
                        SizedBox(width: 4),
                        Text(
                          "Pinned",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 14),

            Text(
              announcement.message,
              style: const TextStyle(
                fontSize: 15,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 18),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  avatar: Icon(
                    Icons.flag_outlined,
                    size: 18,
                    color: _priorityColor,
                  ),
                  label: Text(
                    announcement.priority,
                  ),
                ),

                Chip(
                  avatar: const Icon(
                    Icons.group_outlined,
                    size: 18,
                  ),
                  label: Text(
                    announcement.audience,
                  ),
                ),

                Chip(
                  avatar: const Icon(
                    Icons.category_outlined,
                    size: 18,
                  ),
                  label: Text(
                    announcement.type,
                  ),
                ),
              ],
            ),

            const Divider(height: 28),

            Row(
              children: [
                const Icon(
                  Icons.person_outline,
                  size: 18,
                  color: Colors.grey,
                ),

                const SizedBox(width: 6),

                Expanded(
                  child: Text(
                    announcement.authorName ??
                        "Unknown",
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),

                Text(
                  DateFormat(
                    "MMM d, yyyy • h:mm a",
                  ).format(
                    announcement.createdAt,
                  ),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}