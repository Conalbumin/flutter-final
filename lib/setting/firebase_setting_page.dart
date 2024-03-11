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

Future<void> updatePassword(String newPassword) async {
  try {
    // Get the current user
    User? currentUser = FirebaseAuth.instance.currentUser;

    // If the user is signed in
    if (currentUser != null) {
      // Update the password
      await currentUser.updatePassword(newPassword);

      print('Password updated successfully.');
    } else {
      print('Error: No user is currently signed in.');
    }
  } catch (e) {
    print('Error updating password: $e');
  }
}