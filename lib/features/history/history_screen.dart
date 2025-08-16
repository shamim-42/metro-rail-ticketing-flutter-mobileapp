import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../trip/bloc/trip_bloc.dart';
import '../trip/bloc/trip_event.dart';
import '../trip/bloc/trip_state.dart';
import '../../shared/widgets/custom_back_button.dart';
import '../../shared/widgets/status_bar.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // We'll load trip history when the BLoC is created
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = TripBloc();
        // Load trip history when BLoC is created
        bloc.add(LoadTripHistory());
        return bloc;
      },
      child: BlocListener<TripBloc, TripState>(
        listener: (context, state) {
          if (state is TripFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                // Custom Status Bar
                const CustomStatusBar(),

                // Header with back button
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    children: [
                      const CustomBackButton(),
                      const SizedBox(width: 16),
                      const Text(
                        'Journey History',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                    ],
                  ),
                ),

                // Tab Bar
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: const Color(0xFF20B2AA),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF20B2AA).withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    indicatorPadding: const EdgeInsets.all(2),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: Colors.white,
                    unselectedLabelColor: const Color(0xFF7F8C8D),
                    labelStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    labelPadding: const EdgeInsets.symmetric(vertical: 12),
                    dividerColor: Colors.transparent,
                    overlayColor: MaterialStateProperty.all(Colors.transparent),
                    splashFactory: NoSplash.splashFactory,
                    tabs: const [
                      Tab(text: 'Trip History'),
                      Tab(text: 'Unused Trips'),
                    ],
                    onTap: (index) {
                      if (index == 0) {
                        context.read<TripBloc>().add(LoadTripHistory());
                      } else {
                        context.read<TripBloc>().add(LoadUnusedTrips());
                      }
                    },
                  ),
                ),

                // Tab Content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Trip History Tab
                      BlocBuilder<TripBloc, TripState>(
                        builder: (context, state) {
                          if (state is TripLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (state is TripHistoryLoaded) {
                            if (state.trips.isEmpty) {
                              return const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.history,
                                      size: 64,
                                      color: Color(0xFF7F8C8D),
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'No trip history yet',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Color(0xFF7F8C8D),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: state.trips.length,
                              itemBuilder: (context, index) {
                                final trip = state.trips[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: const Color(0xFF20B2AA),
                                      child: Icon(
                                        trip.status == 'used'
                                            ? Icons.check_circle
                                            : Icons.schedule,
                                        color: Colors.white,
                                      ),
                                    ),
                                    title: Text(
                                      '${trip.boardingStationName.isNotEmpty ? trip.boardingStationName : trip.boardingStation} to ${trip.dropStationName.isNotEmpty ? trip.dropStationName : trip.dropStation}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${trip.numberOfPassengers} passenger(s)',
                                          style: const TextStyle(
                                            color: Color(0xFF7F8C8D),
                                          ),
                                        ),
                                        Text(
                                          'Created: ${_formatDate(trip.createdAt)}',
                                          style: const TextStyle(
                                            color: Color(0xFF7F8C8D),
                                          ),
                                        ),
                                        if (trip.usedAt != null)
                                          Text(
                                            'Used: ${_formatDate(trip.usedAt!)}',
                                            style: const TextStyle(
                                              color: Color(0xFF7F8C8D),
                                            ),
                                          ),
                                      ],
                                    ),
                                    trailing: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '-\৳${trip.fare}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFE74C3C),
                                          ),
                                        ),
                                        Text(
                                          trip.status.toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: trip.status == 'used'
                                                ? Colors.green
                                                : Colors.orange,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          } else {
                            return const Center(
                              child: Text('Failed to load trip history'),
                            );
                          }
                        },
                      ),

                      // Unused Trips Tab
                      BlocBuilder<TripBloc, TripState>(
                        builder: (context, state) {
                          if (state is TripLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (state is UnusedTripsLoaded) {
                            if (state.trips.isEmpty) {
                              return const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.schedule,
                                      size: 64,
                                      color: Color(0xFF7F8C8D),
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'No unused trips',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Color(0xFF7F8C8D),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: state.trips.length,
                              itemBuilder: (context, index) {
                                final trip = state.trips[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.orange,
                                      child: const Icon(
                                        Icons.qr_code,
                                        color: Colors.white,
                                      ),
                                    ),
                                    title: Text(
                                      '${trip.boardingStation} to ${trip.dropStation}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Trip Code: ${trip.tripCode}',
                                          style: const TextStyle(
                                            color: Color(0xFF20B2AA),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          '${trip.numberOfPassengers} passenger(s)',
                                          style: const TextStyle(
                                            color: Color(0xFF7F8C8D),
                                          ),
                                        ),
                                        Text(
                                          'Created: ${_formatDate(trip.createdAt)}',
                                          style: const TextStyle(
                                            color: Color(0xFF7F8C8D),
                                          ),
                                        ),
                                      ],
                                    ),
                                    trailing: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '-\৳${trip.fare}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFE74C3C),
                                          ),
                                        ),
                                        const Text(
                                          'UNUSED',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.orange,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          } else {
                            return const Center(
                              child: Text('Failed to load unused trips'),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today, ${_formatTime(date)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday, ${_formatTime(date)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago, ${_formatTime(date)}';
    } else {
      return '${date.day}/${date.month}/${date.year}, ${_formatTime(date)}';
    }
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
