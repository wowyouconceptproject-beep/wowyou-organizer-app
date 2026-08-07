class SocketEvents {
  SocketEvents._();

  /*
  |--------------------------------------------------------------------------
  | Rooms
  |--------------------------------------------------------------------------
  */

  static const joinEvent =
      "join-event";

  static const leaveEvent =
      "leave-event";

  static const joinOrganizer =
      "join-organizer";

  static const leaveOrganizer =
      "leave-organizer";

  static const joinAttendee =
      "join-attendee";

  static const leaveAttendee =
      "leave-attendee";

  /*
  |--------------------------------------------------------------------------
  | Attendance
  |--------------------------------------------------------------------------
  */

  static const attendanceUpdated =
      "attendance.updated";

  /*
  |--------------------------------------------------------------------------
  | Capacity
  |--------------------------------------------------------------------------
  */

  static const capacityUpdated =
      "capacity.updated";

  /*
  |--------------------------------------------------------------------------
  | Activity
  |--------------------------------------------------------------------------
  */

  static const activityCreated =
      "activity.created";

  /*
  |--------------------------------------------------------------------------
  | Announcements
  |--------------------------------------------------------------------------
  */

  static const announcementCreated =
      "announcement.created";

  static const announcementUpdated =
      "announcement.updated";

  static const announcementDeleted =
      "announcement.deleted";

  /*
  |--------------------------------------------------------------------------
  | Staff
  |--------------------------------------------------------------------------
  */

  static const staffOnline =
      "staff.online";

  static const staffOffline =
      "staff.offline";

  /*
  |--------------------------------------------------------------------------
  | Notifications
  |--------------------------------------------------------------------------
  */

  static const notification =
      "notification";
}