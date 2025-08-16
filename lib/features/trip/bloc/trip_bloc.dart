import 'package:flutter_bloc/flutter_bloc.dart';
import 'trip_event.dart';
import 'trip_state.dart';
import '../../../shared/services/trip_api_service.dart';
import '../../../shared/services/fare_api_service.dart';
import '../../../shared/models/trip_model.dart';
import '../../../shared/models/station_model.dart';
import '../../../shared/models/fare_model.dart';
import '../../../shared/utils/api_error_handler.dart';

class TripBloc extends Bloc<TripEvent, TripState> {
  TripBloc() : super(TripInitial()) {
    on<CreateTrip>(_onCreateTrip);
    on<UseTrip>(_onUseTrip);
    on<LoadTripHistory>(_onLoadTripHistory);
    on<LoadUnusedTrips>(_onLoadUnusedTrips);
    on<LoadAllStations>(_onLoadAllStations);
    on<LoadStationsByZone>(_onLoadStationsByZone);
    on<CalculateFare>(_onCalculateFare);
    on<LoadAllFares>(_onLoadAllFares);
    on<CreateFare>(_onCreateFare);
    on<UpdateFare>(_onUpdateFare);
  }

  Future<void> _onCreateTrip(CreateTrip event, Emitter<TripState> emit) async {
    // Preserve existing stations if they exist
    List<StationModel>? existingStations;
    if (state is StationsLoaded) {
      existingStations = (state as StationsLoaded).stations;
    } else if (state is StationsAndHistoryLoaded) {
      existingStations = (state as StationsAndHistoryLoaded).stations;
    } else if (state is StationsAndFareLoaded) {
      existingStations = (state as StationsAndFareLoaded).stations;
    } else if (state is StationsHistoryAndFareLoaded) {
      existingStations = (state as StationsHistoryAndFareLoaded).stations;
    } else if (state is TripFailureWithStations) {
      existingStations = (state as TripFailureWithStations).stations;
    } else if (state is TripCreatedWithStations) {
      existingStations = (state as TripCreatedWithStations).stations;
    }

    emit(TripLoading());
    try {
      print('🚀 Creating trip...');
      final response = await TripApiService.createTrip(
        boardingStation: event.boardingStation,
        dropStation: event.dropStation,
        numberOfPassengers: event.numberOfPassengers,
      );
      print('📡 Trip creation response: ${response.statusCode}');
      print('📊 Full response data: ${response.data}');

      // The API response structure is: { success, message, data: { trip: {...} } }
      // We need to pass the entire response to TripModel.fromJson so it can handle the nesting
      final trip = TripModel.fromJson(response.data);
      print('✅ Trip created successfully: ${trip.tripCode}');

      // Emit the appropriate state based on whether we have stations
      if (existingStations != null) {
        print(
            '🔄 Preserving ${existingStations.length} stations with created trip');
        emit(TripCreatedWithStations(trip, existingStations));
      } else {
        emit(TripCreated(trip));
      }
    } catch (e) {
      print('💥 Error in _onCreateTrip: $e');
      final errorMessage = ApiErrorHandler.parseError(e);
      emit(TripFailure(errorMessage));
    }
  }

  Future<void> _onUseTrip(UseTrip event, Emitter<TripState> emit) async {
    emit(TripLoading());
    try {
      final response = await TripApiService.useTrip(event.tripCode);
      final message = response.data['message'] ?? 'Trip used successfully';
      emit(TripUsed(message));
    } catch (e) {
      final errorMessage = ApiErrorHandler.parseError(e);
      emit(TripFailure(errorMessage));
    }
  }

  Future<void> _onLoadTripHistory(
      LoadTripHistory event, Emitter<TripState> emit) async {
    // Preserve existing stations if they exist
    List<StationModel>? existingStations;
    if (state is StationsLoaded) {
      existingStations = (state as StationsLoaded).stations;
    } else if (state is StationsAndHistoryLoaded) {
      existingStations = (state as StationsAndHistoryLoaded).stations;
    }

    // Only emit loading if we don't have stations loaded
    if (existingStations == null) {
      emit(TripLoading());
    }

    try {
      final response = await TripApiService.getTripHistory();
      final data = response.data['data'];
      final trips =
          (data as List).map((json) => TripModel.fromJson(json)).toList();

      // If we have stations, emit composite state, otherwise just trip history
      if (existingStations != null) {
        print(
            '🔄 Preserving ${existingStations.length} stations while loading trip history');
        emit(StationsAndHistoryLoaded(existingStations, trips));
      } else {
        emit(TripHistoryLoaded(trips));
      }
    } catch (e) {
      final errorMessage = ApiErrorHandler.parseError(e);
      emit(TripFailure(errorMessage));
    }
  }

