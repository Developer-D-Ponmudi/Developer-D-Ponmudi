import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class SkillsPage extends ConsumerWidget {
  const SkillsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.sizeOf(context);
    final w = size.width;
    final h = size.height;

    // Layout knobs
    final horizontalPad = 24.0;
    final verticalPadTop = 100.0; // leave room for your floating navbar
    final verticalPadBottom = 48.0;

    // Decide columns for desktop/tablet. For phones this will still try to fit,
    // but the design is targeted at web/desktop widths.
    final cols = w >= 1280 ? 3 : (w >= 940 ? 2 : 2);
    final itemCount = _categories.length;
    final rows = (itemCount / cols).ceil();

    // Compute a childAspectRatio so grid fills the viewport height w/o scroll.
    final gridW = w - horizontalPad * 2;
    final gridH = h - verticalPadTop - verticalPadBottom;
    final spacing = 16.0;
    final cardW = (gridW - (cols - 1) * spacing) / cols;
    final cardH = (gridH - (rows - 1) * spacing) / rows;
    final aspect = (cardW / cardH).clamp(1.0, 2.2); // keep sane bounds

    return Padding(
      padding: EdgeInsets.only(
        top: verticalPadTop,
        left: horizontalPad,
        right: horizontalPad,
        bottom: verticalPadBottom,
      ),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _categories.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cols,
          mainAxisSpacing: spacing,
          crossAxisSpacing: spacing,
          childAspectRatio: aspect,
        ),
        itemBuilder: (context, i) => _SkillCategoryCard(cat: _categories[i])
            .animate()
            .fadeIn(duration: 280.ms, delay: (i * 70).ms)
            .moveY(begin: 12, end: 0, duration: 340.ms),
      ),
    );
  }
}

/* ----------------------------- DATA (your list) ---------------------------- */

class _Category {
  final String title;
  final List<_Tag> tags;
  const _Category(this.title, this.tags);
}

class _Tag {
  final String label;
  final String? badge; // optional small badge like "Beginner" / "3 projects"
  const _Tag(this.label, {this.badge});
}

const _categories = <_Category>[
  _Category('Languages', [
    _Tag('Dart'),
    _Tag('JSON'),
    _Tag('GraphQL'),
    _Tag('REST APIs'),
    _Tag('Python', badge: 'FastAPI – Beginner'),
  ]),
  _Category('Frameworks & Libraries', [
    _Tag('Flutter'),
    _Tag('Riverpod', badge: '3 projects'),
    _Tag('GetX', badge: '1 project'),
    _Tag('Bloc', badge: 'Learning'),
    _Tag('Firebase', badge: 'Auth, Firestore, FCM'),
    _Tag('MQTT'),
    _Tag('Bluetooth LE'),
  ]),
  _Category('Tools & Software', [
    _Tag('Android Studio'),
    _Tag('VS Code'),
    _Tag('Xcode'),
    _Tag('Git & GitHub'),
    _Tag('Postman'),
    _Tag('Swagger'),
    _Tag('Figma'),
  ]),
  _Category('Databases', [
    _Tag('MongoDB'),
    _Tag('Firebase Firestore'),
    _Tag('SQLite'),
    _Tag('Hive'),
    _Tag('Shared Preferences'),
  ]),
  _Category('Mobile & Deployment', [
    _Tag('Cross-platform'),
    _Tag('Camera'),
    _Tag('GPS'),
    _Tag('Biometrics'),
    _Tag('Play Store'),
    _Tag('App Store'),
  ]),
];

/* ------------------------------ UI Components ------------------------------ */

class _SkillCategoryCard extends StatelessWidget {
  const _SkillCategoryCard({required this.cat});
  final _Category cat;

  @override
  Widget build(BuildContext context) {
    final titleStyle = GoogleFonts.plusJakartaSans(
      fontSize: 22,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.2,
    );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0F1426).withOpacity(0.92),
            const Color(0xFF1B2340).withOpacity(0.95),
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 26,
            offset: const Offset(0, 16),
          ),
          BoxShadow(
            color: const Color(0xFF4BE1EC).withOpacity(0.08),
            blurRadius: 24,
            spreadRadius: 1,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _GradientText(
            cat.title,
            style: titleStyle,
            gradient: const LinearGradient(
              colors: [Color(0xFF4BE1EC), Color(0xFFB388FF)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: LayoutBuilder(
              builder: (context, c) {
                // Responsive chip sizing to keep everything in-bounds
                final maxW = c.maxWidth;
                final isTight = maxW < 320;
                final chipPadH = isTight ? 8.0 : 10.0;
                final chipPadV = isTight ? 7.0 : 8.0;
                final fontSize = isTight ? 12.5 : 14.0;

                return SingleChildScrollView(
                  // still no page scroll; this is just internal safety on tiny widths
                  physics: const NeverScrollableScrollPhysics(),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (final t in cat.tags)
                        _SkillChip(
                          label: t.label,
                          badge: t.badge,
                          fontSize: fontSize,
                          hp: chipPadH,
                          vp: chipPadV,
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SkillChip extends StatelessWidget {
  const _SkillChip({
    required this.label,
    this.badge,
    required this.fontSize,
    required this.hp,
    required this.vp,
  });

  final String label;
  final String? badge;
  final double fontSize;
  final double hp; // horizontal padding
  final double vp; // vertical padding

  @override
  Widget build(BuildContext context) {
    final labelStyle = GoogleFonts.manrope(
      fontSize: fontSize,
      fontWeight: FontWeight.w800,
      color: Colors.white.withOpacity(0.96),
      letterSpacing: 0.2,
    );

    final badgeStyle = GoogleFonts.inter(
      fontSize: math.max(fontSize - 2, 10),
      fontWeight: FontWeight.w700,
      color: Colors.white.withOpacity(0.92),
    );

    return AnimatedContainer(
      duration: 160.ms,
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.symmetric(horizontal: hp, vertical: vp),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withOpacity(0.06),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.24),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: labelStyle),
          if (badge != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: const LinearGradient(
                  colors: [Color(0xFF4BE1EC), Color(0xFFB388FF)],
                ),
              ),
              child: Text(badge!, style: badgeStyle),
            ),
          ],
        ],
      ),
    ).animate(onPlay: (c) => c.repeat(period: 6.seconds, max: 1)).fadeIn(duration: 200.ms);
  }
}

/* ------------------------------- Helpers ----------------------------------- */

class _GradientText extends StatelessWidget {
  const _GradientText(this.text, {required this.style, required this.gradient});
  final String text;
  final TextStyle style;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (r) => gradient.createShader(r),
      child: Text(text, style: style),
    );
  }
}
