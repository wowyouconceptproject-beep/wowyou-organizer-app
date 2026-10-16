import "dart:convert";

import "package:flutter/material.dart";
import "package:http/http.dart" as http;

import "../../config/api.dart";
import "../../utils/storage.dart";

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _report;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final token = await Storage.getToken();

      if (token == null || token.isEmpty) {
        throw Exception(
          "Your operations session has expired. Please log in again.",
        );
      }

      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/operations/reports"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
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

      final rawReport = body["report"];

      if (rawReport is! Map) {
        throw Exception(
          "The server response did not contain report data.",
        );
      }

      if (!mounted) return;

      setState(() {
        _report = Map<String, dynamic>.from(rawReport);
        _loading = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _report = null;
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
        return "You do not have permission to view reports.";
      case 404:
        return "The reports endpoint was not found.";
      case 500:
        return "A server error occurred while loading reports.";
      default:
        return "Unable to load reports.";
    }
  }

  Map<String, dynamic> _mapValue(
    dynamic value,
  ) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return {};
  }

  List<dynamic> _listValue(
    dynamic value,
  ) {
    return value is List ? value : [];
  }

  int? _intValue(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  double? _doubleValue(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  String _text(
    dynamic value, {
    String fallback = "—",
  }) {
    if (value == null) return fallback;

    final result = value.toString().trim();

    return result.isEmpty ? fallback : result;
  }

  String _formatDate(dynamic value) {
    if (value == null) return "—";

    final date = DateTime.tryParse(value.toString());

    if (date == null) return value.toString();

    final local = date.toLocal();

    String twoDigits(int number) =>
        number.toString().padLeft(2, "0");

    return "${twoDigits(local.day)}/"
        "${twoDigits(local.month)}/"
        "${local.year} "
        "${twoDigits(local.hour)}:"
        "${twoDigits(local.minute)}";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Event Reports"),
        actions: [
          IconButton(
            tooltip: "Refresh reports",
            onPressed: _loading ? null : _loadReports,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: _buildBody(theme),
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_loading && _report == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null && _report == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.bar_chart_outlined,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                "Reports unavailable",
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _loadReports,
                icon: const Icon(Icons.refresh),
                label: const Text("Try again"),
              ),
            ],
          ),
        ),
      );
    }

    final report = _report ?? {};
    final event = _mapValue(report["event"]);
    final attendance = _mapValue(report["attendance"]);

    final checkedIn = _intValue(attendance["checkedIn"]);
    final totalTickets = _intValue(attendance["totalTickets"]);
    final remaining = _intValue(attendance["remaining"]);
    final capacity = _intValue(attendance["capacity"]);

    final onlineStaff = _listValue(report["onlineStaff"]);
    final recentActivity = _listValue(report["recentActivity"]);

    final rawRate = _doubleValue(attendance["attendanceRate"]);

    final attendanceRate = rawRate ??
        (checkedIn != null &&
                totalTickets != null &&
                totalTickets > 0
            ? checkedIn / totalTickets * 100
            : null);

    final rateProgress = attendanceRate == null
        ? 0.0
        : (attendanceRate / 100).clamp(0.0, 1.0);

    return RefreshIndicator(
      onRefresh: _loadReports,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_error != null)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "Refresh warning: $_error",
                style: theme.textTheme.bodySmall,
              ),
            ),

          Text(
            _text(event["name"], fallback: "Event overview"),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            "Attendance and operations summary",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 20),

          _buildMetricGrid(
            checkedIn: checkedIn,
            totalTickets: totalTickets,
            remaining: remaining,
            capacity: capacity,
            onlineStaffCount: onlineStaff.length,
          ),

          const SizedBox(height: 20),

          _buildAttendanceCard(
            theme: theme,
            checkedIn: checkedIn,
            totalTickets: totalTickets,
            attendanceRate: attendanceRate,
            progress: rateProgress,
          ),

          const SizedBox(height: 24),

          _buildSectionHeading(
            title: "Online staff",
            count: onlineStaff.length,
          ),

          const SizedBox(height: 10),

          if (onlineStaff.isEmpty)
            _buildEmptyCard(
              icon: Icons.people_outline,
              message: "No online staff records are available.",
            )
          else
            ...onlineStaff.map(
              (item) => _buildStaffTile(
                theme,
                _mapValue(item),
              ),
            ),

          const SizedBox(height: 24),

          _buildSectionHeading(
            title: "Recent activity",
            count: recentActivity.length,
          ),

          const SizedBox(height: 10),

          if (recentActivity.isEmpty)
            _buildEmptyCard(
              icon: Icons.history,
              message: "No recent activity is available.",
            )
          else
            ...recentActivity.map(
              (item) => _buildActivityTile(
                theme,
                _mapValue(item),
              ),
            ),

          const SizedBox(height: 20),

          Text(
            "Generated: ${_formatDate(report["generatedAt"])}",
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildMetricGrid({
    required int? checkedIn,
    required int? totalTickets,
    required int? remaining,
    required int? capacity,
    required int onlineStaffCount,
  }) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.45,
      children: [
        _metricCard(
          title: "Checked in",
          value: checkedIn?.toString() ?? "—",
          icon: Icons.how_to_reg_outlined,
          color: Colors.green,
        ),
        _metricCard(
          title: "Paid tickets",
          value: totalTickets?.toString() ?? "—",
          icon: Icons.confirmation_number_outlined,
          color: Colors.blue,
        ),
        _metricCard(
          title: "Remaining",
          value: remaining?.toString() ?? "—",
          icon: Icons.person_outline,
          color: Colors.orange,
        ),
        _metricCard(
          title: "Online staff",
          value: onlineStaffCount.toString(),
          icon: Icons.groups_outlined,
          color: Colors.purple,
          subtitle: capacity == null
              ? null
              : "Capacity: $capacity",
        ),
      ],
    );
  }

  Widget _metricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? subtitle,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.dividerColor.withValues(alpha: 0.4),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 21),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceCard({
    required ThemeData theme,
    required int? checkedIn,
    required int? totalTickets,
    required double? attendanceRate,
    required double progress,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.dividerColor.withValues(alpha: 0.4),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Attendance rate",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    attendanceRate == null
                        ? "—"
                        : "${attendanceRate.toStringAsFixed(1)}%",
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  "${checkedIn?.toString() ?? "—"} / "
                  "${totalTickets?.toString() ?? "—"} checked in",
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                value: attendanceRate == null ? null : progress,
                minHeight: 10,
                backgroundColor:
                    theme.colorScheme.surfaceContainerHighest,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeading({
    required String title,
    required int count,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(count.toString()),
        ),
      ],
    );
  }

  Widget _buildStaffTile(
    ThemeData theme,
    Map<String, dynamic> staff,
  ) {
    final name = _text(
      staff["name"],
      fallback: _text(
        staff["staffName"],
        fallback: _text(staff["email"], fallback: "Staff member"),
      ),
    );

    final role = _text(
      staff["role"],
      fallback: _text(staff["station"], fallback: "Operations staff"),
    );

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.withValues(alpha: 0.12),
          child: const Icon(
            Icons.person_outline,
            color: Colors.green,
          ),
        ),
        title: Text(name),
        subtitle: Text(role),
        trailing: const Icon(
          Icons.circle,
          color: Colors.green,
          size: 10,
        ),
      ),
    );
  }

  Widget _buildActivityTile(
    ThemeData theme,
    Map<String, dynamic> activity,
  ) {
    final title = _text(
      activity["action"],
      fallback: _text(
        activity["type"],
        fallback: _text(
          activity["description"],
          fallback: "Event activity",
        ),
      ),
    );

    final actor = _text(
      activity["staffName"],
      fallback: _text(
        activity["actorName"],
        fallback: _text(activity["userName"], fallback: ""),
      ),
    );

    final createdAt = _formatDate(
      activity["createdAt"] ?? activity["timestamp"],
    );

    final subtitleParts = <String>[
      if (actor != "—" && actor.isNotEmpty) actor,
      if (createdAt != "—") createdAt,
    ];

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              theme.colorScheme.primaryContainer,
          child: Icon(
            Icons.history,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(title),
        subtitle: subtitleParts.isEmpty
            ? null
            : Text(subtitleParts.join(" • ")),
      ),
    );
  }

  Widget _buildEmptyCard({
    required IconData icon,
    required String message,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Row(
          children: [
            Icon(
              icon,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}