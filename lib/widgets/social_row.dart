import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/data_services.dart';


class SocialRow extends ConsumerWidget {
  const SocialRow({super.key});


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    return profileAsync.when(
      data: (p) => Wrap(
        spacing: 12,
        children: [
          _LinkButton('GitHub', p.links['github']!),
          _LinkButton('LinkedIn', p.links['linkedin']!),
          _LinkButton('Email', p.links['email']!),
        ],
      ),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}


class _LinkButton extends StatelessWidget {
  const _LinkButton(this.label, this.url);
  final String label;
  final String url;
  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.platformDefault);
      },
      icon: const Icon(Icons.open_in_new, size: 18),
      label: Text(label),
    );
  }
}