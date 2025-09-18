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
              // Keep only Raxtech entries
              final rax = items
                  .where((e) => e.company.toLowerCase().contains('rax'))
                  .toList();

              if (rax.isEmpty) {
                return const Text('No Raxtech experience found.');
              }

              return Column(
                children: [
                  for (int i = 0; i < rax.length; i++)
                    _RaxExperienceCard(exp: rax[i])
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

  @override
  Widget build(BuildContext context) {
    final roleStyle = GoogleFonts.spaceGrotesk(
      fontSize: 28,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.2,
    );

    final companyStyle = GoogleFonts.plusJakartaSans(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: Colors.white.withOpacity(0.8),
    );

    final dateStyle = GoogleFonts.manrope(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: Colors.white.withOpacity(0.7),
      letterSpacing: 0.2,
    );

    final bodyStyle = GoogleFonts.inter(
      fontSize: 16,
      height: 1.6,
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
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Accent stripe with glow
                  Container(
                    width: 8,
                    height: 160,
                    margin: const EdgeInsets.only(left: 14, right: 16, top: 22, bottom: 22),
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

                  // Main content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 20, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Role + Company chip + Dates
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Gradient role
                              _GradientText(
                                exp.role,
                                style: roleStyle,
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF4BE1EC), Color(0xFFB388FF)],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                              ),
                              const SizedBox(width: 10),
                              _CompanyPill(name: exp.company),
                              const Spacer(),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_month_rounded,
                                      size: 18, color: Colors.white70),
                                  const SizedBox(width: 6),
                                  Text('${exp.from} — ${exp.to}', style: dateStyle),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          Text(exp.summary, style: bodyStyle),

                          const SizedBox(height: 12),

                          // Highlights
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: exp.highlights
                                .map((h) => _TagChip(text: h))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
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
  const _CompanyPill({required this.name});
  final String name;

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
          Text(
            name,
            style: GoogleFonts.manrope(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: Colors.white.withOpacity(0.9),
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
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 13.5,
          fontWeight: FontWeight.w700,
          color: Colors.white.withOpacity(0.96),
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

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
