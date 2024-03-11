import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../constant/style.dart';
import 'firebase_setting_page.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  User? _user;

  @override
  void initState() {
    super.initState();
    getUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 50),
              Container(
                child: GestureDetector(
                  onTap: () {},
                  child: Card(
                    color: Colors.transparent,
                    child: Container(
                      decoration: CustomCardDecoration.cardDecoration,
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircleAvatar(
                            radius: 50,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            _user?.displayName ?? '',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _user?.email ?? '',
                            style:
                                TextStyle(fontSize: 18, color: Colors.grey[300]),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ), // Profile
        
              const SizedBox(height: 20),
              Container(
                child: GestureDetector(
                  onTap: () {
                    changeUsername();
                  },
                  child: Card(
                    color: Colors.blue[500],
                    child: Container(
                      decoration: CustomCardDecoration.cardDecoration,
                      padding: const EdgeInsets.all(16.0),
                      child: const Row(
                        children: [
                          Icon(Icons.drive_file_rename_outline,
                              color: Colors.white),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Change username',
                              style: TextStyle(fontSize: 20, color: Colors.white),
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                ),
              ), // Change username
        
              const SizedBox(height: 20),
              Container(
                child: GestureDetector(
                  onTap: () {},
                  child: Card(
                    color: Colors.blue[500],
                    child: Container(
                      decoration: CustomCardDecoration.cardDecoration,
                      padding: const EdgeInsets.all(16.0),
                      child: const Row(
                        children: [
                          Icon(Icons.image, color: Colors.white),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Change avatar',
                              style: TextStyle(fontSize: 20, color: Colors.white),
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                ),
              ), // Change avatar
        
              const SizedBox(height: 20),
              Container(
                child: GestureDetector(
                  onTap: () {},
                  child: Card(
                    color: Colors.blue[500],
                    child: Container(
                      decoration: CustomCardDecoration.cardDecoration,
                      padding: const EdgeInsets.all(16.0),
                      child: const Row(
                        children: [
                          Icon(Icons.lock, color: Colors.white),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Change password',
                              style: TextStyle(fontSize: 20, color: Colors.white),
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                ),
              ), // Change password
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 50),
        child: FloatingActionButton(
          backgroundColor: Colors.blue,
          onPressed: () {
            logout();
          },
          child: const Icon(
            Icons.logout,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
    );
  }

  Future<void> getUserProfile() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    if (user != null) {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentSnapshot userSnapshot = await firestore.collection('users').doc(user.uid).get();
      setState(() {
        _user = user;
      });
    };
  }

// Function to show a dialog for entering a new username
  Future<String?> _showUsernameInputDialog() async {
    TextEditingController _usernameController = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter New Username'),
          content: TextField(
            controller: _usernameController,
            onChanged: (value) {
              // You can perform validation or other actions here
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(null); // Return null when canceled
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(_usernameController.text); // Return the entered value when OK is pressed
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void changeUsername() async {
    String? newUsername = await _showUsernameInputDialog();

    if (newUsername != null && newUsername.isNotEmpty) {
      try {
        // Update the user's profile display name
        await FirebaseAuth.instance.currentUser!.updateProfile(displayName: newUsername);

        // Update the username in Firestore database
        FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .update({'displayName': newUsername});

        // Refresh the user profile
        await getUserProfile();
      } catch (e) {
        print('Error updating username: $e');
      }
    } else {
      print('Error: Invalid username or canceled');
    }
  }




  void changeAvatar() async {}

  void changePassword() async {}

  void logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }
}
