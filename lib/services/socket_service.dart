import "../models/announcement.dart";
import "package:socket_io_client/socket_io_client.dart"
    as io;

import "../config/api.dart";
import "../config/socket_events.dart";

import "../models/activity_event.dart";
import "../models/attendance_update.dart";
import "../models/notification_event.dart";
import "../models/staff_presence.dart";

class SocketService {
  SocketService._();

  static final SocketService instance =
      SocketService._();

  io.Socket? _socket;

  io.Socket? get socket => _socket;

  bool get connected =>
      _socket?.connected ?? false;

  /*
  |--------------------------------------------------------------------------
  | Connection
  |--------------------------------------------------------------------------
  */

  void connect() {
    if (_socket != null) {
      return;
    }

    _socket = io.io(
      ApiConfig.baseUrl,
      io.OptionBuilder()
          .setTransports([
            "websocket",
          ])
          .enableReconnection()
          .setReconnectionAttempts(
            999999,
          )
          .setReconnectionDelay(
            1000,
          )
          .build(),
    );

    _socket!.connect();
  }

  void disconnect() {
    _socket?.disconnect();

    _socket?.dispose();

    _socket = null;
  }

  /*
  |--------------------------------------------------------------------------
  | Rooms
  |--------------------------------------------------------------------------
  */

  void joinEvent(
    String eventId,
  ) {
    _socket?.emit(
      "join-event",
      eventId,
    );
  }

  void leaveEvent(
    String eventId,
  ) {
    _socket?.emit(
      "leave-event",
      eventId,
    );
  }

  /*
  |--------------------------------------------------------------------------
  | Attendance
  |--------------------------------------------------------------------------
  */

  void onAttendance(
    Function(
      AttendanceUpdate,
    ) listener,
  ) {
    _socket?.on(
      SocketEvents.attendanceUpdated,
      (data) {
        listener(
          AttendanceUpdate.fromJson(
            Map<String, dynamic>.from(
              data,
            ),
          ),
        );
      },
    );
  }

  /*
  |--------------------------------------------------------------------------
  | Activity
  |--------------------------------------------------------------------------
  */

  void onActivity(
    Function(
      ActivityEvent,
    ) listener,
  ) {
    _socket?.on(
      SocketEvents.activityCreated,
      (data) {
        listener(
          ActivityEvent.fromJson(
            Map<String, dynamic>.from(
              data,
            ),
          ),
        );
      },
    );
  }

  /*
  |--------------------------------------------------------------------------
  | Announcements
  |--------------------------------------------------------------------------
  */

  void onAnnouncementCreated(
    Function(
      Announcement,
    ) listener,
  ) {
    _socket?.on(
      SocketEvents.announcementCreated,
      (data) {
        listener(
          Announcement.fromJson(
            Map<String, dynamic>.from(
              data,
            ),
          ),
        );
      },
    );
  }

  void onAnnouncementUpdated(
    Function(
      Announcement,
    ) listener,
  ) {
    _socket?.on(
      SocketEvents.announcementUpdated,
      (data) {
        listener(
          Announcement.fromJson(
            Map<String, dynamic>.from(
              data,
            ),
          ),
        );
      },
    );
  }

  void onAnnouncementDeleted(
    Function(
      String,
    ) listener,
  ) {
    _socket?.on(
      SocketEvents.announcementDeleted,
      (data) {
        listener(
          data["id"].toString(),
        );
      },
    );
  }

  /*
  |--------------------------------------------------------------------------
  | Staff Presence
  |--------------------------------------------------------------------------
  */

  void onStaffOnline(
    Function(
      StaffPresence,
    ) listener,
  ) {
    _socket?.on(
      SocketEvents.staffOnline,
      (data) {
        listener(
          StaffPresence.fromJson(
            Map<String, dynamic>.from(
              data,
            ),
          ),
        );
      },
    );
  }

  void onStaffOffline(
    Function(
      StaffPresence,
    ) listener,
  ) {
    _socket?.on(
      SocketEvents.staffOffline,
      (data) {
        listener(
          StaffPresence.fromJson(
            Map<String, dynamic>.from(
              data,
            ),
          ),
        );
      },
    );
  }

  /*
  |--------------------------------------------------------------------------
  | Notifications
  |--------------------------------------------------------------------------
  */

  void onNotification(
    Function(
      NotificationEvent,
    ) listener,
  ) {
    _socket?.on(
      SocketEvents.notification,
      (data) {
        listener(
          NotificationEvent.fromJson(
            Map<String, dynamic>.from(
              data,
            ),
          ),
        );
      },
    );
  }

  /*
  |--------------------------------------------------------------------------
  | Socket Lifecycle
  |--------------------------------------------------------------------------
  */

  void onConnect(
    Function() listener,
  ) {
    _socket?.onConnect(
      (_) => listener(),
    );
  }

  void onDisconnect(
    Function() listener,
  ) {
    _socket?.onDisconnect(
      (_) => listener(),
    );
  }

  /*
  |--------------------------------------------------------------------------
  | Cleanup
  |--------------------------------------------------------------------------
  */

  void clearListeners() {
    _socket?.clearListeners();
  }
}