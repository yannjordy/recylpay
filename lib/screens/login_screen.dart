import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  bool _obscure = true;
  String _selectedRole = 'trieur';
  String? _selectedPhoto;

  final _roles = [
    {'key': 'trieur', 'label': 'Trieur', 'icon': Icons.sort_rounded, 'desc': 'Je trie mes déchets à la source'},
    {'key': 'ramasseur', 'label': 'Ramasseur', 'icon': Icons.cleaning_services_rounded, 'desc': 'Je collecte les déchets'},
    {'key': 'livreur', 'label': 'Livreur', 'icon': Icons.local_shipping_rounded, 'desc': 'Je livre aux entreprises'},
  ];

  final _profilePhotos = [
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&h=200&q=60',
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=200&h=200&q=60',
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=200&h=200&q=60',
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&h=200&q=60',
    'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&w=200&h=200&q=60',
    'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&w=200&h=200&q=60',
    'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=200&h=200&q=60',
    'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=200&h=200&q=60',
  ];

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    final auth = context.read<AuthProvider>();
    final ok = await auth.login(
      _emailCtrl.text.trim(),
      _passwordCtrl.text,
      name: _nameCtrl.text.trim().isNotEmpty ? _nameCtrl.text.trim() : null,
      role: _selectedRole,
      photoUrl: _selectedPhoto,
    );
    if (ok && mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      backgroundColor: AppColors.dark,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              width: isDesktop ? 500 : double.infinity,
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset('assets/images/logo.png', width: 70, height: 70, fit: BoxFit.cover),
                        ),
                        const SizedBox(height: 12),
                        Text('RecycPay', style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: isDesktop ? 32 : 26)),
                        const SizedBox(height: 4),
                        const Text('Collecte, tri et recyclage au Cameroun',
                            style: TextStyle(color: AppColors.grey, fontSize: 13)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  Text('Photo de profil', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 72,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _profilePhotos.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final url = _profilePhotos[i];
                        final selected = _selectedPhoto == url;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedPhoto = url),
                          child: Container(
                            width: 64, height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: selected ? AppColors.green : Colors.transparent, width: 3),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(32),
                              child: Image.network(url, fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.person, color: AppColors.grey)),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text('Catégorie', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14)),
                  const SizedBox(height: 8),
                  Row(
                    children: _roles.map((r) {
                      final selected = _selectedRole == r['key'];
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: r['key'] == 'trieur' ? 0 : 4,
                            right: r['key'] == 'livreur' ? 0 : 4,
                          ),
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedRole = r['key'] as String),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                              decoration: BoxDecoration(
                                color: selected ? AppColors.green.withValues(alpha: 0.15) : AppColors.glassBackground,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: selected ? AppColors.green : AppColors.glassBorder, width: 1.5),
                              ),
                              child: Column(
                                children: [
                                  Icon(r['icon'] as IconData,
                                      color: selected ? AppColors.green : AppColors.grey, size: 22),
                                  const SizedBox(height: 4),
                                  Text(r['label'] as String,
                                      style: TextStyle(
                                          color: selected ? AppColors.green : Colors.white70,
                                          fontSize: 12,
                                          fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  Text('Nom d\'utilisateur',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Votre nom',
                      prefixIcon: Icon(Icons.person_rounded, color: AppColors.grey),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text('Email', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: 'exemple@email.com',
                      prefixIcon: Icon(Icons.email_rounded, color: AppColors.grey),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text('Mot de passe',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _passwordCtrl,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      hintText: '********',
                      prefixIcon: const Icon(Icons.lock_rounded, color: AppColors.grey),
                      suffixIcon: IconButton(
                        icon: Icon(_obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                            color: AppColors.grey),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (auth.error != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(auth.error!, style: const TextStyle(color: AppColors.red, fontSize: 13)),
                    ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: auth.isLoading ? null : _connect,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                        disabledBackgroundColor: AppColors.green.withValues(alpha: 0.3),
                      ),
                      child: auth.isLoading
                          ? const SizedBox(width: 20, height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Se connecter / Créer un compte',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
