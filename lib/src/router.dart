import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/drawer.dart';
import '../widgets/nav_bar.dart';
import 'package:my_portfolio/src/pages/dashboard.dart';
import 'package:my_portfolio/src/pages/experience.dart';
import 'package:my_portfolio/src/pages/projects.dart';
import 'package:my_portfolio/src/pages/skills.dart';

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
      ),
    ],
  );
}

class NavShell extends StatefulWidget {
  const NavShell({super.key, required this.child});
  final Widget child;

  // Tweak this if you want tablet to behave like “desktop”
  static const double breakpoint = 900.0;

  @override
  State<NavShell> createState() => _NavShellState();
}

class _NavShellState extends State<NavShell> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  void _openDrawer() => _scaffoldKey.currentState?.openDrawer();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= NavShell.breakpoint;

    return Scaffold(
      key: _scaffoldKey,
      // IMPORTANT: Don’t draw body behind the AppBar unless your pages add top padding.
      extendBodyBehindAppBar: false,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64), // set the height you want
        child: Material( // keeps elevation/ink behavior sane; can be Container too
          color: Colors.transparent, // or your nav bg color
          child: isDesktop ? const PortfolioNavBar() : null,
        ),
      ),
      // Mobile: show Drawer. Desktop: no drawer.
      drawer: isDesktop ? null : const PortfolioDrawer(),
      drawerEnableOpenDragGesture: !isDesktop,
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
          widget.child,

          // Mobile-only floating menu button (to open the Drawer)
          if (!isDesktop)
            SafeArea(
              child: Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Material(
                    color: Colors.black.withOpacity(0.25),
                    shape: const CircleBorder(),
                    child: IconButton(
                      icon: const Icon(Icons.menu_rounded, color: Colors.white),
                      tooltip: 'Menu',
                      onPressed: _openDrawer,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
