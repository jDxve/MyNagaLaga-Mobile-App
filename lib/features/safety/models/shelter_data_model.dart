enum ShelterStatus { available, limited, full }

class ShelterData {
  final String id;
  final String name;
  final String address;
  final String capacity;
  final int currentOccupancy;
  final int maxCapacity;
  final ShelterStatus status;
  final double latitude;
  final double longitude;
  final int seniors;
  final int infants;
  final int pwd;
  final String barangayName;
  final String? barangayId;

  ShelterData({
    required this.id,
    required this.name,
    required this.address,
    required this.capacity,
    required this.currentOccupancy,
    required this.maxCapacity,
    required this.status,
    required this.latitude,
    required this.longitude,
    required this.seniors,
    required this.infants,
    required this.pwd,
    required this.barangayName,
    this.barangayId,
  });

  factory ShelterData.fromJson(Map<String, dynamic> json) {
    final totalCapacity =
        int.tryParse(json['total_capacity']?.toString() ?? '0') ?? 0;
    final ecStatus = json['ec_status']?.toString() ?? 'Open';

    final events =
        json['disaster_evacuation_events'] as List<dynamic>? ?? [];

    int currentOccupancy = 0;
    int seniors = 0;
    int infants = 0;
    int pwd = 0;

    if (events.isNotEmpty) {
      final event = events.first as Map<String, dynamic>;
      final registrations =
          event['evacuation_registrations'] as List<dynamic>? ?? [];

      for (final reg in registrations) {
        final regMap = reg as Map<String, dynamic>;
        if (regMap['decampment_timestamp'] != null) continue;

        currentOccupancy++;

        final evacueeRes = regMap['evacuee_residents'];
        if (evacueeRes == null) continue;

        final resident = evacueeRes['residents'] as Map<String, dynamic>?;
        if (resident == null) continue;

        final birthdate = resident['birthdate'];
        if (birthdate != null) {
          final birth = DateTime.tryParse(birthdate.toString());
          if (birth != null) {
            final age =
                DateTime.now().difference(birth).inDays ~/ 365;
            if (age < 2) {
              infants++;
            } else if (age >= 60) {
              seniors++;
            }
          }
        }

        final vulnIds =
            regMap['vulnerability_type_ids'] as List<dynamic>? ?? [];
        if (vulnIds.isNotEmpty) pwd++;
      }
    }

    return ShelterData(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      capacity: '$currentOccupancy/$totalCapacity',
      currentOccupancy: currentOccupancy,
      maxCapacity: totalCapacity,
      status: _parseEcStatus(ecStatus),
      latitude:
          double.tryParse(json['latitude']?.toString() ?? '0') ?? 0.0,
      longitude:
          double.tryParse(json['longitude']?.toString() ?? '0') ?? 0.0,
      seniors: seniors,
      infants: infants,
      pwd: pwd,
      barangayName: json['barangays']?['name'] ?? '',
      barangayId: json['barangay_id']?.toString(),
    );
  }

  static ShelterStatus _parseEcStatus(String ecStatus) {
    switch (ecStatus) {
      case 'Full':
      case 'Not_Available':
      case 'Closed':
        return ShelterStatus.full;
      case 'Near_Full':
        return ShelterStatus.limited;
      case 'Open':
      default:
        return ShelterStatus.available;
    }
  }
}

class AssignedCenterData {
  final String centerId;
  final String centerName;
  final String address;
  final String barangayName;
  final double latitude;
  final double longitude;
  final String? disasterEventId;
  final String? disasterName;
  final int currentOccupancy;
  final int maxCapacity;

  AssignedCenterData({
    required this.centerId,
    required this.centerName,
    required this.address,
    required this.barangayName,
    required this.latitude,
    required this.longitude,
    this.disasterEventId,
    this.disasterName,
    required this.currentOccupancy,
    required this.maxCapacity,
  });

  factory AssignedCenterData.fromJson(Map<String, dynamic> json) {
    final events =
        json['disaster_evacuation_events'] as List<dynamic>? ?? [];

    String? disasterEventId;
    String? disasterName;
    int currentOccupancy = 0;

    if (events.isNotEmpty) {
      final event = events.first as Map<String, dynamic>;
      disasterEventId = event['id']?.toString();
      final disaster =
          event['disasters'] as Map<String, dynamic>?;
      disasterName = disaster?['disaster_name'] as String?;

      final registrations =
          event['evacuation_registrations'] as List<dynamic>? ?? [];
      currentOccupancy = registrations
          .where((r) =>
              (r as Map<String, dynamic>)['decampment_timestamp'] == null)
          .length;
    }

    return AssignedCenterData(
      centerId: json['id'].toString(),
      centerName: json['name'] ?? '',
      address: json['address'] ?? '',
      barangayName: json['barangays']?['name'] ?? '',
      latitude:
          double.tryParse(json['latitude']?.toString() ?? '0') ?? 0.0,
      longitude:
          double.tryParse(json['longitude']?.toString() ?? '0') ?? 0.0,
      disasterEventId: disasterEventId,
      disasterName: disasterName,
      currentOccupancy: currentOccupancy,
      maxCapacity:
          int.tryParse(json['total_capacity']?.toString() ?? '0') ?? 0,
    );
  }
}

class SheltersResponse {
  final int totalShelters;
  final List<ShelterData> shelters;

  SheltersResponse({required this.totalShelters, required this.shelters});

  factory SheltersResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final List<dynamic> rawList;
    if (data is List) {
      rawList = data;
    } else if (data is Map && data['data'] is List) {
      rawList = data['data'] as List;
    } else {
      rawList = [];
    }

    final sheltersList = rawList
        .map((s) => ShelterData.fromJson(s as Map<String, dynamic>))
        .toList();

    return SheltersResponse(
      totalShelters: sheltersList.length,
      shelters: sheltersList,
    );
  }
}