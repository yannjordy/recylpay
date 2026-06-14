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
  final _referralCtrl = TextEditingController();
  bool _obscure = true;
  String _selectedRole = 'trieur';
  String? _selectedPhoto;

  final _roles = [
    {'key': 'trieur', 'label': 'Trieur', 'icon': Icons.sort_rounded, 'desc': 'Je trie mes déchets à la source'},
    {'key': 'ramasseur', 'label': 'Ramasseur', 'icon': Icons.cleaning_services_rounded, 'desc': 'Je collecte les déchets'},
    {'key': 'livreur', 'label': 'Livreur', 'icon': Icons.local_shipping_rounded, 'desc': 'Je livre aux entreprises'},
  ];

  final _profilePhotos = [
    'https://images.unsplash.com/photo-1769636929354-59165ba73c7e?auto=format&fit=crop&w=200&h=200&q=60',
    'https://images.unsplash.com/photo-1743871698163-a2e470d8eac7?auto=format&fit=crop&w=200&h=200&q=60',
    'https://images.unsplash.com/photo-1743866356139-579e0df74e55?auto=format&fit=crop&w=200&h=200&q=60',
    'https://images.unsplash.com/photo-1710117045399-0fab00350f4d?auto=format&fit=crop&w=200&h=200&q=60',
    'https://images.unsplash.com/photo-1766107349536-c6de9ab38dcd?auto=format&fit=crop&w=200&h=200&q=60',
    'https://images.unsplash.com/photo-1770396528756-d463cc7f0a8a?auto=format&fit=crop&w=200&h=200&q=60',
    'https://images.unsplash.com/photo-1745690720220-24e337e571c7?auto=format&fit=crop&w=200&h=200&q=60',
    'https://images.unsplash.com/photo-1759300063434-482e4d65f9bf?auto=format&fit=crop&w=200&h=200&q=60',
  ];

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _nameCtrl.dispose();
    _referralCtrl.dispose();
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
      referralCode: _referralCtrl.text.trim().isNotEmpty ? _referralCtrl.text.trim() : null,
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
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.green.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.green.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.people_alt_rounded, size: 16, color: AppColors.green),
                            const SizedBox(width: 8),
                            const Text('Code parrain (optionnel)',
                                style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text('Si tu as un code, entre-le pour que ton parrain gagne 500 FCFA',
                            style: TextStyle(color: AppColors.grey, fontSize: 11)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _referralCtrl,
                          textCapitalization: TextCapitalization.characters,
                          decoration: const InputDecoration(
                            hintText: 'Ex: JOH123',
                            hintStyle: TextStyle(fontSize: 13),
                            prefixIcon: Icon(Icons.card_giftcard_rounded, color: AppColors.grey, size: 20),
                            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                          ),
                        ),
                      ],
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
