import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/post_model.dart';
import '../providers/auth_provider.dart';
import '../providers/feed_provider.dart';
import '../theme/app_theme.dart';
import '../utils/extensions.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  void initState() {
    super.initState();
    context.read<FeedProvider>().loadPosts();
  }

  @override
  Widget build(BuildContext context) {
    final feed = context.watch<FeedProvider>();

    return Scaffold(
      backgroundColor: AppColors.dark,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Text('Communauté', style: Theme.of(context).textTheme.headlineLarge),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.green.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.people_rounded, color: AppColors.green, size: 22),
                    ),
                  ],
                ),
              ),
            ),
            if (feed.posts.isEmpty && !feed.isLoading)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.dynamic_feed_rounded, size: 64, color: AppColors.grey.withValues(alpha: 0.4)),
                      const SizedBox(height: 16),
                      Text('Aucune publication', style: TextStyle(color: AppColors.grey)),
                      const SizedBox(height: 8),
                      Text('Sois le premier à partager!', style: TextStyle(color: AppColors.grey, fontSize: 13)),
                    ],
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildPostCard(feed.posts[index], feed),
                  childCount: feed.posts.length,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _sharePost(BuildContext ctx, PostModel post) {
    final text = '${post.description ?? "Collecte de déchets"} — RecycPay';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(ctx).showSnackBar(
      const SnackBar(content: Text('Texte copié! Partage-le où tu veux'), backgroundColor: AppColors.green, duration: Duration(seconds: 2)),
    );
  }

  Widget _buildPostCard(PostModel post, FeedProvider feed) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.softBlack,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.green.withValues(alpha: 0.15),
                    image: post.userPhotoUrl != null
                        ? DecorationImage(image: NetworkImage(post.userPhotoUrl!), fit: BoxFit.cover)
                        : null,
                  ),
                  child: post.userPhotoUrl == null
                      ? const Icon(Icons.person_rounded, color: AppColors.green, size: 20)
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.userName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      Text(post.userUniqueId, style: const TextStyle(color: AppColors.grey, fontSize: 11)),
                    ],
                  ),
                ),
                Text(post.createdAt.toRelative(), style: const TextStyle(color: AppColors.grey, fontSize: 11)),
              ],
            ),
          ),
          if (post.description != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text(post.description!, style: const TextStyle(fontSize: 14)),
            ),
          if (post.wasteTypes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Wrap(
                spacing: 6, runSpacing: 6,
                children: post.wasteTypes.map((t) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(t, style: const TextStyle(color: AppColors.green, fontSize: 11)),
                )).toList(),
              ),
            ),
          ],
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.zero, bottom: Radius.circular(0)),
            child: post.imageUrl.isNotEmpty && post.imageUrl.startsWith('http')
                ? Image.network(
                    post.imageUrl,
                    height: 260,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _imagePlaceholder(),
                  )
                : _imagePlaceholder(),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                _actionButton(
                  Icons.favorite_rounded,
                  '${post.likes}',
                  post.isLiked ? AppColors.red : AppColors.grey,
                  () => feed.toggleLike(post.id),
                ),
                const SizedBox(width: 20),
                _actionButton(
                  Icons.chat_bubble_rounded,
                  '${post.commentsCount}',
                  AppColors.grey,
                  () => _showComments(post),
                ),
                const Spacer(),
                _actionButton(
                  Icons.share_rounded,
                  'Partager',
                  AppColors.grey,
                  () => _sharePost(context, post),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      height: 260,
      color: AppColors.dark,
      child: const Center(
        child: Icon(Icons.broken_image_rounded, color: AppColors.grey, size: 48),
      ),
    );
  }

  void _showComments(PostModel post) {
    final commentController = TextEditingController();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.softBlack,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: SizedBox(
            height: 400,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Text('Commentaires', style: Theme.of(ctx).textTheme.titleMedium),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.pop(ctx),
                        child: const Icon(Icons.close_rounded, color: AppColors.grey),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: AppColors.glassBorder),
                Expanded(
                  child: Consumer<FeedProvider>(
                    builder: (ctx, feedProv, _) {
                      final cmts = feedProv.getComments(post.id);
                      if (cmts.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.chat_bubble_outline_rounded, size: 40, color: AppColors.grey.withValues(alpha: 0.5)),
                              const SizedBox(height: 8),
                              Text('Soyez le premier à commenter', style: TextStyle(color: AppColors.grey)),
                            ],
                          ),
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: cmts.length,
                        itemBuilder: (_, i) {
                          final c = cmts[i];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 32, height: 32,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.green.withValues(alpha: 0.15),
                                    image: c.userPhotoUrl != null
                                        ? DecorationImage(image: NetworkImage(c.userPhotoUrl!), fit: BoxFit.cover)
                                        : null,
                                  ),
                                  child: c.userPhotoUrl == null
                                      ? Icon(Icons.person_rounded, color: AppColors.green, size: 16)
                                      : null,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(c.userName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                      const SizedBox(height: 2),
                                      Text(c.content, style: const TextStyle(fontSize: 13, color: AppColors.white)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: AppColors.glassBorder)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: commentController,
                          decoration: const InputDecoration(
                            hintText: 'Ajoute un commentaire...',
                            border: InputBorder.none,
                            filled: false,
                            contentPadding: EdgeInsets.symmetric(horizontal: 12),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (commentController.text.trim().isNotEmpty) {
                            final auth = context.read<AuthProvider>();
                            final feedProv = context.read<FeedProvider>();
                            feedProv.addComment(post.id, CommentModel(
                              id: DateTime.now().millisecondsSinceEpoch.toString(),
                              postId: post.id,
                              userId: auth.user?.id ?? '',
                              userName: auth.user?.name ?? '',
                              userPhotoUrl: auth.user?.photoUrl,
                              content: commentController.text.trim(),
                            ));
                            commentController.clear();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.green,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
