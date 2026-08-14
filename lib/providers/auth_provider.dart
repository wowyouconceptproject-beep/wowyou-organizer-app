import "dart:convert";

import "package:flutter/foundation.dart";
import "package:shared_preferences/shared_preferences.dart";

import "../models/event.dart";
import "../models/staff.dart";

import "../services/auth_service.dart";

import "../utils/storage.dart";

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
      | Local logout must still complete.
      |----------------------------------------------------------------------
      */
    }

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
      final savedToken =
          await Storage.getToken();

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

      if (savedToken == null ||
          savedToken.isEmpty ||
          savedStaff == null ||
          savedEvent == null) {
        return false;
      }

      token =
          savedToken;

      staff =
          Staff.fromJson(
        jsonDecode(
          savedStaff,
        ),
      );

      event =
          Event.fromJson(
        jsonDecode(
          savedEvent,
        ),
      );

      if (event != null) {
        realtime.connect(
          event!.id,
        );
      }

      notifyListeners();

      return true;
    } catch (error) {
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
    */

    await Storage.saveToken(
      token!,
    );

    /*
    |----------------------------------------------------------------------
    | Staff
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

    /*
    |----------------------------------------------------------------------
    | Event
    |----------------------------------------------------------------------
    */

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
  | Staff Identity
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
  | Dashboard
  |--------------------------------------------------------------------------
  */

  bool get canViewDashboard =>
      hasPermission(
        "VIEW_DASHBOARD",
      );

  /*
  |--------------------------------------------------------------------------
  | Check-In / Pass Verification
  |--------------------------------------------------------------------------
  */

  bool get canScanQr =>
      hasPermission(
        "SCAN_QR",
      );

  bool get canVerifyPass =>
      hasPermission(
        "VERIFY_PASS",
      );

  bool get canSearchAttendee =>
      hasPermission(
        "SEARCH_ATTENDEE",
      );

  /*
  |--------------------------------------------------------------------------
  | Activity
  |--------------------------------------------------------------------------
  */

  bool get canViewActivity =>
      hasPermission(
        "VIEW_ACTIVITY",
      );

  /*
  |--------------------------------------------------------------------------
  | Communication
  |--------------------------------------------------------------------------
  */

  bool get canSendNotification =>
      hasPermission(
        "SEND_NOTIFICATION",
      );

  bool get canSendAnnouncement =>
      hasPermission(
        "SEND_ANNOUNCEMENT",
      );

  /*
  |--------------------------------------------------------------------------
  | Staff Management
  |--------------------------------------------------------------------------
  */

  bool get canManageStaff =>
      hasPermission(
        "MANAGE_STAFF",
      );

  /*
  |--------------------------------------------------------------------------
  | Vendor Management
  |--------------------------------------------------------------------------
  */

  bool get canManageVendors =>
      hasPermission(
        "MANAGE_VENDORS",
      );

  /*
  |--------------------------------------------------------------------------
  | Reports
  |--------------------------------------------------------------------------
  */

  bool get canViewReports =>
      hasPermission(
        "VIEW_REPORTS",
      );

  /*
  |--------------------------------------------------------------------------
  | Event Management
  |--------------------------------------------------------------------------
  */

  bool get canEditEvent =>
      hasPermission(
        "EDIT_EVENT",
      );

  /*
  |--------------------------------------------------------------------------
  | Role Helpers
  |--------------------------------------------------------------------------
  */

  bool get isOwner =>
      role == "OWNER";

  bool get isOperations =>
      role == "OPERATIONS";

  bool get isCheckIn =>
      role == "CHECK_IN";

  bool get isSecurity =>
      role == "SECURITY";

  bool get isStageManager =>
      role == "STAGE_MANAGER";

  bool get isVendorManager =>
      role == "VENDOR_MANAGER";

  /*
  |--------------------------------------------------------------------------
  | Role Groups
  |--------------------------------------------------------------------------
  */

  bool get isEventManagement =>
      isOwner ||
      canEditEvent;

  bool get isOperationsStaff =>
      isOwner ||
      isOperations;

  bool get isCheckInStaff =>
      isOwner ||
      isCheckIn;

  bool get isSecurityStaff =>
      isOwner ||
      isSecurity;

  /*
  |--------------------------------------------------------------------------
  | Legacy Compatibility
  |--------------------------------------------------------------------------
  |
  | Keep these temporarily so existing screens do not break while we migrate
  | them to the new permission names.
  |
  */

  bool get isScanner =>
      canScanQr;

  bool get canManualCheckIn =>
      canVerifyPass;

  bool get canSearch =>
      canSearchAttendee;

  bool get canBroadcast =>
      canSendAnnouncement;

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