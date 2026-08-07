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

    return jsonDecode(
      response.body,
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
    String? station,
    String? deviceId,
  }) async {
    final jwt =
        await Storage.getToken();

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
        "scanType": scanType,
        "station": station,
        "deviceId": deviceId,
      }),
    );

    return jsonDecode(
      response.body,
    );
  }
}