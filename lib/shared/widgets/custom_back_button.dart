import 'package:flutter/material.dart';
import '../services/navigation_service.dart';

class CustomBackButton extends StatelessWidget {
  final Color? color;
  final double? size;
  final VoidCallback? onPressed;

  const CustomBackButton({
    super.key,
    this.color,
    this.size,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final navigationService = NavigationService();

    return IconButton(
      onPressed: onPressed ??
          () {
            navigationService.goBack(context);
          },
      icon: Icon(
        Icons.arrow_back_ios,
        color: color ?? const Color(0xFF2C3E50),
        size: size ?? 20,
      ),
    );
  }
}
