// features/menu/widgets/menu_option.dart
import 'package:flutter/material.dart';
import '../../../config/constants.dart';

class MenuOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color color;
  final bool showArrow;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  const MenuOption({
    Key? key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.color = AppColors.primary,
    this.showArrow = true,
    this.trailing,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: padding,
        child: Row(
          children: [
            // Icon container
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),

            const SizedBox(width: 16),

            // Title
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: color == Colors.red ? color : AppColors.textPrimary,
                ),
              ),
            ),

            // Trailing (arrow or custom widget)
            if (trailing != null)
              trailing!
            else if (showArrow)
              Icon(
                Icons.chevron_right,
                size: 20,
                color: Colors.grey[400],
              ),
          ],
        ),
      ),
    );
  }
}