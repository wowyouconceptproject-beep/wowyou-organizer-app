class Event {
  final String id;

  final String title;

  final String venue;

  final String status;

  final DateTime startDate;

  final DateTime endDate;

  Event({
    required this.id,
    required this.title,
    required this.venue,
    required this.status,
    required this.startDate,
    required this.endDate,
  });

  factory Event.fromJson(
    Map<String, dynamic> json,
  ) {
    return Event(
      id: json["id"],

      title: json["title"],

      venue: json["venue"],

      status: json["status"],

      startDate: DateTime.parse(
        json["startDate"],
      ),

      endDate: DateTime.parse(
        json["endDate"],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "venue": venue,
      "status": status,
      "startDate":
          startDate.toIso8601String(),
      "endDate":
          endDate.toIso8601String(),
    };
  }
}