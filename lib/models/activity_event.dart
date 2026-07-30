class ActivityEvent {
  final String id;

  final String type;

  final String title;

  final String description;

  final String? actorId;

  final String? actorName;

  final String? actorRole;

  final String? attendeeId;

  final String? attendeeName;

  final String? purchaseId;

  final String? ticketTypeId;

  final String? ticketTypeName;

  final String? station;

  final DateTime createdAt;

  const ActivityEvent({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.createdAt,
    this.actorId,
    this.actorName,
    this.actorRole,
    this.attendeeId,
    this.attendeeName,
    this.purchaseId,
    this.ticketTypeId,
    this.ticketTypeName,
    this.station,
  });

  factory ActivityEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    return ActivityEvent(
      id: json["id"] ?? "",

      type: json["type"] ?? "",

      title: json["title"] ?? "",

      description:
          json["description"] ?? "",

      actorId:
          json["actorId"],

      actorName:
          json["actorName"],

      actorRole:
          json["actorRole"],

      attendeeId:
          json["attendeeId"],

      attendeeName:
          json["attendeeName"],

      purchaseId:
          json["purchaseId"],

      ticketTypeId:
          json["ticketTypeId"],

      ticketTypeName:
          json["ticketTypeName"],

      station:
          json["station"],

      createdAt: DateTime.parse(
        json["createdAt"] ??
            json["timestamp"],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,

      "type": type,

      "title": title,

      "description":
          description,

      "actorId":
          actorId,

      "actorName":
          actorName,

      "actorRole":
          actorRole,

      "attendeeId":
          attendeeId,

      "attendeeName":
          attendeeName,

      "purchaseId":
          purchaseId,

      "ticketTypeId":
          ticketTypeId,

      "ticketTypeName":
          ticketTypeName,

      "station":
          station,

      "createdAt":
          createdAt.toIso8601String(),
    };
  }
}