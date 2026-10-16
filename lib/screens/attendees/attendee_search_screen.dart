import "dart:async";
import "dart:convert";

import "package:flutter/material.dart";
import "package:http/http.dart" as http;

import "../../config/api.dart";
import "../../utils/storage.dart";

class AttendeeSearchScreen extends StatefulWidget {
  const AttendeeSearchScreen({super.key});

  @override
  State<AttendeeSearchScreen> createState() =>
      _AttendeeSearchScreenState();
}

class _AttendeeSearchScreenState extends State<AttendeeSearchScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  Timer? _debounce;

  bool _loading = false;
  bool _searched = false;

  String? _error;
  List<Map<String, dynamic>> _attendees = [];

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchAttendees({String? value}) async {
    final query = (value ?? _searchController.text).trim();

    if (query.isEmpty) {
      setState(() {
        _attendees = [];
        _error = null;
        _loading = false;
        _searched = false;
      });
      return;
    }

    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = null;
      _searched = true;
    });

    try {
      final token = await Storage.getToken();

      if (token == null || token.isEmpty) {
        throw Exception(
          "Your operations session has expired. Please log in again.",
        );
      }

      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/operations/search"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({"query": query}),
      );

      dynamic decoded;

      try {
        decoded = jsonDecode(response.body);
      } catch (_) {
        throw Exception("The server returned an invalid response.");
      }

      if (decoded is! Map) {
        throw Exception("The server returned an invalid response.");
      }

      final body = Map<String, dynamic>.from(decoded);

      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          body["success"] == false) {
        throw Exception(
          _errorMessage(body, response.statusCode),
        );
      }

      final rawAttendees = body["attendees"];

      if (rawAttendees is! List) {
        throw Exception(
          "The server response did not contain an attendee list.",
        );
      }

      final attendees = rawAttendees
          .whereType<Map>()
          .map(
            (item) => Map<String, dynamic>.from(item),
          )
          .toList();

      if (!mounted) return;

      setState(() {
        _attendees = attendees;
        _loading = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _attendees = [];
        _loading = false;
        _error = error.toString().replaceFirst("Exception: ", "");
      });
    }
  }

  String _errorMessage(
    Map<String, dynamic> body,
    int statusCode,
  ) {
    final message = body["message"];

    if (message is String && message.trim().isNotEmpty) {
      return message.trim();
    }

    switch (statusCode) {
      case 401:
        return "Your operations session has expired. Please log in again.";
      case 403:
        return "You do not have permission to search attendees.";
      case 404:
        return "The attendee search endpoint was not found.";
      case 500:
        return "A server error occurred. Please try again.";
      default:
        return "Unable to search attendees.";
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();

    _debounce = Timer(
      const Duration(milliseconds: 400),
      () => _searchAttendees(value: value),
    );
  }

  void _clearSearch() {
    _debounce?.cancel();
    _searchController.clear();

    setState(() {
      _attendees = [];
      _error = null;
      _loading = false;
      _searched = false;
    });
  }

  String _readText(
    dynamic value, {
    String fallback = "",
  }) {
    if (value == null) return fallback;

    final text = value.toString().trim();

    return text.isEmpty ? fallback : text;
  }

  String _attendeeName(Map<String, dynamic> attendee) {
    final user = attendee["user"];

    if (user is Map) {
      final firstName = _readText(user["firstName"]);
      final lastName = _readText(user["lastName"]);
      final fullName = "$firstName $lastName".trim();

      if (fullName.isNotEmpty) return fullName;

      final email = _readText(user["email"]);

      if (email.isNotEmpty) return email;
    }

    final firstName = _readText(attendee["firstName"]);
    final lastName = _readText(attendee["lastName"]);
    final fullName = "$firstName $lastName".trim();

    if (fullName.isNotEmpty) return fullName;

    return _readText(
      attendee["email"],
      fallback: "Unnamed attendee",
    );
  }

  String _attendeeEmail(Map<String, dynamic> attendee) {
    final user = attendee["user"];

    if (user is Map) {
      final email = _readText(user["email"]);

      if (email.isNotEmpty) return email;
    }

    return _readText(
      attendee["email"],
      fallback: "No email available",
    );
  }

  String _ticketName(Map<String, dynamic> attendee) {
    final ticket = attendee["ticket"];

    if (ticket is Map) {
      final name = _readText(ticket["name"]);

      if (name.isNotEmpty) return name;

      final type = _readText(ticket["type"]);

      if (type.isNotEmpty) return type;
    }

    return _readText(
      attendee["ticketType"],
      fallback: "Ticket",
    );
  }

  bool _isCheckedIn(Map<String, dynamic> attendee) {
    if (attendee["checkedIn"] == true) return true;

    if (attendee["checkedInAt"] != null) return true;

    final checkIn = attendee["checkIn"];

    if (checkIn is Map) {
      if (checkIn.isNotEmpty) return true;
    }

    return false;
  }

  String _purchaseId(Map<String, dynamic> attendee) {
    return _readText(
      attendee["id"],
      fallback: _readText(
        attendee["purchaseId"],
        fallback: "Not available",
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendee Search"),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onChanged: _onSearchChanged,
                onSubmitted: (_) => _searchAttendees(),
                decoration: InputDecoration(
                  hintText: "Search name or email",
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: "Clear search",
                          onPressed: _clearSearch,
                          icon: const Icon(Icons.close),
                        ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Search attendees registered for your event.",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  if (_attendees.isNotEmpty)
                    Text(
                      "${_attendees.length} found",
                      style: theme.textTheme.labelMedium,
                    ),
                ],
              ),
            ),
            if (_loading)
              const LinearProgressIndicator(minHeight: 2),
            Expanded(
              child: _buildResults(theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(ThemeData theme) {
    if (_loading && _attendees.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 42,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => _searchAttendees(),
                icon: const Icon(Icons.refresh),
                label: const Text("Try again"),
              ),
            ],
          ),
        ),
      );
    }

    if (!_searched) {
      return _emptyState(
        icon: Icons.person_search_outlined,
        title: "Find an attendee",
        message: "Enter an attendee's name or email to search.",
      );
    }

    if (_attendees.isEmpty) {
      return _emptyState(
        icon: Icons.person_off_outlined,
        title: "No attendees found",
        message: "Try a different name or email address.",
      );
    }

    return RefreshIndicator(
      onRefresh: () => _searchAttendees(),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        itemCount: _attendees.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final attendee = _attendees[index];

          final name = _attendeeName(attendee);
          final email = _attendeeEmail(attendee);
          final ticketName = _ticketName(attendee);
          final checkedIn = _isCheckedIn(attendee);
          final purchaseId = _purchaseId(attendee);

          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(
                color: theme.dividerColor.withValues(alpha: 0.45),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundColor:
                            theme.colorScheme.primaryContainer,
                        foregroundColor:
                            theme.colorScheme.onPrimaryContainer,
                        child: Text(
                          name.isNotEmpty
                              ? name.substring(0, 1).toUpperCase()
                              : "?",
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              email,
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      _statusChip(
                        checkedIn ? "Checked in" : "Not checked in",
                        checkedIn,
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    children: [
                      const Icon(
                        Icons.confirmation_number_outlined,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          ticketName,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.receipt_long_outlined,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Purchase ID: $purchaseId",
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _statusChip(String label, bool checkedIn) {
    final background = checkedIn
        ? Colors.green.withValues(alpha: 0.12)
        : Colors.orange.withValues(alpha: 0.12);

    final foreground = checkedIn
        ? Colors.green.shade800
        : Colors.orange.shade900;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _emptyState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 56,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}