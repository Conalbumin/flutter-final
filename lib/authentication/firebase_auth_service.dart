import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signUpWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return credential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        print("The email address is already in use");
      } else {
        print("An error occurred: ${e.code}");
      }
    }
    return null;
  }

  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return credential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        print("Invalid email or password.");
      } else {
        print("An error occurred: ${e.code}");
      }
    }
    return null;
  }

  Future<User?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      // Return null because there's no user associated with the reset password action
      return null;
    } catch (e) {
      print("An error occurred: $e");
      return null;
    }
  }

  Future<void> addUserToFirestore(User user) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    String uid = user.uid;
    CollectionReference users = firestore.collection('users');
    DocumentReference userDoc = users.doc(uid);

    String email = user.email ?? '';
    String displayName = user.displayName ?? '';

    // Create a map of user data
    Map<String, dynamic> userData = {
      'email': email,
      'username': displayName,
    };

    await userDoc.set(userData);
  }

  void handleSignIn(User user) async {
    // Handle user sign-in (e.g., navigate to the home screen, show a success message, etc.)
    print('User signed in: ${user.displayName}');

    await addUserToFirestore(user);
  }

}
