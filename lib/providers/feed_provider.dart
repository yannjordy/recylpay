import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../services/mock_data.dart';

class FeedProvider extends ChangeNotifier {
  List<PostModel> _posts = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';

  List<PostModel> get posts {
    if (_searchQuery.isEmpty) return _posts;
    final q = _searchQuery.toLowerCase();
    return _posts.where((p) =>
      p.userName.toLowerCase().contains(q) ||
      (p.description?.toLowerCase().contains(q) ?? false) ||
      p.wasteTypes.any((t) => t.toLowerCase().contains(q))
    ).toList();
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;

  set searchQuery(String v) {
    _searchQuery = v;
    notifyListeners();
  }

  FeedProvider() {
    _posts = List.from(MockData.posts);
  }

  Future<void> loadPosts() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 400));
    _posts = List.from(MockData.posts);
    _isLoading = false;
    notifyListeners();
  }

  void addPost(PostModel post) {
    _posts.insert(0, post);
    MockData.posts.insert(0, post);
    notifyListeners();
  }

  void toggleLike(String postId) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final post = _posts[index];
      _posts[index] = post.copyWith(
        likes: post.isLiked ? post.likes - 1 : post.likes + 1,
        isLiked: !post.isLiked,
      );
      notifyListeners();
    }
  }

  void addComment(String postId, CommentModel comment) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final post = _posts[index];
      _posts[index] = post.copyWith(commentsCount: post.commentsCount + 1);
      MockData.comments[postId] ??= [];
      MockData.comments[postId]!.add(comment);
      notifyListeners();
    }
  }

  List<CommentModel> getComments(String postId) {
    return MockData.comments[postId] ?? [];
  }

  void deletePost(String postId) {
    _posts.removeWhere((p) => p.id == postId);
    MockData.posts.removeWhere((p) => p.id == postId);
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
