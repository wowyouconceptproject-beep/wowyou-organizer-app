class StaffPresence {
  final String id;

  final String name;

  final String role;

  const StaffPresence({
    required this.id,
    required this.name,
    required this.role,
  });

  factory StaffPresence.fromJson(
    Map<String, dynamic> json,
  ) {
    return StaffPresence(
      id: json["id"],
      name: json["name"],
      role: json["role"],
    );
  }
}