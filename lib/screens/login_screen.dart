import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/pill_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _nameController = TextEditingController(text: 'Jordan');
  String _selectedRole = 'collecteur';
  File? _profileImage;
  Set<String> _selectedTypes = {};

  final _wasteTypes = [
    'Fer/Métal', 'Aluminium', 'Plastique PET', 'Plastique PEHD',
    'Carton', 'Verre', 'Papier', 'Électronique',
    'Pneu', 'Huile usagée', 'Bois', 'Textile',
    'Déchets organiques', 'Gravats',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, maxWidth: 256);
    if (image != null) setState(() => _profileImage = File(image.path));
  }

  void _enterApp() {
    final auth = context.read<AuthProvider>();
    final name = _nameController.text.trim().isEmpty ? 'Utilisateur' : _nameController.text.trim();
    final types = _selectedTypes.isEmpty ? ['Tout'] : _selectedTypes.toList();

    final mockUser = UserModel(
      id: const Uuid().v4(),
      phone: '+237690000000',
      name: name,
      role: _selectedRole,
      balance: 25000,
      rating: 4.5,
      completedMissions: 12,
      isOnline: true,
      latitude: 4.0511,
      longitude: 9.7679,
      photoUrl: null,
      collectedTypes: types,
    );

    auth.setMockUser(mockUser);
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text('Bienvenue', style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 8),
              Text(
                'Mode test - entre directement',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.grey),
              ),
              const SizedBox(height: 32),
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      Container(
                        width: 96, height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.softBlack,
                          border: Border.all(color: AppColors.green, width: 2),
                          image: _profileImage != null
                              ? DecorationImage(image: FileImage(_profileImage!), fit: BoxFit.cover)
                              : null,
                        ),
                        child: _profileImage == null
                            ? const Icon(Icons.person_rounded, color: AppColors.grey, size: 40)
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
              const SizedBox(height: 24),
              Text('Ton nom', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(hintText: 'Entre ton nom'),
              ),
              const SizedBox(height: 20),
              Text('Ton rôle', style: Theme.of(context).textTheme.titleMedium),
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
              Text('Types de déchets', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text('Tout sélectionner = collecte tous les types',
                  style: const TextStyle(color: AppColors.grey, fontSize: 12)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: _wasteTypes.map((type) {
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
              PillButton(
                width: double.infinity,
                label: 'Entrer dans l\'app',
                onTap: _enterApp,
              ),
            ],
          ),
        ),
      ),
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
