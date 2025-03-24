// shared/widgets/custom_button.dart
import 'package:flutter/material.dart';
import '../../config/constants.dart';

/// Button variants
enum ButtonVariant {
  primary,
  secondary,
  outline,
  danger,
  success,
  text,
  gradient,
}

/// Custom button widget with multiple variants
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final double height;
  final ButtonVariant variant;
  final IconData? icon;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.height = AppDimensions.buttonHeight,
    this.variant = ButtonVariant.primary,
    this.icon,
    this.width,
    this.padding,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Wrap with LayoutBuilder to ensure we don't pass infinite constraints
    return LayoutBuilder(
        builder: (context, constraints) {
          double? effectiveWidth = width ?? (isFullWidth ? constraints.maxWidth : null);

          if (variant == ButtonVariant.gradient) {
            return _buildGradientButton(effectiveWidth);
          } else if (variant == ButtonVariant.text) {
            return _buildTextButton();
          } else {
            return _buildStandardButton(effectiveWidth);
          }
        }
    );
  }

  Widget _buildStandardButton(double? effectiveWidth) {
    return SizedBox(
      width: effectiveWidth,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _getBackgroundColor(),
          foregroundColor: _getForegroundColor(),
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(AppDimensions.radiusL),
            side: variant == ButtonVariant.outline
                ? BorderSide(color: AppColors.primary, width: 1.5)
                : BorderSide.none,
          ),
          elevation: (variant == ButtonVariant.primary || variant == ButtonVariant.success || variant == ButtonVariant.danger)
              ? AppDimensions.elevationS
              : 0,
          padding: padding ?? const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingL,
            vertical: AppDimensions.paddingM,
          ),
          disabledBackgroundColor: _getBackgroundColor().withOpacity(0.6),
        ),
        child: _buildButtonContent(),
      ),
    );
  }

  Widget _buildGradientButton(double? effectiveWidth) {
    return InkWell(
      onTap: isLoading ? null : onPressed,
      borderRadius: borderRadius ?? BorderRadius.circular(AppDimensions.radiusL),
      child: Container(
        // Use specific width instead of double.infinity
        width: effectiveWidth ?? 200,
        height: height,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: AppColors.primaryGradient,
          ),
          borderRadius: borderRadius ?? BorderRadius.circular(AppDimensions.radiusL),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: padding ?? EdgeInsets.zero,
        child: Center(
          child: _buildButtonContent(),
        ),
      ),
    );
  }

  Widget _buildTextButton() {
    return InkWell(
      onTap: isLoading ? null : onPressed,
      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      child: Padding(
        padding: padding ?? const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingM,
          vertical: AppDimensions.paddingS,
        ),
        child: _buildButtonContent(),
      ),
    );
  }

  Widget _buildButtonContent() {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          color: _getLoadingColor(),
          strokeWidth: 2.0,
        ),
      );
    } else if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: _getForegroundColor()),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _getForegroundColor(),
            ),
          ),
        ],
      );
    } else {
      return Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: _getForegroundColor(),
        ),
      );
    }
  }

  Color _getBackgroundColor() {
    switch (variant) {
      case ButtonVariant.primary:
        return AppColors.primary;
      case ButtonVariant.secondary:
        return AppColors.lightGrey;
      case ButtonVariant.outline:
        return Colors.transparent;
      case ButtonVariant.danger:
        return AppColors.error;
      case ButtonVariant.success:
        return AppColors.success;
      case ButtonVariant.text:
        return Colors.transparent;
      case ButtonVariant.gradient:
        return Colors.transparent;
    }
  }

  Color _getForegroundColor() {
    switch (variant) {
      case ButtonVariant.primary:
      case ButtonVariant.danger:
      case ButtonVariant.success:
      case ButtonVariant.gradient:
        return Colors.white;
      case ButtonVariant.secondary:
        return AppColors.textPrimary;
      case ButtonVariant.outline:
      case ButtonVariant.text:
        return AppColors.primary;
    }
  }

  Color _getLoadingColor() {
    switch (variant) {
      case ButtonVariant.primary:
      case ButtonVariant.danger:
      case ButtonVariant.success:
      case ButtonVariant.gradient:
        return Colors.white;
      case ButtonVariant.secondary:
        return AppColors.textPrimary;
      case ButtonVariant.outline:
      case ButtonVariant.text:
        return AppColors.primary;
    }
  }
}