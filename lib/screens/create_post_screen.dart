import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/post_model.dart';
import '../providers/auth_provider.dart';
import '../providers/feed_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/pill_button.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Text(
                'Publications',
                style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            TabBar(
              controller: _tabController,
              indicatorColor: AppColors.green,
              labelColor: AppColors.green,
              unselectedLabelColor: AppColors.grey,
              tabs: const [
                Tab(text: 'Comment ça marche'),
                Tab(text: 'Nouvelle'),
                Tab(text: 'Mes publications'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildHowItWorks(),
                  _CreatePostForm(onCreated: () => _tabController.animateTo(2)),
                  _buildMyPosts(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHowItWorks() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoCard(
            Icons.photo_camera_rounded,
            '1. Prends une photo',
            'Photographie les déchets que tu souhaites partager (plastique, métal, carton, etc.)',
            AppColors.green,
          ),
          const SizedBox(height: 12),
          _infoCard(
            Icons.description_rounded,
            '2. Décris',
            'Ajoute une description et sélectionne les types de déchets pour mieux les identifier',
            AppColors.yellow,
          ),
          const SizedBox(height: 12),
          _infoCard(
            Icons.publish_rounded,
            '3. Publie',
            'Partage ta publication avec la communauté RecycPay',
            AppColors.blue,
          ),
          const SizedBox(height: 12),
          _infoCard(
            Icons.recycling_rounded,
            '4. Reçois des points',
            'Gagne des points éco à chaque publication et contribute à un Cameroun plus propre',
            AppColors.green,
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.green.withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.lightbulb_rounded, color: AppColors.yellow, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Plus tu publies, plus tu gagnes de points éco. Les points peuvent être échangés contre des récompenses !',
                    style: TextStyle(color: AppColors.white, fontSize: 13, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(IconData icon, String title, String desc, Color color) {
    return Container(
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
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(color: AppColors.grey, fontSize: 13, height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyPosts() {
    final feed = context.watch<FeedProvider>();
    final auth = context.read<AuthProvider>();
    final myPosts = feed.posts.where((p) => p.userId == auth.user?.id).toList();

    if (myPosts.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.article_rounded, size: 64, color: AppColors.grey.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            const Text("Tu n'as pas encore de publication", style: TextStyle(color: AppColors.grey, fontSize: 16)),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => _tabController.animateTo(1),
              child: const Text('Créer une publication', style: TextStyle(color: AppColors.green)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: myPosts.length,
      itemBuilder: (_, i) {
        final post = myPosts[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
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
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.green.withValues(alpha: 0.15),
                    ),
                    child: const Icon(Icons.person_rounded, color: AppColors.green, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(post.userName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14)),
                        const SizedBox(height: 2),
                        Text(post.userUniqueId, style: const TextStyle(color: AppColors.grey, fontSize: 11)),
                      ],
                    ),
                  ),
                  const Icon(Icons.more_horiz_rounded, color: AppColors.grey, size: 20),
                ],
              ),
              if (post.wasteTypes.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: post.wasteTypes.map((t) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(t, style: const TextStyle(color: AppColors.green, fontSize: 11)),
                  )).toList(),
                ),
              ],
              if (post.imageUrl != null && post.imageUrl!.isNotEmpty) ...[
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: post.imageUrl!.startsWith('http')
                      ? Image.network(post.imageUrl!, fit: BoxFit.cover, height: 160, width: double.infinity)
                      : Image.file(File(post.imageUrl!), fit: BoxFit.cover, height: 160, width: double.infinity, errorBuilder: (_, __, ___) => const SizedBox.shrink()),
                ),
              ],
              if (post.description != null) ...[
                const SizedBox(height: 8),
                Text(post.description!, style: const TextStyle(color: Colors.white, fontSize: 13)),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _CreatePostForm extends StatefulWidget {
  final VoidCallback onCreated;
  const _CreatePostForm({required this.onCreated});

  @override
  State<_CreatePostForm> createState() => _CreatePostFormState();
}

class _CreatePostFormState extends State<_CreatePostForm> {
  final _descController = TextEditingController();
  Set<String> _selectedWasteTypes = {};
  String? _imagePath;

  final _wasteTypes = [
    'Fer/Métal', 'Aluminium', 'Plastique PET', 'Plastique PEHD',
    'Carton', 'Verre', 'Papier', 'Électronique',
    'Pneu', 'Huile usagée', 'Bois', 'Mixte',
  ];

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1024);
    if (img != null) setState(() => _imagePath = img.path);
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.camera, maxWidth: 1024);
    if (img != null) setState(() => _imagePath = img.path);
  }

  void _submit() {
    if (_selectedWasteTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sélectionne au moins un type de déchet'), backgroundColor: AppColors.red),
      );
      return;
    }
    final auth = context.read<AuthProvider>();
    final feed = context.read<FeedProvider>();

    feed.addPost(PostModel(
      id: const Uuid().v4(),
      userId: auth.user?.id ?? '',
      userName: auth.user?.name ?? '',
      userUniqueId: auth.user?.uniqueId ?? '',
      userPhotoUrl: auth.user?.photoUrl,
      imageUrl: _imagePath ?? '',
      description: _descController.text.isNotEmpty ? _descController.text : null,
      wasteTypes: _selectedWasteTypes.toList(),
      createdAt: DateTime.now(),
    ));

    setState(() {
      _descController.clear();
      _selectedWasteTypes.clear();
      _imagePath = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Publication partagée! +10 points éco'), backgroundColor: AppColors.green),
    );
    widget.onCreated();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Qu'est-ce que tu partages ?", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text('Ajoute une photo et décris les déchets', style: TextStyle(color: AppColors.grey, fontSize: 14)),
          const SizedBox(height: 20),

          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.softBlack,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.glassBorder),
                image: _imagePath != null
                    ? DecorationImage(image: FileImage(File(_imagePath!)), fit: BoxFit.cover)
                    : null,
              ),
              child: _imagePath == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.image_rounded, size: 48, color: AppColors.grey),
                        const SizedBox(height: 8),
                        const Text('Ajoute une photo', style: TextStyle(color: AppColors.grey, fontSize: 16)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _imgBtn(Icons.photo_library_rounded, 'Galerie', _pickImage),
                            const SizedBox(width: 16),
                            _imgBtn(Icons.camera_alt_rounded, 'Caméra', _takePhoto),
                          ],
                        ),
                      ],
                    )
                  : Stack(
                      children: [
                        Positioned(
                          top: 8, right: 8,
                          child: GestureDetector(
                            onTap: () => setState(() => _imagePath = null),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                              child: const Icon(Icons.close_rounded, color: Colors.white, size: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),

          const SizedBox(height: 20),
          TextField(
            controller: _descController,
            maxLines: 3,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Décris ce que tu partages (quantité, état, etc.)...',
              hintStyle: TextStyle(color: AppColors.grey),
              filled: true,
              fillColor: AppColors.softBlack,
              border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.all(Radius.circular(16))),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Types de déchets', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: _wasteTypes.map((type) {
              final isSelected = _selectedWasteTypes.contains(type);
              return GestureDetector(
                onTap: () => setState(() {
                  isSelected ? _selectedWasteTypes.remove(type) : _selectedWasteTypes.add(type);
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: isSelected ? const LinearGradient(colors: [AppColors.green, Color(0xFF27AE60)]) : null,
                    color: isSelected ? null : AppColors.softBlack,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isSelected ? AppColors.green : AppColors.glassBorder),
                  ),
                  child: Text(type, style: TextStyle(
                    color: isSelected ? AppColors.white : AppColors.grey,
                    fontSize: 13, fontWeight: FontWeight.w500,
                  )),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          PillButton(width: double.infinity, label: 'Publier', onTap: _submit),
        ],
      ),
    );
  }

  Widget _imgBtn(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.green.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: AppColors.green, size: 24),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 11)),
        ],
      ),
    );
  }
}
