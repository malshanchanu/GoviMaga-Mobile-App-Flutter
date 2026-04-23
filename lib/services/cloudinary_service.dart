import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

class CloudinaryService {
  static late CloudinaryPublic _cloudinary;
  static bool _isInitialized = false;
  
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    await dotenv.load();
    
    final cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'];
    if (cloudName == null) {
      throw Exception('CLOUDINARY_CLOUD_NAME not found in .env file');
    }
    
    _cloudinary = CloudinaryPublic(cloudName, 'unsigned_preset');
    _isInitialized = true;
  }
  
  static Future<String?> uploadImage(File imageFile, {String folder = 'forum_posts'}) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    try {
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          resourceType: CloudinaryResourceType.Image,
          folder: folder,
        ),
      );
      return response.secureUrl;
    } catch (e) {
      debugPrint('Upload error: $e');
      return null;
    }
  }
}