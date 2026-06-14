import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../services/mock_data.dart';

class FeedProvider extends ChangeNotifier {
  List<PostModel> _posts = [];
  bool _isLoading = false;
  String? _error;

  List<PostModel> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get error => _error;

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

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
