class UserStatisticsModel {
  final int totalTrips;
  final int totalExpense;
  final int currentBalance;
  final int monthlyTrips;
  final int monthlyExpense;

  UserStatisticsModel({
    required this.totalTrips,
    required this.totalExpense,
    required this.currentBalance,
    required this.monthlyTrips,
    required this.monthlyExpense,
  });

  factory UserStatisticsModel.fromJson(Map<String, dynamic> json) {
    return UserStatisticsModel(
      totalTrips: json['totalTrips'] ?? 0,
      totalExpense: json['totalExpense'] ?? 0,
      currentBalance: json['currentBalance'] ?? 0,
      monthlyTrips: json['monthlyTrips'] ?? 0,
      monthlyExpense: json['monthlyExpense'] ?? 0,
    );
  }
}
