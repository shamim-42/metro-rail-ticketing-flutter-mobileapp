import 'package:equatable/equatable.dart';

abstract class TripEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// Trip Creation Events
class CreateTrip extends TripEvent {
  final String boardingStation;
  final String dropStation;
  final int numberOfPassengers;

  CreateTrip({
    required this.boardingStation,
    required this.dropStation,
    required this.numberOfPassengers,
  });

  @override
  List<Object?> get props => [boardingStation, dropStation, numberOfPassengers];
}

// Trip Usage Events
class UseTrip extends TripEvent {
  final String tripCode;

  UseTrip(this.tripCode);

  @override
  List<Object?> get props => [tripCode];
}

// Trip History Events
class LoadTripHistory extends TripEvent {}

class LoadUnusedTrips extends TripEvent {}

// Station Events
class LoadAllStations extends TripEvent {}

class LoadStationsByZone extends TripEvent {
  final String zone;

  LoadStationsByZone(this.zone);

  @override
  List<Object?> get props => [zone];
}

// Fare Events
class CalculateFare extends TripEvent {
  final String fromStationId;
  final String toStationId;

  CalculateFare({
    required this.fromStationId,
    required this.toStationId,
  });

  @override
  List<Object?> get props => [fromStationId, toStationId];
}

class LoadAllFares extends TripEvent {}

class CreateFare extends TripEvent {
  final String fromStationId;
  final String toStationId;
  final int fare;
  final double distance;
  final int duration;

  CreateFare({
    required this.fromStationId,
    required this.toStationId,
    required this.fare,
    required this.distance,
    required this.duration,
  });

  @override
  List<Object?> get props =>
      [fromStationId, toStationId, fare, distance, duration];
}

class UpdateFare extends TripEvent {
  final String fareId;
  final int fare;
  final double distance;
  final int duration;

  UpdateFare({
    required this.fareId,
    required this.fare,
    required this.distance,
    required this.duration,
  });

  @override
  List<Object?> get props => [fareId, fare, distance, duration];
}
