class StationModel {
  final String id;
  final String name;
  final String zone;
  final String address;
  final List<String> facilities;
  final Map<String, double> location;

  StationModel({
    required this.id,
    required this.name,
    required this.zone,
    required this.address,
    required this.facilities,
    required this.location,
  });

  factory StationModel.fromJson(Map<String, dynamic> json) {
    try {
      print('🔧 StationModel.fromJson called with: $json');

      // Handle location data - convert string values to double if needed
      Map<String, double> location = {};
      if (json['location'] != null) {
        print('📍 Processing location data: ${json['location']}');
        if (json['location'] is Map<String, dynamic>) {
          final locationData = json['location'] as Map<String, dynamic>;
          locationData.forEach((key, value) {
            print(
                '📍 Location field $key: $value (type: ${value.runtimeType})');
            if (value is String) {
              location[key] = double.tryParse(value) ?? 0.0;
            } else if (value is double) {
              location[key] = value;
            } else if (value is int) {
              location[key] = value.toDouble();
            } else {
              location[key] = 0.0;
            }
          });
        } else {
          print('⚠️ Location is not a Map: ${json['location'].runtimeType}');
        }
      }

      final station = StationModel(
        id: json['_id'] ?? json['id'],
        name: json['name'] ?? '',
        zone: json['zone'] ?? '',
        address: json['address'] ?? '',
        facilities: List<String>.from(json['facilities'] ?? []),
        location: location,
      );

      print('✅ StationModel created successfully: ${station.name}');
      return station;
    } catch (e) {
      print('❌ Error in StationModel.fromJson: $e');
      print('❌ JSON data: $json');
      rethrow;
    }
  }
}
