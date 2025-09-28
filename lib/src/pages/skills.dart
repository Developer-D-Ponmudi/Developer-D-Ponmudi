import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class SkillsPage extends ConsumerWidget {
  const SkillsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const horizontalPad = 24.0;
    const topPad = 100.0;   // room for your floating navbar
    const bottomPad = 48.0;
    const gap = 16.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        // Simple breakpoints
        final isDesktop = w >= 1280;
        final isTablet = w >= 940 && w < 1280;
        final crossAxisCount = isDesktop ? 3 : (isTablet ? 2 : 1);
        final childAspectRatio = isDesktop ? 1.25 : (isTablet ? 1.15 : 0.95);

        return Padding(
          padding: const EdgeInsets.only(
              top: topPad, left: horizontalPad, right: horizontalPad, bottom: bottomPad),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title
                Text(
                  'Skills',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: isDesktop ? 36 : (isTablet ? 30 : 26),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tools, languages, and platforms I use',
                  style: GoogleFonts.manrope(
                    fontSize: isDesktop ? 16 : 14,
                    color: Colors.white.withOpacity(0.7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),

                // Responsive grid that grows with content
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _categories.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: gap,
                    crossAxisSpacing: gap,
                    childAspectRatio: childAspectRatio,
                  ),
                  itemBuilder: (context, i) => _SkillCategoryCard(cat: _categories[i])
                      .animate()
                      .fadeIn(duration: 280.ms, delay: (i * 70).ms)
                      .moveY(begin: 12, end: 0, duration: 340.ms),
                ),
              ],
            ),
          ),
        );
      },
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
  final String? badge; // optional badge like "Beginner" / "3 projects"
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
    final w = MediaQuery.sizeOf(context).width;
    final isDesktop = w >= 1280;
    final isTablet = w >= 940 && w < 1280;

    final titleStyle = GoogleFonts.plusJakartaSans(
      fontSize: isDesktop ? 22 : (isTablet ? 20 : 18),
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

          // Flexible content; no intrinsics, no nested scroll issues
          Expanded(
            child: LayoutBuilder(
              builder: (context, c) {
                final maxW = c.maxWidth;
                final tight = maxW < 320;
                final chipHP = tight ? 8.0 : 10.0;
                final chipVP = tight ? 6.0 : 8.0;
                final fontSize = tight ? 12.5 : 14.0;

                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final t in cat.tags)
                      _SkillChip(
                        label: t.label,
                        badge: t.badge,
                        fontSize: fontSize,
                        hp: chipHP,
                        vp: chipVP,
                      ),
                  ],
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
          Text(label, style: labelStyle, maxLines: 1, overflow: TextOverflow.ellipsis),
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
              child: Text(badge!, style: badgeStyle, maxLines: 1, overflow: TextOverflow.ellipsis),
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
      child: Text(
        text,
        style: style,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        softWrap: true,
      ),
    );
  }
}
