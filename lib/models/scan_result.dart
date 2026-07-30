class ScanResult {
  final bool success;

  final int attendance;

  final int totalTickets;

  final int remaining;

  final Attendee attendee;

  final Ticket ticket;

  final EventSummary event;

  ScanResult({
    required this.success,
    required this.attendance,
    required this.totalTickets,
    required this.remaining,
    required this.attendee,
    required this.ticket,
    required this.event,
  });

  factory ScanResult.fromJson(
    Map<String, dynamic> json,
  ) {
    return ScanResult(
      success: json["success"],

      attendance:
          json["attendance"],

      totalTickets:
          json["totalTickets"],

      remaining:
          json["remaining"],

      attendee:
          Attendee.fromJson(
        json["attendee"],
      ),

      ticket:
          Ticket.fromJson(
        json["ticket"],
      ),

      event:
          EventSummary.fromJson(
        json["event"],
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
      id: json["id"],

      firstName:
          json["firstName"],

      lastName:
          json["lastName"],

      email:
          json["email"],
    );
  }

  String get fullName =>
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
      id: json["id"],

      name: json["name"],

      price: json["price"],
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
      id: json["id"],

      title: json["title"],

      currency:
          json["currency"],
    );
  }
}