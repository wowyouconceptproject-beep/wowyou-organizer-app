import "dart:convert";

import "package:http/http.dart"
    as http;

import "../config/api.dart";
import "../utils/storage.dart";

class PassService {
  /*
  |--------------------------------------------------------------------------
  | Verify Pass
  |--------------------------------------------------------------------------
  */

  Future<Map<String, dynamic>>
      verifyPass(
    String token,
  ) async {
    final jwt =
        await Storage.getToken();

    final response =
        await http.post(
      Uri.parse(
        "${ApiConfig.baseUrl}/passes/verify",
      ),
      headers: {
        "Content-Type":
            "application/json",

        "Authorization":
            "Bearer $jwt",
      },
      body: jsonEncode({
        "token": token,
      }),
    );

    return _handleResponse(
      response,
    );
  }

  /*
  |--------------------------------------------------------------------------
  | Check In
  |--------------------------------------------------------------------------
  */

  Future<Map<String, dynamic>>
      checkIn(
    String token, {
    String scanType = "QR",
    String? staffId,
    String? station,
    String? deviceId,
  }) async {
    /*
    |--------------------------------------------------------------------------
    | Validate Staff
    |--------------------------------------------------------------------------
    */

    if (
      staffId == null ||
      staffId.trim().isEmpty
    ) {
      throw Exception(
        "Staff session is not available.",
      );
    }

    /*
    |--------------------------------------------------------------------------
    | Authentication
    |--------------------------------------------------------------------------
    */

    final jwt =
        await Storage.getToken();

    /*
    |--------------------------------------------------------------------------
    | Request
    |--------------------------------------------------------------------------
    */

    final response =
        await http.post(
      Uri.parse(
        "${ApiConfig.baseUrl}/checkin",
      ),
      headers: {
        "Content-Type":
            "application/json",

        "Authorization":
            "Bearer $jwt",
      },
      body: jsonEncode({
        "token": token,

        "scanType":
            scanType,

        "staffId":
            staffId,

        if (
          station != null &&
          station.trim().isNotEmpty
        )
          "station":
              station.trim(),

        if (
          deviceId != null &&
          deviceId.trim().isNotEmpty
        )
          "deviceId":
              deviceId.trim(),
      }),
    );

    return _handleResponse(
      response,
    );
  }

  /*
  |--------------------------------------------------------------------------
  | Response Handler
  |--------------------------------------------------------------------------
  */

  Map<String, dynamic>
      _handleResponse(
    http.Response response,
  ) {
    /*
    |--------------------------------------------------------------------------
    | Decode
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

    /*
    |--------------------------------------------------------------------------
    | Response Must Be Object
    |--------------------------------------------------------------------------
    */

    if (
      decoded
          is! Map<String, dynamic>
    ) {
      throw Exception(
        "Invalid server response.",
      );
    }

    /*
    |--------------------------------------------------------------------------
    | HTTP Error
    |--------------------------------------------------------------------------
    */

    if (
      response.statusCode < 200 ||
      response.statusCode >= 300
    ) {
      throw Exception(
        _extractErrorMessage(
          decoded,
          response.statusCode,
        ),
      );
    }

    /*
    |--------------------------------------------------------------------------
    | Backend Error
    |--------------------------------------------------------------------------
    */

    if (
      decoded["success"] ==
          false
    ) {
      throw Exception(
        _extractErrorMessage(
          decoded,
          response.statusCode,
        ),
      );
    }

    /*
    |--------------------------------------------------------------------------
    | Success
    |--------------------------------------------------------------------------
    */

    return decoded;
  }

  /*
  |--------------------------------------------------------------------------
  | Error Message
  |--------------------------------------------------------------------------
  */

  String _extractErrorMessage(
    Map<String, dynamic> body,
    int statusCode,
  ) {
    final message =
        body["message"];

    if (
      message is String &&
      message.trim().isNotEmpty
    ) {
      return message.trim();
    }

    final error =
        body["error"];

    if (
      error is String &&
      error.trim().isNotEmpty
    ) {
      return error.trim();
    }

    return switch (statusCode) {
      400 =>
        "Invalid request.",

      401 =>
        "You are not authenticated.",

      403 =>
        "You do not have permission to perform this action.",

      404 =>
        "The requested resource was not found.",

      409 =>
        "This action conflicts with the current state.",

      422 =>
        "The submitted data is invalid.",

      500 =>
        "A server error occurred.",

      _ =>
        "Request failed.",
    };
  }
}