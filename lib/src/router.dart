import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:my_portfolio/src/pages/dashboard.dart';
import 'package:my_portfolio/src/pages/experience.dart';
import 'package:my_portfolio/src/pages/projects.dart';
import 'package:my_portfolio/src/pages/skills.dart';

import '../widgets/nav_bar.dart';



GoRouter createRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) => NavShell(child: child),
        routes: [
          GoRoute(path: '/', name: 'home', builder: (_, __) => const DashboardPage()),
          GoRoute(path: '/skills', name: 'skills', builder: (_, __) => const SkillsPage()),
          GoRoute(path: '/experience', name: 'experience', builder: (_, __) => const ExperiencePage()),
          GoRoute(path: '/projects', name: 'projects', builder: (_, __) => const ProjectsPage()),
        ],
      )
    ],
  );
}

class NavShell extends StatelessWidget {
  const NavShell({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // We’re drawing everything ourselves on a Stack.
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  radius: 1.2,
                  colors: [
                    const Color(0xFF0E1320),
                    const Color(0xFF1B2340).withOpacity(0.9),
                  ],
                  center: const Alignment(-0.6, -0.8),
                ),
              ),
            ),
          ),

          // Page content
          Positioned.fill(child: child),

          // Floating, transparent “app bar” (just the nav bar)
          Positioned(
            top: 8,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Center(
                child: const PortfolioNavBar(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}