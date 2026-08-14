import "package:flutter/foundation.dart";

import "../models/announcement.dart";
import "../services/announcement_service.dart";

import "auth_provider.dart";

class AnnouncementProvider
    extends ChangeNotifier {
  final AnnouncementService
      _service =
      AnnouncementService();

  bool loading = false;

  final List<Announcement>
      _announcements = [];

  List<Announcement>
      get announcements =>
          List.unmodifiable(
            _announcements,
          );

  /*
  |--------------------------------------------------------------------------
  | Load Announcements
  |--------------------------------------------------------------------------
  */

  Future<void> load({
    int limit = 50,
    bool requirePermission = true,
    AuthProvider? auth,
  }) async {
    if (requirePermission &&
        auth != null &&
        !auth.canSendAnnouncement) {
      return;
    }

    loading = true;

    notifyListeners();

    try {
      final result =
          await _service.list(
        limit: limit,
      );

      _announcements
        ..clear()
        ..addAll(result);
    } finally {
      loading = false;

      notifyListeners();
    }
  }

  /*
  |--------------------------------------------------------------------------
  | Create Announcement
  |--------------------------------------------------------------------------
  */

  Future<Announcement> create({
    required String title,
    required String message,
    required String type,
    required String priority,
    required String audience,
    bool isPinned = false,
    required AuthProvider auth,
  }) async {
    /*
    |--------------------------------------------------------------------------
    | Permission
    |--------------------------------------------------------------------------
    */

    if (!auth.canSendAnnouncement) {
      throw Exception(
        "You do not have permission to send announcements.",
      );
    }

    /*
    |--------------------------------------------------------------------------
    | Create
    |--------------------------------------------------------------------------
    */

    final announcement =
        await _service.create(
      title: title,
      message: message,
      type: type,
      priority: priority,
      audience: audience,
      isPinned: isPinned,
    );

    addRealtime(
      announcement,
    );

    return announcement;
  }

  /*
  |--------------------------------------------------------------------------
  | Pin / Unpin
  |--------------------------------------------------------------------------
  */

  Future<void> pin(
    String id,
    bool pinned, {
    required AuthProvider auth,
  }) async {
    if (!auth.canSendAnnouncement) {
      throw Exception(
        "You do not have permission to modify announcements.",
      );
    }

    final updated =
        await _service.pin(
      id,
      pinned,
    );

    updateRealtime(
      updated,
    );
  }

  /*
  |--------------------------------------------------------------------------
  | Delete
  |--------------------------------------------------------------------------
  */

  Future<void> delete(
    String id, {
    required AuthProvider auth,
  }) async {
    if (!auth.canSendAnnouncement) {
      throw Exception(
        "You do not have permission to delete announcements.",
      );
    }

    await _service.delete(
      id,
    );

    removeRealtime(
      id,
    );
  }

  /*
  |--------------------------------------------------------------------------
  | Realtime Create
  |--------------------------------------------------------------------------
  */

  void addRealtime(
    Announcement announcement,
  ) {
    final exists =
        _announcements.any(
      (item) =>
          item.id ==
          announcement.id,
    );

    if (exists) {
      return;
    }

    _announcements.insert(
      0,
      announcement,
    );

    notifyListeners();
  }

  /*
  |--------------------------------------------------------------------------
  | Realtime Update
  |--------------------------------------------------------------------------
  */

  void updateRealtime(
    Announcement announcement,
  ) {
    final index =
        _announcements.indexWhere(
      (item) =>
          item.id ==
          announcement.id,
    );

    if (index == -1) {
      _announcements.insert(
        0,
        announcement,
      );
    } else {
      _announcements[index] =
          announcement;
    }

    notifyListeners();
  }

  /*
  |--------------------------------------------------------------------------
  | Realtime Delete
  |--------------------------------------------------------------------------
  */

  void removeRealtime(
    String id,
  ) {
    _announcements.removeWhere(
      (item) =>
          item.id == id,
    );

    notifyListeners();
  }

  /*
  |--------------------------------------------------------------------------
  | Refresh
  |--------------------------------------------------------------------------
  */

  Future<void> refresh({
    AuthProvider? auth,
  }) async {
    await load(
      auth: auth,
    );
  }

  /*
  |--------------------------------------------------------------------------
  | Helpers
  |--------------------------------------------------------------------------
  */

  bool get hasAnnouncements =>
      _announcements.isNotEmpty;

  Announcement?
      get pinnedAnnouncement {
    try {
      return _announcements
          .firstWhere(
        (item) =>
            item.isPinned,
      );
    } catch (_) {
      return null;
    }
  }

  /*
  |--------------------------------------------------------------------------
  | Clear
  |--------------------------------------------------------------------------
  */

  void clear() {
    _announcements.clear();

    notifyListeners();
  }
}