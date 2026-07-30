import "package:flutter/foundation.dart";

import "../models/attendance_update.dart";
import "../models/notification_event.dart";
import "../models/staff_presence.dart";

import "../providers/activity_provider.dart";
import "../providers/announcement_provider.dart";

import "../services/socket_service.dart";

class RealtimeProvider extends ChangeNotifier {
  final SocketService _socket =
      SocketService.instance;

  bool connected = false;

  bool _initialized = false;

  String? _eventId;

  ActivityProvider?
      _activityProvider;

  AnnouncementProvider?
      _announcementProvider;

  AttendanceUpdate? attendance;

  final List<NotificationEvent>
      notifications = [];

  final List<StaffPresence>
      onlineStaff = [];

  /*
  |--------------------------------------------------------------------------
  | Bind Providers
  |--------------------------------------------------------------------------
  */

  void bindActivity(
    ActivityProvider provider,
  ) {
    _activityProvider =
        provider;
  }

  void bindAnnouncements(
    AnnouncementProvider
        provider,
  ) {
    _announcementProvider =
        provider;
  }

  /*
  |--------------------------------------------------------------------------
  | Connect
  |--------------------------------------------------------------------------
  */

  void connect(
    String eventId,
  ) {
    if (_initialized) {
      return;
    }

    _eventId = eventId;

    _socket.connect();

    _listen();

    _socket.joinEvent(
      eventId,
    );

    _initialized = true;
  }

  /*
  |--------------------------------------------------------------------------
  | Disconnect
  |--------------------------------------------------------------------------
  */

  void disconnect() {
    if (_eventId != null) {
      _socket.leaveEvent(
        _eventId!,
      );
    }

    _socket.clearListeners();

    _socket.disconnect();

    connected = false;

    _initialized = false;

    _eventId = null;

    clear();

    notifyListeners();
  }

  /*
  |--------------------------------------------------------------------------
  | Socket Listeners
  |--------------------------------------------------------------------------
  */

  void _listen() {
    _socket.onConnect(() {
      connected = true;

      if (_eventId != null) {
        _socket.joinEvent(
          _eventId!,
        );
      }

      notifyListeners();
    });

    _socket.onDisconnect(() {
      connected = false;

      notifyListeners();
    });

    /*
    |--------------------------------------------------------------------------
    | Attendance
    |--------------------------------------------------------------------------
    */

    _socket.onAttendance(
      (attendance) {
        this.attendance =
            attendance;

        notifyListeners();
      },
    );

    /*
    |--------------------------------------------------------------------------
    | Activity
    |--------------------------------------------------------------------------
    */

    _socket.onActivity(
      (activity) {
        _activityProvider?.add(
          activity,
        );
      },
    );

    /*
    |--------------------------------------------------------------------------
    | Announcements
    |--------------------------------------------------------------------------
    */

    _socket.onAnnouncementCreated(
      (announcement) {
        _announcementProvider
            ?.addRealtime(
          announcement,
        );
      },
    );

    _socket.onAnnouncementUpdated(
      (announcement) {
        _announcementProvider
            ?.updateRealtime(
          announcement,
        );
      },
    );

    _socket.onAnnouncementDeleted(
      (id) {
        _announcementProvider
            ?.removeRealtime(
          id,
        );
      },
    );

    /*
    |--------------------------------------------------------------------------
    | Notifications
    |--------------------------------------------------------------------------
    */

    _socket.onNotification(
      (notification) {
        notifications.insert(
          0,
          notification,
        );

        notifyListeners();
      },
    );

    /*
    |--------------------------------------------------------------------------
    | Staff Presence
    |--------------------------------------------------------------------------
    */

    _socket.onStaffOnline(
      (staff) {
        onlineStaff.removeWhere(
          (s) => s.id == staff.id,
        );

        onlineStaff.insert(
          0,
          staff,
        );

        notifyListeners();
      },
    );

    _socket.onStaffOffline(
      (staff) {
        onlineStaff.removeWhere(
          (s) => s.id == staff.id,
        );

        notifyListeners();
      },
    );
  }

  /*
  |--------------------------------------------------------------------------
  | Attendance Helpers
  |--------------------------------------------------------------------------
  */

  int get checkedIn =>
      attendance?.checkedIn ?? 0;

  int get totalTickets =>
      attendance?.totalTickets ??
      0;

  int get remaining =>
      attendance?.remaining ?? 0;

  /*
  |--------------------------------------------------------------------------
  | State Helpers
  |--------------------------------------------------------------------------
  */

  bool get hasAttendance =>
      attendance != null;

  bool get hasNotifications =>
      notifications.isNotEmpty;

  bool get hasOnlineStaff =>
      onlineStaff.isNotEmpty;

  /*
  |--------------------------------------------------------------------------
  | Reset
  |--------------------------------------------------------------------------
  */

  void clear() {
    attendance = null;

    notifications.clear();

    onlineStaff.clear();
  }

  @override
  void dispose() {
    _socket.clearListeners();

    _socket.disconnect();

    super.dispose();
  }
}