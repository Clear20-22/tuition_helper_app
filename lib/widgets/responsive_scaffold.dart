import 'package:flutter/material.dart';
import '../../core/utils/responsive_utils.dart';

class ResponsiveScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final Widget? drawer;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final bool extendBodyBehindAppBar;

  const ResponsiveScaffold({
    super.key,
    required this.title,
    required this.body,
    this.drawer,
    this.actions,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.extendBodyBehindAppBar = false,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: (context, constraints) => _buildMobileLayout(context),
      tablet: (context, constraints) => _buildTabletLayout(context),
      desktop: (context, constraints) => _buildDesktopLayout(context),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), actions: actions, elevation: 0),
      drawer: drawer,
      body: body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: actions,
        elevation: 0,
        toolbarHeight: 70,
      ),
      drawer: drawer,
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: body,
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: _buildTabletBottomNavigation(context),
      extendBodyBehindAppBar: extendBodyBehindAppBar,
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    if (drawer != null) {
      return Scaffold(
        body: Row(
          children: [
            SizedBox(width: 280, child: drawer),
            Expanded(
              child: Scaffold(
                appBar: AppBar(
                  title: Text(title),
                  actions: actions,
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  toolbarHeight: 80,
                ),
                body: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: body,
                ),
                floatingActionButton: floatingActionButton,
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: actions,
        elevation: 0,
        toolbarHeight: 80,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: body,
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: _buildDesktopBottomNavigation(context),
      extendBodyBehindAppBar: extendBodyBehindAppBar,
    );
  }

  Widget? _buildTabletBottomNavigation(BuildContext context) {
    if (bottomNavigationBar is BottomNavigationBar) {
      final nav = bottomNavigationBar as BottomNavigationBar;
      return Container(
        height: 80,
        decoration: BoxDecoration(
          color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: nav.currentIndex,
          onTap: nav.onTap,
          items: nav.items,
          type: nav.type,
          selectedItemColor: nav.selectedItemColor,
          unselectedItemColor: nav.unselectedItemColor,
          iconSize: 28,
          selectedFontSize: 14,
          unselectedFontSize: 12,
        ),
      );
    }
    return bottomNavigationBar;
  }

  Widget? _buildDesktopBottomNavigation(BuildContext context) {
    if (bottomNavigationBar is BottomNavigationBar) {
      final nav = bottomNavigationBar as BottomNavigationBar;
      return Container(
        height: 90,
        decoration: BoxDecoration(
          color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: nav.currentIndex,
          onTap: nav.onTap,
          items: nav.items,
          type: nav.type,
          selectedItemColor: nav.selectedItemColor,
          unselectedItemColor: nav.unselectedItemColor,
          iconSize: 32,
          selectedFontSize: 16,
          unselectedFontSize: 14,
        ),
      );
    }
    return bottomNavigationBar;
  }
}
