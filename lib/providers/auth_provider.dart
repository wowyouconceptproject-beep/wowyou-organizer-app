import "dart:convert";

import "package:flutter/foundation.dart";
import "package:shared_preferences/shared_preferences.dart";

import "../models/event.dart";
import "../models/staff.dart";

import "../services/auth_service.dart";

import "../utils/storage.dart";

import "realtime_provider.dart";

class AuthProvider
    extends ChangeNotifier {
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
    if (loading) {
      return;
    }

    loading = true;

    notifyListeners();

    try {
      final result =
          await _service.login(
        accessCode,
      );

      /*
      |----------------------------------------------------------------------
      | Authentication
      |----------------------------------------------------------------------
      */

      token =
          result.token;

      staff =
          result.staff;

      event =
          result.event;

      /*
      |----------------------------------------------------------------------
      | Persist Session
      |----------------------------------------------------------------------
      |
      | AuthService has already stored the JWT in FlutterSecureStorage.
      | Persist the staff/event information here.
      |
      */

      await _persistSession();

      /*
      |----------------------------------------------------------------------
      | Connect Realtime
      |----------------------------------------------------------------------
      */

      if (event != null) {
        realtime.connect(
          event!.id,
        );
      }
    } catch (error) {
      /*
      |----------------------------------------------------------------------
      | Login Failure
      |----------------------------------------------------------------------
      */

      token = null;
      staff = null;
      event = null;

      rethrow;
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
      /*
      |----------------------------------------------------------------------
      | Local logout must still complete even if remote cleanup fails.
      |----------------------------------------------------------------------
      */
    }

    /*
    |----------------------------------------------------------------------
    | Clear Cached Session
    |----------------------------------------------------------------------
    */

    final prefs =
        await SharedPreferences
            .getInstance();

    await prefs.remove(
      "staff",
    );

    await prefs.remove(
      "event",
    );

    /*
    |----------------------------------------------------------------------
    | Clear Authentication State
    |----------------------------------------------------------------------
    */

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
    try {
      /*
      |----------------------------------------------------------------------
      | JWT
      |----------------------------------------------------------------------
      */

      final savedToken =
          await Storage.getToken();

      /*
      |----------------------------------------------------------------------
      | Cached Models
      |----------------------------------------------------------------------
      */

      final prefs =
          await SharedPreferences
              .getInstance();

      final savedStaff =
          prefs.getString(
        "staff",
      );

      final savedEvent =
          prefs.getString(
        "event",
      );

      /*
      |----------------------------------------------------------------------
      | Validate Session
      |----------------------------------------------------------------------
      */

      if (savedToken == null ||
          savedToken.isEmpty ||
          savedStaff == null ||
          savedEvent == null) {
        return false;
      }

      /*
      |----------------------------------------------------------------------
      | Restore JWT
      |----------------------------------------------------------------------
      */

      token =
          savedToken;

      /*
      |----------------------------------------------------------------------
      | Restore Staff
      |----------------------------------------------------------------------
      */

      staff =
          Staff.fromJson(
        jsonDecode(
          savedStaff,
        ),
      );

      /*
      |----------------------------------------------------------------------
      | Restore Event
      |----------------------------------------------------------------------
      */

      event =
          Event.fromJson(
        jsonDecode(
          savedEvent,
        ),
      );

      /*
      |----------------------------------------------------------------------
      | Reconnect Realtime
      |----------------------------------------------------------------------
      */

      realtime.connect(
        event!.id,
      );

      notifyListeners();

      return true;
    } catch (error) {
      /*
      |----------------------------------------------------------------------
      | Invalid Cached Session
      |----------------------------------------------------------------------
      */

      await Storage.clear();

      final prefs =
          await SharedPreferences
              .getInstance();

      await prefs.remove(
        "staff",
      );

      await prefs.remove(
        "event",
      );

      clear();

      return false;
    }
  }

  /*
  |--------------------------------------------------------------------------
  | Persist Session
  |--------------------------------------------------------------------------
  */

  Future<void>
      _persistSession() async {
    if (token == null ||
        token!.isEmpty ||
        staff == null ||
        event == null) {
      return;
    }

    /*
    |----------------------------------------------------------------------
    | JWT
    |----------------------------------------------------------------------
    |
    | The JWT is stored exclusively in FlutterSecureStorage.
    |
    */

    await Storage.saveToken(
      token!,
    );

    /*
    |----------------------------------------------------------------------
    | Staff + Event Cache
    |----------------------------------------------------------------------
    */

    final prefs =
        await SharedPreferences
            .getInstance();

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
      token != null &&
      token!.isNotEmpty;

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
  | Clear
  |--------------------------------------------------------------------------
  */

  void clear() {
    staff = null;

    event = null;

    token = null;

    notifyListeners();
  }
}