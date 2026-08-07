class ScanResult {
  final bool success;

  final bool alreadyCheckedIn;

  final Attendee attendee;

  final Ticket ticket;

  final EventSummary event;

  final CheckedInBy? checkedInBy;

  ScanResult({
    required this.success,
    required this.alreadyCheckedIn,
    required this.attendee,
    required this.ticket,
    required this.event,
    this.checkedInBy,
  });

  factory ScanResult.fromJson(
    Map<String, dynamic> json,
  ) {
    return ScanResult(
      success: json["success"] ?? false,

      alreadyCheckedIn:
          json["alreadyCheckedIn"] ?? false,

      attendee: Attendee.fromJson(
        json["attendee"] ??
            <String, dynamic>{},
      ),

      ticket: Ticket.fromJson(
        json["ticket"] ??
            <String, dynamic>{},
      ),

      event: EventSummary.fromJson(
        json["event"] ??
            <String, dynamic>{},
      ),

      checkedInBy:
          json["checkedInBy"] == null
              ? null
              : CheckedInBy.fromJson(
                  json["checkedInBy"],
                ),
    );
  }
}

class Attendee {
  final String id;

  final String firstName;

  final String lastName;

  final String email;

  Attendee({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  factory Attendee.fromJson(
    Map<String, dynamic> json,
  ) {
    return Attendee(
      id: json["id"] ?? "",

      firstName:
          json["firstName"] ?? "",

      lastName:
          json["lastName"] ?? "",

      email:
          json["email"] ?? "",
    );
  }

  String get fullName =>
      "$firstName $lastName";

  String get name =>
      "$firstName $lastName";
}

class Ticket {
  final String id;

  final String name;

  final dynamic price;

  Ticket({
    required this.id,
    required this.name,
    required this.price,
  });

  factory Ticket.fromJson(
    Map<String, dynamic> json,
  ) {
    return Ticket(
      id: json["id"] ?? "",

      name:
          json["name"] ?? "",

      price:
          json["price"],
    );
  }
}

class EventSummary {
  final String id;

  final String title;

  final String currency;

  EventSummary({
    required this.id,
    required this.title,
    required this.currency,
  });

  factory EventSummary.fromJson(
    Map<String, dynamic> json,
  ) {
    return EventSummary(
      id: json["id"] ?? "",

      title:
          json["title"] ?? "",

      currency:
          json["currency"] ?? "",
    );
  }
}

class CheckedInBy {
  final String id;

  final String name;

  final String station;

  final String checkedInAt;

  CheckedInBy({
    required this.id,
    required this.name,
    required this.station,
    required this.checkedInAt,
  });

  factory CheckedInBy.fromJson(
    Map<String, dynamic> json,
  ) {
    return CheckedInBy(
      id: json["id"] ?? "",

      name:
          json["name"] ?? "",

      station:
          json["station"] ?? "",

      checkedInAt:
          json["checkedInAt"] ?? "",
    );
  }
}