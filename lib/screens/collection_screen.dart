import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/waste_collection_model.dart';
import '../providers/auth_provider.dart';
import '../providers/collection_provider.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';
import '../utils/extensions.dart';
import '../widgets/glass_container.dart';
import '../widgets/pill_button.dart';

class CollectionScreen extends StatefulWidget {
  const CollectionScreen({super.key});

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedCategory;
  final _weightController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<CollectionProvider>().loadCollections());
  }

  @override
  void dispose() {
    _weightController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  double get _estimatedRevenue {
    if (_selectedCategory == null) return 0;
    final weight = double.tryParse(_weightController.text) ?? 0;
    final price = Constants.defaultPrices[_selectedCategory] ?? 0;
    return weight * price;
  }

  Future<void> _submit() async {
    if (_selectedCategory == null) return;
    final weight = double.tryParse(_weightController.text);
    if (weight == null || weight <= 0) return;

    final auth = context.read<AuthProvider>();
    final collection = context.read<CollectionProvider>();

    setState(() => _isSubmitting = true);

    final wasteCollection = WasteCollectionModel(
      id: const Uuid().v4(),
      userId: auth.user?.id ?? '',
      userName: auth.user?.name ?? 'Utilisateur',
      category: _selectedCategory!,
      estimatedWeight: weight,
      pricePerKg: Constants.defaultPrices[_selectedCategory] ?? 0,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      latitude: auth.user?.latitude ?? 4.0511,
      longitude: auth.user?.longitude ?? 9.7679,
      status: 'pending',
    );

    await collection.createCollection(wasteCollection);

    if (mounted) {
      setState(() {
        _isSubmitting = false;
        _selectedCategory = null;
        _weightController.clear();
        _descriptionController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Demande de collecte soumise !'),
          backgroundColor: AppColors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final collection = context.watch<CollectionProvider>();

    return Scaffold(
      backgroundColor: AppColors.dark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildForm(),
              const SizedBox(height: 24),
              _buildCollectionList(collection),
              const SizedBox(height: 32),
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
        Text(
          'Demande de Collecte',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 6),
        const Text(
          'Programmez une collecte de vos déchets recyclables',
          style: TextStyle(color: AppColors.grey, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return GlassContainer(
      width: double.infinity,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Type de déchet',
              style: TextStyle(color: AppColors.grey, fontSize: 13),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              hint: const Text(
                'Sélectionnez une catégorie',
                style: TextStyle(color: AppColors.grey, fontSize: 13),
              ),
              items: Constants.wasteCategories.map((cat) {
                final price = Constants.defaultPrices[cat] ?? 0;
                return DropdownMenuItem(
                  value: cat,
                  child: Text(
                    '$cat — ${price.toFCFA()}/kg',
                    style: const TextStyle(fontSize: 13),
                  ),
                );
              }).toList(),
              onChanged: (v) => setState(() => _selectedCategory = v),
              decoration: _inputDeco(),
              style: const TextStyle(color: Colors.white, fontSize: 13),
              dropdownColor: AppColors.softBlack,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: _inputDeco(hint: 'Poids estimé (kg)'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: _inputDeco(
                hint: 'Adresse ou description (optionnel)',
              ),
            ),
            if (_estimatedRevenue > 0) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Revenu estimé',
                      style: TextStyle(color: AppColors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _estimatedRevenue.toFCFA(),
                      style: const TextStyle(
                        color: AppColors.green,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            PillButton(
              label: 'Soumettre',
              icon: Icons.send_rounded,
              width: double.infinity,
              isLoading: _isSubmitting,
              onTap: _submit,
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDeco({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.grey, fontSize: 13),
      filled: true,
      fillColor: AppColors.softBlack,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }

  Widget _buildCollectionList(CollectionProvider collection) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Mes collectes', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.green.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${collection.collections.length}',
                style: const TextStyle(
                  color: AppColors.green,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (collection.isLoading)
          const Center(child: CircularProgressIndicator())
        else if (collection.collections.isEmpty)
          _buildEmptyState()
        else
          ...collection.collections.map((c) => _buildCollectionCard(c)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.recycling_rounded,
            size: 48,
            color: AppColors.grey.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          const Text(
            'Aucune collecte pour le moment',
            style: TextStyle(color: AppColors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionCard(WasteCollectionModel c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.softBlack,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  c.category,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              _statusBadge(c.status),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _infoChip(Icons.scale_rounded, '${c.estimatedWeight} kg'),
              const SizedBox(width: 12),
              _infoChip(Icons.monetization_on_rounded, c.calculatedAmount.toFCFA()),
              const SizedBox(width: 12),
              _infoChip(Icons.access_time_rounded, c.createdAt.toRelative()),
            ],
          ),
          if (c.description != null && c.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              c.description!,
              style: const TextStyle(color: AppColors.grey, fontSize: 12),
            ),
          ],
          const SizedBox(height: 12),
          if (c.status == 'pending')
            SizedBox(
              width: double.infinity,
              child: PillButton(
                label: 'Annuler',
                icon: Icons.close_rounded,
                color: AppColors.red,
                onTap: () => _confirmCancel(c),
              ),
            )
          else if (c.status == 'accepted' || c.status == 'in_progress')
            SizedBox(
              width: double.infinity,
              child: PillButton(
                label: 'Valider le poids',
                icon: Icons.check_rounded,
                color: AppColors.green,
                onTap: () => _showWeightDialog(c),
              ),
            ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _statusLabel(status),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return AppColors.yellow;
      case 'accepted':
        return AppColors.green;
      case 'in_progress':
        return AppColors.blue;
      case 'completed':
        return AppColors.grey;
      case 'paid':
        return const Color(0xFFFFD700);
      case 'cancelled':
        return AppColors.red;
      default:
        return AppColors.grey;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'En attente';
      case 'accepted':
        return 'Acceptée';
      case 'in_progress':
        return 'En cours';
      case 'completed':
        return 'Terminée';
      case 'paid':
        return 'Payée';
      case 'cancelled':
        return 'Annulée';
      default:
        return status;
    }
  }

  Widget _infoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.grey),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: AppColors.grey, fontSize: 11)),
      ],
    );
  }

  void _confirmCancel(WasteCollectionModel c) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.softBlack,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Annuler la collecte',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Voulez-vous vraiment annuler cette demande de collecte ?',
          style: TextStyle(color: AppColors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Non', style: TextStyle(color: AppColors.grey)),
          ),
          TextButton(
            onPressed: () {
              context.read<CollectionProvider>().cancelCollection(c.id);
              Navigator.pop(ctx);
            },
            child: const Text(
              'Oui, annuler',
              style: TextStyle(color: AppColors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showWeightDialog(WasteCollectionModel c) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.softBlack,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Valider le poids',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Entrez le poids réel collecté :',
              style: TextStyle(color: AppColors.grey, fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Poids (kg)',
                hintStyle: const TextStyle(color: AppColors.grey),
                filled: true,
                fillColor: AppColors.dark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Annuler',
              style: TextStyle(color: AppColors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              final weight = double.tryParse(controller.text);
              if (weight == null || weight <= 0) return;
              context.read<CollectionProvider>().validateWeight(c.id, weight);
              Navigator.pop(ctx);
            },
            child: const Text(
              'Valider',
              style: TextStyle(color: AppColors.green),
            ),
          ),
        ],
      ),
    );
  }
}
