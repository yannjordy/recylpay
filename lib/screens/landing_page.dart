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
      image: 'assets/images/decharge2.jpg',
      fallback: 'assets/images/decharge.jpg',
      title: 'Le Fléau des Déchets',
      subtitle: 'Des dépotoirs sauvages envahissent nos villes. Caniveaux bouchés, décharges à ciel ouvert, pollution des nappes phréatiques. Au Cameroun, la gestion des déchets est un défi majeur qui menace notre santé et notre environnement.',
      icon: Icons.warning_amber_rounded,
      color: AppColors.red,
    ),
    _LandingSection(
      image: 'assets/images/pollution2.jpg',
      fallback: 'assets/images/pollution.jpg',
      title: 'La Pollution au Cameroun',
      subtitle: 'Yaoundé, Douala, Bafoussam... Nos métropoles étouffent sous les sacs plastiques, les déchets ménagers et les eaux usées. Les cours d\'eau sont pollués, l\'air devient irrespirable. Il est urgent d\'agir pour notre santé et notre planète.',
      icon: Icons.eco_rounded,
      color: AppColors.orange,
    ),
    _LandingSection(
      image: 'assets/images/tri2.jpg',
      fallback: 'assets/images/tri.jpg',
      title: 'La Solution : Trier et Recycler',
      subtitle: 'Trier ses déchets à la source, c\'est le premier geste. Avec RecycPay, chaque déchet trié devient une ressource. Plastique, métal, carton, verre, électronique... Tout se recycle et se transforme en revenus pour vous.',
      icon: Icons.recycling_rounded,
      color: AppColors.green,
    ),
  ];

  final _howItWorks = [
    _StepData(icon: Icons.sort_rounded, title: '1. Trie tes déchets', desc: 'Sépare les déchets recyclables (plastique, métal, carton, verre) des déchets ménagers. Chaque geste de tri compte.'),
    _StepData(icon: Icons.cleaning_services_rounded, title: '2. Collecte ou dépose', desc: 'Fais collecter tes déchets par un ramasseur ou dépose-les dans un point de collecte partenaire près de chez toi.'),
    _StepData(icon: Icons.monetization_on_rounded, title: '3. Vends et gagne', desc: 'Vends tes déchets triés aux entreprises de recyclage partenaires. Reçois ton paiement directement sur Mobile Money.'),
    _StepData(icon: Icons.people_rounded, title: '4. Construis la communauté', desc: 'Partage tes actions, gagne des points éco, et contribue à faire du Cameroun un pays plus propre et plus vert.'),
  ];

  final _features = [
    _FeatureData(icon: Icons.price_change_rounded, title: 'Prix du Marché', desc: 'Consulte les prix actualisés des matériaux recyclables au kilogramme. Estime tes revenus en temps réel.'),
    _FeatureData(icon: Icons.map_rounded, title: 'Carte Interactive', desc: 'Localise les points de collecte, les entreprises de recyclage et les zones de pollution signalées autour de toi.'),
    _FeatureData(icon: Icons.wallet_rounded, title: 'Portefeuille Mobile', desc: 'Gère ton solde, effectue des retraits vers Mobile Money et suis l\'historique de tes transactions.'),
    _FeatureData(icon: Icons.dynamic_feed_rounded, title: 'Fil d\'Actualité', desc: 'Publie tes collectes, partage tes astuces et connecte-toi avec la communauté RecycPay.'),
    _FeatureData(icon: Icons.stars_rounded, title: 'Système de Points', desc: 'Gagne des points éco à chaque publication et action. Échange-les contre des récompenses exclusives.'),
    _FeatureData(icon: Icons.recycling_rounded, title: 'Économie Circulaire', desc: 'Rejoins un réseau qui valorise les déchets, crée des emplois verts et protège l\'environnement camerounais.'),
  ];

  final _objectives = [
    'Réduire la pollution plastique au Cameroun de 50% d\'ici 2030',
    'Créer 10 000 emplois verts dans le secteur du recyclage',
    'Sensibiliser 1 million de Camerounais au tri des déchets',
    'Faciliter l\'accès au recyclage pour tous, même dans les zones rurales',
    'Valoriser 500 000 tonnes de déchets recyclables par an',
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

    return Scaffold(
      backgroundColor: AppColors.dark,
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollCtrl,
            child: Column(
              children: [
                // ─── HERO ───────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: size.height,
                  child: Stack(
                    children: [
                      Transform.translate(
                        offset: Offset(0, -_parallaxOffset * 30),
                        child: Image.asset('assets/images/cameroun.jpg',
                            fit: BoxFit.cover, width: double.infinity, height: size.height + 200,
                            errorBuilder: (_, __, ___) => Container(color: AppColors.dark)),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter, end: Alignment.bottomCenter,
                            colors: [Colors.black.withValues(alpha: 0.4), Colors.black.withValues(alpha: 0.6), AppColors.dark],
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
                                    Text('RecycPay',
                                        style: TextStyle(color: Colors.white, fontSize: isDesktop ? 52 : 36,
                                            fontWeight: FontWeight.bold, letterSpacing: 3,
                                            shadows: [Shadow(color: AppColors.green.withValues(alpha: 0.5), blurRadius: 20)])),
                                    const SizedBox(height: 12),
                                    Text('Valorisons nos déchets ensemble',
                                        style: TextStyle(color: Colors.white70, fontSize: isDesktop ? 22 : 16, letterSpacing: 1)),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                      decoration: BoxDecoration(color: AppColors.green.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(50)),
                                      child: const Text('Cameroun • Recyclage • Économie Circulaire',
                                          style: TextStyle(color: AppColors.green, fontSize: 12, fontWeight: FontWeight.w500)),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(flex: 1),
                              _buildAwarenessTicker(),
                              const SizedBox(height: 40),
                              GestureDetector(
                                onTap: () => setState(() => _showIntro = false),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(border: Border.all(color: Colors.white24), borderRadius: BorderRadius.circular(50)),
                                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                                    Text('Découvrir', style: TextStyle(color: Colors.white54, fontSize: 14)),
                                    SizedBox(width: 8), Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white54),
                                  ]),
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
                  padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
                  child: DesktopScaffold(
                    child: Column(
                      children: [
                        Text('Le Recyclage au Cameroun en Chiffres',
                            style: TextStyle(fontSize: isDesktop ? 28 : 22, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 32),
                        Wrap(alignment: WrapAlignment.center, spacing: 24, runSpacing: 24, children: [
                          _statCard('6M+', 'Tonnes de\ndéchets/an', AppColors.red),
                          _statCard('20%', 'Taux de\nrecyclage', AppColors.yellow),
                          _statCard('50K', 'Emplois verts\npotentiels', AppColors.green),
                          _statCard('400', 'Ans pour un\nsac plastique', AppColors.orange),
                        ]),
                      ],
                    ),
                  ),
                ),
                // ─── PROBLEM SECTIONS ─────────────────────────────
                ...List.generate(_sections.length, (i) => _buildSection(i, isDesktop)),
                // ─── FONCTIONNEMENT ────────────────────────────────
                Container(
                  width: double.infinity,
                  color: AppColors.green.withValues(alpha: 0.03),
                  padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 16),
                  child: DesktopScaffold(
                    child: Column(
                      children: [
                        Text('Comment fonctionne RecycPay ?',
                            style: TextStyle(fontSize: isDesktop ? 28 : 22, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 8),
                        Text('Du tri à la poche, en quatre étapes simples',
                            style: TextStyle(color: AppColors.grey, fontSize: isDesktop ? 16 : 14)),
                        const SizedBox(height: 40),
                        isDesktop
                            ? Row(
                                children: _howItWorks.map((s) => Expanded(child: _stepCard(s))).toList(),
                              )
                            : Column(
                                children: _howItWorks.map((s) => Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: _stepCard(s),
                                )).toList(),
                              ),
                      ],
                    ),
                  ),
                ),
                // ─── FONCTIONNALITÉS ──────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 16),
                  child: DesktopScaffold(
                    child: Column(
                      children: [
                        Text('Fonctionnalités de l\'application',
                            style: TextStyle(fontSize: isDesktop ? 28 : 22, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 8),
                        Text('Tout ce dont vous avez besoin pour recycler et gagner',
                            style: TextStyle(color: AppColors.grey, fontSize: isDesktop ? 16 : 14)),
                        const SizedBox(height: 40),
                        Wrap(
                          spacing: 20, runSpacing: 20,
                          children: _features.map((f) => SizedBox(
                            width: isDesktop ? 320 : double.infinity,
                            child: _featureCard(f),
                          )).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                // ─── OBJECTIFS ─────────────────────────────────────
                Container(
                  width: double.infinity,
                  color: AppColors.green.withValues(alpha: 0.05),
                  padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 16),
                  child: DesktopScaffold(
                    child: Column(
                      children: [
                        Text('Nos Objectifs pour le Cameroun',
                            style: TextStyle(fontSize: isDesktop ? 28 : 22, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 40),
                        ...List.generate(_objectives.length, (i) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(color: AppColors.green.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                                child: Icon(Icons.check_rounded, color: AppColors.green, size: 20),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(_objectives[i],
                                    style: TextStyle(color: Colors.white, fontSize: isDesktop ? 16 : 14, height: 1.4)),
                              ),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                ),
                // ─── CTA ───────────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [AppColors.green.withValues(alpha: 0.1), AppColors.dark]),
                  ),
                  child: DesktopScaffold(
                    child: Column(
                      children: [
                        Icon(Icons.recycling_rounded, size: 64, color: AppColors.green.withValues(alpha: 0.6)),
                        const SizedBox(height: 20),
                        Text('Prêt à faire la différence ?',
                            style: TextStyle(fontSize: isDesktop ? 32 : 24, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 12),
                        Text('Rejoignez des milliers de Camerounais qui transforment leurs déchets en revenus.',
                            textAlign: TextAlign.center, style: TextStyle(fontSize: isDesktop ? 18 : 15, color: AppColors.grey)),
                        const SizedBox(height: 32),
                        GestureDetector(
                          onTap: _start,
                          child: Container(
                            width: isDesktop ? 320 : 260, padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [AppColors.green, Color(0xFF27AE60)]),
                              borderRadius: BorderRadius.circular(50),
                              boxShadow: [BoxShadow(color: AppColors.green.withValues(alpha: 0.4), blurRadius: 24, spreadRadius: 2)],
                            ),
                            child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                              Text('Créer mon compte', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                              SizedBox(width: 8), Icon(Icons.arrow_forward_rounded, color: Colors.white),
                            ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // ─── FOOTER ────────────────────────────────────────
                Container(
                  width: double.infinity,
                  color: const Color(0xFF060A18),
                  padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
                  child: DesktopScaffold(
                    child: Column(
                      children: [
                        isDesktop
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(flex: 2, child: _footerAbout()),
                                  const SizedBox(width: 48),
                                  Expanded(child: _footerLinks()),
                                  const SizedBox(width: 48),
                                  Expanded(child: _footerContact()),
                                ],
                              )
                            : Column(
                                children: [
                                  _footerAbout(),
                                  const SizedBox(height: 32),
                                  _footerLinks(),
                                  const SizedBox(height: 32),
                                  _footerContact(),
                                ],
                              ),
                        const SizedBox(height: 40),
                        Container(height: 1, color: AppColors.glassBorder),
                        const SizedBox(height: 24),
                        Text('© ${DateTime.now().year} RecycPay. Tous droits réservés.',
                            style: const TextStyle(color: AppColors.grey, fontSize: 13)),
                        const SizedBox(height: 8),
                        const Text('Fait avec ❤️ pour un Cameroun plus propre.',
                            style: TextStyle(color: AppColors.grey, fontSize: 12)),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // ─── FLOATING BUTTON ────────────────────────────────────
          if (!_showIntro)
            Positioned(
              top: 16, right: 16,
              child: GestureDetector(
                onTap: _start,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.green, Color(0xFF27AE60)]),
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [BoxShadow(color: AppColors.green.withValues(alpha: 0.3), blurRadius: 12)],
                  ),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Text('Connexion', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                    SizedBox(width: 6), Icon(Icons.login_rounded, size: 18, color: Colors.white),
                  ]),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ─── WIDGETS ──────────────────────────────────────────────────────

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
                  child: Text(_awarenessMessages[_currentSlide % _awarenessMessages.length],
                      key: ValueKey(_currentSlide), style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4)),
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
      width: 180, padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.softBlack, borderRadius: BorderRadius.circular(20),
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

  Widget _buildSection(int index, bool isDesktop) {
    final s = _sections[index];
    final isEven = index.isEven;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: isDesktop ? 80 : 48, horizontal: 16),
      child: DesktopScaffold(
        child: isDesktop
            ? Row(
                children: [
                  if (isEven) ...[Expanded(child: _sectionImage(s)), const SizedBox(width: 48)],
                  Expanded(child: _sectionContent(s)),
                  if (!isEven) ...[const SizedBox(width: 48), Expanded(child: _sectionImage(s))],
                ],
              )
            : Column(children: [_sectionImage(s), const SizedBox(height: 20), _sectionContent(s)]),
      ),
    );
  }

  Widget _sectionImage(_LandingSection s) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        children: [
          Image.asset(s.image, width: double.infinity, height: 300, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => s.fallback != null
                  ? Image.asset(s.fallback!, width: double.infinity, height: 300, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(height: 300, color: AppColors.softBlack,
                          child: Center(child: Icon(s.icon, color: s.color, size: 60))))
                  : Container(height: 300, color: AppColors.softBlack,
                      child: Center(child: Icon(s.icon, color: s.color, size: 60)))),
          Container(
            height: 300,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
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

  Widget _stepCard(_StepData s) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.softBlack, borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.green.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(16)),
            child: Icon(s.icon, color: AppColors.green, size: 32),
          ),
          const SizedBox(height: 16),
          Text(s.title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(s.desc, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.grey, fontSize: 13, height: 1.5)),
        ],
      ),
    );
  }

  Widget _featureCard(_FeatureData f) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.softBlack, borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.green.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
            child: Icon(f.icon, color: AppColors.green, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(f.title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(f.desc, style: const TextStyle(color: AppColors.grey, fontSize: 13, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _footerAbout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset('assets/images/logo.png', width: 32, height: 32, fit: BoxFit.cover),
            ),
            const SizedBox(width: 10),
            const Text('RecycPay', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 12),
        const Text('La plateforme camerounaise de gestion des déchets et de recyclage. Transformez vos déchets en revenus et contribuez à un Cameroun plus propre.',
            style: TextStyle(color: AppColors.grey, fontSize: 13, height: 1.5)),
      ],
    );
  }

  Widget _footerLinks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Liens utiles', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _footerLink('Comment ça marche', () => {}),
        const SizedBox(height: 8),
        _footerLink('Confidentialité', () => {}),
        const SizedBox(height: 8),
        _footerLink('Aide & Support', () => {}),
        const SizedBox(height: 8),
        _footerLink('À propos', () => {}),
      ],
    );
  }

  Widget _footerContact() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Contact', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _footerContactItem(Icons.email_rounded, 'support@recylpay.com'),
        const SizedBox(height: 8),
        _footerContactItem(Icons.phone_rounded, '+237 690 000 000'),
        const SizedBox(height: 8),
        _footerContactItem(Icons.location_on_rounded, 'Douala, Cameroun'),
      ],
    );
  }

  Widget _footerLink(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 13, height: 1.5)),
    );
  }

  Widget _footerContactItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.green),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(color: AppColors.grey, fontSize: 13)),
      ],
    );
  }
}

class _LandingSection {
  final String image;
  final String? fallback;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  const _LandingSection({required this.image, this.fallback, required this.title, required this.subtitle, required this.icon, required this.color});
}

class _StepData {
  final IconData icon;
  final String title;
  final String desc;
  const _StepData({required this.icon, required this.title, required this.desc});
}

class _FeatureData {
  final IconData icon;
  final String title;
  final String desc;
  const _FeatureData({required this.icon, required this.title, required this.desc});
}
