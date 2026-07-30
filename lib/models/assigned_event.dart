class AssignedEvent {
  final String id;
  final String title;
  final String venue;
  final DateTime startDate;
  final int capacity;
  final int checkedIn;
  final String role;

  AssignedEvent({
    required this.id,
    required this.title,
    required this.venue,
    required this.startDate,
    required this.capacity,
    required this.checkedIn,
    required this.role,
  });

  factory AssignedEvent.fromJson(
      Map<String, dynamic> json) {
    return AssignedEvent(
      id: json["event"]["id"],
      title: json["event"]["title"],
      venue: json["event"]["venue"],
      startDate: DateTime.parse(
        json["event"]["startDate"],
      ),
      capacity:
          json["event"]["capacity"],
      checkedIn:
          json["event"]["_count"]
                  ["purchases"] ??
              0,
      role: json["role"],
    );
  }
}