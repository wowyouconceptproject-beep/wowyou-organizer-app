import "dart:convert";

import "package:http/http.dart" as http;

import "../config/api.dart";
import "../utils/storage.dart";

class PassService {
  /*
  |--------------------------------------------------------------------------
  | Authentication Headers
  |--------------------------------------------------------------------------
  */

  Future<Map<String, String>> _headers() async {
    final jwt = await Storage.getToken();

    if (jwt == null || jwt.isEmpty) {
      throw Exception("You are not authenticated.");
    }

    return {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $jwt",
    };
  }

  /*
  |--------------------------------------------------------------------------
  | Verify Pass
  |--------------------------------------------------------------------------
  |
  | Uses the authenticated organizer operations session.
  | Verification does not check the attendee in.
  |
  */

  Future<Map<String, dynamic>> verifyPass(
    String token,
  ) async {
    final normalizedToken = token.trim();

    if (normalizedToken.isEmpty) {
      throw Exception("Enter a valid pass token.");
    }

    final response = await http.post(
      Uri.parse(
        "${ApiConfig.baseUrl}/operations/verify-pass",
      ),
      headers: await _headers(),
      body: jsonEncode({
        "token": normalizedToken,
      }),
    );

    return _handleResponse(response);
  }

  /*
  |--------------------------------------------------------------------------
  | Check In
  |--------------------------------------------------------------------------
  |
  | Uses the operations scanner endpoint.
  | The backend obtains the staff ID, event ID, and station
  | from the authenticated operations session.
  |
  */

  Future<Map<String, dynamic>> checkIn(
    String token, {
    String scanType = "QR",
    String? staffId,
    String? station,
    String? deviceId,
  }) async {
    final normalizedToken = token.trim();

    if (normalizedToken.isEmpty) {
      throw Exception("Invalid pass token.");
    }

    // Retain the existing method parameters for compatibility
    // with ScanProvider. Staff identity is authenticated by
    // the operations token, not supplied by the client.

    final response = await http.post(
      Uri.parse(
        "${ApiConfig.baseUrl}/operations/scan",
      ),
      headers: await _headers(),
      body: jsonEncode({
        "token": normalizedToken,
      }),
    );

    return _handleResponse(response);
  }

  /*
  |--------------------------------------------------------------------------
  | Response Handler
  |--------------------------------------------------------------------------
  */

  Map<String, dynamic> _handleResponse(
    http.Response response,
  ) {
    dynamic decoded;

    try {
      decoded = jsonDecode(response.body);
    } catch (_) {
      throw Exception(
        "The server returned an invalid response.",
      );
    }

    if (decoded is! Map) {
      throw Exception(
        "The server returned an invalid response.",
      );
    }

    final body = Map<String, dynamic>.from(decoded);

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        _extractErrorMessage(
          body,
          response.statusCode,
        ),
      );
    }

    if (body["success"] == false) {
      throw Exception(
        _extractErrorMessage(
          body,
          response.statusCode,
        ),
      );
    }

    return body;
  }

  /*
  |--------------------------------------------------------------------------
  | Error Messages
  |--------------------------------------------------------------------------
  */

  String _extractErrorMessage(
    Map<String, dynamic> body,
    int statusCode,
  ) {
    final message = body["message"];

    if (message is String && message.trim().isNotEmpty) {
      return message.trim();
    }

    final error = body["error"];

    if (error is String && error.trim().isNotEmpty) {
      return error.trim();
    }

    switch (statusCode) {
      case 400:
        return "Invalid request.";
      case 401:
        return "Your operations session has expired. Please log in again.";
      case 403:
        return "You do not have permission to perform this action.";
      case 404:
        return "The requested resource was not found.";
      case 409:
        return "This action conflicts with the current state.";
      case 422:
        return "The submitted data is invalid.";
      case 500:
        return "A server error occurred. Please try again.";
      default:
        return "Request failed. Please try again.";
    }
  }
}