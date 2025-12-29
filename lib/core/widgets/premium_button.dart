import 'package:firebase_playground/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Premium Gradient Button with animations
class PremiumButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final LinearGradient? gradient;
  final IconData? icon;
  final double? width;
  final double height;
  final BorderRadius? borderRadius;

  const PremiumButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.gradient,
    this.icon,
    this.width,
    this.height = 56,
    this.borderRadius,
  });

  @override
  State<PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<PremiumButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.isLoading ? null : widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: widget.width ?? double.infinity,
        height: widget.height,
        transform: Matrix4.identity()..scale(_isPressed ? 0.97 : 1.0),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: widget.onPressed != null
              ? (widget.gradient ?? AppTheme.primaryGradient)
              : LinearGradient(
                  colors: [Colors.grey.shade400, Colors.grey.shade500],
                ),
          borderRadius: widget.borderRadius ?? BorderRadius.circular(AppTheme.radiusMd),
          boxShadow: widget.onPressed != null
              ? [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: _isPressed ? 0.2 : 0.4),
                    blurRadius: _isPressed ? 8 : 16,
                    offset: Offset(0, _isPressed ? 4 : 8),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: widget.isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(
                        widget.icon,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                    ],
                    Text(
                      widget.text,
                      style: const TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// Outline Button with premium styling
class PremiumOutlineButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;
  final double? width;
  final double height;

  const PremiumOutlineButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.color,
    this.width,
    this.height = 56,
  });

  @override
  State<PremiumOutlineButton> createState() => _PremiumOutlineButtonState();
}

class _PremiumOutlineButtonState extends State<PremiumOutlineButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppTheme.primaryColor;
    
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: widget.width ?? double.infinity,
        height: widget.height,
        transform: Matrix4.identity()..scale(_isPressed ? 0.97 : 1.0),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: _isPressed ? color.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  color: color,
                  size: 20,
                ),
                const SizedBox(width: 10),
              ],
              Text(
                widget.text,
                style: TextStyle(
                  fontFamily: 'Satoshi',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: color,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Social Sign-in Button
class SocialButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Widget icon;
  final bool isLoading;

  const SocialButton({
    super.key,
    required this.text,
    this.onPressed,
    required this.icon,
    this.isLoading = false,
  });

  @override
  State<SocialButton> createState() => _SocialButtonState();
}

class _SocialButtonState extends State<SocialButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.isLoading ? null : widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        height: 56,
        transform: Matrix4.identity()..scale(_isPressed ? 0.97 : 1.0),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: isDark 
              ? (_isPressed ? Colors.white.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.05))
              : (_isPressed ? Colors.grey.shade100 : Colors.white),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
            width: 1,
          ),
        ),
        child: Center(
          child: widget.isLoading
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(width: 24, height: 24, child: widget.icon),
                    const SizedBox(width: 12),
                    Text(
                      widget.text,
                      style: TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}