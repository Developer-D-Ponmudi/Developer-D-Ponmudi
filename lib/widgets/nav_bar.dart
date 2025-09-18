import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PortfolioNavBar extends StatelessWidget {
  const PortfolioNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final tabs = const [
      _NavItem('HOME', '/'),
      _NavItem('SKILLS', '/skills'),
      _NavItem('EXPERIENCE', '/experience'),
      _NavItem('PROJECTS', '/projects'),
    ];

    // Works with recent go_router
    final loc = GoRouterState.of(context).uri.toString();
    bool isActive(String path) => loc == path || (path != '/' && loc.startsWith(path));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
      child: Center(
        child: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 100, // adjust if you want tighter spacing
          runSpacing: 8,
          children: [
            for (final t in tabs)
              _NavChip(
                label: t.label,
                active: isActive(t.path),
                onTap: () => context.go(t.path),
              ).animate().fadeIn(duration: 200.ms),
          ],
        ),
      ),
    );
  }
}

class _NavChip extends StatefulWidget {
  const _NavChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  State<_NavChip> createState() => _NavChipState();
}

class _NavChipState extends State<_NavChip> {
  bool _pressed = false;

  void _onTapDown(TapDownDetails _) => setState(() => _pressed = true);
  void _onTapCancel() => setState(() => _pressed = false);
  void _onTapUp(TapUpDetails _) => setState(() => _pressed = false);

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).textTheme.labelLarge ?? const TextStyle(fontSize: 14);
    final baseSize = base.fontSize ?? 14.0;

    // Active is bigger; press adds a little more “oomph”
    final targetSize = baseSize + (widget.active ? 6 : 0) + (_pressed ? 2 : 0);
    final scale = (widget.active ? 1.12 : 1.0) * (_pressed ? 1.06 : 1.0);

    // Glow intensity
    final glowBoost = (widget.active ? 1.0 : 0.6) + (_pressed ? 0.6 : 0.0);
    final whiteGlow = (0.25 + 0.35 * glowBoost).clamp(0.0, 1.0);
    final cyanGlow  = (0.15 + 0.25 * glowBoost).clamp(0.0, 1.0);
    final whiteBlur = 10.0 + 16.0 * glowBoost;
    final cyanBlur  = 14.0 + 20.0 * glowBoost;

    return AnimatedScale(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOutCubic,
      scale: scale,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _onTapDown,
        onTapCancel: _onTapCancel,
        onTapUp: _onTapUp,
        onTap: widget.onTap,
        child: Padding(
          // padding creates a comfortable hit target without any box visuals
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOutCubic,
            style: base.copyWith(
              fontSize: targetSize,
              fontWeight: widget.active ? FontWeight.w800 : FontWeight.w600,
              letterSpacing: widget.active ? 0.5 : 0.2,
              color: Colors.white.withOpacity(widget.active ? 0.98 : 0.78),
              // Pure text glow (no container)
              shadows: (widget.active || _pressed)
                  ? [
                Shadow(color: Colors.white.withOpacity(whiteGlow), blurRadius: whiteBlur),
                const Shadow(offset: Offset(0, 0)),
                Shadow(
                  color: const Color(0xFF4BE1EC).withOpacity(cyanGlow),
                  blurRadius: cyanBlur,
                ),
              ]
                  : const [],
            ),
            child: Text(widget.label),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final String label;
  final String path;
  const _NavItem(this.label, this.path);
}