  Future<void> _onLoadUnusedTrips(
      LoadUnusedTrips event, Emitter<TripState> emit) async {
    emit(TripLoading());
    try {
      final response = await TripApiService.getUnusedTrips();
      final data = response.data['data'];
      final trips =
          (data as List).map((json) => TripModel.fromJson(json)).toList();
      emit(UnusedTripsLoaded(trips));
    } catch (e) {
      final errorMessage = ApiErrorHandler.parseError(e);
      emit(TripFailure(errorMessage));
    }
  }

  Future<void> _onLoadAllStations(
      LoadAllStations event, Emitter<TripState> emit) async {
    emit(TripLoading());
    try {
      print('🚀 Loading all stations...');
      final response = await TripApiService.getAllStations();
      print('📡 Response received: ${response.statusCode}');

      // Check if response is successful
      if (response.statusCode != 200) {
        throw Exception('API returned status code: ${response.statusCode}');
      }

      // Check if response has data
      if (response.data == null) {
        throw Exception('No data received from API');
      }

      final data = response.data['data'];
      print('📋 Raw data: $data');

      // Validate data structure
      if (data == null) {
        throw Exception('API response missing data field');
      }

      if (data is! List) {
        throw Exception('Expected array of stations, got: ${data.runtimeType}');
      }

      if (data.isEmpty) {
        throw Exception('No stations returned from API');
      }

      print('🔍 First station data: ${data.first}');
      print('🔍 First station data type: ${data.first.runtimeType}');

      List<StationModel> stations = [];
      try {
        stations = (data as List).map((json) {
          print('🔄 Processing station: $json');
          return StationModel.fromJson(json);
        }).toList();
        print('🏢 Parsed stations: ${stations.length} stations');

        // Validate that we have at least one station with proper data
        if (stations.isEmpty) {
          throw Exception('Failed to parse any stations from API response');
        }

        // Check if stations have required fields
        for (var station in stations) {
          if (station.id.isEmpty || station.name.isEmpty) {
            throw Exception(
                'Station missing required fields: ID=${station.id}, Name=${station.name}');
          }
        }
      } catch (e) {
        print('💥 Error parsing stations: $e');
        rethrow;
      }
      emit(StationsLoaded(stations));
    } catch (e) {
      print('💥 Error in _onLoadAllStations: $e');
      final errorMessage = ApiErrorHandler.parseError(e);
      emit(TripFailure(errorMessage));
    }
  }

  Future<void> _onLoadStationsByZone(
      LoadStationsByZone event, Emitter<TripState> emit) async {
    emit(TripLoading());
    try {
      final response = await TripApiService.getStationsByZone(event.zone);
      final data = response.data['data'];
      final stations =
          (data as List).map((json) => StationModel.fromJson(json)).toList();
      emit(StationsLoaded(stations));
    } catch (e) {
      final errorMessage = ApiErrorHandler.parseError(e);
      emit(TripFailure(errorMessage));
    }
  }

