import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/data_services.dart';
import '../../widgets/section_container.dart';

class ExperiencePage extends ConsumerWidget {
  const ExperiencePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expAsync = ref.watch(experienceProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 100, left: 24, right: 24, bottom: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          expAsync.when(
            data: (items) {
              final rax = items.where((e) => e.company.toLowerCase().contains('rax')).toList();
              if (rax.isEmpty) return const Text('No Raxtech experience found.');

              return Column(
                children: [
                  for (int i = 0; i < rax.length; i++)
                    _RaxExperienceCard(exp: rax[i])
                    // If you want scroll-safe animations, you can pass an adapter:
                    // .animate(adapter: const ScrollAdapter())
                        .animate()
                        .fadeIn(duration: 320.ms, delay: (i * 120).ms)
                        .moveY(begin: 14, end: 0, duration: 340.ms),
                ],
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const Text('Failed to load experience'),
          ),
        ],
      ),
    );
  }
}

class _RaxExperienceCard extends StatelessWidget {
  const _RaxExperienceCard({required this.exp});
  final Experience exp;

  bool get _hasSummary => (exp.summary).trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isDesktop = w >= 1024;
    final isTablet = w >= 700 && w < 1024;

    final roleSize = isDesktop ? 28.0 : (isTablet ? 24.0 : 20.0);
    final companySize = isDesktop ? 18.0 : (isTablet ? 16.0 : 14.0);
    final dateSize = isDesktop ? 14.0 : 13.0;
    final bodySize = isDesktop ? 16.0 : 14.5;

    final roleStyle = GoogleFonts.spaceGrotesk(
      fontSize: roleSize,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.2,
    );

    final companyStyle = GoogleFonts.plusJakartaSans(
      fontSize: companySize,
      fontWeight: FontWeight.w700,
      color: Colors.white.withOpacity(0.85),
    );

    final dateStyle = GoogleFonts.manrope(
      fontSize: dateSize,
      fontWeight: FontWeight.w700,
      color: Colors.white.withOpacity(0.7),
      letterSpacing: 0.2,
    );

    final bodyStyle = GoogleFonts.inter(
      fontSize: bodySize,
      height: 1.55,
      color: Colors.white.withOpacity(0.95),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Stack(
        children: [
          // Gradient border shell
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Color(0xFF4BE1EC), Color(0xFFB388FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.all(1.4),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(19),
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF0F1426).withOpacity(0.96),
                    const Color(0xFF1B2340).withOpacity(0.96),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              // SAFE LAYOUT: stripe is absolutely positioned; content padded
              child: SizedBox(
                width: double.infinity,
                child: Stack(
                  children: [
                    // Accent stripe pinned to left
                    Positioned(
                      left: 14,
                      top: 14,
                      bottom: 14,
                      child: Container(
                        width: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4BE1EC), Color(0xFFB388FF)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4BE1EC).withOpacity(0.35),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Main content
                    Padding(
                      // 14 (left inset) + 8 (stripe) + 16 (gap) = 38
                      padding: EdgeInsets.fromLTRB(
                          38, isDesktop ? 20 : 16, isDesktop ? 20 : 14, isDesktop ? 20 : 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header: Role + Company + Dates
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final canKeepRow = constraints.maxWidth > 720; // heuristic
                              final header = [
                                // Role (gradient)
                                Flexible(
                                  fit: FlexFit.loose,
                                  child: _GradientText(
                                    exp.role,
                                    style: roleStyle,
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF4BE1EC), Color(0xFFB388FF)],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                // Company pill
                                Flexible(
                                  fit: FlexFit.loose,
                                  child: _CompanyPill(
                                    name: exp.company,
                                    textStyle: companyStyle,
                                  ),
                                ),
                                const Spacer(),
                                // Dates
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.calendar_month_rounded,
                                        size: 18, color: Colors.white70),
                                    const SizedBox(width: 6),
                                    ConstrainedBox(
                                      constraints: const BoxConstraints(maxWidth: 220),
                                      child: Text(
                                        '${exp.from} — ${exp.to}',
                                        style: dateStyle,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ];

                              if (canKeepRow) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: header,
                                );
                              }
                              // On small widths: wrap neatly
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _GradientText(
                                          exp.role,
                                          style: roleStyle,
                                          gradient: const LinearGradient(
                                            colors: [Color(0xFF4BE1EC), Color(0xFFB388FF)],
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    runSpacing: 6,
                                    spacing: 8,
                                    children: [
                                      _CompanyPill(name: exp.company, textStyle: companyStyle),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.calendar_month_rounded,
                                              size: 18, color: Colors.white70),
                                          const SizedBox(width: 6),
                                          Text(
                                            '${exp.from} — ${exp.to}',
                                            style: dateStyle,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),

                          const SizedBox(height: 10),

                          if (_hasSummary)
                            Text(
                              exp.summary,
                              style: bodyStyle,
                              softWrap: true,
                              maxLines: 6,
                              overflow: TextOverflow.ellipsis,
                            ),

                          const SizedBox(height: 12),

                          // Highlights
                          if (exp.highlights.isNotEmpty)
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: exp.highlights.map((h) => _TagChip(text: h)).toList(),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ------------------------------- Sub-widgets ------------------------------- */

class _CompanyPill extends StatelessWidget {
  const _CompanyPill({required this.name, this.textStyle});
  final String name;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white.withOpacity(0.08),
        border: Border.all(color: Colors.white.withOpacity(0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.business_rounded, size: 16, color: Colors.white70),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220),
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: (textStyle ??
                  GoogleFonts.manrope(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white.withOpacity(0.9),
                  )),
            ),
          ),
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: 160.ms,
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white.withOpacity(0.06),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 260),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: Colors.white.withOpacity(0.96),
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}

class _GradientText extends StatelessWidget {
  const _GradientText(
      this.text, {
        required this.style,
        required this.gradient,
        this.maxLines,
        this.overflow,
      });
  final String text;
  final TextStyle style;
  final Gradient gradient;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (r) => gradient.createShader(r),
      child: Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: overflow,
        softWrap: true,
      ),
    );
  }
}
