import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

Future<void> updateUsername(User user, String newUsername) async {
  try {
    String uid = user.uid;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({'displayName': newUsername});
    print('Username updated successfully.');
  } catch (e) {
    print('Error updating username: $e');
  }
}

Future<void> updatePassword(String newPassword) async {
  try {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      await currentUser.updatePassword(newPassword);
      print('Password updated successfully.');
    } else {
      print('Error: No user is currently signed in.');
    }
  } catch (e) {
    print('Error updating password: $e');
  }
}

Future<String> updateAvatar(User user, String imagePath) async {
  try {
    User? currentUser = FirebaseAuth.instance.currentUser;

    String uid = user.uid;
    Reference storageReference = FirebaseStorage.instance.ref().child('avatars/$uid/avatar.jpg');
    UploadTask uploadTask = storageReference.putFile(File(imagePath));
    await uploadTask.whenComplete(() => null);
    await currentUser?.updatePhotoURL(imagePath);
    String newAvatarURL = await storageReference.getDownloadURL();

    FirebaseFirestore.instance.collection('users').doc(uid).update({'avatarURL': newAvatarURL});

    return newAvatarURL;
  } catch (e) {
    print('Error updating avatar: $e');
    rethrow;
  }
}

