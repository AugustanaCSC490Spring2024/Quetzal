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
    //  user pick an image from their gallery
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (kDebugMode) {
      print('Selected image path: ${image?.path}');
    }

    if (image == null) {
      // if the User canceled the picker
      return null;
    }

    File file = File(image.path);

    try {
      // Assuming the user is logged + have uid
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw FirebaseAuthException(
          code: 'no-user',
          message: 'No signed-in user found',
        );
      }

      String filePath = 'profile_pictures/${currentUser.uid}.jpg';
      Reference ref = _storage.ref().child(filePath);

      // Upload the file to Firebase Storage
      await ref.putFile(file);

      // Once the file upload is complete, retrieve the download URL
      String downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } on FirebaseException catch (e) {
      // Handle any errors from the Firebase platform
      if (kDebugMode) {
        print(e);
      }
      return null;
    } catch (e) {
      // Handle any other errors
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  }
}
