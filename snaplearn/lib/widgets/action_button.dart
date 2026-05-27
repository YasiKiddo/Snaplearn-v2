import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class ActionButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isSmall;

  const ActionButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryPink,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: isSmall ? 16 : 32,
          vertical: isSmall ? 8 : 18,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isSmall ? 14 : 18,
            ),
          ),
          SizedBox(width: 8),
          Icon(Icons.chevron_right, size: isSmall ? 18 : 22),
        ],
      ),
    );
  }
}