  Future<void> _onCalculateFare(
      CalculateFare event, Emitter<TripState> emit) async {
    // Preserve existing stations and trips if they exist
    List<StationModel>? existingStations;
    List<TripModel>? existingTrips;

    if (state is StationsLoaded) {
      existingStations = (state as StationsLoaded).stations;
    } else if (state is StationsAndHistoryLoaded) {
      existingStations = (state as StationsAndHistoryLoaded).stations;
      existingTrips = (state as StationsAndHistoryLoaded).trips;
    } else if (state is StationsAndFareLoaded) {
      existingStations = (state as StationsAndFareLoaded).stations;
    } else if (state is StationsHistoryAndFareLoaded) {
      existingStations = (state as StationsHistoryAndFareLoaded).stations;
      existingTrips = (state as StationsHistoryAndFareLoaded).trips;
    } else if (state is TripFailureWithStations) {
      existingStations = (state as TripFailureWithStations).stations;
      existingTrips = (state as TripFailureWithStations).trips;
    } else if (state is TripHistoryLoaded) {
      existingTrips = (state as TripHistoryLoaded).trips;
    }

    // Only emit loading if we don't have critical data loaded
    if (existingStations == null && existingTrips == null) {
      emit(TripLoading());
    }

    try {
      print(
          '🚀 Calculating fare for station IDs: ${event.fromStationId} to ${event.toStationId}');
      final response = await TripApiService.getFareBetweenStations(
        fromStationId: event.fromStationId,
        toStationId: event.toStationId,
      );
      print('📡 Fare response received: ${response.statusCode}');
      print('📊 Full response data: ${response.data}');

      // The API returns data nested under 'data.fare'
      final data = response.data['data'];
      print('📋 Fare raw data: $data');

      if (data == null) {
        throw Exception('No fare data received from API');
      }

      // Extract the fare object from the response
      final fareData = data['fare'];
      if (fareData == null) {
        throw Exception('No fare information in response');
      }

      print('🔍 Fare data: $fareData');
      final fare = FareModel.fromJson(fareData);
      print('💰 Parsed fare: \$${fare.amount}');

      // Create composite state that preserves stations and trips along with fare
      if (existingStations != null && existingTrips != null) {
        print(
            '🔄 Preserving ${existingStations.length} stations and ${existingTrips.length} trips while calculating fare');
        emit(StationsHistoryAndFareLoaded(
            existingStations, existingTrips, fare));
      } else if (existingStations != null) {
        print(
            '🔄 Preserving ${existingStations.length} stations while calculating fare');
        emit(StationsAndFareLoaded(existingStations, fare));
      } else {
        emit(FareCalculated(fare));
      }
    } catch (e) {
      print('💥 Error in _onCalculateFare: $e');
      final errorMessage = ApiErrorHandler.parseError(e);

      // Debug: Log current state and station preservation
      print('📊 Current state before error: ${state.runtimeType}');
      print('📍 Existing stations: ${existingStations?.length ?? 0}');
      print('🚇 Existing trips: ${existingTrips?.length ?? 0}');

      // Preserve existing stations and trips if they exist
      if (existingStations != null) {
        print(
            '🔄 Preserving ${existingStations.length} stations while showing fare error');
        emit(TripFailureWithStations(
            errorMessage, existingStations, existingTrips));
      } else {
        print('❌ No stations to preserve, emitting regular TripFailure');
        emit(TripFailure(errorMessage));
      }
    }
  }

  // Fare Management Event Handlers
  Future<void> _onLoadAllFares(
      LoadAllFares event, Emitter<TripState> emit) async {
    try {
      print('📋 Loading all fares...');

      // Preserve existing stations if available
      List<StationModel>? existingStations;
      if (state is StationsLoaded) {
        existingStations = (state as StationsLoaded).stations;
      } else if (state is StationsAndFaresLoaded) {
        existingStations = (state as StationsAndFaresLoaded).stations;
      }

      if (existingStations == null) {
        emit(TripLoading());
      }

      final fares = await FareApiService.getAllFares();
      print('✅ Loaded ${fares.length} fares');

      if (existingStations != null) {
        emit(StationsAndFaresLoaded(existingStations, fares));
      } else {
        emit(FaresLoaded(fares));
      }
    } catch (e) {
      print('❌ Error loading fares: $e');
      final errorMessage = ApiErrorHandler.parseError(e);
      emit(TripFailure(errorMessage));
    }
  }

  Future<void> _onCreateFare(CreateFare event, Emitter<TripState> emit) async {
    try {
      print('🆕 Creating fare...');
      emit(TripLoading());

      final newFare = await FareApiService.createFare(
        fromStationId: event.fromStationId,
        toStationId: event.toStationId,
        fare: event.fare,
        distance: event.distance,
        duration: event.duration,
      );

      print('✅ Fare created successfully: ${newFare.id}');
      emit(FareCreated(newFare));

      // Reload fares to get updated list
      add(LoadAllFares());
    } catch (e) {
      print('❌ Error creating fare: $e');
      final errorMessage = ApiErrorHandler.parseError(e);
      emit(TripFailure(errorMessage));
    }
  }

  Future<void> _onUpdateFare(UpdateFare event, Emitter<TripState> emit) async {
    try {
      print('🔄 Updating fare: ${event.fareId}');
      emit(TripLoading());

      final updatedFare = await FareApiService.updateFare(
        fareId: event.fareId,
        fare: event.fare,
        distance: event.distance,
        duration: event.duration,
      );

      print('✅ Fare updated successfully: ${updatedFare.id}');
      emit(FareUpdated(updatedFare));

      // Reload fares to get updated list
      add(LoadAllFares());
    } catch (e) {
      print('❌ Error updating fare: $e');
      final errorMessage = ApiErrorHandler.parseError(e);
      emit(TripFailure(errorMessage));
    }
  }
}
