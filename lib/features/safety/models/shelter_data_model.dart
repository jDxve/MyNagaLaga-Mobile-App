class ShelterData {
  final String name;
  final String address;
  final String capacity;
  final ShelterStatus status;
  final double latitude;
  final double longitude;
  final int seniors;
  final int infants;
  final int pwd;

  ShelterData({
    required this.name,
    required this.address,
    required this.capacity,
    required this.status,
    required this.latitude,
    required this.longitude,
    required this.seniors,
    required this.infants,
    required this.pwd,
  });
}

enum ShelterStatus {
  available,
  limited,
  full,
}