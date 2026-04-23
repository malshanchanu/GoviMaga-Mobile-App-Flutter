import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'cloudinary_service.dart';

class ForumService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  String get _userId => _auth.currentUser?.uid ?? '';
  String get _userName => _auth.currentUser?.displayName ?? 'Anonymous Farmer';
  
  // Create a new post
  Future<void> createPost({
    required String title,
    required String content,
    required String category,
    File? imageFile,
  }) async {
    String? imageUrl;
    
    // Upload image if provided
    if (imageFile != null) {
      try {
        imageUrl = await CloudinaryService.uploadImage(imageFile, folder: 'forum_posts');
      } catch (e) {
        debugPrint('Image upload failed: $e');
      }
    }
    
    await _firestore.collection('forum_posts').add({
      'title': title,
      'content': content,
      'category': category,
      'authorId': _userId,
      'authorName': _userName,
      'imageUrl': imageUrl,
      'likes': 0,
      'replies': 0,
      'views': 0,
      'likedBy': [],
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
  
  // Like/unlike a post
  Future<void> toggleLike(String postId, bool isLiked) async {
    final postRef = _firestore.collection('forum_posts').doc(postId);
    
    if (isLiked) {
      await postRef.update({
        'likes': FieldValue.increment(1),
        'likedBy': FieldValue.arrayUnion([_userId]),
      });
    } else {
      await postRef.update({
        'likes': FieldValue.increment(-1),
        'likedBy': FieldValue.arrayRemove([_userId]),
      });
    }
  }
  
  // Add a comment to a post
  Future<void> addComment(String postId, String comment) async {
    await _firestore
        .collection('forum_posts')
        .doc(postId)
        .collection('comments')
        .add({
      'content': comment,
      'authorId': _userId,
      'authorName': _userName,
      'timestamp': FieldValue.serverTimestamp(),
    });
    
    // Increment reply count
    await _firestore.collection('forum_posts').doc(postId).update({
      'replies': FieldValue.increment(1),
    });
  }
  
  // Increment view count
  Future<void> incrementViews(String postId) async {
    await _firestore.collection('forum_posts').doc(postId).update({
      'views': FieldValue.increment(1),
    });
  }
  
  // Delete a post
  Future<void> deletePost(String postId) async {
    // Delete all comments first
    final comments = await _firestore
        .collection('forum_posts')
        .doc(postId)
        .collection('comments')
        .get();
    
    for (var comment in comments.docs) {
      await comment.reference.delete();
    }
    
    // Delete the post
    await _firestore.collection('forum_posts').doc(postId).delete();
  }
  
  // Stream of posts with filtering
  Stream<List<QueryDocumentSnapshot>> getPosts({
    String? category,
    String? searchQuery,
  }) {
    var query = _firestore
        .collection('forum_posts')
        .orderBy('timestamp', descending: true);
    
    if (category != null && category != 'All') {
      query = query.where('category', isEqualTo: category);
    }
    
    return query.snapshots().map((snapshot) {
      var posts = snapshot.docs;
      
      if (searchQuery != null && searchQuery.isNotEmpty) {
        posts = posts.where((doc) {
          final data = doc.data();
          final title = data['title']?.toLowerCase() ?? '';
          final content = data['content']?.toLowerCase() ?? '';
          return title.contains(searchQuery.toLowerCase()) ||
              content.contains(searchQuery.toLowerCase());
        }).toList();
      }
      
      return posts;
    });
  }
  
  // Get comments for a post
  Stream<QuerySnapshot> getComments(String postId) {
    return _firestore
        .collection('forum_posts')
        .doc(postId)
        .collection('comments')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
  
  // Check if user has liked a post
  Future<bool> isPostLiked(String postId) async {
    final doc = await _firestore.collection('forum_posts').doc(postId).get();
    final likedBy = doc.data()?['likedBy'] as List? ?? [];
    return likedBy.contains(_userId);
  }
}