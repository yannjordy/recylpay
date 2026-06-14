import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});
  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> with TickerProviderStateMixin {
  late final AnimationController _logoCtrl;
  late final AnimationController _heroTextCtrl;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<Offset> _heroSlide;
  late final ScrollController _scrollCtrl;
  int _currentSlide = 0;
  bool _showIntro = true;

  final _awarenessMessages = [
    'Chaque année, le Cameroun produit plus de 6 millions de tonnes de déchets dont seulement 20% sont recyclés.',
    'Un sac plastique met 400 ans à se dégrader dans la nature. Ensemble, réduisons notre empreinte.',
    'Le recyclage au Cameroun pourrait créer plus de 50 000 emplois verts d\'ici 2030.',
    'En triant vos déchets, vous contribuez à réduire la pollution des océans et des cours d\'eau.',
    '80% des déchets camerounais sont valorisables. Ne les jetons plus, recyclons-les !',
  ];

  final _sections = [
    _LandingSection(
      image: 'assets/images/decharge.jpg',
      title: 'Le Fléau des Déchets',
      subtitle: 'Des dépotoirs sauvages envahissent nos villes. Caniveaux bouchés, décharges à ciel ouvert, pollution des nappes phréatiques. Il est temps d\'agir.',
      icon: Icons.warning_amber_rounded,
      color: AppColors.red,
    ),
    _LandingSection(
      image: 'assets/images/pollution.jpg',
      title: 'La Pollution au Cameroun',
      subtitle: 'Yaoundé, Douala, Bafoussam... Nos métropoles étouffent. Sacs plastiques, déchets ménagers, eaux usées déversées dans la nature.',
      icon: Icons.eco_rounded,
      color: AppColors.orange,
    ),
    _LandingSection(
      image: 'assets/images/tri.jpg',
      title: 'La Solution Existe',
      subtitle: 'Trier, collecter, recycler. Chaque geste compte. Avec RecycPay, transformez vos déchets en revenus et participez à l\'économie circulaire.',
      icon: Icons.recycling_rounded,
      color: AppColors.green,
    ),
    _LandingSection(
      image: 'assets/images/africa.jpg',
      title: 'Agissons Ensemble',
      subtitle: 'Rejoignez une communauté de trieurs, ramasseurs et livreurs. Gagnez de l\'argent en recyclant et construisons un Cameroun plus propre.',
      icon: Icons.people_rounded,
      color: AppColors.blue,
    ),
    _LandingSection(
      image: 'assets/images/recyclage.jpg',
      title: 'Comment ça Marche',
      subtitle: '1. Collectez vos déchets recyclables  |  2. Vendez-les aux entreprises partenaires  |  3. Recevez votre paiement Mobile Money.',
      icon: Icons.timeline_rounded,
      color: AppColors.yellow,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _logoCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _heroTextCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: const Interval(0.0, 0.6, curve: Curves.elasticOut)),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: const Interval(0.0, 0.4, curve: Curves.easeIn)),
    );
    _heroSlide = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(
      CurvedAnimation(parent: _heroTextCtrl, curve: Curves.easeOutCubic),
    );
    _scrollCtrl = ScrollController()..addListener(() => setState(() {}));
    _logoCtrl.forward().then((_) => _heroTextCtrl.forward());
    Future.delayed(const Duration(seconds: 6), () {
      if (mounted) setState(() => _showIntro = false);
    });
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _heroTextCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('landing_seen', true);
    if (mounted) Navigator.pushReplacementNamed(context, '/login');
  }

  double get _parallaxOffset {
    if (!_scrollCtrl.hasClients) return 0;
    return _scrollCtrl.offset / 400;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = Responsive.isDesktop(context);
    final contentW = Responsive.contentWidth(context);

    return Scaffold(
      backgroundColor: AppColors.dark,
      body: Stack(
        children: [
          // Main scrollable content
          SingleChildScrollView(
            controller: _scrollCtrl,
            child: Column(
              children: [
                // ─── INTRO SECTION ────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: size.height,
                  child: Stack(
                    children: [
                      Transform.translate(
                        offset: Offset(0, -_parallaxOffset * 30),
                        child: Image.asset(
                          'assets/images/cameroun.jpg',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: size.height + 200,
                          errorBuilder: (_, __, ___) => Container(color: AppColors.dark),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.4),
                              Colors.black.withValues(alpha: 0.6),
                              AppColors.dark,
                            ],
                          ),
                        ),
                      ),
                      Center(
                        child: DesktopScaffold(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Spacer(flex: 2),
                              AnimatedBuilder(
                                animation: _logoOpacity,
                                builder: (_, child) => Opacity(
                                  opacity: _logoOpacity.value,
                                  child: ScaleTransition(scale: _logoScale, child: child),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: Image.asset('assets/images/logo.png',
                                      width: isDesktop ? 120 : 80, height: isDesktop ? 120 : 80, fit: BoxFit.cover),
                                ),
                              ),
                              const SizedBox(height: 24),
                              AnimatedBuilder(
                                animation: _heroTextCtrl,
                                builder: (_, child) => SlideTransition(position: _heroSlide, child: child),
                                child: Column(
                                  children: [
                                    Text(
                                      'RecycPay',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: isDesktop ? 52 : 36,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 3,
                                        shadows: [Shadow(color: AppColors.green.withValues(alpha: 0.5), blurRadius: 20)],
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Valorisons nos déchets ensemble',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: isDesktop ? 22 : 16,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: AppColors.green.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      child: const Text(
                                        'Cameroun • Recyclage • Économie Circulaire',
                                        style: TextStyle(color: AppColors.green, fontSize: 12, fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(flex: 1),
                              // Awareness ticker
                              _buildAwarenessTicker(),
                              const SizedBox(height: 40),
                              GestureDetector(
                                onTap: () => setState(() => _showIntro = false),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white24),
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('Découvrir', style: TextStyle(color: Colors.white54, fontSize: 14)),
                                      SizedBox(width: 8),
                                      Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white54),
                                    ],
                                  ),
                                ),
                              ),
                              const Spacer(flex: 1),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // ─── AWARENESS STATS ──────────────────────────────
                Container(
                  width: double.infinity,
                  color: AppColors.green.withValues(alpha: 0.05),
                  padding: EdgeInsets.symmetric(vertical: 40, horizontal: 16),
                  child: DesktopScaffold(
                    child: Column(
                      children: [
                        Text('Le Recyclage au Cameroun en Chiffres',
                            style: TextStyle(fontSize: isDesktop ? 28 : 22, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 32),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 24,
                          runSpacing: 24,
                          children: [
                            _statCard('6M+', 'Tonnes de\ndéchets/an', AppColors.red),
                            _statCard('20%', 'Taux de\nrecyclage', AppColors.yellow),
                            _statCard('50K', 'Emplois verts\npotentiels', AppColors.green),
                            _statCard('400', 'Ans pour un\nsac plastique', AppColors.orange),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // ─── SECTIONS ──────────────────────────────────────
                ...List.generate(_sections.length, (i) => _buildSection(i, isDesktop, contentW)),
                // ─── CTA ───────────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 60, horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.green.withValues(alpha: 0.1), AppColors.dark],
                    ),
                  ),
                  child: DesktopScaffold(
                    child: Column(
                      children: [
                        Icon(Icons.recycling_rounded, size: 64, color: AppColors.green.withValues(alpha: 0.6)),
                        const SizedBox(height: 20),
                        Text('Prêt à faire la différence ?',
                            style: TextStyle(fontSize: isDesktop ? 32 : 24, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 12),
                        Text(
                          'Rejoignez des milliers de Camerounais qui transforment leurs déchets en revenus.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: isDesktop ? 18 : 15, color: AppColors.grey),
                        ),
                        const SizedBox(height: 32),
                        GestureDetector(
                          onTap: _start,
                          child: Container(
                            width: isDesktop ? 320 : 260,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [AppColors.green, Color(0xFF27AE60)]),
                              borderRadius: BorderRadius.circular(50),
                              boxShadow: [BoxShadow(color: AppColors.green.withValues(alpha: 0.4), blurRadius: 24, spreadRadius: 2)],
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Créer mon compte', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward_rounded, color: Colors.white),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // ─── FLOATING LOGIN BUTTON ────────────────────────────
          if (!_showIntro)
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: _start,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.green, Color(0xFF27AE60)]),
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [BoxShadow(color: AppColors.green.withValues(alpha: 0.3), blurRadius: 12)],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Connexion', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                      SizedBox(width: 6),
                      Icon(Icons.login_rounded, size: 18, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAwarenessTicker() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      builder: (_, value, __) => Opacity(
        opacity: value,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.eco_rounded, color: AppColors.green, size: 20),
              const SizedBox(width: 12),
              Flexible(
                child: AnimatedSwitcher(
                  duration: const Duration(seconds: 3),
                  child: Text(
                    _awarenessMessages[_currentSlide % _awarenessMessages.length],
                    key: ValueKey(_currentSlide),
                    style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(String value, String label, Color color) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.softBlack,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.1), blurRadius: 12)],
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 8),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.grey, fontSize: 13, height: 1.3)),
        ],
      ),
    );
  }

  Widget _buildSection(int index, bool isDesktop, double contentW) {
    final s = _sections[index];
    final isEven = index.isEven;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: isDesktop ? 80 : 48, horizontal: 16),
      child: DesktopScaffold(
        child: isDesktop
            ? Row(
                children: [
                  if (isEven) ...[
                    Expanded(child: _sectionImage(s)),
                    const SizedBox(width: 48),
                  ],
                  Expanded(child: _sectionContent(s)),
                  if (!isEven) ...[
                    const SizedBox(width: 48),
                    Expanded(child: _sectionImage(s)),
                  ],
                ],
              )
            : Column(
                children: [
                  _sectionImage(s),
                  const SizedBox(height: 20),
                  _sectionContent(s),
                ],
              ),
      ),
    );
  }

  Widget _sectionImage(_LandingSection s) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        children: [
          Image.asset(s.image, width: double.infinity, height: 300, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(height: 300, color: AppColors.softBlack, child: Center(child: Icon(s.icon, color: s.color, size: 60)))),
          Container(
            height: 300,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, AppColors.dark.withValues(alpha: 0.6)],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionContent(_LandingSection s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: s.color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14)),
          child: Icon(s.icon, color: s.color, size: 28),
        ),
        const SizedBox(height: 16),
        Text(s.title, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Text(s.subtitle, style: const TextStyle(color: AppColors.grey, fontSize: 16, height: 1.6)),
      ],
    );
  }
}

class _LandingSection {
  final String image;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  const _LandingSection({required this.image, required this.title, required this.subtitle, required this.icon, required this.color});
}
