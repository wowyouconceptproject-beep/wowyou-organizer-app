import "package:flutter/foundation.dart";

import "../models/activity_event.dart";

import "../services/activity_service.dart";

class ActivityProvider extends ChangeNotifier {
  final ActivityService _service =
      ActivityService();

  bool loading = false;

  final List<ActivityEvent>
      _history = [];

  List<ActivityEvent> get history =>
      List.unmodifiable(
        _history,
      );

  /*
  |--------------------------------------------------------------------------
  | Load Activity History
  |--------------------------------------------------------------------------
  */

  Future<void> load({
    int limit = 50,
  }) async {
    loading = true;

    notifyListeners();

    try {
      final result =
          await _service.list(
        limit: limit,
      );

      _history
        ..clear()
        ..addAll(result);
    } finally {
      loading = false;

      notifyListeners();
    }
  }

  /*
  |--------------------------------------------------------------------------
  | Add Realtime Activity
  |--------------------------------------------------------------------------
  */

  void add(
    ActivityEvent activity,
  ) {
    final exists =
        _history.any(
      (item) =>
          item.id ==
          activity.id,
    );

    if (exists) {
      return;
    }

    _history.insert(
      0,
      activity,
    );

    notifyListeners();
  }

  /*
  |--------------------------------------------------------------------------
  | Add Multiple Activities
  |--------------------------------------------------------------------------
  */

  void addAll(
    List<ActivityEvent>
        activities,
  ) {
    for (final activity
        in activities) {
      add(activity);
    }
  }

  /*
  |--------------------------------------------------------------------------
  | Remove Activity
  |--------------------------------------------------------------------------
  */

  void remove(
    String id,
  ) {
    _history.removeWhere(
      (activity) =>
          activity.id == id,
    );

    notifyListeners();
  }

  /*
  |--------------------------------------------------------------------------
  | Refresh
  |--------------------------------------------------------------------------
  */

  Future<void> refresh() async {
    await load();
  }

  /*
  |--------------------------------------------------------------------------
  | Clear
  |--------------------------------------------------------------------------
  */

  void clear() {
    _history.clear();

    notifyListeners();
  }
}