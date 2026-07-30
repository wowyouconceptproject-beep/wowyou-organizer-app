class Announcement {
  final String id;

  final String eventId;

  final String title;

  final String message;

  final String type;

  final String priority;

  final String audience;

  final bool isPinned;

  final String authorId;

  final String? authorName;

  final DateTime createdAt;

  const Announcement({
    required this.id,
    required this.eventId,
    required this.title,
    required this.message,
    required this.type,
    required this.priority,
    required this.audience,
    required this.isPinned,
    required this.authorId,
    this.authorName,
    required this.createdAt,
  });

  factory Announcement.fromJson(
    Map<String, dynamic> json,
  ) {
    return Announcement(
      id: json["id"],

      eventId:
          json["eventId"],

      title:
          json["title"],

      message:
          json["message"],

      type:
          json["type"],

      priority:
          json["priority"],

      audience:
          json["audience"],

      isPinned:
          json["isPinned"],

      authorId:
          json["authorId"],

      authorName:
          json["authorName"],

      createdAt:
          DateTime.parse(
        json["createdAt"],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,

      "eventId": eventId,

      "title": title,

      "message": message,

      "type": type,

      "priority": priority,

      "audience": audience,

      "isPinned": isPinned,

      "authorId": authorId,

      "authorName": authorName,

      "createdAt":
          createdAt
              .toIso8601String(),
    };
  }
}