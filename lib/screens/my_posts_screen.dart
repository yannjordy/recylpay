import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/feed_provider.dart';
import '../theme/app_theme.dart';

class MyPostsScreen extends StatelessWidget {
  const MyPostsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final feed = context.watch<FeedProvider>();
    final auth = context.read<AuthProvider>();
    final myPosts = feed.posts.where((p) => p.userId == auth.user?.id).toList();

    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        backgroundColor: AppColors.dark,
        title: const Text('Mes Publications', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: myPosts.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.article_rounded, size: 64, color: AppColors.grey.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  const Text("Aucune publication", style: TextStyle(color: AppColors.grey, fontSize: 16)),
                ],
              ),
            )
          : ListView.builder(
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
                          Expanded(child: Text(post.userName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500))),
                        ],
                      ),
                      if (post.wasteTypes.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          children: post.wasteTypes.map((t) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: AppColors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                            child: Text(t, style: const TextStyle(color: AppColors.green, fontSize: 11)),
                          )).toList(),
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
            ),
    );
  }
}
