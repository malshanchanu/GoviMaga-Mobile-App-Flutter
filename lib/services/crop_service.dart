import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CropService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  List<Map<String, dynamic>> _crops = [];
  List<Map<String, dynamic>> _upcomingTasks = [];

  List<Map<String, dynamic>> get crops => _crops;
  List<Map<String, dynamic>> get upcomingTasks => _upcomingTasks;

  // Get crops ONLY for current logged-in user
  Stream<QuerySnapshot> getUserCrops() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.empty();
    
    return _firestore
        .collection('crops')
        .where('userId', isEqualTo: userId)
        .snapshots();
  }

  // Load crops into memory
  Future<void> loadCrops() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      _crops = [];
      return;
    }

    final snapshot = await _firestore
        .collection('crops')
        .where('userId', isEqualTo: userId)
        .get();
    
    _crops = snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'name': data['name'] ?? '',
        'variety': data['variety'] ?? '',
        'plantedDate': data['plantedDate'],
        'userId': data['userId'],
        'createdAt': data['createdAt'],
      };
    }).toList();
  }

  // Get all upcoming tasks (7 days)
  Future<List<Map<String, dynamic>>> getAllUpcomingTasks({int days = 7}) async {
    _upcomingTasks = [];
    
    for (var crop in _crops) {
      final tasks = await _getTasksForCrop(crop['id'] as String);
      final now = DateTime.now();
      final future = now.add(Duration(days: days));
      
      for (var task in tasks) {
        final taskDate = (task['dueDate'] as Timestamp).toDate();
        if (taskDate.isAfter(now) && taskDate.isBefore(future) && task['isCompleted'] != true) {
          _upcomingTasks.add({
            'id': task['id'],
            'cropId': crop['id'],
            'cropName': crop['name'],
            'title': task['title'],
            'dueDate': taskDate,
            'isCompleted': false,
          });
        }
      }
    }
    
    _upcomingTasks.sort((a, b) => (a['dueDate'] as DateTime).compareTo(b['dueDate'] as DateTime));
    return _upcomingTasks;
  }

  // Get crop by task ID
  Map<String, dynamic>? getCropByTaskId(String taskId) {
    for (var crop in _crops) {
      final tasks = _cropTasksCache[crop['id']] ?? [];
      for (var task in tasks) {
        if (task['id'] == taskId) {
          return crop;
        }
      }
    }
    return null;
  }

  // Cache for crop tasks
  final Map<String, List<Map<String, dynamic>>> _cropTasksCache = {};

  // Get tasks for a specific crop
  Future<List<Map<String, dynamic>>> _getTasksForCrop(String cropId) async {
    if (_cropTasksCache.containsKey(cropId)) {
      return _cropTasksCache[cropId]!;
    }

    final snapshot = await _firestore
        .collection('crops')
        .doc(cropId)
        .collection('tasks')
        .orderBy('dueDate')
        .get();
    
    final tasks = snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'title': data['title'] ?? '',
        'dueDate': data['dueDate'],
        'isCompleted': data['isCompleted'] ?? false,
      };
    }).toList();
    
    _cropTasksCache[cropId] = tasks;
    return tasks;
  }

  // Complete a task
  Future<void> completeTask(String cropId, String taskId) async {
    await _firestore
        .collection('crops')
        .doc(cropId)
        .collection('tasks')
        .doc(taskId)
        .update({
      'isCompleted': true,
      'completedAt': FieldValue.serverTimestamp(),
    });
    
    // Update cache
    if (_cropTasksCache.containsKey(cropId)) {
      final tasks = _cropTasksCache[cropId]!;
      final index = tasks.indexWhere((t) => t['id'] == taskId);
      if (index != -1) {
        tasks[index]['isCompleted'] = true;
      }
    }
    
    // Refresh upcoming tasks
    await getAllUpcomingTasks(days: 7);
  }

  // Add new crop
  Future<void> addCrop({
    required String name,
    required String variety,
    required DateTime plantedDate,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not logged in');

    final cropRef = await _firestore.collection('crops').add({
      'name': name,
      'variety': variety,
      'plantedDate': Timestamp.fromDate(plantedDate),
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    
    // Add default tasks
    await _generateDefaultTasks(cropRef.id, name, plantedDate);
    
    await loadCrops();
  }

  Future<void> _generateDefaultTasks(String cropId, String cropType, DateTime plantedDate) async {
    if (cropType == 'Paddy') {
      await addTask(cropId: cropId, title: 'Water Management', dueDate: plantedDate.add(const Duration(days: 7)));
      await addTask(cropId: cropId, title: 'Apply Urea Fertilizer', dueDate: plantedDate.add(const Duration(days: 30)));
      await addTask(cropId: cropId, title: 'Pest Control', dueDate: plantedDate.add(const Duration(days: 45)));
      await addTask(cropId: cropId, title: 'Harvest Preparation', dueDate: plantedDate.add(const Duration(days: 100)));
    } else if (cropType == 'Tomato') {
      await addTask(cropId: cropId, title: 'Daily Watering', dueDate: plantedDate.add(const Duration(days: 1)));
      await addTask(cropId: cropId, title: 'Apply NPK Fertilizer', dueDate: plantedDate.add(const Duration(days: 15)));
      await addTask(cropId: cropId, title: 'Pest Inspection', dueDate: plantedDate.add(const Duration(days: 25)));
      await addTask(cropId: cropId, title: 'Start Harvesting', dueDate: plantedDate.add(const Duration(days: 70)));
    } else if (cropType == 'Chili') {
      await addTask(cropId: cropId, title: 'Watering', dueDate: plantedDate.add(const Duration(days: 3)));
      await addTask(cropId: cropId, title: 'Apply Fertilizer', dueDate: plantedDate.add(const Duration(days: 20)));
      await addTask(cropId: cropId, title: 'Pest Control', dueDate: plantedDate.add(const Duration(days: 35)));
      await addTask(cropId: cropId, title: 'Harvesting', dueDate: plantedDate.add(const Duration(days: 60)));
    } else {
      // Generic tasks
      await addTask(cropId: cropId, title: 'Watering', dueDate: plantedDate.add(const Duration(days: 2)));
      await addTask(cropId: cropId, title: 'Fertilizer Application', dueDate: plantedDate.add(const Duration(days: 14)));
      await addTask(cropId: cropId, title: 'Harvesting', dueDate: plantedDate.add(const Duration(days: 90)));
    }
  }

  // Update crop
  Future<void> updateCrop({
    required String cropId,
    required String name,
    required String variety,
    required DateTime plantedDate,
  }) async {
    await _firestore.collection('crops').doc(cropId).update({
      'name': name,
      'variety': variety,
      'plantedDate': Timestamp.fromDate(plantedDate),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    
    await loadCrops();
  }

  // Delete crop
  Future<void> deleteCrop(String cropId) async {
    final tasks = await _firestore
        .collection('crops')
        .doc(cropId)
        .collection('tasks')
        .get();
    
    for (var task in tasks.docs) {
      await task.reference.delete();
    }
    
    await _firestore.collection('crops').doc(cropId).delete();
    
    _crops.removeWhere((c) => c['id'] == cropId);
    _cropTasksCache.remove(cropId);
    
    await loadCrops();
  }

  // Add task to crop
  Future<void> addTask({
    required String cropId,
    required String title,
    required DateTime dueDate,
  }) async {
    await _firestore
        .collection('crops')
        .doc(cropId)
        .collection('tasks')
        .add({
      'title': title,
      'dueDate': Timestamp.fromDate(dueDate),
      'isCompleted': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
    
    _cropTasksCache.remove(cropId);
  }

  // Toggle task completion
  Future<void> toggleTaskCompletion(String cropId, String taskId, bool isCompleted) async {
    await _firestore
        .collection('crops')
        .doc(cropId)
        .collection('tasks')
        .doc(taskId)
        .update({
      'isCompleted': isCompleted,
    });
    
    _cropTasksCache.remove(cropId);
  }

  // Get tasks for a specific crop as a stream
  Stream<QuerySnapshot> getTasksForCrop(String cropId) {
    return _firestore
        .collection('crops')
        .doc(cropId)
        .collection('tasks')
        .orderBy('dueDate', descending: false)
        .snapshots();
  }
}