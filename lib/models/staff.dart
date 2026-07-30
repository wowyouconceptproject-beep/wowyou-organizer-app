class Staff {
  final String id;

  final String name;

  final String role;

  final String? station;

  final List<String> permissions;

  const Staff({
    required this.id,
    required this.name,
    required this.role,
    this.station,
    required this.permissions,
  });

  factory Staff.fromJson(
    Map<String, dynamic> json,
  ) {
    return Staff(
      id: json["id"],

      name: json["name"],

      role: json["role"],

      station: json["station"],

      permissions:
          List<String>.from(
        json["permissions"] ?? [],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,

      "name": name,

      "role": role,

      "station": station,

      "permissions": permissions,
    };
  }
}