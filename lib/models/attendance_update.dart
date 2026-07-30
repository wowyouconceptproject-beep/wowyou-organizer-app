class AttendanceUpdate {
  final String eventId;

  final int checkedIn;

  final int totalTickets;

  final int remaining;

  final String purchaseId;

  final String attendeeId;

  final String? attendeeName;

  final String ticketTypeId;

  final String? ticketTypeName;

  final String staffId;

  final String? staffName;

  final String? station;

  final DateTime checkedInAt;

  const AttendanceUpdate({
    required this.eventId,
    required this.checkedIn,
    required this.totalTickets,
    required this.remaining,
    required this.purchaseId,
    required this.attendeeId,
    this.attendeeName,
    required this.ticketTypeId,
    this.ticketTypeName,
    required this.staffId,
    this.staffName,
    this.station,
    required this.checkedInAt,
  });

  factory AttendanceUpdate.fromJson(
    Map<String, dynamic> json,
  ) {
    return AttendanceUpdate(
      eventId: json["eventId"],
      checkedIn: json["checkedIn"],
      totalTickets:
          json["totalTickets"],
      remaining:
          json["remaining"],
      purchaseId:
          json["purchaseId"],
      attendeeId:
          json["attendeeId"],
      attendeeName:
          json["attendeeName"],
      ticketTypeId:
          json["ticketTypeId"],
      ticketTypeName:
          json["ticketTypeName"],
      staffId:
          json["staffId"],
      staffName:
          json["staffName"],
      station:
          json["station"],
      checkedInAt:
          DateTime.parse(
        json["checkedInAt"],
      ),
    );
  }
}