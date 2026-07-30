class NotificationEvent {
  final String type;

  final String title;

  final String message;

  final String? eventId;

  final String? purchaseId;

  final DateTime? checkedInAt;

  const NotificationEvent({
    required this.type,
    required this.title,
    required this.message,
    this.eventId,
    this.purchaseId,
    this.checkedInAt,
  });

  factory NotificationEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    return NotificationEvent(
      type: json["type"],
      title: json["title"],
      message: json["message"],
      eventId: json["eventId"],
      purchaseId:
          json["purchaseId"],
      checkedInAt:
          json["checkedInAt"] ==
                  null
              ? null
              : DateTime.parse(
                  json[
                      "checkedInAt"],
                ),
    );
  }
}