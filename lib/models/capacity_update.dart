class CapacityUpdate {
  final String eventId;

  final int capacity;

  final int currentOccupancy;

  final int totalCheckIns;

  final int totalCheckOuts;

  final double occupancyPercentage;

  CapacityUpdate({
    required this.eventId,
    required this.capacity,
    required this.currentOccupancy,
    required this.totalCheckIns,
    required this.totalCheckOuts,
    required this.occupancyPercentage,
  });

  factory CapacityUpdate.fromJson(
    Map<String, dynamic> json,
  ) {
    return CapacityUpdate(
      eventId:
          json["eventId"],

      capacity:
          json["capacity"],

      currentOccupancy:
          json["currentOccupancy"],

      totalCheckIns:
          json["totalCheckIns"],

      totalCheckOuts:
          json["totalCheckOuts"],

      occupancyPercentage:
          (json["occupancyPercentage"] as num)
              .toDouble(),
    );
  }
}