import 'package:flutter/material.dart';

class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const Responsive({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 768;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 768 &&
      MediaQuery.of(context).size.width < 1200;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200;

  static double contentWidth(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= 1200) return 1100;
    if (w >= 768) return w * 0.9;
    return w;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1200) return desktop;
    if (width >= 768) return tablet ?? desktop;
    return mobile;
  }
}

class DesktopScaffold extends StatelessWidget {
  final Widget child;

  const DesktopScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1200;
    final isTablet = width >= 768 && width < 1200;

    if (isDesktop || isTablet) {
      return Center(
        child: Container(
          width: Responsive.contentWidth(context),
          constraints: const BoxConstraints(maxWidth: 1200),
          child: child,
        ),
      );
    }
    return child;
  }
}
