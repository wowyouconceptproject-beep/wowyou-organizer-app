import "event.dart";
import "staff.dart";

class LoginResponse {
  final bool success;

  final String token;

  final Staff staff;

  final Event event;

  LoginResponse({
    required this.success,
    required this.token,
    required this.staff,
    required this.event,
  });

  factory LoginResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return LoginResponse(
      success: json["success"],

      token: json["token"],

      staff: Staff.fromJson(
        json["staff"],
      ),

      event: Event.fromJson(
        json["event"],
      ),
    );
  }
}