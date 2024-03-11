import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
