import "dart:convert";

import "package:http/http.dart"
    as http;

import "../config/api.dart";

import "../models/activity_event.dart";

import "auth_service.dart";

class ActivityService {
  final AuthService _auth =
      AuthService();

  Future<List<ActivityEvent>>
      list({
    int limit = 50,
  }) async {
    final token =
        await _auth.token();

    final response =
        await http.get(
      Uri.parse(
        "${ApiConfig.baseUrl}/operations/activity?limit=$limit",
      ),
      headers: {
        "Authorization":
            "Bearer $token",
      },
    );

    final body =
        jsonDecode(response.body);

    if (!body["success"]) {
      throw Exception(
        body["message"],
      );
    }

    return (body["activity"]
            as List)
        .map(
          (e) =>
              ActivityEvent
                  .fromJson(e),
        )
        .toList();
  }
}