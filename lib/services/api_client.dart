import "dart:convert";

import "package:http/http.dart" as http;

import "../config/api.dart";
import "../utils/storage.dart";

class ApiClient {
  Future<Map<String, String>>
      _headers() async {
    final token =
        await Storage.getToken();

    if (token == null ||
        token.isEmpty) {
      throw Exception(
        "Not authenticated.",
      );
    }

    return {
      "Authorization":
          "Bearer $token",
      "Content-Type":
          "application/json",
      "Accept":
          "application/json",
    };
  }

  Future<dynamic> get(
    String path,
  ) async {
    final response =
        await http.get(
      Uri.parse(
        "${ApiConfig.baseUrl}$path",
      ),
      headers:
          await _headers(),
    );

    return _handleResponse(
      response,
    );
  }

  Future<dynamic> post(
    String path, {
    Map<String, dynamic>?
        body,
  }) async {
    final response =
        await http.post(
      Uri.parse(
        "${ApiConfig.baseUrl}$path",
      ),
      headers:
          await _headers(),
      body:
          body == null
              ? null
              : jsonEncode(body),
    );

    return _handleResponse(
      response,
    );
  }

  dynamic _handleResponse(
    http.Response response,
  ) {
    dynamic data;

    if (response.body.isNotEmpty) {
      try {
        data =
            jsonDecode(
          response.body,
        );
      } catch (_) {
        data = response.body;
      }
    }

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        data is Map
            ? data["message"] ??
                "Request failed."
            : "Request failed.",
      );
    }

    return data;
  }
}