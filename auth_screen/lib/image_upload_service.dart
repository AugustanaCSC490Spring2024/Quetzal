// image_upload_service.dart
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class ImageUploadService {
  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> uploadProfilePicture() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (kDebugMode) {
      print('Selected image path: ${image?.path}');
    }

    if (image == null) {
      return null;
    }

    File file = File(image.path);

    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw FirebaseAuthException(
          code: 'no-user',
          message: 'No signed-in user found',
        );
      }

      String filePath = 'profile_pictures/${currentUser.uid}.jpg';
      Reference ref = _storage.ref().child(filePath);

      await ref.putFile(file);

      String downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  }
}
