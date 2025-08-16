class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final int balance;
  final int totalTrips;
  final int totalExpense;
  final String role;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.balance,
    required this.totalTrips,
    required this.totalExpense,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? json['_id'],
      fullName: json['fullName'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      balance: json['balance'] ?? 0,
      totalTrips: json['totalTrips'] ?? 0,
      totalExpense: json['totalExpense'] ?? 0,
      role: json['role'] ?? 'user',
    );
  }
}
