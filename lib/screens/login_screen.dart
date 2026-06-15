import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';
import '../utils/responsive.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  int _tabIndex = 0;
  int _regStep = 1;

  // Login
  final _loginEmailCtrl = TextEditingController();
  final _loginPassCtrl = TextEditingController();
  bool _obscureLogin = true;

  // Register step 1
  final _regPhoneCtrl = TextEditingController(text: '+237');
  final _regEmailCtrl = TextEditingController();
  final _regPassCtrl = TextEditingController();
  bool _obscureReg = true;

  // Register step 2
  String _selectedRole = 'trieur';
  String? _profilePhotoPath;
  final Set<String> _selectedMaterials = {};

  final _roles = [
    {'key': 'trieur', 'label': 'Trieur', 'icon': Icons.sort_rounded, 'desc': 'Je trie mes déchets à la source'},
    {'key': 'ramasseur', 'label': 'Ramasseur', 'icon': Icons.cleaning_services_rounded, 'desc': 'Je collecte les déchets'},
    {'key': 'livreur', 'label': 'Livreur', 'icon': Icons.local_shipping_rounded, 'desc': 'Je livre aux entreprises'},
  ];

  @override
  void dispose() {
    _loginEmailCtrl.dispose();
    _loginPassCtrl.dispose();
    _regPhoneCtrl.dispose();
    _regEmailCtrl.dispose();
    _regPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_loginEmailCtrl.text.trim().isEmpty || _loginPassCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Remplis tous les champs'), backgroundColor: AppColors.red),
      );
      return;
    }
    final auth = context.read<AuthProvider>();
    final ok = await auth.login(_loginEmailCtrl.text.trim(), _loginPassCtrl.text);
    if (ok && mounted) Navigator.pushReplacementNamed(context, '/home');
  }

  Future<void> _register() async {
    if (_profilePhotoPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ajoute une photo de profil'), backgroundColor: AppColors.red),
      );
      return;
    }
    if (_selectedMaterials.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sélectionne au moins un matériau à recycler'), backgroundColor: AppColors.red),
      );
      return;
    }
    final name = _regEmailCtrl.text.trim().split('@').first;
    final auth = context.read<AuthProvider>();
    final ok = await auth.login(
      _regEmailCtrl.text.trim(),
      _regPassCtrl.text,
      name: name,
      role: _selectedRole,
      photoUrl: _profilePhotoPath,
    );
    if (ok && mounted) Navigator.pushReplacementNamed(context, '/home');
  }

  Future<void> _pickProfilePhoto() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery, maxWidth: 512);
    if (img != null) setState(() => _profilePhotoPath = img.path);
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
                children: [
                  _buildLogo(),
                  const SizedBox(height: 24),
                  _buildTabSelector(),
                  const SizedBox(height: 28),
                  if (_tabIndex == 0) _buildLoginForm(auth),
                  if (_tabIndex == 1) _buildRegisterForm(auth),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.asset('assets/images/logo.png', width: 70, height: 70, fit: BoxFit.cover),
        ),
        const SizedBox(height: 12),
        const Text('RecycPay', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
        const SizedBox(height: 4),
        const Text('Collecte, tri et recyclage au Cameroun', style: TextStyle(color: AppColors.grey, fontSize: 13)),
      ],
    );
  }

  Widget _buildTabSelector() {
    final tabs = ['Connexion', 'Inscription'];
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.softBlack,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: List.generate(2, (i) {
          final active = _tabIndex == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() { _tabIndex = i; _regStep = 1; }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: active ? AppColors.green.withValues(alpha: 0.15) : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(active ? Icons.check_circle_rounded : Icons.circle_outlined,
                        color: active ? AppColors.green : AppColors.grey, size: 16),
                    const SizedBox(width: 8),
                    Text(tabs[i], style: TextStyle(
                      color: active ? AppColors.green : AppColors.grey,
                      fontSize: 15, fontWeight: FontWeight.w600,
                    )),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildLoginForm(AuthProvider auth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Email', style: TextStyle(color: AppColors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: _loginEmailCtrl,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          decoration: const InputDecoration(hintText: 'exemple@email.com', prefixIcon: Icon(Icons.email_rounded, color: AppColors.grey)),
        ),
        const SizedBox(height: 16),
        const Text('Mot de passe', style: TextStyle(color: AppColors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: _loginPassCtrl,
          obscureText: _obscureLogin,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          decoration: InputDecoration(
            hintText: '********',
            prefixIcon: const Icon(Icons.lock_rounded, color: AppColors.grey),
            suffixIcon: IconButton(
              icon: Icon(_obscureLogin ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: AppColors.grey),
              onPressed: () => setState(() => _obscureLogin = !_obscureLogin),
            ),
          ),
        ),
        if (auth.error != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Text(auth.error!, style: const TextStyle(color: AppColors.red, fontSize: 12)),
          ),
        ],
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: auth.isLoading ? null : _login,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.green,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
              disabledBackgroundColor: AppColors.green.withValues(alpha: 0.3),
            ),
            child: auth.isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Se connecter', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterForm(AuthProvider auth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _stepDot(1, 'Compte'),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Icon(Icons.chevron_right_rounded, color: AppColors.grey, size: 18)),
            _stepDot(2, 'Profil'),
          ],
        ),
        const SizedBox(height: 24),
        if (_regStep == 1) _buildRegStep1(auth),
        if (_regStep == 2) _buildRegStep2(auth),
      ],
    );
  }

  Widget _stepDot(int step, String label) {
    final active = _regStep == step;
    final done = step < _regStep;
    return GestureDetector(
      onTap: done || active ? null : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              color: active || done ? AppColors.green : AppColors.grey.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: done
                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                  : Text('$step', style: TextStyle(color: active || done ? Colors.white : AppColors.grey, fontSize: 13, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: active || done ? AppColors.green : AppColors.grey, fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildRegStep1(AuthProvider auth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Numéro de téléphone', style: TextStyle(color: AppColors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: _regPhoneCtrl,
          keyboardType: TextInputType.phone,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          decoration: const InputDecoration(prefixIcon: Icon(Icons.phone_rounded, color: AppColors.grey)),
        ),
        const SizedBox(height: 16),
        const Text('Email', style: TextStyle(color: AppColors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: _regEmailCtrl,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          decoration: const InputDecoration(hintText: 'exemple@email.com', prefixIcon: Icon(Icons.email_rounded, color: AppColors.grey)),
        ),
        const SizedBox(height: 16),
        const Text('Mot de passe', style: TextStyle(color: AppColors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: _regPassCtrl,
          obscureText: _obscureReg,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          decoration: InputDecoration(
            hintText: '********',
            prefixIcon: const Icon(Icons.lock_rounded, color: AppColors.grey),
            suffixIcon: IconButton(
              icon: Icon(_obscureReg ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: AppColors.grey),
              onPressed: () => setState(() => _obscureReg = !_obscureReg),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Text('Étape 1/2', style: TextStyle(color: AppColors.grey.withValues(alpha: 0.6), fontSize: 12)),
              const Spacer(),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(value: 0.5, backgroundColor: Colors.white.withValues(alpha: 0.06), valueColor: const AlwaysStoppedAnimation(AppColors.green), minHeight: 6),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              if (_regEmailCtrl.text.trim().isEmpty || _regPassCtrl.text.length < 3) return;
              setState(() => _regStep = 2);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.green,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            ),
            child: const Text('Suivant', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildRegStep2(AuthProvider auth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Photo de profil', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickProfilePhoto,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: AppColors.softBlack,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.glassBorder, style: BorderStyle.solid),
            ),
            child: Column(
              children: [
                if (_profilePhotoPath != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.file(
                      File(_profilePhotoPath!),
                      width: 80, height: 80, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.person, color: AppColors.grey, size: 40),
                    ),
                  )
                else
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: const Icon(Icons.camera_alt_rounded, color: AppColors.green, size: 36),
                  ),
                const SizedBox(height: 12),
                Text(
                  _profilePhotoPath != null ? 'Modifier la photo' : 'Ajouter une photo',
                  style: const TextStyle(color: AppColors.green, fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text('Matériaux à recycler', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: Constants.wasteCategories.map((m) {
            final selected = _selectedMaterials.contains(m);
            return GestureDetector(
              onTap: () => setState(() {
                if (selected) { _selectedMaterials.remove(m); } else { _selectedMaterials.add(m); }
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? AppColors.green.withValues(alpha: 0.15) : AppColors.softBlack,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: selected ? AppColors.green : AppColors.glassBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                        color: selected ? AppColors.green : AppColors.grey, size: 16),
                    const SizedBox(width: 6),
                    Text(m, style: TextStyle(color: selected ? AppColors.green : AppColors.grey, fontSize: 13)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        const Text('Type d\'utilisateur', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Row(
          children: _roles.map((r) {
            final selected = _selectedRole == r['key'];
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: r['key'] == 'trieur' ? 0 : 4, right: r['key'] == 'livreur' ? 0 : 4),
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
                        Icon(r['icon'] as IconData, color: selected ? AppColors.green : AppColors.grey, size: 22),
                        const SizedBox(height: 4),
                        Text(r['label'] as String, style: TextStyle(
                          color: selected ? AppColors.green : Colors.white70,
                          fontSize: 12, fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                        )),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        if (auth.error != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Text(auth.error!, style: const TextStyle(color: AppColors.red, fontSize: 12)),
          ),
        ],
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Text('Étape 2/2', style: TextStyle(color: AppColors.grey.withValues(alpha: 0.6), fontSize: 12)),
              const Spacer(),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(value: 1.0, backgroundColor: Colors.white.withValues(alpha: 0.06), valueColor: const AlwaysStoppedAnimation(AppColors.green), minHeight: 6),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _regStep = 1),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.grey,
                  side: const BorderSide(color: AppColors.glassBorder),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                ),
                child: const Text('Retour', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: auth.isLoading ? null : _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                  disabledBackgroundColor: AppColors.green.withValues(alpha: 0.3),
                ),
                child: auth.isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Créer mon compte', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
