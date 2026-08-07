import "package:socket_io_client/socket_io_client.dart"
    as io;

import "../config/api.dart";
import "../config/socket_events.dart";

import "../models/activity_event.dart";
import "../models/announcement.dart";
import "../models/attendance_update.dart";
import "../models/capacity_update.dart";
import "../models/notification_event.dart";
import "../models/staff_presence.dart";

import "../utils/storage.dart";

class SocketService {
  SocketService._();

  static final SocketService instance =
      SocketService._();

  io.Socket? _socket;

  io.Socket? get socket =>
      _socket;

  bool get connected =>
      _socket?.connected ??
      false;

  /*
  |--------------------------------------------------------------------------
  | Connection
  |--------------------------------------------------------------------------
  */

  Future<void> connect() async {
    if (_socket != null) {
      return;
    }

    final token =
        await Storage.getToken();

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
          .setAuth({
            "token": token,
          })
          .build(),
    );

    _socket!.connect();
  }

  void disconnect() {
    _socket?.clearListeners();

    _socket?.disconnect();

    _socket?.dispose();

    _socket = null;
  }

  /*
  |--------------------------------------------------------------------------
  | Rooms
  |--------------------------------------------------------------------------
  */

  Future<void> joinEvent(
    String eventId,
  ) async {
    final jwt =
        await Storage.getToken();

    _socket?.emit(
      SocketEvents.joinEvent,
      {
        "eventId": eventId,
        "token": jwt,
      },
    );
  }

  void leaveEvent(
    String eventId,
  ) {
    _socket?.emit(
      SocketEvents.leaveEvent,
      eventId,
    );
  }

  Future<void> joinOrganizer(
    String organizerId,
  ) async {
    final jwt =
        await Storage.getToken();

    _socket?.emit(
      SocketEvents.joinOrganizer,
      {
        "organizerId":
            organizerId,
        "token": jwt,
      },
    );
  }

  void leaveOrganizer(
    String organizerId,
  ) {
    _socket?.emit(
      SocketEvents.leaveOrganizer,
      organizerId,
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
  | Capacity
  |--------------------------------------------------------------------------
  */

  void onCapacityUpdated(
    Function(
      CapacityUpdate,
    ) listener,
  ) {
    _socket?.on(
      SocketEvents.capacityUpdated,
      (data) {
        listener(
          CapacityUpdate.fromJson(
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
      SocketEvents
          .announcementCreated,
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
      SocketEvents
          .announcementUpdated,
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
      SocketEvents
          .announcementDeleted,
      (data) {
        listener(
          data["id"]
              .toString(),
        );
      },
    );
  }

  /*
  |--------------------------------------------------------------------------
  | Staff
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
  | Lifecycle
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