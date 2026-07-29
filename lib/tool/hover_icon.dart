import 'package:flutter/material.dart';
import 'package:lootbazarweb/core/theme.dart';

class HoverIcon extends StatefulWidget {
  final IconData icon;
  final IconData selectedIcon;
  final bool selected;

  const HoverIcon({
    super.key,
    required this.icon,
    required this.selectedIcon,
    required this.selected,
  });

  @override
  State<HoverIcon> createState() => _HoverIconState();
}

class _HoverIconState extends State<HoverIcon> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 200),
        scale: _hovered ? 1.15 : 1.0,
        child: Icon(
          widget.selected
              ? widget.selectedIcon
              : widget.icon,
          color: widget.selected
              ? AppTheme.primary
              : _hovered
              ? AppTheme.primary.withValues(alpha: 0.8)
              : AppTheme.secondary,
        ),
      ),
    );
  }
}
