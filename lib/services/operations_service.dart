import "dart:convert";

import "package:http/http.dart"
    as http;

import "../models/assigned_event.dart";

class OperationsService {
  static const baseUrl =
      "https://YOUR_BACKEND";

  Future<List<AssignedEvent>>
      getEvents(
    String token,
  ) async {
    final response =
        await http.get(
      Uri.parse(
          "$baseUrl/operations/events"),
      headers: {
        "Authorization":
            "Bearer $token",
      },
    );

    final json =
        jsonDecode(response.body);

    return (json["events"] as List)
        .map(
          (e) =>
              AssignedEvent.fromJson(
                  e),
        )
        .toList();
  }
}