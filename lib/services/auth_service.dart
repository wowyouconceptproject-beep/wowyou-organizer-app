import "dart:convert";

import "package:flutter/foundation.dart";
import "package:http/http.dart" as http;

import "../config/api.dart";
import "../models/login_response.dart";
import "../utils/storage.dart";

class AuthService {
  /*
  |--------------------------------------------------------------------------
  | Organizer Operations Login
  |--------------------------------------------------------------------------
  */

  Future<LoginResponse> login(
    String accessCode,
  ) async {
    /*
    |--------------------------------------------------------------------------
    | Normalize Access Code
    |--------------------------------------------------------------------------
    |
    | Prevent accidental spaces from the input field from causing an exact
    | database lookup failure.
    |
    */

    final normalizedAccessCode =
        accessCode.trim();

    if (normalizedAccessCode.isEmpty) {
      throw Exception(
        "Access code is required.",
      );
    }

    /*
    |--------------------------------------------------------------------------
    | Debug
    |--------------------------------------------------------------------------
    */

    debugPrint(
      "OPERATIONS ACCESS CODE SENT: "
      "[$normalizedAccessCode]",
    );

    final url =
        "${ApiConfig.baseUrl}/operations/access";

    debugPrint(
      "OPERATIONS LOGIN URL: $url",
    );

    /*
    |--------------------------------------------------------------------------
    | Request
    |--------------------------------------------------------------------------
    */

    final response =
        await http.post(
      Uri.parse(url),
      headers: {
        "Content-Type":
            "application/json",
        "Accept":
            "application/json",
      },
      body: jsonEncode({
        "accessCode":
            normalizedAccessCode,
        "deviceId":
            "flutter-device",
        "deviceName":
            "WowYou Operations",
        "platform":
            "flutter",
        "appVersion":
            "1.0.0",
      }),
    );

    /*
    |--------------------------------------------------------------------------
    | Debug Response
    |--------------------------------------------------------------------------
    */

    debugPrint(
      "OPERATIONS LOGIN STATUS: "
      "${response.statusCode}",
    );

    debugPrint(
      "OPERATIONS LOGIN RESPONSE: "
      "${response.body}",
    );

    /*
    |--------------------------------------------------------------------------
    | Empty Response
    |--------------------------------------------------------------------------
    */

    if (response.body.isEmpty) {
      throw Exception(
        "Empty server response.",
      );
    }

    /*
    |--------------------------------------------------------------------------
    | Parse Response
    |--------------------------------------------------------------------------
    */

    dynamic decoded;

    try {
      decoded =
          jsonDecode(
        response.body,
      );
    } catch (_) {
      throw Exception(
        "Invalid server response.",
      );
    }

    if (decoded
        is! Map<String, dynamic>) {
      throw Exception(
        "Invalid server response.",
      );
    }

    /*
    |--------------------------------------------------------------------------
    | HTTP Error
    |--------------------------------------------------------------------------
    */

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        decoded["message"]
                ?.toString() ??
            "Login failed.",
      );
    }

    /*
    |--------------------------------------------------------------------------
    | API Error
    |--------------------------------------------------------------------------
    */

    if (decoded["success"] !=
        true) {
      throw Exception(
        decoded["message"]
                ?.toString() ??
            "Login failed.",
      );
    }

    /*
    |--------------------------------------------------------------------------
    | Parse Login
    |--------------------------------------------------------------------------
    */

    final login =
        LoginResponse.fromJson(
      decoded,
    );

    /*
    |--------------------------------------------------------------------------
    | Validate JWT
    |--------------------------------------------------------------------------
    */

    if (login.token.isEmpty) {
      throw Exception(
        "Authentication token was not returned.",
      );
    }

    /*
    |--------------------------------------------------------------------------
    | Store Operations JWT
    |--------------------------------------------------------------------------
    */

    await Storage.saveToken(
      login.token,
    );

    debugPrint(
      "OPERATIONS LOGIN SUCCESS",
    );

    return login;
  }

  /*
  |--------------------------------------------------------------------------
  | Logout
  |--------------------------------------------------------------------------
  */

  Future<void> logout() async {
    await Storage.clear();
  }

  /*
  |--------------------------------------------------------------------------
  | Authentication State
  |--------------------------------------------------------------------------
  */

  Future<bool> isLoggedIn() async {
    final token =
        await Storage.getToken();

    return token != null &&
        token.isNotEmpty;
  }

  /*
  |--------------------------------------------------------------------------
  | Current Token
  |--------------------------------------------------------------------------
  */

  Future<String?> token() async {
    return Storage.getToken();
  }
}