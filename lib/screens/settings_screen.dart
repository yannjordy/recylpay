import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';
import '../widgets/pill_button.dart';
import '../utils/responsive.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _nameController;
  String _selectedRole = 'collecteur';
  Set<String> _selectedTypes = {};
  File? _newPhoto;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _selectedRole = user?.role ?? 'collecteur';
    _selectedTypes = Set.from(user?.collectedTypes ?? []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickNewPhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, maxWidth: 512);
    if (image != null) {
      setState(() => _newPhoto = File(image.path));
    }
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final auth = context.read<AuthProvider>();
    final data = <String, dynamic>{
      'name': _nameController.text.trim(),
      'role': _selectedRole,
      'collected_types': _selectedTypes.isEmpty ? ['Tout'] : _selectedTypes.toList(),
    };
    if (_newPhoto != null) {
      data['photo_url'] = _newPhoto!.path;
    }
    await auth.updateProfile(
      name: data['name'] as String?,
      role: data['role'] as String?,
      collectedTypes: data['collected_types'] != null ? List<String>.from(data['collected_types'] as List) : null,
    );
    setState(() => _isSaving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil mis à jour!'), backgroundColor: AppColors.green),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        title: const Text('Paramètres'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: DesktopScaffold(child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickNewPhoto,
                child: Stack(
                  children: [
                    Container(
                      width: 96, height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.softBlack,
                        border: Border.all(color: AppColors.green, width: 3),
                        image: _newPhoto != null
                            ? DecorationImage(image: FileImage(_newPhoto!), fit: BoxFit.cover)
                            : (user?.photoUrl != null
                                ? DecorationImage(image: NetworkImage(user!.photoUrl!), fit: BoxFit.cover)
                                : null),
                      ),
                      child: user?.photoUrl == null && _newPhoto == null
                          ? const Icon(Icons.person_rounded, color: AppColors.green, size: 40)
                          : null,
                    ),
                    Positioned(
                      bottom: 0, right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.dark, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                user?.uniqueId ?? '',
                style: const TextStyle(color: AppColors.grey, fontSize: 13),
              ),
            ),
            Center(
              child: Text(
                'ID unique - non modifiable',
                style: const TextStyle(color: AppColors.grey, fontSize: 11),
              ),
            ),
            const SizedBox(height: 32),
            Text('Nom complet', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(hintText: 'Ton nom'),
            ),
            const SizedBox(height: 20),
            Text('Rôle', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                _roleChip('collecteur', Icons.person_search_rounded),
                const SizedBox(width: 8),
                _roleChip('trieur', Icons.sort_rounded),
                const SizedBox(width: 8),
                _roleChip('livreur', Icons.local_shipping_rounded),
              ],
            ),
            const SizedBox(height: 20),
            Text('Types de déchets collectés', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: Constants.wasteCategories.map((type) {
                final isSelected = _selectedTypes.contains(type);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      isSelected ? _selectedTypes.remove(type) : _selectedTypes.add(type);
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.green.withValues(alpha: 0.2) : AppColors.softBlack,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isSelected ? AppColors.green : Colors.transparent),
                    ),
                    child: Text(type, style: TextStyle(
                      color: isSelected ? AppColors.green : AppColors.grey,
                      fontSize: 13,
                    )),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            // Referral code display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.green.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.green.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.card_giftcard_rounded, color: AppColors.green, size: 20),
                      const SizedBox(width: 8),
                      const Text('Code parrainage', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      if (user?.referralCode != null) {
                        Clipboard.setData(ClipboardData(text: user!.referralCode!));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Code copié !'), backgroundColor: AppColors.green, duration: Duration(seconds: 2)),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.dark,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.green.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(user?.referralCode ?? '------',
                              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 3)),
                          const SizedBox(width: 10),
                          const Icon(Icons.copy_rounded, color: AppColors.green, size: 18),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text('Partage ce code avec tes amis. Tu gagnes 5 points par inscription.',
                      style: TextStyle(color: AppColors.grey, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            PillButton(
              width: double.infinity,
              label: 'Enregistrer',
              isLoading: _isSaving,
              onTap: _save,
            ),
          ],
        ),
      )),
    );
  }

  Widget _roleChip(String role, IconData icon) {
    final isSelected = _selectedRole == role;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.green.withValues(alpha: 0.2) : AppColors.softBlack,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.green : Colors.transparent),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: isSelected ? AppColors.green : AppColors.grey),
            const SizedBox(width: 6),
            Text(
              role == 'collecteur' ? 'Collecteur' : role == 'trieur' ? 'Trieur' : 'Livreur',
              style: TextStyle(
                color: isSelected ? AppColors.green : AppColors.grey,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
