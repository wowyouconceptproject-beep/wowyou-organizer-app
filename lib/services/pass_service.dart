import "dart:convert";

import "package:http/http.dart"
    as http;

import "../config/api.dart";
import "../utils/storage.dart";

class PassService {
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

  Future<Map<String, dynamic>>
      checkIn(
    String token,
  ) async {
    final jwt =
        await Storage.getToken();

    final response =
        await http.post(
      Uri.parse(
        "${ApiConfig.baseUrl}/passes/check-in",
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
}