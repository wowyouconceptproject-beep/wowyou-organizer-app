import "dart:convert";

import "package:flutter/foundation.dart";
import "package:shared_preferences/shared_preferences.dart";

import "../models/event.dart";
import "../models/staff.dart";

import "../services/auth_service.dart";

import "realtime_provider.dart";

class AuthProvider extends ChangeNotifier {
  final AuthService _service =
      AuthService();

  bool loading = false;

  Staff? staff;

  Event? event;

  String? token;

  /*
  |--------------------------------------------------------------------------
  | Login
  |--------------------------------------------------------------------------
  */

  Future<void> login(
    String accessCode,
    RealtimeProvider realtime,
  ) async {
    loading = true;

    notifyListeners();

    try {
      final result =
          await _service.login(
        accessCode,
      );

      token = result.token;

      staff = result.staff;

      event = result.event;

      await _persistSession();

      if (event != null) {
        realtime.connect(
          event!.id,
        );
      }
    } finally {
      loading = false;

      notifyListeners();
    }
  }

  /*
  |--------------------------------------------------------------------------
  | Logout
  |--------------------------------------------------------------------------
  */

  Future<void> logout(
    RealtimeProvider realtime,
  ) async {
    realtime.disconnect();

    try {
      await _service.logout();
    } catch (_) {
      // Ignore logout API errors.
    }

    final prefs =
        await SharedPreferences
            .getInstance();

    await prefs.remove(
      "token",
    );

    await prefs.remove(
      "staff",
    );

    await prefs.remove(
      "event",
    );

    clear();
  }

  /*
  |--------------------------------------------------------------------------
  | Restore Session
  |--------------------------------------------------------------------------
  */

  Future<bool> restoreSession(
    RealtimeProvider realtime,
  ) async {
    final prefs =
        await SharedPreferences
            .getInstance();

    final savedToken =
        prefs.getString(
      "token",
    );

    final savedStaff =
        prefs.getString(
      "staff",
    );

    final savedEvent =
        prefs.getString(
      "event",
    );

    if (savedToken == null ||
        savedStaff == null ||
        savedEvent == null) {
      return false;
    }

    token = savedToken;

    staff = Staff.fromJson(
      jsonDecode(
        savedStaff,
      ),
    );

    event = Event.fromJson(
      jsonDecode(
        savedEvent,
      ),
    );

    realtime.connect(
      event!.id,
    );

    notifyListeners();

    return true;
  }

  /*
  |--------------------------------------------------------------------------
  | Persist Session
  |--------------------------------------------------------------------------
  */

  Future<void>
      _persistSession() async {
    if (token == null ||
        staff == null ||
        event == null) {
      return;
    }

    final prefs =
        await SharedPreferences
            .getInstance();

    await prefs.setString(
      "token",
      token!,
    );

    await prefs.setString(
      "staff",
      jsonEncode(
        staff!.toJson(),
      ),
    );

    await prefs.setString(
      "event",
      jsonEncode(
        event!.toJson(),
      ),
    );
  }

  /*
  |--------------------------------------------------------------------------
  | Authentication
  |--------------------------------------------------------------------------
  */

  bool get isLoggedIn =>
      token != null;

  /*
  |--------------------------------------------------------------------------
  | Staff
  |--------------------------------------------------------------------------
  */

  String? get staffId =>
      staff?.id;

  String get staffName =>
      staff?.name ?? "";

  String get role =>
      staff?.role ?? "";

  String? get station =>
      staff?.station;

  /*
  |--------------------------------------------------------------------------
  | Permissions
  |--------------------------------------------------------------------------
  */

  List<String> get permissions =>
      staff?.permissions ?? [];

  bool hasPermission(
    String permission,
  ) {
    return permissions.contains(
      permission,
    );
  }

  /*
  |--------------------------------------------------------------------------
  | Roles
  |--------------------------------------------------------------------------
  */

  bool get isAdmin =>
      role == "ADMIN";

  bool get isOrganizer =>
      role == "ORGANIZER";

  /*
  |--------------------------------------------------------------------------
  | Operations Permissions
  |--------------------------------------------------------------------------
  */

  bool get isScanner =>
      hasPermission(
        "SCAN_QR",
      );

  bool get canManualCheckIn =>
      hasPermission(
        "MANUAL_CHECK_IN",
      );

  bool get canSearch =>
      hasPermission(
        "SEARCH_ATTENDEE",
      );

  bool get canViewActivity =>
      hasPermission(
        "VIEW_ACTIVITY",
      );

  bool get canSendAnnouncement =>
      hasPermission(
        "SEND_ANNOUNCEMENT",
      );

  bool get canBroadcast =>
      canSendAnnouncement ||
      isAdmin ||
      isOrganizer;

  /*
  |--------------------------------------------------------------------------
  | Reset
  |--------------------------------------------------------------------------
  */

  void clear() {
    staff = null;

    event = null;

    token = null;

    notifyListeners();
  }
}