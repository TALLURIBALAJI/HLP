import 'package:flutter/material.dart';
import '../theme.dart';

class AvatarGradient extends StatelessWidget {
  final Widget child;
  final double size;
  const AvatarGradient({super.key, required this.child, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: const Color.fromRGBO(0,0,0,0.12), blurRadius: 6, offset: const Offset(0, 3))],
      ),
      child: Center(child: ClipOval(child: Padding(padding: const EdgeInsets.all(6.0), child: child))),
    );
  }
}

class GradientButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  const GradientButton({super.key, required this.onPressed, required this.child});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(30)),
        child: DefaultTextStyle(style: const TextStyle(color: Colors.white), child: child),
      ),
    );
  }
}

class Badge extends StatelessWidget {
  final String text;
  final Color color;
  const Badge({super.key, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
  decoration: BoxDecoration(color: color.withAlpha((0.12 * 255).round()), borderRadius: BorderRadius.circular(12)),
      child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
    );
  }
}
