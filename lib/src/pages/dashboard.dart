import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/data_services.dart';
import '../../widgets/section_container.dart';
// import '../../widgets/social_row.dart'; // ← no longer needed

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  double _tiltX = 0; // -1..1 (left/right)
  double _tiltY = 0; // -1..1 (top/bottom)

  // === Links you provided ===
  static final Uri _github   = Uri.parse('https://github.com/Developer-D-Ponmudi/Developer-D-Ponmudi');
  static final Uri _linkedin = Uri.parse('http://www.linkedin.com/in/ponmudiddeveloper');
  static final Uri _cv       = Uri.parse('https://drive.google.com/file/d/1cNmvcHGUrFlwrI0bOFb70PmXPw2QQe-K/view?usp=sharing');
  static final Uri _email    = Uri(
    scheme: 'mailto',
    path: 'developer.ponmudi@gmail.com',
    queryParameters: {'subject': 'Hi Ponmudi — from your portfolio'},
  );

  // Universal launcher helpers
  Future<void> _launch(Uri uri) async {
    final ok = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
      webOnlyWindowName: '_blank', // opens new tab on web
    );
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open: $uri')),
      );
    }
  }

  Future<void> _openCv() => _launch(_cv);
  Future<void> _openGithub() => _launch(_github);
  Future<void> _openLinkedIn() => _launch(_linkedin);
  Future<void> _sendEmail() => _launch(_email);

  void _onHover(PointerHoverEvent e, Size size) {
    final dx = (e.localPosition.dx / size.width) * 2 - 1;  // -1..1
    final dy = (e.localPosition.dy / size.height) * 2 - 1; // -1..1
    setState(() {
      _tiltX = dx.clamp(-1.0, 1.0);
      _tiltY = dy.clamp(-1.0, 1.0);
    });
  }

  void _resetTilt(PointerExitEvent _) {
    setState(() {
      _tiltX = 0;
      _tiltY = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 100, left: 24, right: 24, bottom: 48),
      child: LayoutBuilder(
        builder: (context, c) {
          final isWide = c.maxWidth >= 980;
          final textMaxWidth = isWide ? c.maxWidth * 0.48 : c.maxWidth;
          final avatarSize = isWide ? 420.0 : 280.0;

          // === Premium Typography ===
          final greetStyle = GoogleFonts.plusJakartaSans(
            fontSize: isWide ? 22 : 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
            color: Colors.white.withOpacity(0.92),
          );

          final nameStyle = GoogleFonts.spaceGrotesk(
            fontSize: isWide ? 58 : 40,
            fontWeight: FontWeight.w800,
            height: 1.02,
            letterSpacing: -0.3,
          );

          final subtitleStyle = GoogleFonts.manrope(
            fontSize: isWide ? 22 : 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
            color: Colors.white.withOpacity(0.80),
          );

          final aboutStyle = GoogleFonts.inter(
            fontSize: isWide ? 18 : 16,
            height: 1.6,
            color: Colors.white.withOpacity(0.92),
          );

          // gradient for the name
          const nameGradient = LinearGradient(
            colors: [Color(0xFF4BE1EC), Color(0xFFB388FF)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── HERO: Left (intro) • Right (3D avatar)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // LEFT: Intro
                  SizedBox(
                    width: textMaxWidth,
                    child: profileAsync.when(
                      loading: () => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 80),
                        child: LinearProgressIndicator(),
                      ),
                      error: (_, __) => const Text('Failed to load.'),
                      data: (p) => Column(
                        crossAxisAlignment:
                        isWide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                        children: [
                          Text("Hello, I'm", style: greetStyle)
                              .animate()
                              .fadeIn(duration: 280.ms)
                              .moveY(begin: 20, end: 0, duration: 320.ms),

                          const SizedBox(height: 8),

                          _GradientText(
                            'Ponmudi D',
                            style: nameStyle,
                            gradient: nameGradient,
                          )
                              .animate(delay: 90.ms)
                              .fadeIn(duration: 380.ms)
                              .moveY(begin: 18, end: 0, duration: 380.ms),

                          const SizedBox(height: 10),

                          Text('Flutter Developer ', style: subtitleStyle)
                              .animate(delay: 160.ms)
                              .fadeIn(duration: 360.ms)
                              .moveY(begin: 14, end: 0, duration: 360.ms),

                          const SizedBox(height: 20),

                          Text(
                            p.about,
                            textAlign: isWide ? TextAlign.start : TextAlign.center,
                            style: aboutStyle,
                          )
                              .animate(delay: 220.ms)
                              .fadeIn(duration: 380.ms)
                              .moveY(begin: 10, end: 0, duration: 360.ms),

                          const SizedBox(height: 18),

                          // Social links row (GitHub / LinkedIn / Gmail)
                          Align(
                            alignment: isWide ? Alignment.centerLeft : Alignment.center,
                            child: _SocialLinksRow(
                              onGithub: _openGithub,
                              onLinkedIn: _openLinkedIn,
                              onEmail: _sendEmail,
                            ),
                          )
                              .animate(delay: 260.ms)
                              .fadeIn(duration: 420.ms)
                              .moveY(begin: 10, end: 0, duration: 360.ms),

                          const SizedBox(height: 14),

                          // Open CV button
                          Align(
                            alignment: isWide ? Alignment.centerLeft : Alignment.center,
                            child: _GradientPrimaryButton(
                              onTap: _openCv,
                              icon: Icons.description_rounded,
                              label: 'Open CV',
                            )
                                .animate(delay: 300.ms)
                                .fadeIn(duration: 420.ms)
                                .moveY(begin: 10, end: 0, duration: 360.ms),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (isWide) const Spacer(),

                  // RIGHT: 3D Avatar (right-center)
                  if (isWide)
                    profileAsync.when(
                      loading: () => const SizedBox(
                        height: 380,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (_, __) => const SizedBox.shrink(),
                      data: (p) {
                        final imgProvider = p.avatar.startsWith('http')
                            ? NetworkImage(p.avatar)
                            : AssetImage(p.avatar) as ImageProvider;

                        return _HeroImage3D(
                          size: avatarSize,
                          image: imgProvider,
                          tiltX: _tiltX,
                          tiltY: _tiltY,
                          onHover: _onHover,
                          onExit: _resetTilt,
                        )
                            .animate()
                            .fadeIn(duration: 450.ms)
                            .scale(begin: const Offset(0.96, 0.96), end: const Offset(1, 1));
                      },
                    ),
                ],
              ).animate().fadeIn(duration: 500.ms, delay: 120.ms),

              if (!isWide) ...[
                const SizedBox(height: 28),
                profileAsync.when(
                  loading: () => const SizedBox(
                    height: 280,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (p) {
                    final imgProvider = p.avatar.startsWith('http')
                        ? NetworkImage(p.avatar)
                        : AssetImage(p.avatar) as ImageProvider;
                    return _HeroImage3D(
                      size: avatarSize,
                      image: imgProvider,
                      tiltX: _tiltX,
                      tiltY: _tiltY,
                      onHover: _onHover,
                      onExit: _resetTilt,
                    )
                        .animate()
                        .fadeIn(duration: 450.ms)
                        .scale(begin: const Offset(0.96, 0.96), end: const Offset(1, 1));
                  },
                ),
              ],

              const SizedBox(height: 48),
              const SectionContainer(
                title: 'What I do',
                child: Text(
                  'I build fast, beautiful Flutter apps for mobile and web, with clean architecture, smooth animations, and great DX.',
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Social buttons row (GitHub / LinkedIn / Gmail)
class _SocialLinksRow extends StatefulWidget {
  const _SocialLinksRow({
    required this.onGithub,
    required this.onLinkedIn,
    required this.onEmail,
  });

  final VoidCallback onGithub;
  final VoidCallback onLinkedIn;
  final VoidCallback onEmail;

  @override
  State<_SocialLinksRow> createState() => _SocialLinksRowState();
}

class _SocialLinksRowState extends State<_SocialLinksRow> {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _GlassIconButton(
          icon: Icons.code_rounded,
          label: 'GitHub',
          onTap: widget.onGithub,
        ),
        _GlassIconButton(
          icon: Icons.business_center_rounded,
          label: 'LinkedIn',
          onTap: widget.onLinkedIn,
        ),
        _GlassIconButton(
          icon: Icons.mail_rounded,
          label: 'Gmail',
          onTap: widget.onEmail,
        ),
      ],
    );
  }
}

class _GlassIconButton extends StatefulWidget {
  const _GlassIconButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  State<_GlassIconButton> createState() => _GlassIconButtonState();
}

class _GlassIconButtonState extends State<_GlassIconButton> {
  bool _hover = false;
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final scale = (_hover ? 1.03 : 1.0) * (_down ? 0.98 : 1.0);

    return Tooltip(
      message: widget.label,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _down = true),
          onTapUp: (_) => setState(() => _down = false),
          onTapCancel: () => setState(() => _down = false),
          onTap: widget.onTap,
          child: AnimatedScale(
            duration: 140.ms,
            curve: Curves.easeOutCubic,
            scale: scale,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white.withOpacity(0.06),
                border: Border.all(color: Colors.white.withOpacity(0.14)),
                boxShadow: [
                  if (_hover)
                    BoxShadow(
                      color: const Color(0xFF4BE1EC).withOpacity(0.18),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(widget.icon, size: 18, color: Colors.white.withOpacity(0.96)),
                    const SizedBox(width: 8),
                    Text(
                      widget.label,
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                        color: Colors.white.withOpacity(0.96),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Simple gradient text helper (keeps your Text API but adds gradient color)
class _GradientText extends StatelessWidget {
  const _GradientText(this.text, {required this.style, required this.gradient});
  final String text;
  final TextStyle style;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(text, style: style),
    );
  }
}

/// Fancy gradient primary button used for "Open CV"
class _GradientPrimaryButton extends StatefulWidget {
  const _GradientPrimaryButton({
    required this.onTap,
    required this.icon,
    required this.label,
  });
  final VoidCallback onTap;
  final IconData icon;
  final String label;

  @override
  State<_GradientPrimaryButton> createState() => _GradientPrimaryButtonState();
}

class _GradientPrimaryButtonState extends State<_GradientPrimaryButton> {
  bool _hover = false;
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final scale = (_hover ? 1.02 : 1.0) * (_down ? 0.98 : 1.0);

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _down = true),
        onTapCancel: () => setState(() => _down = false),
        onTapUp: (_) => setState(() => _down = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          duration: 140.ms,
          curve: Curves.easeOutCubic,
          scale: scale,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: const LinearGradient(
                colors: [Color(0xFF4BE1EC), Color(0xFFB388FF)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4BE1EC).withOpacity(0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(widget.icon, size: 18, color: Colors.black),
                  const SizedBox(width: 8),
                  Text(
                    widget.label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A circular hero image with subtle 3D tilt (on hover for web), glow,
/// layered shadows and a glossy highlight to feel elevated.
class _HeroImage3D extends StatelessWidget {
  const _HeroImage3D({
    required this.size,
    required this.image,
    required this.tiltX,
    required this.tiltY,
    required this.onHover,
    required this.onExit,
  });

  final double size;
  final ImageProvider image;
  final double tiltX; // -1..1
  final double tiltY; // -1..1
  final void Function(PointerHoverEvent e, Size size) onHover;
  final void Function(PointerExitEvent e) onExit;

  @override
  Widget build(BuildContext context) {
    final perspective = 0.0016;
    final rotateY = -tiltX * 0.20; // left/right tilt
    final rotateX = tiltY * 0.20;  // up/down tilt
    final lift = (1 + (0.06 * (tiltX.abs() + tiltY.abs()))); // slight scale on hover

    return SizedBox(
      width: size,
      height: size,
      child: LayoutBuilder(builder: (context, c) {
        final boxSize = Size(c.maxWidth, c.maxHeight);

        return MouseRegion(
          onHover: (e) => onHover(e, boxSize),
          onExit: onExit,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, perspective)
              ..rotateX(rotateX)
              ..rotateY(rotateY)
              ..scale(lift),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Soft outer glow
                Container(
                  width: size * 1.15,
                  height: size * 1.15,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.05),
                        blurRadius: 80,
                        spreadRadius: 20,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.6),
                        blurRadius: 60,
                        offset: const Offset(0, 30),
                      ),
                    ],
                  ),
                ),

                // Gradient ring behind (subtle)
                Container(
                  width: size * 1.02,
                  height: size * 1.02,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      colors: [
                        Colors.white.withOpacity(0.18),
                        Colors.white.withOpacity(0.04),
                        Colors.white.withOpacity(0.18),
                      ],
                    ),
                  ),
                ),

                // Main circular image with shadows
                Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(image: image, fit: BoxFit.cover),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.55),
                        blurRadius: 40,
                        offset: const Offset(0, 26),
                      ),
                      BoxShadow(
                        color: const Color(0xFF4BE1EC).withOpacity(0.18),
                        blurRadius: 50,
                        spreadRadius: 6,
                        offset: const Offset(0, 12),
                      ),
                    ],
                    border: Border.all(color: Colors.white10, width: 2),
                  ),
                ),

                // Glossy highlight for 3D feel
                IgnorePointer(
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        center: const Alignment(-0.5, -0.6),
                        radius: 0.6,
                        colors: [
                          Colors.white.withOpacity(0.18),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
