import "dart:convert";

import "package:http/http.dart" as http;

import "../config/api.dart";

import "../models/announcement.dart";

import "../services/auth_service.dart";

class AnnouncementService {
  final AuthService _auth =
      AuthService();

  /*
  |--------------------------------------------------------------------------
  | Headers
  |--------------------------------------------------------------------------
  */

  Future<Map<String, String>>
      _headers() async {
    final token =
    await _auth.token();

    return {
      "Content-Type":
          "application/json",

      "Authorization":
          "Bearer $token",
    };
  }

  /*
  |--------------------------------------------------------------------------
  | List
  |--------------------------------------------------------------------------
  */

  Future<List<Announcement>>
      list({
    int limit = 50,
  }) async {
    final response =
        await http.get(
      Uri.parse(
        "${ApiConfig.baseUrl}/operations/announcements?limit=$limit",
      ),
      headers:
          await _headers(),
    );

    final body =
        jsonDecode(
      response.body,
    );

    if (response.statusCode !=
        200) {
      throw Exception(
        body["message"],
      );
    }

    return (body["announcements"]
            as List)
        .map(
          (json) =>
              Announcement
                  .fromJson(
            json,
          ),
        )
        .toList();
  }

  /*
  |--------------------------------------------------------------------------
  | Create
  |--------------------------------------------------------------------------
  */

  Future<Announcement>
      create({
    required String title,
    required String message,
    required String type,
    required String priority,
    required String audience,
    bool isPinned = false,
  }) async {
    final response =
        await http.post(
      Uri.parse(
        "${ApiConfig.baseUrl}/operations/announcements",
      ),

      headers:
          await _headers(),

      body: jsonEncode({
        "title": title,

        "message":
            message,

        "type": type,

        "priority":
            priority,

        "audience":
            audience,

        "isPinned":
            isPinned,
      }),
    );

    final body =
        jsonDecode(
      response.body,
    );

    if (response.statusCode !=
            201 &&
        response.statusCode !=
            200) {
      throw Exception(
        body["message"],
      );
    }

    return Announcement
        .fromJson(
      body["announcement"],
    );
  }

  /*
  |--------------------------------------------------------------------------
  | Pin
  |--------------------------------------------------------------------------
  */

  Future<Announcement> pin(
    String id,
    bool pinned,
  ) async {
    final response =
        await http.patch(
      Uri.parse(
        "${ApiConfig.baseUrl}/operations/announcements/$id/pin",
      ),

      headers:
          await _headers(),

      body: jsonEncode({
        "isPinned":
            pinned,
      }),
    );

    final body =
        jsonDecode(
      response.body,
    );

    if (response.statusCode !=
        200) {
      throw Exception(
        body["message"],
      );
    }

    return Announcement
        .fromJson(
      body["announcement"],
    );
  }

  /*
  |--------------------------------------------------------------------------
  | Delete
  |--------------------------------------------------------------------------
  */

  Future<void> delete(
    String id,
  ) async {
    final response =
        await http.delete(
      Uri.parse(
        "${ApiConfig.baseUrl}/operations/announcements/$id",
      ),
      headers:
          await _headers(),
    );

    if (response.statusCode !=
        200) {
      final body =
          jsonDecode(
        response.body,
      );

      throw Exception(
        body["message"],
      );
    }
  }
}