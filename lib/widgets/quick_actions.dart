import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    final actions = <_QuickAction>[
      _QuickAction(
        title: 'Scan QR',
        subtitle: 'Scan attendee tickets',
        icon: Icons.qr_code_scanner_rounded,
        color: const Color(0xFF4F46E5),
        route: '/scan',
        visible: auth.canScanQr,
      ),
      _QuickAction(
        title: 'Verify Pass',
        subtitle: 'Validate an attendee pass',
        icon: Icons.verified_user_rounded,
        color: const Color(0xFF0891B2),
        route: '/verify-pass',
        visible: auth.canVerifyPass,
      ),
      _QuickAction(
        title: 'Find Attendee',
        subtitle: 'Search attendee records',
        icon: Icons.person_search_rounded,
        color: const Color(0xFF7C3AED),
        route: '/search-attendee',
        visible: auth.canSearchAttendee,
      ),
      _QuickAction(
        title: 'Activity',
        subtitle: 'Review event activity',
        icon: Icons.history_rounded,
        color: const Color(0xFF0D9488),
        route: '/activity',
        visible: auth.canViewActivity,
      ),
      _QuickAction(
        title: 'Announcements',
        subtitle: 'Send event announcements',
        icon: Icons.campaign_rounded,
        color: const Color(0xFFEA580C),
        route: '/announcements',
        visible: auth.canSendAnnouncement,
      ),
      _QuickAction(
        title: 'Notifications',
        subtitle: 'Notify event attendees',
        icon: Icons.notifications_active_rounded,
        color: const Color(0xFFDB2777),
        route: '/announcements',
        visible: auth.canSendNotification,
      ),
      _QuickAction(
        title: 'Manage Staff',
        subtitle: 'View and manage event staff',
        icon: Icons.groups_rounded,
        color: const Color(0xFF2563EB),
        route: '/staff',
        visible: auth.canManageStaff,
      ),
      _QuickAction(
        title: 'Manage Vendors',
        subtitle: 'View event vendors',
        icon: Icons.storefront_rounded,
        color: const Color(0xFF9333EA),
        route: '/vendors',
        visible: auth.canManageVendors,
      ),
      _QuickAction(
        title: 'Reports',
        subtitle: 'View attendance reports',
        icon: Icons.bar_chart_rounded,
        color: const Color(0xFFCA8A04),
        route: '/reports',
        visible: auth.canViewReports,
      ),
      _QuickAction(
        title: 'Event Pulse',
        subtitle: 'Submit live field observations',
        icon: Icons.monitor_heart_rounded,
        color: const Color(0xFFDC2626),
        route: '/event-pulse',
        visible: auth.hasPermission('VIEW_DASHBOARD'),
      ),
      _QuickAction(
        title: 'Edit Event',
        subtitle: 'Manage event information',
        icon: Icons.edit_calendar_rounded,
        color: const Color(0xFF475569),
        route: '/edit-event',
        visible: auth.canEditEvent,
      ),
    ];

    final availableActions =
        actions.where((action) => action.visible).toList();

    if (availableActions.isEmpty) {
      return const _EmptyQuickActions();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111827),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Tools available for your role',
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: availableActions.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 140,
          ),
          itemBuilder: (context, index) {
            final action = availableActions[index];

            return _QuickActionCard(
              action: action,
              onTap: () {
                Navigator.of(context).pushNamed(action.route);
              },
            );
          },
        ),
      ],
    );
  }
}

class _QuickAction {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String route;
  final bool visible;

  const _QuickAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.route,
    required this.visible,
  });
}

class _QuickActionCard extends StatelessWidget {
  final _QuickAction action;
  final VoidCallback onTap;

  const _QuickActionCard({
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
              color: const Color(0xFFE5E7EB),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                  const Icon(
                    Icons.arrow_outward_rounded,
                    size: 17,
                    color: Color(0xFF9CA3AF),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                action.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                action.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  height: 1.35,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyQuickActions extends StatelessWidget {
  const _EmptyQuickActions();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.lock_outline_rounded,
            size: 32,
            color: Color(0xFF9CA3AF),
          ),
          SizedBox(height: 10),
          Text(
            'No quick actions available',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF374151),
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Your assigned permissions determine which tools you can access.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}