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
      note: json['note'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      isActive: json['isActive'],
    );
  }
}