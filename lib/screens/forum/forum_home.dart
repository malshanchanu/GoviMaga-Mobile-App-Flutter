import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart' as app_auth;
import '../../widgets/login_required_dialog.dart';

class ForumHome extends StatelessWidget {
  final String language;
  const ForumHome({super.key, required this.language});

  @override
  Widget build(BuildContext context) {
    return const ForumScreen();
  }
}

class ForumScreen extends StatefulWidget {
  const ForumScreen({super.key});

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _isLoading = false;
  
  final List<String> _categories = [
    'All', 'My Questions', 'Rice', 'Vegetables', 'Pest Control', 'Fertilizer', 'Harvesting'
  ];
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  User? _currentUser;
  
  @override
  void initState() {
    super.initState();
    // _currentUser is handled in build() via AuthProvider
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _commentController.dispose();
    _searchController.dispose();
    super.dispose();
  }
  
  String _formatTimeAgo(Timestamp? timestamp) {
    if (timestamp == null) return 'Recently';
    final dateTime = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 7) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
  
  String _getInitial(String? name) {
    if (name == null || name.trim().isEmpty) return '?';
    return name.trim()[0].toUpperCase();
  }
  
  // Removed _showLoginPrompt, using LoginRequiredDialog instead
  
  Future<void> _createPost() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }
    
    final authProvider = Provider.of<app_auth.AuthProvider>(context, listen: false);
    if (authProvider.isGuest || authProvider.user == null) {
      LoginRequiredDialog.show(context: context, action: 'create a post');
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      await _firestore.collection('forum_posts').add({
        'title': _titleController.text.trim(),
        'content': _contentController.text.trim(),
        'category': _selectedCategory == 'All' ? 'General' : _selectedCategory,
        'authorId': authProvider.user!.uid,
        'authorName': authProvider.user!.displayName ?? 'Anonymous Farmer',
        'likes': 0,
        'replies': 0,
        'views': 0,
        'likedBy': [],
        'timestamp': FieldValue.serverTimestamp(),
      });
      
      _titleController.clear();
      _contentController.clear();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post created successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _updatePost(String postId) async {
    if (_titleController.text.trim().isEmpty) return;

    setState(() => _isLoading = true);

    try {
      await _firestore.collection('forum_posts').doc(postId).update({
        'title': _titleController.text.trim(),
        'content': _contentController.text.trim(),
        'category': _selectedCategory == 'All' ? 'General' : _selectedCategory,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post updated successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }

    setState(() => _isLoading = false);
  }

  Future<void> _deletePost(String postId) async {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              setState(() => _isLoading = true);
              try {
                await _firestore.collection('forum_posts').doc(postId).delete();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Post deleted successfully!')),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                );
              }
              setState(() => _isLoading = false);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _addComment(String postId) async {
    if (_commentController.text.trim().isEmpty) return;
    
    final authProvider = Provider.of<app_auth.AuthProvider>(context, listen: false);
    if (authProvider.isGuest || authProvider.user == null) {
      LoginRequiredDialog.show(context: context, action: 'comment on posts');
      return;
    }
    
    try {
      await _firestore
          .collection('forum_posts')
          .doc(postId)
          .collection('comments')
          .add({
        'content': _commentController.text.trim(),
        'authorId': authProvider.user!.uid,
        'authorName': authProvider.user!.displayName ?? 'Anonymous',
        'timestamp': FieldValue.serverTimestamp(),
      });
      
      await _firestore.collection('forum_posts').doc(postId).update({
        'replies': FieldValue.increment(1),
      });
      
      _commentController.clear();
    } catch (e) {
      debugPrint('Error adding comment: $e');
    }
  }
  
  Future<void> _toggleLike(String postId, int currentLikes, List<dynamic> likedBy) async {
    final authProvider = Provider.of<app_auth.AuthProvider>(context, listen: false);
    if (authProvider.isGuest || authProvider.user == null) {
      LoginRequiredDialog.show(context: context, action: 'like posts');
      return;
    }
    
    final userId = authProvider.user!.uid;
    final hasLiked = likedBy.contains(userId);
    
    await _firestore.collection('forum_posts').doc(postId).update({
      'likes': hasLiked ? currentLikes - 1 : currentLikes + 1,
      'likedBy': hasLiked 
          ? FieldValue.arrayRemove([userId]) 
          : FieldValue.arrayUnion([userId]),
    });
  }
  
  void _showCreatePostDialog({DocumentSnapshot? postToEdit}) {
    
    if (postToEdit != null) {
      final data = postToEdit.data() as Map<String, dynamic>;
      _titleController.text = data['title'] ?? '';
      _contentController.text = data['content'] ?? '';
      if (_categories.contains(data['category'])) {
        _selectedCategory = data['category'];
      }
    } else {
      _titleController.clear();
      _contentController.clear();
    }
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String dialogCategory = _categories[1];
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(postToEdit != null ? 'Edit Post' : 'Create New Post'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: dialogCategory,
                      items: _categories.where((c) => c != 'All').map((category) {
                        return DropdownMenuItem(value: category, child: Text(category));
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() => dialogCategory = value!);
                      },
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _titleController,
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        hintText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: null,
                      minLines: 1,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _contentController,
                      keyboardType: TextInputType.multiline,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.newline,
                      decoration: const InputDecoration(
                        hintText: 'Content',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 5,
                      minLines: 3,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : () {
                    if (postToEdit != null) {
                      _updatePost(postToEdit.id);
                    } else {
                      _createPost();
                    }
                  },
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(postToEdit != null ? 'Save Changes' : 'Post'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  
  void _showCommentsBottomSheet(String postId, String postTitle) {
    _commentController.clear();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
                ),
                child: Text(
                  postTitle,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('forum_posts')
                      .doc(postId)
                      .collection('comments')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    final comments = snapshot.data!.docs;
                    
                    if (comments.isEmpty) {
                      return const Center(
                        child: Text('No comments yet. Be the first to comment!'),
                      );
                    }
                    
                    return ListView.builder(
                      controller: scrollController,
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final comment = comments[index].data() as Map<String, dynamic>;
                        return ListTile(
                          leading: CircleAvatar(
                            child: Text(_getInitial(comment['authorName'])),
                          ),
                          title: Text(
                            comment['authorName'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(comment['content']),
                          trailing: Text(
                            _formatTimeAgo(comment['timestamp']),
                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                  top: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: Colors.grey.withValues(alpha: 0.2), blurRadius: 8),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: InputDecoration(
                          hintText: 'Write a comment...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.send, color: Colors.green),
                      onPressed: () => _addComment(postId),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<app_auth.AuthProvider>(context);
    _currentUser = authProvider.user;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8F5),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                ),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.forum, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Farmers Forum',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            Text(
                              'Connect with fellow farmers',
                              style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.8)),
                            ),
                          ],
                        ),
                      ),
                      if (_currentUser != null)
                        CircleAvatar(
                          radius: 16,
                          child: Text(_getInitial(_currentUser!.displayName)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Search Bar
                  TextField(
                    onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
                    decoration: InputDecoration(
                      hintText: 'Search discussions...',
                      prefixIcon: const Icon(Icons.search, color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            
            // Categories
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = selected ? category : 'All';
                        });
                      },
                      backgroundColor: Colors.white,
                      selectedColor: Colors.green[100],
                    ),
                  );
                },
              ),
            ),
            
            // Posts List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('forum_posts')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  var posts = snapshot.data!.docs;
                  
                  // Filter by category
                  if (_selectedCategory == 'My Questions') {
                    posts = posts.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return data['authorId'] == _currentUser?.uid;
                    }).toList();
                  } else if (_selectedCategory != 'All') {
                    posts = posts.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return data['category'] == _selectedCategory;
                    }).toList();
                  }
                  
                  // Filter by search
                  if (_searchQuery.isNotEmpty) {
                    posts = posts.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final title = data['title']?.toLowerCase() ?? '';
                      final content = data['content']?.toLowerCase() ?? '';
                      return title.contains(_searchQuery) || content.contains(_searchQuery);
                    }).toList();
                  }
                  
                  if (posts.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.forum_outlined, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No posts found'),
                          SizedBox(height: 8),
                          Text('Be the first to ask a question!'),
                        ],
                      ),
                    );
                  }
                  
                  return ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index].data() as Map<String, dynamic>;
                      final postId = posts[index].id;
                      final timestamp = post['timestamp'] as Timestamp?;
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: InkWell(
                          onTap: () => _showCommentsBottomSheet(postId, post['title']),
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      child: Text(_getInitial(post['authorName'])),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            post['authorName'],
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                          ),
                                          Text(
                                            _formatTimeAgo(timestamp),
                                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.green[50],
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: Colors.green[200]!),
                                      ),
                                      child: Text(
                                        post['category'] ?? 'General',
                                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green[700]),
                                      ),
                                    ),
                                    if (post['authorId'] == _currentUser?.uid)
                                      PopupMenuButton<String>(
                                        icon: const Icon(Icons.more_vert, size: 20, color: Colors.grey),
                                        onSelected: (value) {
                                          if (value == 'edit') {
                                            _showCreatePostDialog(postToEdit: posts[index]);
                                          } else if (value == 'delete') {
                                            _deletePost(postId);
                                          }
                                        },
                                        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                          const PopupMenuItem<String>(
                                            value: 'edit',
                                            child: ListTile(
                                              leading: Icon(Icons.edit, size: 20),
                                              title: Text('Edit'),
                                              contentPadding: EdgeInsets.zero,
                                            ),
                                          ),
                                          const PopupMenuItem<String>(
                                            value: 'delete',
                                            child: ListTile(
                                              leading: Icon(Icons.delete, color: Colors.red, size: 20),
                                              title: Text('Delete', style: TextStyle(color: Colors.red)),
                                              contentPadding: EdgeInsets.zero,
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  post['title'],
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, height: 1.3),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  post['content'],
                                  style: TextStyle(fontSize: 14, color: Colors.grey[800], height: 1.4),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 16),
                                const Divider(height: 1),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    _buildStatCounter(
                                      icon: (post['likedBy'] as List?)?.contains(_currentUser?.uid) == true
                                          ? Icons.thumb_up
                                          : Icons.thumb_up_outlined,
                                      count: post['likes'] ?? 0,
                                      color: (post['likedBy'] as List?)?.contains(_currentUser?.uid) == true
                                          ? Colors.blue
                                          : Colors.grey[600]!,
                                      onTap: () => _toggleLike(postId, post['likes'] ?? 0, post['likedBy'] ?? []),
                                    ),
                                    const SizedBox(width: 24),
                                    _buildStatCounter(
                                      icon: Icons.chat_bubble_outline,
                                      count: post['replies'] ?? 0,
                                      color: Colors.grey[600]!,
                                    ),
                                    const Spacer(),
                                    _buildStatCounter(
                                      icon: Icons.remove_red_eye_outlined,
                                      count: post['views'] ?? 0,
                                      color: Colors.grey[600]!,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, -2)),
                ],
              ),
              child: FloatingActionButton.extended(
                onPressed: () {
                  final authProvider = Provider.of<app_auth.AuthProvider>(context, listen: false);
                  if (authProvider.isGuest || authProvider.user == null) {
                    LoginRequiredDialog.show(context: context, action: 'ask a question');
                    return;
                  }
                  _showCreatePostDialog();
                },
                icon: const Icon(Icons.add),
                label: const Text('Ask a Question'),
                backgroundColor: const Color(0xFF1B5E20),
                foregroundColor: Colors.white,
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCounter({required IconData icon, required int count, required Color color, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 14,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}