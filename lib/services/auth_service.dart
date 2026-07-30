import "dart:convert";

import "package:http/http.dart" as http;
import "package:shared_preferences/shared_preferences.dart";

import "../config/api.dart";
import "../models/login_response.dart";

class AuthService {
  Future<LoginResponse> login(
    String accessCode,
  ) async {
    final response = await http.post(
      Uri.parse(
  "${ApiConfig.baseUrl}/operations/access",
),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
       "accessCode": accessCode,
       "deviceId": "flutter-device",
       "deviceName": "WowYou Operations",
       "platform": "flutter",
       "appVersion": "1.0.0",
      }),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        body["message"] ??
            "Login failed.",
      );
    }

    final login =
        LoginResponse.fromJson(
      body,
    );

    final prefs =
        await SharedPreferences
            .getInstance();

    await prefs.setString(
      "token",
      login.token,
    );

    await prefs.setString(
      "staff",
      jsonEncode(
        body["staff"],
      ),
    );

    await prefs.setString(
      "event",
      jsonEncode(
        body["event"],
      ),
    );

    return login;
  }

  Future<void> logout() async {
    final prefs =
        await SharedPreferences
            .getInstance();

    await prefs.clear();
  }

  Future<bool> isLoggedIn() async {
    final prefs =
        await SharedPreferences
            .getInstance();

    return prefs.containsKey(
      "token",
    );
  }

  Future<String?> token() async {
    final prefs =
        await SharedPreferences
            .getInstance();

    return prefs.getString(
      "token",
    );
  }
}