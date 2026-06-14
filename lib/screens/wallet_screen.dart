import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wallet_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_container.dart';
import '../widgets/pill_button.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  bool _showWithdraw = false;
  final _amountController = TextEditingController();
  final _phoneController = TextEditingController(text: '+237');
  final _scrollController = ScrollController();
  final _historyKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    try {
      final wp = context.read<WalletProvider>();
      wp.loadBalance();
      wp.loadTransactions();
    } catch (_) {}
  }

  @override
  void dispose() {
    _amountController.dispose();
    _phoneController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToHistory() {
    final ctx = _historyKey.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    }
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

    return Container(
      color: AppColors.dark,
      child: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Portefeuille', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              GlassContainer(
                width: double.infinity,
                child: Column(
                  children: [
                    const Text('Solde disponible', style: TextStyle(color: AppColors.grey, fontSize: 14)),
                    const SizedBox(height: 8),
                    Text(
                      _fcfx(wallet.balance),
                      style: const TextStyle(color: AppColors.green, fontSize: 36, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: PillButton(
                            label: 'Retrait',
                            icon: Icons.logout_rounded,
                            onTap: () => setState(() => _showWithdraw = !_showWithdraw),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _scrollToHistory,
                            icon: const Icon(Icons.history_rounded),
                            label: const Text('Historique'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.green,
                              side: const BorderSide(color: AppColors.green, width: 1.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (_showWithdraw) _buildWithdrawForm(wallet),
              Row(
                key: _historyKey,
                children: [
                  const Text('Historique', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  if (wallet.transactions.isNotEmpty)
                    GestureDetector(
                      onTap: () => _showClearAllDialog(wallet),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: AppColors.red.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                        child: const Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.delete_sweep_rounded, color: AppColors.red, size: 14),
                          SizedBox(width: 4),
                          Text('Tout effacer', style: TextStyle(color: AppColors.red, fontSize: 11)),
                        ]),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (wallet.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (wallet.transactions.isEmpty)
                _emptyHistory()
              else
                ...wallet.transactions.map((t) => _txTile(t, wallet)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWithdrawForm(WalletProvider wallet) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.softBlack,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Retrait Mobile Money', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 16),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Numéro Mobile Money',
              labelStyle: TextStyle(color: AppColors.grey),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.glassBorder)),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.green)),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Montant',
              labelStyle: TextStyle(color: AppColors.grey),
              suffixText: 'FCFA',
              suffixStyle: TextStyle(color: AppColors.green),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.glassBorder)),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.green)),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: PillButton(label: 'Annuler', color: AppColors.softBlack, onTap: () {
                setState(() { _showWithdraw = false; _amountController.clear(); });
              })),
              const SizedBox(width: 12),
              Expanded(child: PillButton(label: 'Retirer', onTap: () async {
                final a = double.tryParse(_amountController.text);
                if (a == null || a <= 0) return;
                final ok = await wallet.requestWithdrawal(a, _phoneController.text.trim());
                if (ok && mounted) {
                  _amountController.clear();
                  setState(() => _showWithdraw = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Demande de retrait envoyée!'), backgroundColor: AppColors.green),
                  );
                }
              })),
            ],
          ),
          if (wallet.error != null) ...[
            const SizedBox(height: 8),
            Text(wallet.error!, style: const TextStyle(color: AppColors.red)),
          ],
        ],
      ),
    );
  }

  Widget _txTile(dynamic t, WalletProvider wallet) {
    final isCredit = t.type == 'deposit' || t.type == 'payment';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.softBlack, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (isCredit ? AppColors.green : AppColors.red).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                color: isCredit ? AppColors.green : AppColors.red, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.typeLabel, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(_relDate(t.createdAt), style: const TextStyle(color: AppColors.grey, fontSize: 12)),
              ],
            ),
          ),
          Text(
            '${isCredit ? '+' : '-'}${_fcfx(t.amount)}',
            style: TextStyle(color: isCredit ? AppColors.green : AppColors.red, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _showDeleteDialog(wallet, t),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(8)),
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

  void _showDeleteDialog(WalletProvider wallet, dynamic t) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.softBlack,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Supprimer', style: TextStyle(color: Colors.white)),
        content: const Text('Supprimer cette transaction de l\'historique ?', style: TextStyle(color: AppColors.grey)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler', style: TextStyle(color: AppColors.grey))),
          TextButton(
            onPressed: () {
              wallet.deleteTransaction(t.id);
              Navigator.pop(ctx);
            },
            child: const Text('Supprimer', style: TextStyle(color: AppColors.red)),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Tout effacer', style: TextStyle(color: Colors.white)),
        content: const Text('Supprimer tout l\'historique des transactions ? Cette action est irréversible.', style: TextStyle(color: AppColors.grey)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler', style: TextStyle(color: AppColors.grey))),
          TextButton(
            onPressed: () {
              wallet.clearAllTransactions();
              Navigator.pop(ctx);
            },
            child: const Text('Tout effacer', style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
  }

  Widget _emptyHistory() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.receipt_long_rounded, size: 48, color: AppColors.grey.withValues(alpha: 0.5)),
          const SizedBox(height: 12),
          const Text('Aucune transaction', style: TextStyle(color: AppColors.grey)),
        ],
      ),
    );
  }
}
