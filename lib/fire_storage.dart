import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:timer_team/models/user_object.dart';

import 'fire_database.dart';

class FireStorage {
  final ref = FirebaseStorage.instance.ref();

  Future<UserObject> setImageUser(
      {required UserObject userObject, required File image}) async {
    final newChildRef = ref.child(
        "users/${userObject.id}"); // generates a new child with a unique ID
    try {
      await newChildRef.putFile(image);
    } on FirebaseException catch (e) {
      print("failed to upload to FireStorage : $e");
    }
    return FireDatabase().getUser(user: userObject);
  }

  Future<String?> getImageUser({required String idUser}) async {
    String? imageUrl;
    final newChildRef =
        ref.child("users/$idUser"); // generates a new child with a unique ID
    try {
      imageUrl = await newChildRef.getDownloadURL();
    } on FirebaseException catch (e) {
      print("failed to upload to FireStorage : $e");
    }
    return imageUrl;
  }
}
