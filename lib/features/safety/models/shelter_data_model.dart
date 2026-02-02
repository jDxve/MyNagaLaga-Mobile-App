enum ShelterStatus { available, limited, full }

class ShelterData {
  final String id;
  final String name;
  final String address;
  final String capacity;
  final ShelterStatus status;
  final double latitude;
  final double longitude;
  final int seniors;
  final int infants;
  final int pwd;
  final String barangayName;

  ShelterData({
    required this.id,
    required this.name,
    required this.address,
    required this.capacity,
    required this.status,
    required this.latitude,
    required this.longitude,
    required this.seniors,
    required this.infants,
    required this.pwd,
    required this.barangayName,
  });

  factory ShelterData.fromJson(Map<String, dynamic> json) {
    final totalCapacity =
        int.tryParse(json['total_capacity']?.toString() ?? '0') ?? 0;
    final ecStatus = json['ec_status']?.toString() ?? 'Open';

    return ShelterData(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      capacity: '0/$totalCapacity',
      status: _parseEcStatus(ecStatus),
      latitude: double.tryParse(json['latitude']?.toString() ?? '0') ?? 0.0,
      longitude: double.tryParse(json['longitude']?.toString() ?? '0') ?? 0.0,
      seniors: 0,
      infants: 0,
      pwd: 0,
      barangayName: json['barangays']?['name'] ?? '',
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

class SheltersResponse {
  final int totalShelters;
  final List<ShelterData> shelters;

  SheltersResponse({required this.totalShelters, required this.shelters});

  // ✅ FIXED: Handle the complete API response structure
  factory SheltersResponse.fromJson(Map<String, dynamic> json) {
    // The API returns: { "success": true, "data": [...] }
    final data = json['data'];
    
    // Handle both cases: data as List or nested in response
    final List<dynamic> rawList;
    if (data is List) {
      rawList = data;
    } else if (data is Map && data['data'] is List) {
      rawList = data['data'] as List;
    } else {
      rawList = [];
    }

    final sheltersList = rawList
        .map((shelter) => ShelterData.fromJson(shelter as Map<String, dynamic>))
        .toList();

    return SheltersResponse(
      totalShelters: sheltersList.length,
      shelters: sheltersList,
    );
  }

  // ✅ ADDED: Alternative factory for when you already have the data array
  factory SheltersResponse.fromList(List<dynamic> dataList) {
    final sheltersList = dataList
        .map((shelter) => ShelterData.fromJson(shelter as Map<String, dynamic>))
        .toList();

    return SheltersResponse(
      totalShelters: sheltersList.length,
      shelters: sheltersList,
    );
  }
}