import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../../providers/auth_provider.dart";
import "../../providers/realtime_provider.dart";

import "../dashboard/dashboard_screen.dart";

class OperationsHomeScreen extends StatelessWidget {
  const OperationsHomeScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.canViewDashboard) {
      return const DashboardScreen();
    }

    final actions = <_OperationAction>[
      if (auth.canScanQr)
        const _OperationAction(
          title: "Scan QR",
          description: "Scan and check in attendee tickets.",
          icon: Icons.qr_code_scanner_rounded,
          color: Color(0xFF4F46E5),
          route: "/scan",
        ),
      if (auth.canVerifyPass)
        const _OperationAction(
          title: "Verify Pass",
          description: "Verify attendee pass details.",
          icon: Icons.verified_user_rounded,
          color: Color(0xFF0891B2),
          route: "/verify-pass",
        ),
      if (auth.canSearchAttendee)
        const _OperationAction(
          title: "Find Attendee",
          description: "Search attendee and ticket records.",
          icon: Icons.person_search_rounded,
          color: Color(0xFF7C3AED),
          route: "/search-attendee",
        ),
      if (auth.canViewActivity)
        const _OperationAction(
          title: "Event Activity",
          description: "Review recorded event operations.",
          icon: Icons.history_rounded,
          color: Color(0xFF0D9488),
          route: "/activity",
        ),
      if (auth.canSendAnnouncement)
        const _OperationAction(
          title: "Announcements",
          description: "Publish an event announcement.",
          icon: Icons.campaign_rounded,
          color: Color(0xFFEA580C),
          route: "/announcements",
        ),
      if (auth.canViewReports)
        const _OperationAction(
          title: "Reports",
          description: "Review attendance and activity reports.",
          icon: Icons.bar_chart_rounded,
          color: Color(0xFFCA8A04),
          route: "/reports",
        ),
      if (auth.canViewDashboard)
        const _OperationAction(
          title: "Event Pulse",
          description: "Record live field observations.",
          icon: Icons.monitor_heart_rounded,
          color: Color(0xFFDC2626),
          route: "/event-pulse",
        ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: const Text(
          "WowYou Operations",
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: Color(0xFF111827),
          ),
        ),
        actions: [
          IconButton(
            tooltip: "Sign out",
            onPressed: () => _logout(context),
            icon: const Icon(
              Icons.logout_rounded,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // Refresh the data-backed screens when opened.
            // The activity and report screens load their data
            // through their existing providers/services.
            await Future<void>.delayed(
              const Duration(milliseconds: 100),
            );
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            children: [
              _StaffHeader(
                name: auth.staffName,
                role: auth.role,
                station: auth.station,
                eventId: auth.event?.id,
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Your operations",
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  Text(
                    "${actions.length} available",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                "Open a tool to carry out your assigned event duties.",
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 18),
              if (actions.isEmpty)
                _NoAvailableActions(
                  permissions: auth.permissions,
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: actions.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    mainAxisExtent: 154,
                  ),
                  itemBuilder: (context, index) {
                    final action = actions[index];

                    return _OperationActionCard(
                      action: action,
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          action.route,
                        );
                      },
                    );
                  },
                ),
              const SizedBox(height: 24),
              _PermissionsSection(
                permissions: auth.permissions,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final realtime = context.read<RealtimeProvider>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Sign out?"),
          content: const Text(
            "You will need your access code to sign in again.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text("Cancel"),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text("Sign out"),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    await auth.logout(realtime);

    if (!context.mounted) {
      return;
    }

    Navigator.of(context).pushNamedAndRemoveUntil(
      "/",
      (route) => false,
    );
  }
}

class _StaffHeader extends StatelessWidget {
  final String name;
  final String role;
  final String? station;
  final String? eventId;

  const _StaffHeader({
    required this.name,
    required this.role,
    required this.station,
    required this.eventId,
  });

  @override
  Widget build(BuildContext context) {
    final displayName =
        name.trim().isEmpty ? "Operations staff" : name.trim();

    final displayRole = role.trim().isEmpty
        ? "Staff"
        : role
            .trim()
            .toLowerCase()
            .split("_")
            .map(
              (part) => part.isEmpty
                  ? part
                  : "${part[0].toUpperCase()}${part.substring(1)}",
            )
            .join(" ");

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF111827),
            Color(0xFF273449),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.shield_rounded,
                color: Color(0xFF93C5FD),
                size: 18,
              ),
              SizedBox(width: 8),
              Text(
                "OPERATIONS ACCESS",
                style: TextStyle(
                  color: Color(0xFFCBD5E1),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            "Welcome, $displayName",
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              height: 1.2,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            displayRole,
            style: const TextStyle(
              color: Color(0xFFBFDBFE),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (station != null && station!.trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            _HeaderDetail(
              icon: Icons.location_on_outlined,
              label: "Station: ${station!.trim()}",
            ),
          ],
          if (eventId != null && eventId!.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            _HeaderDetail(
              icon: Icons.event_outlined,
              label: "Event ID: ${eventId!.trim()}",
            ),
          ],
        ],
      ),
    );
  }
}

class _HeaderDetail extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeaderDetail({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: const Color(0xFFCBD5E1),
          size: 16,
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFFE2E8F0),
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class _OperationAction {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String route;

  const _OperationAction({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.route,
  });
}

class _OperationActionCard extends StatelessWidget {
  final _OperationAction action;
  final VoidCallback onTap;

  const _OperationActionCard({
    required this.action,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: action.color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  action.icon,
                  color: action.color,
                  size: 22,
                ),
              ),
              const Spacer(),
              Text(
                action.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                action.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PermissionsSection extends StatelessWidget {
  final List<String> permissions;

  const _PermissionsSection({
    required this.permissions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Assigned permissions",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "${permissions.length} permission${permissions.length == 1 ? '' : 's'} assigned to your account.",
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
            ),
          ),
          if (permissions.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: permissions.map((permission) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Text(
                    _formatPermission(permission),
                    style: const TextStyle(
                      color: Color(0xFF334155),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  String _formatPermission(String permission) {
    return permission
        .toLowerCase()
        .split("_")
        .map(
          (part) => part.isEmpty
              ? part
              : "${part[0].toUpperCase()}${part.substring(1)}",
        )
        .join(" ");
  }
}

class _NoAvailableActions extends StatelessWidget {
  final List<String> permissions;

  const _NoAvailableActions({
    required this.permissions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.lock_outline_rounded,
            size: 34,
            color: Color(0xFF64748B),
          ),
          const SizedBox(height: 12),
          const Text(
            "No accessible operations",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            permissions.isEmpty
                ? "Your account currently has no assigned permissions. Contact the event owner to review your access."
                : "Your account has permissions, but none of the corresponding screens are available from this home screen.",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              height: 1.5,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}