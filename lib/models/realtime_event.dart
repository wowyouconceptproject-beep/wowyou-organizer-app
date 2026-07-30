class RealtimeEvent {
  final String type;

  final Map<String, dynamic>
      payload;

  RealtimeEvent({
    required this.type,
    required this.payload,
  });

  factory RealtimeEvent.fromJson(
    String type,
    dynamic json,
  ) {
    return RealtimeEvent(
      type: type,

      payload:
          Map<String, dynamic>.from(
        json,
      ),
    );
  }
}