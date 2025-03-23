// shared/widgets/custom_text_field.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/constants.dart';

/// Custom text field widget with various options
class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String? labelText;
  final bool obscureText;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final String? errorText;
  final bool enabled;
  final int? maxLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final bool autofocus;
  final String? helperText;
  final EdgeInsetsGeometry? contentPadding;
  final bool filled;
  final Color? fillColor;
  final BorderRadius? borderRadius;
  final TextStyle? style;
  final TextStyle? hintStyle;
  final TextStyle? labelStyle;
  final bool isDense;
  final bool showCounter;
  final Color? cursorColor;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    this.labelText,
    this.obscureText = false,
    this.suffixIcon,
    this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.onChanged,
    this.onSubmitted,
    this.errorText,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.focusNode,
    this.autofocus = false,
    this.helperText,
    this.contentPadding,
    this.filled = true,
    this.fillColor,
    this.borderRadius,
    this.style,
    this.hintStyle,
    this.labelStyle,
    this.isDense = false,
    this.showCounter = false,
    this.cursorColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null) ...[
          Text(
            labelText!,
            style: labelStyle ?? const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          enabled: enabled,
          maxLines: maxLines,
          maxLength: maxLength,
          inputFormatters: inputFormatters,
          focusNode: focusNode,
          autofocus: autofocus,
          style: style ?? const TextStyle(
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
          cursorColor: cursorColor ?? AppColors.primary,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: hintStyle ?? TextStyle(
              color: AppColors.mediumGrey,
              fontSize: style?.fontSize ?? 16,
            ),
            filled: filled,
            fillColor: fillColor ?? (enabled ? AppColors.lightGrey : Colors.grey[100]),
            suffixIcon: suffixIcon,
            prefixIcon: prefixIcon,
            errorText: errorText,
            helperText: helperText,
            isDense: isDense,
            enabledBorder: OutlineInputBorder(
              borderRadius: borderRadius ?? BorderRadius.circular(AppDimensions.radiusL),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: borderRadius ?? BorderRadius.circular(AppDimensions.radiusL),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: borderRadius ?? BorderRadius.circular(AppDimensions.radiusL),
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: borderRadius ?? BorderRadius.circular(AppDimensions.radiusL),
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: borderRadius ?? BorderRadius.circular(AppDimensions.radiusL),
              borderSide: BorderSide.none,
            ),
            contentPadding: contentPadding ?? const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingL,
              vertical: AppDimensions.paddingM,
            ),
            counterText: showCounter ? null : '',
          ),
        ),
      ],
    );
  }
}

/// Search text field with rounded corners and search icon
class SearchTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final Function(String)? onChanged;
  final VoidCallback? onClear;
  final FocusNode? focusNode;
  final bool autofocus;
  final EdgeInsetsGeometry? contentPadding;
  final Color? fillColor;
  final BorderRadius? borderRadius;

  const SearchTextField({
    Key? key,
    required this.controller,
    this.hintText = 'Search',
    this.onChanged,
    this.onClear,
    this.focusNode,
    this.autofocus = false,
    this.contentPadding,
    this.fillColor,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      hintText: hintText,
      onChanged: onChanged,
      focusNode: focusNode,
      autofocus: autofocus,
      contentPadding: contentPadding ?? const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
        vertical: AppDimensions.paddingS,
      ),
      fillColor: fillColor ?? AppColors.lightGrey,
      borderRadius: borderRadius ?? BorderRadius.circular(AppDimensions.radiusL),
      prefixIcon: const Icon(
        Icons.search,
        color: AppColors.mediumGrey,
      ),
      suffixIcon: controller.text.isNotEmpty
          ? IconButton(
              icon: const Icon(
                Icons.clear,
                color: AppColors.mediumGrey,
                size: 20,
              ),
              onPressed: () {
                controller.clear();
                if (onClear != null) {
                  onClear!();
                } else if (onChanged != null) {
                  onChanged!('');
                }
              },
            )
          : null,
      isDense: true,
    );
  }
}

/// Password text field with toggle for password visibility
class PasswordTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String? labelText;
  final TextInputAction textInputAction;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final String? errorText;
  final bool enabled;
  final FocusNode? focusNode;
  final bool autofocus;

  const PasswordTextField({
    Key? key,
    required this.controller,
    this.hintText = 'Password',
    this.labelText,
    this.textInputAction = TextInputAction.next,
    this.onChanged,
    this.onSubmitted,
    this.errorText,
    this.enabled = true,
    this.focusNode,
    this.autofocus = false,
  }) : super(key: key);

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: widget.controller,
      hintText: widget.hintText,
      labelText: widget.labelText,
      obscureText: _obscureText,
      textInputAction: widget.textInputAction,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      errorText: widget.errorText,
      enabled: widget.enabled,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      keyboardType: TextInputType.visiblePassword,
      suffixIcon: IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: AppColors.mediumGrey,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      ),
    );
  }
}