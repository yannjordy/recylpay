import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> with TickerProviderStateMixin {
  late final AnimationController _rotateCtrl;
  late final AnimationController _slideCtrl;
  late final AnimationController _floatCtrl;
  late final Animation<double> _rotateAnim;
  late final Animation<Offset> _slideAnim;
  final _pageCtrl = PageController(viewportFraction: 0.85);
  int _currentPage = 0;

  final _pages = [
    _LandingPageData(
      image: 'assets/images/cameroun.jpg',
      title: 'Bienvenue sur RecycPay',
      subtitle: 'La plateforme camerounaise de gestion des déchets et de recyclage',
      icon: Icons.public_rounded,
      color: AppColors.green,
    ),
    _LandingPageData(
      image: 'assets/images/decharge.jpg',
      title: 'Le Problème',
      subtitle: 'Des dépotoirs sauvages, des caniveaux bouchés, des décharges à ciel ouvert. Notre environnement souffre. 🌍',
      icon: Icons.warning_amber_rounded,
      color: AppColors.red,
    ),
    _LandingPageData(
      image: 'assets/images/pollution.jpg',
      title: 'La Pollution au Cameroun',
      subtitle: 'Sac plastique, déchets ménagers, eaux usées. Les villes camerounaises étouffent sous les déchets.',
      icon: Icons.eco_rounded,
      color: AppColors.orange,
    ),
    _LandingPageData(
      image: 'assets/images/tri.jpg',
      title: 'Notre Mission',
      subtitle: 'Collecter, trier et recycler les déchets. Chaque geste compte pour un Cameroun plus propre et plus vert.',
      icon: Icons.recycling_rounded,
      color: AppColors.green,
    ),
    _LandingPageData(
      image: 'assets/images/africa.jpg',
      title: 'La Mission du Citoyen',
      subtitle: 'Trier tes déchets à la source, les déposer aux points de collecte, et gagner de l\'argent en recyclant.',
      icon: Icons.people_rounded,
      color: AppColors.blue,
    ),
    _LandingPageData(
      image: 'assets/images/recyclage.jpg',
      title: 'Comment ça marche ?',
      subtitle: '1. Collecte tes déchets recyclables\n2. Vends-les aux entreprises partenaires\n3. Reçois ton paiement sur Mobile Money',
      icon: Icons.timeline_rounded,
      color: AppColors.yellow,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _rotateCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _slideCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _floatCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);
    _rotateAnim = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: _rotateCtrl, curve: Curves.easeInOut),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));
    _pageCtrl.addListener(() {
      final p = _pageCtrl.page ?? 0;
      setState(() => _currentPage = p.round());
    });
    _rotateCtrl..forward()..repeat(reverse: true);
    _slideCtrl.forward();
  }

  @override
  void dispose() {
    _rotateCtrl.dispose();
    _slideCtrl.dispose();
    _floatCtrl.dispose();
    _pageCtrl.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('landing_seen', true);
    if (mounted) Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      body: Stack(
        children: [
          // Background image with 3D parallax
          AnimatedBuilder(
            animation: _rotateAnim,
            builder: (_, child) {
              final offset = (_currentPage - (_pages.length / 2)) * 0.02;
              return Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(_rotateAnim.value + offset)
                  ..translate(-offset * 20),
                alignment: Alignment.center,
                child: child,
              );
            },
            child: Image.asset(
              _pages[_currentPage].image,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          // Dark gradient overlay animated
          AnimatedBuilder(
            animation: _floatCtrl,
            builder: (_, child) => Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.6 + _floatCtrl.value * 0.1),
                    Colors.black.withValues(alpha: 0.85 + _floatCtrl.value * 0.05),
                    Colors.black,
                  ],
                ),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 16),
                // Logo + Name with 3D
                AnimatedBuilder(
                  animation: _rotateAnim,
                  builder: (_, child) => Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.002)
                      ..rotateY(_rotateAnim.value * 2),
                    alignment: Alignment.center,
                    child: child,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset('assets/images/logo.png', width: 36, height: 36, fit: BoxFit.cover),
                      ),
                      const SizedBox(width: 10),
                      const Text('RecycPay', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Cards
                Expanded(
                  child: PageView.builder(
                    controller: _pageCtrl,
                    itemCount: _pages.length,
                    onPageChanged: (i) {
                      _slideCtrl.reset();
                      _slideCtrl.forward();
                    },
                    itemBuilder: (ctx, i) {
                      final p = _pages[i];
                      final isCenter = i == _currentPage;
                      final scale = isCenter ? 1.0 : 0.9;
                      return AnimatedBuilder(
                        animation: _slideAnim,
                        builder: (_, child) => Transform.translate(
                          offset: i == _currentPage ? _slideAnim.value : Offset.zero,
                          child: Transform.scale(scale: scale, child: child),
                        ),
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: 16, right: 16,
                            top: isCenter ? 0 : 20,
                            bottom: isCenter ? 0 : 20,
                          ),
                          child: _build3DCard(p, i, isCenter),
                        ),
                      );
                    },
                  ),
                ),
                // Dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_pages.length, (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == i ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == i ? _pages[i].color : AppColors.grey.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  )),
                ),
                const SizedBox(height: 20),
                // Button
                AnimatedBuilder(
                  animation: _floatCtrl,
                  builder: (_, child) => Transform.translate(
                    offset: Offset(0, -_floatCtrl.value * 6),
                    child: child,
                  ),
                  child: GestureDetector(
                    onTap: _start,
                    child: Container(
                      width: 220,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [AppColors.green, Color(0xFF2ECC71)]),
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [BoxShadow(color: AppColors.green.withValues(alpha: 0.4), blurRadius: 20, spreadRadius: 1)],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Commencer', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _build3DCard(_LandingPageData p, int index, bool isCenter) {
    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateX(isCenter ? _rotateAnim.value * 0.5 : 0),
      alignment: Alignment.center,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.softBlack.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.glassBorder),
          boxShadow: [
            BoxShadow(color: p.color.withValues(alpha: 0.15), blurRadius: 30, spreadRadius: 2),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            children: [
              // Image section
              Expanded(
                flex: 5,
                child: Stack(
                  children: [
                    Transform(
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.002)
                        ..rotateY(_rotateAnim.value),
                      alignment: Alignment.center,
                      child: Image.asset(
                        p.image,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: AppColors.dark, child: Center(child: Icon(p.icon, color: p.color.withValues(alpha: 0.3), size: 60))),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, AppColors.softBlack.withValues(alpha: 0.6)],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Text section
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: p.color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                            child: Icon(p.icon, color: p.color, size: 20),
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: Text(p.title, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold))),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        p.subtitle,
                        style: const TextStyle(color: AppColors.grey, fontSize: 13, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LandingPageData {
  final String image;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  const _LandingPageData({required this.image, required this.title, required this.subtitle, required this.icon, required this.color});
}
