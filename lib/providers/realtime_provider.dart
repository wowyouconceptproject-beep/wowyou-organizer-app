
import "package:flutter/foundation.dart";

import "../models/attendance_update.dart";
import "../models/notification_event.dart";
import "../models/staff_presence.dart";

import "../providers/activity_provider.dart";
import "../providers/announcement_provider.dart";

import "../services/socket_service.dart";

class RealtimeProvider extends ChangeNotifier {
  final SocketService _socket = SocketService.instance;

  bool connected = false;
  bool _initialized = false;
  bool _disposed = false;

  String? _eventId;

  ActivityProvider? _activityProvider;
  AnnouncementProvider? _announcementProvider;

  AttendanceUpdate? attendance;

  final List<NotificationEvent> notifications = [];
  final List<StaffPresence> onlineStaff = [];

  String? get eventId => _eventId;

  /*
  |--------------------------------------------------------------------------
  | Bind Providers
  |--------------------------------------------------------------------------
  */

  void bindActivity(ActivityProvider provider) {
    _activityProvider = provider;
  }

  void bindAnnouncements(AnnouncementProvider provider) {
    _announcementProvider = provider;
  }

  /*
  |--------------------------------------------------------------------------
  | Connect
  |--------------------------------------------------------------------------
  */

  void connect(String eventId) {
    if (_disposed) return;

    final normalizedEventId = eventId.trim();

    if (normalizedEventId.isEmpty) return;

    if (_initialized && _eventId == normalizedEventId) {
      reconnect();
      return;
    }

    if (_initialized) {
      _socket.leaveEvent(_eventId!);
      _socket.clearListeners();
      _socket.disconnect();
    }

    _eventId = normalizedEventId;
    connected = false;

    _listen();

    _initialized = true;

    // The onConnect callback joins the event room.
    // Do not join before the socket is connected.
    _socket.connect();
  }

  /*
  |--------------------------------------------------------------------------
  | Reconnect
  |--------------------------------------------------------------------------
  */

  void reconnect() {
    if (_disposed || !_initialized || _eventId == null) {
      return;
    }

    if (_socket.connected) {
      connected = true;
      _socket.joinEvent(_eventId!);
      notifyListeners();
      return;
    }

    connected = false;

    // SocketService handles reconnecting an existing socket.
    // The onConnect callback rejoins the event room.
    _socket.reconnect();
  }

  /*
  |--------------------------------------------------------------------------
  | Disconnect
  |--------------------------------------------------------------------------
  */

  void disconnect() {
    if (_eventId != null && _socket.connected) {
      _socket.leaveEvent(_eventId!);
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
      if (_disposed) return;

      connected = true;

      final currentEventId = _eventId;

      if (currentEventId != null) {
        _socket.joinEvent(currentEventId);
      }

      notifyListeners();
    });

    _socket.onDisconnect(() {
      if (_disposed) return;

      connected = false;
      notifyListeners();
    });

    /*
    |--------------------------------------------------------------------------
    | Attendance
    |--------------------------------------------------------------------------
    */

    _socket.onAttendance((update) {
      if (_disposed) return;

      attendance = update;
      notifyListeners();
    });

    /*
    |--------------------------------------------------------------------------
    | Activity
    |--------------------------------------------------------------------------
    */

    _socket.onActivity((activity) {
      if (_disposed) return;

      _activityProvider?.add(activity);
    });

    /*
    |--------------------------------------------------------------------------
    | Announcements
    |--------------------------------------------------------------------------
    */

    _socket.onAnnouncementCreated((announcement) {
      if (_disposed) return;

      _announcementProvider?.addRealtime(announcement);
    });

    _socket.onAnnouncementUpdated((announcement) {
      if (_disposed) return;

      _announcementProvider?.updateRealtime(announcement);
    });

    _socket.onAnnouncementDeleted((id) {
      if (_disposed) return;

      _announcementProvider?.removeRealtime(id);
    });

    /*
    |--------------------------------------------------------------------------
    | Notifications
    |--------------------------------------------------------------------------
    */

    _socket.onNotification((notification) {
      if (_disposed) return;

      notifications.insert(0, notification);
      notifyListeners();
    });

    /*
    |--------------------------------------------------------------------------
    | Staff Presence
    |--------------------------------------------------------------------------
    */

    _socket.onStaffOnline((staff) {
      if (_disposed) return;

      onlineStaff.removeWhere((item) => item.id == staff.id);
      onlineStaff.insert(0, staff);

      notifyListeners();
    });

    _socket.onStaffOffline((staff) {
      if (_disposed) return;

      onlineStaff.removeWhere((item) => item.id == staff.id);

      notifyListeners();
    });
  }

  /*
  |--------------------------------------------------------------------------
  | Attendance Helpers
  |--------------------------------------------------------------------------
  */

  int get checkedIn => attendance?.checkedIn ?? 0;

  int get totalTickets => attendance?.totalTickets ?? 0;

  int get remaining => attendance?.remaining ?? 0;

  /*
  |--------------------------------------------------------------------------
  | State Helpers
  |--------------------------------------------------------------------------
  */

  bool get hasAttendance => attendance != null;

  bool get hasNotifications => notifications.isNotEmpty;

  bool get hasOnlineStaff => onlineStaff.isNotEmpty;

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
    _disposed = true;

    _socket.clearListeners();
    _socket.disconnect();

    super.dispose();
  }
}
