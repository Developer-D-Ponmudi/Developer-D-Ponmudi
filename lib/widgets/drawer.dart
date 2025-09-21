import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

class PortfolioDrawer extends StatelessWidget {
  const PortfolioDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final items = const [
      _NavItem('Home', '/'),
      _NavItem('Skills', '/skills'),
      _NavItem('Experience', '/experience'),
      _NavItem('Projects', '/projects'),
    ];

    final loc = GoRouterState.of(context).uri.toString();
    bool isActive(String path) => loc == path || (path != '/' && loc.startsWith(path));

    return Drawer(
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        // keep the overall drawer background stylish, but text has no boxes
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0F1426).withOpacity(0.96),
              const Color(0xFF1B2340).withOpacity(0.98),
            ],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            children: [
              // Minimal header (text only)
              const Text(
                'MENU',
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 4,
                  fontWeight: FontWeight.w800,
                  color: Colors.white54,
                ),
              ).animate().fadeIn(duration: 220.ms).moveY(begin: -6, end: 0),
              const SizedBox(height: 8),

              for (int i = 0; i < items.length; i++)
                _GlowNavTile(
                  label: items[i].label,
                  active: isActive(items[i].path),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.go(items[i].path);
                  },
                )
                    .animate()
                    .fadeIn(duration: 220.ms, delay: (70 * i).ms)
                    .moveX(begin: -10, end: 0, curve: Curves.easeOutCubic),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlowNavTile extends StatefulWidget {
  const _GlowNavTile({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  State<_GlowNavTile> createState() => _GlowNavTileState();
}

class _GlowNavTileState extends State<_GlowNavTile> {
  bool _hover = false;
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).textTheme.titleMedium ?? const TextStyle(fontSize: 16);
    final glow = widget.active || _hover;
    final size = (base.fontSize ?? 16) + (glow ? 4 : 0) + (_down ? 1 : 0);
    final opacity = glow ? 0.98 : 0.86;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _down = true),
        onTapCancel: () => setState(() => _down = false),
        onTapUp: (_) => setState(() => _down = false),
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOutCubic,
            style: base.copyWith(
              fontSize: size,
              fontWeight: glow ? FontWeight.w800 : FontWeight.w700,
              letterSpacing: glow ? 0.8 : 0.4,
              color: Colors.white.withOpacity(opacity),
              // neon-like text-only glow
              shadows: glow
                  ? [
                Shadow(color: Colors.white.withOpacity(0.35), blurRadius: 14),
                Shadow(color: const Color(0xFF4BE1EC).withOpacity(0.25), blurRadius: 20),
                Shadow(color: const Color(0xFFB388FF).withOpacity(0.15), blurRadius: 24),
              ]
                  : const [],
            ),
            child: Text(widget.label.toUpperCase()),
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
