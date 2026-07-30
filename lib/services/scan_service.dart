import "dart:convert";

import "package:http/http.dart" as http;
import "package:shared_preferences/shared_preferences.dart";

import "../config/api.dart";
import "../models/scan_result.dart";

class ScanService {
  Future<ScanResult> scan(
    String qrToken,
  ) async {
    final prefs =
        await SharedPreferences
            .getInstance();

    final token =
        prefs.getString(
      "token",
    );

    if (token == null) {
      throw Exception(
        "You are not logged in."
      );
    }

    final response =
        await http.post(
      Uri.parse(
        "${ApiConfig.baseUrl}/operations/scan",
      ),

      headers: {
        "Authorization":
            "Bearer $token",

        "Content-Type":
            "application/json",
      },

      body: jsonEncode({
        "token": qrToken,
      }),
    );

    final body =
        jsonDecode(
      response.body,
    );

    if (response.statusCode != 200) {
      throw Exception(
        body["message"] ??
            "Unable to scan pass.",
      );
    }

    return ScanResult.fromJson(
      body,
    );
  }
}