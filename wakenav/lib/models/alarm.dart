// models/alarm.dart

class Alarm {
  final String id;
  final String name;
  final double distance;
  final String note;
  final double latitude;
  final double longitude;
  bool isActive;

  Alarm({
    required this.id,
    required this.name,
    required this.distance,
    this.note = '',
    required this.latitude,
    required this.longitude,
    this.isActive = false,
  });

  // Add this method to deactivate the alarm
  void deactivate() {
    isActive = false;
  }

  // Add this method to activate the alarm
  void activate() {
    isActive = true;
  }

  // Add this method to toggle the alarm's active state
  void toggleActive() {
    isActive = !isActive;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'distance': distance,
      'note': note,
      'latitude': latitude,
      'longitude': longitude,
      'isActive': isActive,
    };
  }

  factory Alarm.fromJson(Map<String, dynamic> json) {
    return Alarm(
      id: json['id'],
      name: json['name'],
      distance: json['distance'],
      note: json['note'] ?? '',
      latitude: json['latitude'],
      longitude: json['longitude'],
      isActive: json['isActive'] ?? false,
    );
  }

  // Add this method to create a copy of the alarm with updated fields
  Alarm copyWith({
    String? id,
    String? name,
    double? distance,
    String? note,
    double? latitude,
    double? longitude,
    bool? isActive,
  }) {
    return Alarm(
      id: id ?? this.id,
      name: name ?? this.name,
      distance: distance ?? this.distance,
      note: note ?? this.note,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isActive: isActive ?? this.isActive,
    );
  }
}