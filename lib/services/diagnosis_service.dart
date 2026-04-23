import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'cloudinary_service.dart';

class DiagnosisService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  String get _userId => _auth.currentUser?.uid ?? '';
  bool get _isLoggedIn => _userId.isNotEmpty;

  Future<void> saveDiagnosis({
    required File imageFile,
    required Map<String, dynamic> diagnosisData,
    required String language,
  }) async {
    if (!_isLoggedIn) return;
    
    try {
      // Upload image to Storage
      String imageUrl = await _uploadImage(imageFile);
      
      // Create diagnosis document
      Map<String, dynamic> diagnosisDoc = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'imageUrl': imageUrl,
        'diagnosis': diagnosisData,
        'language': language,
        'timestamp': FieldValue.serverTimestamp(),
        'cropName': diagnosisData['cropName']?[language] ?? 'Unknown',
        'diseaseName': diagnosisData['diseaseName']?[language] ?? 'Unknown',
        'confidence': diagnosisData['confidence'] ?? 0,
        'severity': diagnosisData['severity'] ?? 'UNKNOWN',
      };
      
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('diagnoses')
          .add(diagnosisDoc);
          
    } catch (e) {
      debugPrint('Error saving diagnosis: $e');
      rethrow;
    }
  }
  
  Future<String> _uploadImage(File imageFile) async {
    final downloadUrl = await CloudinaryService.uploadImage(imageFile, folder: 'diagnoses/$_userId');
    if (downloadUrl == null) {
      throw Exception('Failed to upload image to Cloudinary');
    }
    return downloadUrl;
  }
  
  Future<List<Map<String, dynamic>>> getDiagnoses() async {
    if (!_isLoggedIn) return [];
    
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('diagnoses')
          .orderBy('timestamp', descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        data['date'] = (data['timestamp'] as Timestamp?)?.toDate().toIso8601String() ?? DateTime.now().toIso8601String();
        return data;
      }).toList();
    } catch (e) {
      debugPrint('Error getting diagnoses: $e');
      return [];
    }
  }
  
  Future<void> deleteDiagnosis(String diagnosisId, String? imageUrl) async {
    if (!_isLoggedIn) return;
    
    try {
      // Delete from Firestore
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('diagnoses')
          .doc(diagnosisId)
          .delete();
      // Note: Cloudinary image deletion is skipped here as it requires admin API setup.
      // If image deletion is strictly needed, it should be done via a backend server.
    } catch (e) {
      debugPrint('Error deleting diagnosis: $e');
      rethrow;
    }
  }
}