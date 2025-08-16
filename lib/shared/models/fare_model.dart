class FareModel {
  final String id;
  final String fromStation;
  final String toStation;
  final int amount;
  final String fareType;
  final double distance;
  final int duration;

  FareModel({
    required this.id,
    required this.fromStation,
    required this.toStation,
    required this.amount,
    required this.fareType,
    required this.distance,
    required this.duration,
  });

  factory FareModel.fromJson(Map<String, dynamic> json) {
    print('🔧 FareModel.fromJson called with: $json');

    try {
      // Handle fromStation - could be string or object
      String fromStationName = '';
      if (json['fromStation'] is String) {
        fromStationName = json['fromStation'];
        print('📍 FromStation (string): $fromStationName');
      } else if (json['fromStation'] is Map<String, dynamic>) {
        fromStationName = json['fromStation']['name'] ?? '';
        print('📍 FromStation (object): $fromStationName');
      }

      // Handle toStation - could be string or object
      String toStationName = '';
      if (json['toStation'] is String) {
        toStationName = json['toStation'];
        print('📍 ToStation (string): $toStationName');
      } else if (json['toStation'] is Map<String, dynamic>) {
        toStationName = json['toStation']['name'] ?? '';
        print('📍 ToStation (object): $toStationName');
      }

      // Handle fare amount - backend uses 'fare' field
      int fareAmount = 0;
      if (json['fare'] != null) {
        print(
            '💰 Processing fare field: ${json['fare']} (type: ${json['fare'].runtimeType})');
        if (json['fare'] is int) {
          fareAmount = json['fare'];
        } else if (json['fare'] is double) {
          fareAmount = json['fare'].toInt();
        } else if (json['fare'] is String) {
          fareAmount = int.tryParse(json['fare']) ?? 0;
        }
      } else if (json['amount'] != null) {
        print(
            '💰 Processing amount field: ${json['amount']} (type: ${json['amount'].runtimeType})');
        if (json['amount'] is int) {
          fareAmount = json['amount'];
        } else if (json['amount'] is double) {
          fareAmount = json['amount'].toInt();
        } else if (json['amount'] is String) {
          fareAmount = int.tryParse(json['amount']) ?? 0;
        }
      }

      print('✅ Final fare amount: $fareAmount');

      // Handle distance
      double distance = 0.0;
      if (json['distance'] != null) {
        if (json['distance'] is double) {
          distance = json['distance'];
        } else if (json['distance'] is int) {
          distance = (json['distance'] as int).toDouble();
        } else if (json['distance'] is String) {
          distance = double.tryParse(json['distance']) ?? 0.0;
        }
      }

      // Handle duration
      int duration = 0;
      if (json['duration'] != null) {
        if (json['duration'] is int) {
          duration = json['duration'];
        } else if (json['duration'] is double) {
          duration = (json['duration'] as double).toInt();
        } else if (json['duration'] is String) {
          duration = int.tryParse(json['duration']) ?? 0;
        }
      }

      return FareModel(
        id: json['_id'] ?? json['id'],
        fromStation: fromStationName,
        toStation: toStationName,
        amount: fareAmount,
        fareType: json['fareType'] ?? 'regular',
        distance: distance,
        duration: duration,
      );
    } catch (e) {
      print('❌ Error in FareModel.fromJson: $e');
      print('❌ JSON data: $json');
      rethrow;
    }
  }
}
