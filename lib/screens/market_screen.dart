import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/recycling_company_model.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../providers/market_provider.dart';
import '../services/mock_data.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';
import '../utils/extensions.dart';
import '../widgets/glass_container.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  bool _showEstimation = false;
  final _weightController = TextEditingController();
  String _estimationMaterial = 'PET';
  String _profileSearch = '';
  String _profileRole = 'Tous';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final market = context.watch<MarketProvider>();

    return Scaffold(
      backgroundColor: AppColors.dark,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(auth),
            TabBar(
              controller: _tabController,
              indicatorColor: AppColors.green,
              labelColor: AppColors.green,
              unselectedLabelColor: AppColors.grey,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              tabs: const [
                Tab(text: 'Prix du marché'),
                Tab(text: 'Acheteurs'),
                Tab(text: 'Profils'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPrixTab(),
                  _buildAcheteursTab(market),
                  _buildProfilsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AuthProvider auth) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Scaffold.of(context).openDrawer(),
            child: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.green.withValues(alpha: 0.15),
                image: auth.user?.photoUrl != null
                    ? DecorationImage(image: NetworkImage(auth.user!.photoUrl!), fit: BoxFit.cover)
                    : null,
              ),
              child: auth.user?.photoUrl == null
                  ? const Icon(Icons.menu_rounded, color: AppColors.green)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Marché', style: Theme.of(context).textTheme.titleLarge),
                Text('${auth.user?.name ?? 'Utilisateur'} • ${auth.user?.uniqueId ?? ''}',
                    style: const TextStyle(color: AppColors.grey, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── TAB 1: PRIX DU MARCHÉ ───────────────────────────────────────

  Widget _buildPrixTab() {
    final categories = _searchQuery.isEmpty
        ? Constants.wasteCategories
        : Constants.wasteCategories.where((c) => c.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildSearchBar('Matériau...')),
        SliverToBoxAdapter(child: _buildEstimationToggle()),
        if (_showEstimation) SliverToBoxAdapter(child: _buildEstimationCard()),
        SliverToBoxAdapter(child: _buildInfoBanner()),
        SliverToBoxAdapter(child: const SizedBox(height: 12)),
        ...categories.map((cat) => SliverToBoxAdapter(child: _buildPriceCard(cat))),
        SliverToBoxAdapter(child: const SizedBox(height: 32)),
      ],
    );
  }

  Widget _buildSearchBar(String hint) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.softBlack,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, color: AppColors.grey, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Rechercher un $hint',
                  border: InputBorder.none,
                  filled: false,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            if (_searchQuery.isNotEmpty)
              GestureDetector(
                onTap: () => setState(() => _searchQuery = ''),
                child: const Icon(Icons.clear_rounded, color: AppColors.grey, size: 20),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEstimationToggle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: OutlinedButton.icon(
        onPressed: () => setState(() => _showEstimation = !_showEstimation),
        icon: Icon(_showEstimation ? Icons.expand_less_rounded : Icons.calculate_rounded),
        label: Text(_showEstimation ? 'Masquer' : 'Estimer mes revenus'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.green,
          side: const BorderSide(color: AppColors.green),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          padding: const EdgeInsets.symmetric(vertical: 12),
          minimumSize: const Size(double.infinity, 0),
        ),
      ),
    );
  }

  Widget _buildEstimationCard() {
    final market = context.read<MarketProvider>();
    final materials = market.availableMaterials.where((m) => m != 'Tous').toList();
    if (materials.isEmpty) return const SizedBox.shrink();
    if (!materials.contains(_estimationMaterial)) _estimationMaterial = materials.first;
    final weight = double.tryParse(_weightController.text) ?? 0;
    final revenue = weight > 0 ? market.estimateRevenue(_estimationMaterial, weight) : null;
    final best = weight > 0 ? market.bestBuyerFor(_estimationMaterial) : null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: GlassContainer(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calculate_rounded, color: AppColors.green, size: 20),
                const SizedBox(width: 8),
                const Text('Estimation de revenus', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _estimationMaterial,
                    items: materials.map((m) => DropdownMenuItem(value: m, child: Text(m, style: const TextStyle(fontSize: 13)))).toList(),
                    onChanged: (v) => setState(() => _estimationMaterial = v ?? materials.first),
                    decoration: _inputDeco('Matériau'),
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    dropdownColor: AppColors.softBlack,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: _inputDeco('Poids (kg)'),
                  ),
                ),
              ],
            ),
            if (revenue != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
                child: Column(
                  children: [
                    const Text('Revenu estimé', style: TextStyle(color: AppColors.grey, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(
                      '${revenue.toInt().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ')} FCFA',
                      style: const TextStyle(color: AppColors.green, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    if (best != null) Text('Meilleur acheteur: ${best.name}', style: const TextStyle(color: AppColors.grey, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.grey, fontSize: 13),
      filled: true,
      fillColor: AppColors.softBlack,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }

  Widget _buildInfoBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: GlassContainer(
        width: double.infinity,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.yellow.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.info_rounded, color: AppColors.yellow),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Prix par kg en FCFA', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  const Text('Prix indicatifs validés par les\nentreprises de recyclage partenaires.',
                      style: TextStyle(color: AppColors.grey, fontSize: 12, height: 1.3)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceCard(String category) {
    final price = Constants.defaultPrices[category] ?? 0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.softBlack, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.glassBorder)),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: _categoryColor(category).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
              child: Icon(_categoryIcon(category), color: _categoryColor(category), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(category, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 1),
                  const Text('Prix au kilogramme', style: TextStyle(color: AppColors.grey, fontSize: 11)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: AppColors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: Text(price.toFCFA(), style: const TextStyle(color: AppColors.green, fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }

  // ─── TAB 2: ACHETEURS ─────────────────────────────────────────────

  Widget _buildAcheteursTab(MarketProvider market) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildSearchBar('entreprise, ville, matériau...')),
        SliverToBoxAdapter(child: _buildFilterChips(market)),
        SliverToBoxAdapter(child: _buildSectionTitle('Acheteurs', market.filteredCompanies.length)),
        if (market.filteredCompanies.isEmpty)
          SliverFillRemaining(child: _buildEmptyState('Aucun acheteur trouvé'))
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildCompanyCard(market.filteredCompanies[index]),
              childCount: market.filteredCompanies.length,
            ),
          ),
      ],
    );
  }

  Widget _buildFilterChips(MarketProvider market) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 34,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final city in market.availableCities.take(6))
                  _filterChip(city, market.selectedCity, (v) => market.selectedCity = v),
              ],
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 34,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final mat in market.availableMaterials.take(12))
                  _filterChip(mat, market.selectedMaterial, (v) => market.selectedMaterial = v),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String selected, Function(String) onTap) {
    final isSelected = label == selected;
    return GestureDetector(
      onTap: () => onTap(label),
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
          gradient: isSelected ? const LinearGradient(colors: [AppColors.green, Color(0xFF27AE60)]) : null,
          color: isSelected ? null : AppColors.softBlack,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: isSelected ? AppColors.green : AppColors.glassBorder),
        ),
        child: Text(
          label.length > 18 ? '${label.substring(0, 16)}...' : label,
          style: TextStyle(color: isSelected ? AppColors.white : AppColors.grey, fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildCompanyCard(RecyclingCompany company) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        decoration: BoxDecoration(color: AppColors.softBlack, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.glassBorder)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(color: AppColors.green.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14)),
                    child: const Icon(Icons.recycling_rounded, color: AppColors.green, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(company.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14), overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.location_on_rounded, size: 12, color: AppColors.grey),
                            const SizedBox(width: 4),
                            Text(company.city, style: const TextStyle(color: AppColors.grey, fontSize: 11)),
                            if (company.rating > 0) ...[
                              const SizedBox(width: 8),
                              const Icon(Icons.star_rounded, size: 12, color: AppColors.yellow),
                              const SizedBox(width: 2),
                              Text(company.rating.toStringAsFixed(1), style: const TextStyle(color: AppColors.yellow, fontSize: 11)),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Wrap(
                spacing: 6, runSpacing: 6,
                children: company.materials.take(4).map((m) => _materialBadge(m)).toList(),
              ),
            ),
            if (company.services.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
                child: Text(company.services.join(' • '), style: const TextStyle(color: AppColors.grey, fontSize: 10)),
              ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (company.phone != null) {
                        Clipboard.setData(ClipboardData(text: company.phone!));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Numéro copié!'), backgroundColor: AppColors.green, duration: Duration(seconds: 2)),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: AppColors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
                      child: const Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.call_rounded, color: AppColors.green, size: 16),
                        SizedBox(width: 4),
                        Text('Appeler', style: TextStyle(color: AppColors.green, fontSize: 12)),
                      ]),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(company.hours ?? '', style: const TextStyle(color: AppColors.grey, fontSize: 10)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/home'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: AppColors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
                      child: const Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.map_rounded, color: AppColors.blue, size: 16),
                        SizedBox(width: 4),
                        Text('Carte', style: TextStyle(color: AppColors.blue, fontSize: 12)),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _materialBadge(AcceptedMaterial m) {
    final hasPrice = m.priceMin != null || m.priceMax != null;
    final priceStr = hasPrice
        ? '${m.priceMin?.toInt() ?? ''}${m.priceMin != null && m.priceMax != null ? '-' : ''}${m.priceMax?.toInt() ?? ''}'
        : (m.priceNote ?? '');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: AppColors.green.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.green.withValues(alpha: 0.2))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(m.name, style: const TextStyle(color: AppColors.green, fontSize: 11, fontWeight: FontWeight.w500)),
          if (priceStr.isNotEmpty) ...[
            const SizedBox(width: 6),
            Container(height: 12, width: 1, color: AppColors.green.withValues(alpha: 0.3)),
            const SizedBox(width: 6),
            Text('$priceStr FCFA/kg', style: const TextStyle(color: AppColors.green, fontSize: 10, fontWeight: FontWeight.w600)),
          ],
        ],
      ),
    );
  }

  // ─── TAB 3: PROFILS ──────────────────────────────────────────────

  Widget _buildProfilsTab() {
    final allUsers = MockData.users;

    List<UserModel> filtered = allUsers.where((u) {
      if (_profileRole != 'Tous' && u.role != _profileRole) return false;
      if (_profileSearch.isNotEmpty) {
        final q = _profileSearch.toLowerCase();
        if (!u.name.toLowerCase().contains(q) &&
            !u.uniqueId.toLowerCase().contains(q) &&
            !u.role.toLowerCase().contains(q)) return false;
      }
      return true;
    }).toList()
      ..sort((a, b) {
        final scoreA = a.points + a.completedMissions * 10;
        final scoreB = b.points + b.completedMissions * 10;
        return scoreB.compareTo(scoreA);
      });

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: AppColors.softBlack, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.glassBorder)),
            child: Row(
              children: [
                const Icon(Icons.search_rounded, color: AppColors.grey, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    onChanged: (v) => setState(() => _profileSearch = v),
                    decoration: const InputDecoration(
                      hintText: 'Rechercher un profil...',
                      border: InputBorder.none,
                      filled: false,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                if (_profileSearch.isNotEmpty)
                  GestureDetector(
                    onTap: () => setState(() => _profileSearch = ''),
                    child: const Icon(Icons.clear_rounded, color: AppColors.grey, size: 20),
                  ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: SizedBox(
            height: 34,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: ['Tous', 'collecteur', 'trieur', 'livreur'].map((role) {
                final isSelected = _profileRole == role;
                final label = role == 'Tous' ? 'Tous' : (role == 'collecteur' ? 'Collecteurs' : role == 'trieur' ? 'Trieurs' : 'Livreurs');
                final color = role == 'collecteur' ? AppColors.blue : role == 'trieur' ? AppColors.yellow : role == 'livreur' ? AppColors.orange : AppColors.green;
                return GestureDetector(
                  onTap: () => setState(() => _profileRole = role),
                  child: Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      gradient: isSelected ? LinearGradient(colors: [color, color.withValues(alpha: 0.8)]) : null,
                      color: isSelected ? null : AppColors.softBlack,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: isSelected ? color : AppColors.glassBorder),
                    ),
                    child: Text(label, style: TextStyle(color: isSelected ? Colors.white : AppColors.grey, fontSize: 12, fontWeight: FontWeight.w500)),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Row(
            children: [
              const Text('Profils', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(color: AppColors.green.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                child: Text('${filtered.length}', style: const TextStyle(color: AppColors.green, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.search_off_rounded, color: AppColors.grey.withValues(alpha: 0.5), size: 48),
                      const SizedBox(height: 16),
                      const Text('Aucun profil trouvé', style: TextStyle(color: AppColors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => _buildProfileCard(filtered[i]),
                ),
        ),
      ],
    );
  }

  Widget _buildProfileCard(UserModel user) {
    final roleColor = user.role == 'collecteur'
        ? AppColors.blue
        : user.role == 'trieur'
            ? AppColors.yellow
            : AppColors.orange;
    final waUrl = 'https://wa.me/${user.phone.replaceAll(RegExp(r'[^0-9]'), '')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.softBlack, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.glassBorder)),
      child: Row(
        children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.dark,
              border: Border.all(color: roleColor, width: 2),
              image: user.photoUrl != null ? DecorationImage(image: NetworkImage(user.photoUrl!), fit: BoxFit.cover) : null,
            ),
            child: user.photoUrl == null ? Icon(Icons.person_rounded, color: roleColor, size: 26) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(user.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    if (user.isOnline) ...[
                      const SizedBox(width: 6),
                      Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.green)),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(user.uniqueId, style: const TextStyle(color: AppColors.grey, fontSize: 11)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: roleColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                      child: Text(user.roleLabel, style: TextStyle(color: roleColor, fontSize: 10, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.star_rounded, size: 12, color: AppColors.yellow),
                    const SizedBox(width: 2),
                    Text(user.rating.toStringAsFixed(1), style: const TextStyle(color: AppColors.yellow, fontSize: 11)),
                    const SizedBox(width: 8),
                    Text('${user.completedMissions} missions', style: const TextStyle(color: AppColors.grey, fontSize: 10)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.yellow.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.stars_rounded, size: 10, color: AppColors.yellow),
                          const SizedBox(width: 2),
                          Text('${user.points} pts', style: const TextStyle(color: AppColors.yellow, fontSize: 10, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: user.phone));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Numéro copié!'), backgroundColor: AppColors.green, duration: Duration(seconds: 2)),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppColors.green.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.phone_rounded, color: AppColors.green, size: 18),
                ),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: waUrl));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Lien WhatsApp copié!'), backgroundColor: AppColors.green, duration: Duration(seconds: 2)),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: const Color(0xFF25D366).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.chat_rounded, color: Color(0xFF25D366), size: 18),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── HELPERS ──────────────────────────────────────────────────────

  Widget _buildSectionTitle(String title, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(color: AppColors.green.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
            child: Text('$count', style: const TextStyle(color: AppColors.green, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String msg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, color: AppColors.grey.withValues(alpha: 0.5), size: 48),
            const SizedBox(height: 16),
            Text(msg, style: const TextStyle(color: AppColors.grey)),
          ],
        ),
      ),
    );
  }

  Color _categoryColor(String cat) {
    if (cat.contains('Plastique') || cat.contains('PET')) return AppColors.green;
    if (cat.contains('Aluminium') || cat.contains('Métal') || cat.contains('Fer')) return AppColors.blue;
    if (cat.contains('Carton') || cat.contains('Papier')) return AppColors.yellow;
    if (cat.contains('Verre')) return const Color(0xFF3498DB);
    if (cat.contains('Électronique')) return const Color(0xFFE74C3C);
    if (cat.contains('Pneu')) return const Color(0xFF2C3E50);
    if (cat.contains('Huile')) return const Color(0xFFE67E22);
    return AppColors.grey;
  }

  IconData _categoryIcon(String cat) {
    if (cat.contains('Plastique') || cat.contains('PET')) return Icons.local_drink_rounded;
    if (cat.contains('Aluminium') || cat.contains('Métal') || cat.contains('Fer')) return Icons.handyman_rounded;
    if (cat.contains('Carton') || cat.contains('Papier')) return Icons.inventory_2_rounded;
    if (cat.contains('Verre')) return Icons.wine_bar_rounded;
    if (cat.contains('Électronique')) return Icons.devices_rounded;
    if (cat.contains('Pneu')) return Icons.circle_rounded;
    if (cat.contains('Huile')) return Icons.water_drop_rounded;
    return Icons.recycling_rounded;
  }
}
