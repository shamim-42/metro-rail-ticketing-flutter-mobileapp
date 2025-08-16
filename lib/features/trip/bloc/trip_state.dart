import 'package:equatable/equatable.dart';
import '../../../shared/models/trip_model.dart';
import '../../../shared/models/station_model.dart';
import '../../../shared/models/fare_model.dart';

abstract class TripState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TripInitial extends TripState {}

class TripLoading extends TripState {}

// Trip Creation States
class TripCreated extends TripState {
  final TripModel trip;

  TripCreated(this.trip);

  @override
  List<Object?> get props => [trip];
}

class TripCreatedWithStations extends TripState {
  final TripModel trip;
  final List<StationModel> stations;

  TripCreatedWithStations(this.trip, this.stations);

  @override
  List<Object?> get props => [trip, stations];
}

// Trip Usage States
class TripUsed extends TripState {
  final String message;

  TripUsed(this.message);

  @override
  List<Object?> get props => [message];
}

// Trip History States
class TripHistoryLoaded extends TripState {
  final List<TripModel> trips;

  TripHistoryLoaded(this.trips);

  @override
  List<Object?> get props => [trips];
}

class UnusedTripsLoaded extends TripState {
  final List<TripModel> trips;

  UnusedTripsLoaded(this.trips);

  @override
  List<Object?> get props => [trips];
}

// Station States
class StationsLoaded extends TripState {
  final List<StationModel> stations;

  StationsLoaded(this.stations);

  @override
  List<Object?> get props => [stations];
}

// Composite state for when we have both stations and trip history
class StationsAndHistoryLoaded extends TripState {
  final List<StationModel> stations;
  final List<TripModel> trips;

  StationsAndHistoryLoaded(this.stations, this.trips);

  @override
  List<Object?> get props => [stations, trips];
}

// Composite state for stations and calculated fare
class StationsAndFareLoaded extends TripState {
  final List<StationModel> stations;
  final FareModel fare;

  StationsAndFareLoaded(this.stations, this.fare);

  @override
  List<Object?> get props => [stations, fare];
}

// Composite state for stations, trip history, and calculated fare
class StationsHistoryAndFareLoaded extends TripState {
  final List<StationModel> stations;
  final List<TripModel> trips;
  final FareModel fare;

  StationsHistoryAndFareLoaded(this.stations, this.trips, this.fare);

  @override
  List<Object?> get props => [stations, trips, fare];
}

// Fare States
class FareCalculated extends TripState {
  final FareModel fare;

  FareCalculated(this.fare);

  @override
  List<Object?> get props => [fare];
}

class FaresLoaded extends TripState {
  final List<FareModel> fares;

  FaresLoaded(this.fares);

  @override
  List<Object?> get props => [fares];
}

class FareCreated extends TripState {
  final FareModel fare;

  FareCreated(this.fare);

  @override
  List<Object?> get props => [fare];
}

class FareUpdated extends TripState {
  final FareModel fare;

  FareUpdated(this.fare);

  @override
  List<Object?> get props => [fare];
}

// Composite state for stations and fares list
class StationsAndFaresLoaded extends TripState {
  final List<StationModel> stations;
  final List<FareModel> fares;

  StationsAndFaresLoaded(this.stations, this.fares);

  @override
  List<Object?> get props => [stations, fares];
}

// Error State
class TripFailure extends TripState {
  final String message;

  TripFailure(this.message);

  @override
  List<Object?> get props => [message];
}

// Error state that preserves stations data
class TripFailureWithStations extends TripState {
  final String message;
  final List<StationModel> stations;
  final List<TripModel>? trips;

  TripFailureWithStations(this.message, this.stations, [this.trips]);

  @override
  List<Object?> get props => [message, stations, trips];
}
