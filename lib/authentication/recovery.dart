import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quizlet_final_flutter/authentication/firebase_auth_service.dart';
import 'package:quizlet_final_flutter/authentication/signup.dart';
import 'package:quizlet_final_flutter/constant/color.dart';
import 'package:quizlet_final_flutter/constant/text_style.dart';

import 'form_container_widget.dart';
import 'login.dart';
import 'toast.dart';

class RecoveyPage extends StatefulWidget {
  const RecoveyPage({Key? key}) : super(key: key);

  @override
  State<RecoveyPage> createState() => _RecoveyPageState();
}

class _RecoveyPageState extends State<RecoveyPage> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  bool obscureText = true;
  bool isRecovery = false;
  TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Recovery",
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                ),
                const Text(
                  "Enter the email you signed up with. We'll send you a link to log in and reset your password. "
                      "If you signed up with your parent’s email, we’ll send them a link.",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
                ),
                const SizedBox(
                  height: 30,
                ),
                FormContainerWidget(
                  controller: _emailController,
                  hintText: "Email",
                  isPasswordField: false,
                ),
              
                const SizedBox(
                  height: 35,
                ),
                GestureDetector(
                  onTap:  (){
                    _resetPassword();
                  },
                  child: Container(
                    width: double.infinity,
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                        child: isRecovery ? const CircularProgressIndicator(color: Colors.white,):const Text(
                          "Send",
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.white, fontWeight: FontWeight.bold),
                        )),
                  ),
                ),
                Container(
                  child: Image.asset('assets/forgot-password.png'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _resetPassword() async {
    setState(() {
      isRecovery = true;
    });

    String email = _emailController.text;

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      showToast(message: "Password reset email sent successfully.");
    } catch (e) {
      showToast(message: "Error sending password reset email: $e");
    }

    setState(() {
      isRecovery = false;
    });
  }

}
