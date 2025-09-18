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

    // Layout paddings to match the rest of your app
    const horizontalPad = 24.0;
    const topPad = 100.0; // room for floating navbar
    const bottomPad = 48.0;
    const spacing = 16.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final screen = MediaQuery.sizeOf(context);
        final availW = constraints.maxWidth - horizontalPad * 2;
        final availH = screen.height;

        // Header height budget (title + small gap)
        const headerH = 56.0;

        // Grid area height
        final gridH = (availH - headerH).clamp(200.0, double.infinity);

        // For a 2x2 grid, compute card size so everything fits without scroll.
        const cols = 2;
        const rows = 2;
        final cardW = (availW - (cols - 1) * spacing) / cols;
        final cardH = (gridH - (rows - 1) * spacing) / rows;
        final childAspectRatio = (cardW / cardH).clamp(0.8, 2.2);

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

            
                // Fixed-height grid → no scroll, no overflow
                SizedBox(
                  height: gridH,
                  child: projectsAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (_, __) => const Center(child: Text('Failed to load projects')),
                    data: (list) {
                      // Inject "Water Softner" and cap to 4 items (2x2)
                      final injected = [
                        Project(
                          'Water Softner',
                          'The Water Softener Monitoring App is a multi-role system that enables remote monitoring and control of water softener devices, tracking parameters like hardness, salt levels, and maintenance alerts in real time.',
                          ['Flutter & Dart', 'HTTP', 'MQTT', 'SignalR', 'Multi-role'],
                          'https://picsum.photos/seed/watersoftner/1200/600',
                          'https://example.com/water-softener',
                        ),
                        ...list,
                      ];
                      final items = injected.take(4).toList();
            
                      if (items.isEmpty) {
                        return const Center(child: Text('No projects to show yet.'));
                      }
            
                      return GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: items.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: cols,
                          mainAxisSpacing: spacing,
                          crossAxisSpacing: spacing,
                          childAspectRatio: childAspectRatio,
                        ),
                        itemBuilder: (context, i) => _ProjectCard(item: items[i])
                            .animate()
                            .fadeIn(duration: 300.ms, delay: (i * 70).ms)
                            .moveY(begin: 12, end: 0),
                      );
                    },
                  ),
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
    final titleStyle = GoogleFonts.spaceGrotesk(
      fontSize: 20, // smaller for a tighter card
      fontWeight: FontWeight.w800,
    );
    final bodyStyle = GoogleFonts.inter(
      fontSize: 13.2,
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
        transform: Matrix4.identity()..translate(0.0, _hover ? -4.0 : 0.0),
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
            if (_hover)
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 22,
                offset: const Offset(0, 14),
              ),
            if (_hover)
              BoxShadow(
                color: const Color(0xFF4BE1EC).withOpacity(0.10),
                blurRadius: 20,
                spreadRadius: 1,
                offset: const Offset(0, 6),
              ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: LayoutBuilder(
          builder: (context, box) {
            // Make the image shorter so details always fit in the same tile.
            final imgH = box.maxHeight * 0.42; // ~42% image, ~58% details

            // limit tags so the row stays compact
            final tags = widget.item.tags;
            const maxVisibleTags = 3;
            final moreCount = (tags.length - maxVisibleTags);
            final tagChips = <Widget>[
              for (final t in tags.take(maxVisibleTags)) _TagChip(text: t),
              if (moreCount > 0) _TagChip(text: '+$moreCount'),
            ];

            return Column(
              children: [
                // Image header (fixed height instead of 16:9 so it’s shorter)
                SizedBox(
                  height: imgH,
                  width: double.infinity,
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
                      // top gloss
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

                // Body (compact)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title (gradient on hover)
                        _GradientText(
                          widget.item.name,
                          style: titleStyle,
                          gradient: LinearGradient(
                            colors: _hover
                                ? [const Color(0xFF4BE1EC), const Color(0xFFB388FF)]
                                : [Colors.white, Colors.white],
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Description (tightened lines)
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

                        // Tags + Link (compact)
                        Row(
                          children: [
                            Expanded(
                              child: Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: tagChips,
                              ),
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
            );
          },
        ),
      ),
    );
  }
}


/* -------------------------------- Sub-widgets ------------------------------- */

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
        foregroundColor: Colors.white,
        side: BorderSide(color: Colors.white.withOpacity(0.25)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
      child: Text(text, style: style),
    );
  }
}
