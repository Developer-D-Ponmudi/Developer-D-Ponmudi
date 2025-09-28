import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/data_services.dart';

class ProjectsPage extends ConsumerWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectsProvider);

    // Match app paddings
    const horizontalPad = 24.0;
    const topPad = 100.0; // room for floating navbar
    const bottomPad = 48.0;
    const gap = 16.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;

        // Simple responsive breakpoints
        final isDesktop = w >= 1200;
        final isTablet = w >= 800 && w < 1200;
        final crossAxisCount = isDesktop ? 3 : (isTablet ? 2 : 1);
        // Slightly wider tiles on desktop so text breathes
        final childAspectRatio = isDesktop ? 0.9: (isTablet ? 0.9 : 0.8);

        return Padding(
          padding: const EdgeInsets.only(
            top: topPad,
            left: horizontalPad,
            right: horizontalPad,
            bottom: bottomPad,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title
                Text(
                  'Projects',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: isDesktop ? 36 : (isTablet ? 30 : 26),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Selected work & experiments',
                  style: GoogleFonts.manrope(
                    fontSize: isDesktop ? 16 : 14,
                    color: Colors.white.withOpacity(0.7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),

                // Grid grows with content; page scrolls naturally
                projectsAsync.when(
                  loading: () => const Center(child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: CircularProgressIndicator(),
                  )),
                  error: (_, __) => const Center(child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Text('Failed to load projects'),
                  )),
                  data: (list) {
                    // Inject “Water Softner” + cap items for visual cleanliness
                    final injected = [

                      ...list,
                    ];
                    final items = injected.take(isDesktop ? 6 : (isTablet ? 4 : 4)).toList();

                    if (items.isEmpty) {
                      return const Center(child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Text('No projects to show yet.'),
                      ));
                    }

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: gap,
                        crossAxisSpacing: gap,
                        childAspectRatio: childAspectRatio,
                      ),
                      itemBuilder: (context, i) => _ProjectCard(item: items[i])
                      // If you prefer scroll-safe animations:
                      // .animate(adapter: const ScrollAdapter())
                          .animate()
                          .fadeIn(duration: 300.ms, delay: (i * 90).ms)
                          .moveY(begin: 12, end: 0, duration: 320.ms),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/* ------------------------------ Card widget ------------------------------ */

class _ProjectCard extends StatefulWidget {
  const _ProjectCard({required this.item});
  final Project item;

  @override
  State<_ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<_ProjectCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final isDesktop = w >= 1200;
    final isTablet = w >= 800 && w < 1200;

    final titleStyle = GoogleFonts.spaceGrotesk(
      fontSize: isDesktop ? 22 : (isTablet ? 20 : 18),
      fontWeight: FontWeight.w800,
    );
    final bodyStyle = GoogleFonts.inter(
      fontSize: isDesktop ? 13.5 : 13.0,
      height: 1.45,
      color: Colors.white.withOpacity(0.95),
    );

    final isWaterSoftner = widget.item.name.toLowerCase().contains('softner');

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit:  (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: 180.ms,
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()..translate(0.0, _hover && (kIsWeb || isDesktop) ? -4.0 : 0.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0F1426).withOpacity(0.95),
              const Color(0xFF1B2340).withOpacity(0.97),
            ],
          ),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
          boxShadow: [
            if (_hover && (kIsWeb || isDesktop))
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 22,
                offset: const Offset(0, 14),
              ),
            if (_hover && (kIsWeb || isDesktop))
              BoxShadow(
                color: const Color(0xFF4BE1EC).withOpacity(0.10),
                blurRadius: 20,
                spreadRadius: 1,
                offset: const Offset(0, 6),
              ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // Image header with safe, fixed aspect ratio
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    widget.item.image,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, prog) =>
                    prog == null ? child : const Center(child: CircularProgressIndicator()),
                    errorBuilder: (_, __, ___) => Container(color: Colors.black26),
                  ),
                  // subtle gloss
                  IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.white.withOpacity(0.08), Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Body
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title with gradient on hover
                    _GradientText(
                      widget.item.name,
                      style: titleStyle,
                      gradient: LinearGradient(
                        colors: _hover && (kIsWeb || isDesktop)
                            ? [const Color(0xFF4BE1EC), const Color(0xFFB388FF)]
                            : [Colors.white, Colors.white],
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Description — tight, safe wrapping
                    if (isWaterSoftner) ...[
                      Text(
                        '• Monitor & control water softeners remotely — hardness, salt level, maintenance alerts.',
                        style: bodyStyle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '• Roles: Admin, Manager, Engineer, Customer.',
                        style: bodyStyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '• Tech: HTTP, MQTT, SignalR for real-time updates.',
                        style: bodyStyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ] else
                      Text(
                        widget.item.desc,
                        style: bodyStyle,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),

                    const Spacer(),

                    // Tags + Link
                    Row(
                      children: [
                        Expanded(
                          child: _TagsWrap(tags: widget.item.tags, maxVisible: 3),
                        ),
                        const SizedBox(width: 8),
                        _LinkButton(url: widget.item.link),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* -------------------------------- Sub-widgets ------------------------------- */

class _TagsWrap extends StatelessWidget {
  const _TagsWrap({required this.tags, this.maxVisible = 3});
  final List<String> tags;
  final int maxVisible;

  @override
  Widget build(BuildContext context) {
    final visible = tags.take(maxVisible).toList();
    final more = tags.length - visible.length;

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final t in visible) _TagChip(text: t),
        if (more > 0) _TagChip(text: '+$more'),
      ],
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white.withOpacity(0.08),
        border: Border.all(color: Colors.white.withOpacity(0.16)),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.inter(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: Colors.white.withOpacity(0.96),
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _LinkButton extends StatelessWidget {
  const _LinkButton({required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.platformDefault);
        }
      },
      icon: const Icon(Icons.open_in_new_rounded, size: 18),
      label: const Text('View'),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        minimumSize: const Size(80, 40),
        foregroundColor: Colors.white,
        side: BorderSide(color: Colors.white.withOpacity(0.25)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.manrope(fontWeight: FontWeight.w800, fontSize: 12.5),
      ),
    );
  }
}

/// Gradient text helper
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
