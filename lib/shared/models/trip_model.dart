class TripModel {
  final String id;
  final String tripCode;
  final String boardingStation;
  final String dropStation;
  final String boardingStationName;
  final String dropStationName;
  final int fare;
  final int numberOfPassengers;
  final int totalAmount;
  final String status;
  final String paymentMethod;
  final String paymentStatus;
  final DateTime expiresAt;
  final DateTime createdAt;
  final DateTime? usedAt;

  TripModel({
    required this.id,
    required this.tripCode,
    required this.boardingStation,
    required this.dropStation,
    required this.boardingStationName,
    required this.dropStationName,
    required this.fare,
    required this.numberOfPassengers,
    required this.totalAmount,
    required this.status,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.expiresAt,
    required this.createdAt,
    this.usedAt,
  });

  factory TripModel.fromJson(Map<String, dynamic> json) {
    print('🔍 Parsing TripModel from JSON: $json');

    // Handle nested response structure: data.trip
    final tripData = json['data']?['trip'] ?? json;
    print('🔍 Trip data: $tripData');

    // Extract station information
    final fromStation = tripData['fromStation'];
    final toStation = tripData['toStation'];

    print('🔍 From station: $fromStation');
    print('🔍 To station: $toStation');

    String boardingStationId = '';
    String boardingStationName = '';
    String dropStationId = '';
    String dropStationName = '';

    if (fromStation is Map<String, dynamic>) {
      boardingStationId = fromStation['_id'] ?? '';
      boardingStationName = fromStation['name'] ?? '';
      print(
          '📍 From station parsed - ID: $boardingStationId, Name: $boardingStationName');
    } else {
      boardingStationId = fromStation?.toString() ?? '';
      boardingStationName = '';
      print('📍 From station is not a map: $fromStation');
    }

    if (toStation is Map<String, dynamic>) {
      dropStationId = toStation['_id'] ?? '';
      dropStationName = toStation['name'] ?? '';
      print(
          '📍 To station parsed - ID: $dropStationId, Name: $dropStationName');
    } else {
      dropStationId = toStation?.toString() ?? '';
      dropStationName = '';
      print('📍 To station is not a map: $toStation');
    }

    final trip = TripModel(
      id: tripData['_id'] ?? tripData['id'] ?? '',
      tripCode: tripData['tripCode'] ?? '',
      boardingStation: boardingStationId,
      dropStation: dropStationId,
      boardingStationName: boardingStationName,
      dropStationName: dropStationName,
      fare: tripData['fare'] ?? 0,
      numberOfPassengers: tripData['numberOfPassengers'] ?? 1,
      totalAmount: tripData['totalAmount'] ?? 0,
      status: tripData['status'] ?? 'created',
      paymentMethod: tripData['paymentMethod'] ?? 'balance',
      paymentStatus: tripData['paymentStatus'] ?? 'pending',
      expiresAt: DateTime.parse(tripData['expiresAt'] ??
          DateTime.now().add(Duration(hours: 1)).toIso8601String()),
      createdAt: DateTime.parse(
          tripData['createdAt'] ?? DateTime.now().toIso8601String()),
      usedAt: tripData['usedAt'] != null
          ? DateTime.parse(tripData['usedAt'])
          : null,
    );

    print('✅ TripModel created:');
    print('   - ID: ${trip.id}');
    print('   - Trip Code: ${trip.tripCode}');
    print('   - From: ${trip.boardingStationName} (${trip.boardingStation})');
    print('   - To: ${trip.dropStationName} (${trip.dropStation})');
    print('   - Fare: ${trip.fare}');
    print('   - Passengers: ${trip.numberOfPassengers}');
    print('   - Status: ${trip.status}');

    return trip;
  }
}
