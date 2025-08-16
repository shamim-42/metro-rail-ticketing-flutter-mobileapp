class UserInitials {
  /// Generates initials from a full name
  /// Takes the first letter of the first two words
  /// Example: "John Doe" -> "JD", "Mujahid Hossain" -> "MH"
  static String generate(String fullName) {
    if (fullName.isEmpty) return 'U'; // Default for "User"

    final names = fullName.trim().split(' ');

    if (names.length == 1) {
      // Single name: take first letter
      return names[0][0].toUpperCase();
    } else {
      // Multiple names: take first letter of first two words
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
  }
}
