import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wallet_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_container.dart';
import '../widgets/pill_button.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  int _selectedTab = 0;

  final _depositController = TextEditingController();
  final _phoneController = TextEditingController(text: '+237');
  String? _selectedOperator;

  // Payment
  final _paymentRecipientController = TextEditingController();
  final _paymentAmountController = TextEditingController();
  String? _foundRecipientName;
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  final _scrollController = ScrollController();
  final _historyKey = GlobalKey();
  Timer? _searchTimer;
  bool _showPoints = false;

  @override
  void initState() {
    super.initState();
    try {
      final wp = context.read<WalletProvider>();
      wp.loadBalance();
      wp.loadTransactions();
    } catch (_) {}
  }

  void _searchUsers(String query) {
    _searchTimer?.cancel();
    if (query.trim().length < 2) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }
    _searchTimer = Timer(const Duration(milliseconds: 300), () async {
      final wallet = context.read<WalletProvider>();
      final results = await wallet.searchRecipients(query.trim());
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _depositController.dispose();
    _phoneController.dispose();
    _paymentRecipientController.dispose();
    _paymentAmountController.dispose();
    _searchTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  String _fcfx(double amount) {
    final i = amount.toInt();
    final s = i.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]} ',
    );
    return '$s FCFA';
  }

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>();
    final auth = context.watch<AuthProvider>();
    final points = auth.user?.points ?? 0;

    return Container(
      color: AppColors.dark,
      child: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 28),
              _buildBalanceCard(wallet, points),
              const SizedBox(height: 32),
              _buildTabSelector(),
              const SizedBox(height: 24),
              if (_selectedTab == 0) _buildDepositForm(wallet),
              if (_selectedTab == 1) _buildPaymentForm(wallet),
              const SizedBox(height: 16),
              _buildHistorySection(wallet),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 6,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.green,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 14),
            const Text(
              'Portefeuille',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text(
            'Gérez vos transactions et votre solde',
            style: TextStyle(
              color: AppColors.grey.withValues(alpha: 0.8),
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceCard(WalletProvider wallet, int points) {
    final moneyMax = 500000.0;
    final moneyProgress = (wallet.balance / moneyMax).clamp(0.0, 1.0);
    final pointsProgress = (points / 1000.0).clamp(0.0, 1.0);
    final pointsLevel = points ~/ 50;
    final nextLevel = ((pointsLevel + 1) * 50).clamp(0, 1000);
    final levelNames = ['Bronze', 'Argent', 'Or', 'Platine', 'Diamant'];
    final levelName = pointsLevel < levelNames.length ? levelNames[pointsLevel] : 'Diamant';

    return GestureDetector(
      onTap: () => setState(() => _showPoints = !_showPoints),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _showPoints
                ? [const Color(0xFF2A251A), AppColors.softBlack, AppColors.softBlack]
                : [const Color(0xFF1A3A2A), AppColors.softBlack, AppColors.softBlack],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.glassBorder),
          boxShadow: [
            BoxShadow(
              color: (_showPoints ? AppColors.yellow : AppColors.green).withValues(alpha: 0.08),
              blurRadius: 30,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (_showPoints ? AppColors.yellow : AppColors.green).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      _showPoints ? Icons.star_rounded : Icons.account_balance_wallet_rounded,
                      color: _showPoints ? AppColors.yellow : AppColors.green,
                      size: 24,
                      key: ValueKey(_showPoints),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    color: _showPoints ? AppColors.yellow : AppColors.green,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                  child: Text(_showPoints ? 'Mes Points' : 'Mon Solde'),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => setState(() => _showPoints = !_showPoints),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _showPoints ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                          color: AppColors.grey,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _showPoints ? 'Voir solde' : 'Voir points',
                          style: TextStyle(color: AppColors.grey.withValues(alpha: 0.7), fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: _showPoints
                  ? _pointsContent(points, pointsProgress, levelName, nextLevel)
                  : _moneyContent(wallet, moneyProgress),
            ),
          ],
        ),
      ),
    );
  }

  Widget _moneyContent(WalletProvider wallet, double moneyProgress) {
    return Column(
      key: const ValueKey('money'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Solde disponible', style: TextStyle(color: AppColors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        Text(
          _fcfx(wallet.balance),
          style: const TextStyle(color: AppColors.green, fontSize: 42, fontWeight: FontWeight.w800, letterSpacing: -1, height: 1.1),
        ),
        const SizedBox(height: 20),
        _sliderBar(value: moneyProgress, barColor: AppColors.green, label: '${_fcfx(wallet.balance)}', maxLabel: '500 000 FCFA'),
        const SizedBox(height: 16),
        Row(
          children: [
            _statChip(Icons.receipt_rounded, '${wallet.transactions.length}', 'Opérations'),
            const SizedBox(width: 16),
            _statChip(
              Icons.access_time_rounded,
              wallet.transactions.isNotEmpty ? _relDateShort(wallet.transactions.first.createdAt) : '--',
              'Dernière',
            ),
          ],
        ),
      ],
    );
  }

  Widget _pointsContent(int points, double pointsProgress, String levelName, int nextLevel) {
    return Column(
      key: const ValueKey('points'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '$points pts',
              style: const TextStyle(color: AppColors.yellow, fontSize: 42, fontWeight: FontWeight.w800, letterSpacing: -1, height: 1.1),
            ),
            const SizedBox(width: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.yellow.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.yellow.withValues(alpha: 0.3)),
              ),
              child: Text('Niveau $levelName', style: const TextStyle(color: AppColors.yellow, fontSize: 12, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _sliderBar(value: pointsProgress, barColor: AppColors.yellow, label: '$points / 1 000 pts', maxLabel: '$nextLevel pts'),
        const SizedBox(height: 16),
        Row(
          children: [
            _statChip(Icons.emoji_events_rounded, levelName, 'Palier actuel'),
            const SizedBox(width: 16),
            _statChip(Icons.trending_up_rounded, '${1000 - points} pts restants', 'Vers le max'),
          ],
        ),
      ],
    );
  }

  Widget _sliderBar({required double value, required Color barColor, required String label, required String maxLabel}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
            Text(maxLabel, style: TextStyle(color: AppColors.grey.withValues(alpha: 0.6), fontSize: 11)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: Colors.white.withValues(alpha: 0.06),
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
            minHeight: 12,
          ),
        ),
      ],
    );
  }

  Widget _statChip(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.grey, size: 14),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
              Text(label, style: TextStyle(color: AppColors.grey.withValues(alpha: 0.7), fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabSelector() {
    final tabLabels = ['Dépôt', 'Payer'];
    final tabIcons = [Icons.add_rounded, Icons.send_rounded];
    final tabColors = [AppColors.green, const Color(0xFF007AFF)];

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.softBlack,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: List.generate(2, (i) {
          final isActive = _selectedTab == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isActive ? tabColors[i].withValues(alpha: 0.15) : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      tabIcons[i],
                      color: isActive ? tabColors[i] : AppColors.grey,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      tabLabels[i],
                      style: TextStyle(
                        color: isActive ? tabColors[i] : AppColors.grey,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDepositForm(WalletProvider wallet) {
    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.blue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.add_card_rounded, color: AppColors.blue, size: 20),
              ),
              const SizedBox(width: 14),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Dépôt Mobile Money', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
                  SizedBox(height: 2),
                  Text('Commission de 2% appliquée', style: TextStyle(color: AppColors.grey, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Opérateur', style: TextStyle(color: AppColors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _operatorCard('Orange Money', 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/02/Orange_Money_logo.svg/640px-Orange_Money_logo.svg.png', const Color(0xFFFF7900))),
              const SizedBox(width: 14),
              Expanded(child: _operatorCard('MTN Mobile Money', 'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6b/MTN_Group_logo.svg/640px-MTN_Group_logo.svg.png', const Color(0xFFFFC000))),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            style: const TextStyle(color: Colors.white, fontSize: 15),
            decoration: const InputDecoration(labelText: 'Numéro de téléphone'),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _depositController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white, fontSize: 15),
            decoration: InputDecoration(
              labelText: 'Montant à déposer',
              suffixText: 'FCFA',
              suffixStyle: const TextStyle(color: AppColors.green, fontWeight: FontWeight.w600),
            ),
            onChanged: (_) => setState(() {}),
          ),
          if (_depositController.text.isNotEmpty) ...[
            const SizedBox(height: 8),
            _feePreview(double.tryParse(_depositController.text) ?? 0),
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _depositController.clear();
                    setState(() => _selectedOperator = null);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.grey,
                    side: const BorderSide(color: AppColors.glassBorder),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Effacer', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 2,
                child: PillButton(
                  label: 'Déposer',
                  onTap: () async {
                    final op = _selectedOperator;
                    if (op == null) return;
                    final p = _phoneController.text.trim();
                    if (p.length < 9) return;
                    final a = double.tryParse(_depositController.text);
                    if (a == null || a <= 0) return;
                    final ok = await wallet.deposit(a);
                    if (ok && mounted) {
                      _depositController.clear();
                      setState(() => _selectedOperator = null);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${a.toInt()} FCFA déposés via $op'), backgroundColor: AppColors.green),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
          if (wallet.error != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: AppColors.red, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(wallet.error!, style: const TextStyle(color: AppColors.red, fontSize: 12))),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _feePreview(double amount) {
    if (amount <= 0) return const SizedBox.shrink();
    final fee = amount * 0.02;
    final net = amount - fee;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.dark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Montant', style: TextStyle(color: AppColors.grey, fontSize: 13)),
              Text('${amount.toInt()} FCFA', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Commission (2%)', style: TextStyle(color: AppColors.grey, fontSize: 13)),
              Text('-${fee.toInt()} FCFA', style: const TextStyle(color: AppColors.red, fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 6), child: Divider(color: AppColors.glassBorder, height: 1)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Net crédité', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
              Text('${net.toInt()} FCFA', style: const TextStyle(color: AppColors.green, fontSize: 14, fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _operatorCard(String name, String logoUrl, Color color) {
    final selected = _selectedOperator == name;
    return GestureDetector(
      onTap: () => setState(() => _selectedOperator = name),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.12) : AppColors.dark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? color : AppColors.glassBorder,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                logoUrl,
                width: 44, height: 44,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      name == 'Orange Money' ? 'OM' : 'MTN',
                      style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              name == 'Orange Money' ? 'Orange Money' : 'MTN MoMo',
              style: TextStyle(
                color: selected ? color : AppColors.grey,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentForm(WalletProvider wallet) {

    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.green.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.send_rounded, color: AppColors.green, size: 20),
              ),
              const SizedBox(width: 14),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Payer un utilisateur', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
                  SizedBox(height: 2),
                  Text('Transférez de l\'argent sur RecycPay', style: TextStyle(color: AppColors.grey, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _paymentRecipientController,
            style: const TextStyle(color: Colors.white, fontSize: 15),
            decoration: InputDecoration(
              labelText: 'ID ou nom du destinataire',
              hintText: '@utilisateur ou nom',
              hintStyle: TextStyle(color: AppColors.grey.withValues(alpha: 0.4)),
              suffixIcon: _paymentRecipientController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppColors.grey, size: 20),
                      onPressed: () {
                        _paymentRecipientController.clear();
                        setState(() {
                          _foundRecipientName = null;
                          _searchResults = [];
                        });
                      },
                    )
                  : null,
            ),
            onChanged: (v) {
              setState(() {
                _foundRecipientName = null;
                _isSearching = true;
              });
              _searchUsers(v);
            },
          ),
          if (_searchResults.isNotEmpty && _foundRecipientName == null) ...[
            const SizedBox(height: 6),
            Container(
              constraints: const BoxConstraints(maxHeight: 220),
              decoration: BoxDecoration(
                color: AppColors.softBlack,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemCount: _searchResults.length,
                separatorBuilder: (_, __) => const Divider(color: AppColors.glassBorder, height: 1, indent: 14, endIndent: 14),
                itemBuilder: (ctx, i) {
                  final r = _searchResults[i];
                  final uid = r['uniqueId'] as String;
                  final name = r['name'] as String;
                  return InkWell(
                    onTap: () {
                      _paymentRecipientController.text = uid;
                      _paymentRecipientController.selection = TextSelection.collapsed(offset: uid.length);
                      setState(() {
                        _foundRecipientName = name;
                        _searchResults = [];
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                name.isNotEmpty ? name[0].toUpperCase() : '?',
                                style: const TextStyle(color: AppColors.green, fontWeight: FontWeight.w700, fontSize: 15),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                                Text(uid, style: const TextStyle(color: AppColors.grey, fontSize: 12)),
                              ],
                            ),
                          ),
                          const Icon(Icons.add_rounded, color: AppColors.green, size: 20),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          if (_isSearching && _searchResults.isEmpty && _paymentRecipientController.text.length >= 2 && _foundRecipientName == null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.softBlack,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search_off_rounded, color: AppColors.grey, size: 18),
                  const SizedBox(width: 10),
                  const Text('Aucun utilisateur trouvé', style: TextStyle(color: AppColors.grey, fontSize: 13)),
                ],
              ),
            ),
          ],
          if (_foundRecipientName != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.green.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.green.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: AppColors.green, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _foundRecipientName!,
                      style: const TextStyle(color: AppColors.green, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          TextField(
            controller: _paymentAmountController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white, fontSize: 15),
            decoration: InputDecoration(
              labelText: 'Montant à envoyer',
              suffixText: 'FCFA',
              suffixStyle: const TextStyle(color: AppColors.green, fontWeight: FontWeight.w600),
            ),
            onChanged: (_) => setState(() {}),
          ),
          if (wallet.error != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: AppColors.red, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(wallet.error!, style: const TextStyle(color: AppColors.red, fontSize: 12))),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _paymentRecipientController.clear();
                    _paymentAmountController.clear();
                    setState(() => _foundRecipientName = null);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.grey,
                    side: const BorderSide(color: AppColors.glassBorder),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Effacer', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 2,
                child: PillButton(
                  label: 'Envoyer',
                  onTap: () async {
                    final id = _paymentRecipientController.text.trim();
                    final a = double.tryParse(_paymentAmountController.text);
                    if (id.isEmpty || a == null || a <= 0) return;
                    final points = await wallet.sendPayment(id, a);
                    if (mounted) {
                      if (points > 0) {
                        context.read<AuthProvider>().addPoints(points);
                        _paymentRecipientController.clear();
                        _paymentAmountController.clear();
                        setState(() => _foundRecipientName = null);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${a.toInt()} FCFA envoyés · +$points pts'),
                            backgroundColor: AppColors.green,
                          ),
                        );
                      } else if (wallet.error != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(wallet.error!), backgroundColor: AppColors.red),
                        );
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection(WalletProvider wallet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          key: _historyKey,
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.green,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Historique',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${wallet.transactions.length} opérations',
                style: const TextStyle(color: AppColors.grey, fontSize: 12),
              ),
            ),
            const SizedBox(width: 8),
            if (wallet.transactions.isNotEmpty)
              GestureDetector(
                onTap: () => _showClearAllDialog(wallet),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.delete_sweep_rounded, color: AppColors.red, size: 16),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (wallet.isLoading)
          const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
        else if (wallet.transactions.isEmpty)
          _emptyHistory()
        else
          ...wallet.transactions.take(20).map((t) => _txTile(t, wallet)),
      ],
    );
  }

  Widget _txTile(dynamic t, WalletProvider wallet) {
    final isCredit = t.type == 'deposit' || t.type == 'payment_received';
    final iconColor = isCredit ? AppColors.green : AppColors.red;

    IconData typeIcon;
    switch (t.type) {
      case 'deposit':
        typeIcon = Icons.add_card_rounded;
      case 'payment_received':
        typeIcon = Icons.download_rounded;
      case 'payment_sent':
        typeIcon = Icons.send_rounded;
      case 'withdrawal':
        typeIcon = Icons.logout_rounded;
      case 'commission':
        typeIcon = Icons.percent_rounded;
      default:
        typeIcon = Icons.receipt_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.softBlack,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(typeIcon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.typeLabel,
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                ),
                if (t.description != null && t.description!.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    t.description!,
                    style: const TextStyle(color: AppColors.grey, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 3),
                Text(
                  _relDate(t.createdAt),
                  style: TextStyle(color: AppColors.grey.withValues(alpha: 0.6), fontSize: 11),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isCredit ? '+' : '-'}${_fcfx(t.type == 'payment_received' ? (t.amount as double) : t.amount)}',
                style: TextStyle(
                  color: isCredit ? AppColors.green : AppColors.red,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (t.commission != null && t.commission > 0 && t.type == 'payment_received') ...[
                const SizedBox(height: 2),
                Text(
                  'dont ${(t.commission as double).toInt()} FCFA de frais',
                  style: TextStyle(color: AppColors.red.withValues(alpha: 0.7), fontSize: 10),
                ),
              ],
            ],
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _showDeleteDialog(wallet, t),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.close_rounded, color: AppColors.grey, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  String _relDate(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 1) return "À l'instant";
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays}j';
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  String _relDateShort(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 1) return 'Maintenant';
    if (diff.inHours < 1) return '${diff.inMinutes}min';
    if (diff.inDays < 1) return '${diff.inHours}h';
    return '${diff.inDays}j';
  }

  void _showDeleteDialog(WalletProvider wallet, dynamic t) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.softBlack,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Supprimer', style: TextStyle(color: Colors.white, fontSize: 18)),
        content: const Text('Supprimer cette transaction de l\'historique ?', style: TextStyle(color: AppColors.grey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler', style: TextStyle(color: AppColors.grey, fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () {
              wallet.deleteTransaction(t.id);
              Navigator.pop(ctx);
            },
            child: const Text('Supprimer', style: TextStyle(color: AppColors.red, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog(WalletProvider wallet) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.softBlack,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Tout effacer', style: TextStyle(color: Colors.white, fontSize: 18)),
        content: const Text('Supprimer tout l\'historique des transactions ? Cette action est irréversible.', style: TextStyle(color: AppColors.grey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler', style: TextStyle(color: AppColors.grey, fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () {
              wallet.clearAllTransactions();
              Navigator.pop(ctx);
            },
            child: const Text('Tout effacer', style: TextStyle(color: AppColors.red, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _emptyHistory() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48),
      decoration: BoxDecoration(
        color: AppColors.softBlack,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        children: [
          Icon(Icons.receipt_long_rounded, size: 56, color: AppColors.grey.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          const Text('Aucune transaction', style: TextStyle(color: AppColors.grey, fontSize: 15)),
          const SizedBox(height: 6),
          Text(
            'Utilisez Dépôt, Retrait ou Payer\npour effectuer votre première opération',
            style: TextStyle(color: AppColors.grey.withValues(alpha: 0.6), fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
