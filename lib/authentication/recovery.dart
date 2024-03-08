import 'package:flutter/material.dart';
import 'package:quizlet_final_flutter/authentication/signup.dart';
import 'package:quizlet_final_flutter/constant/color.dart';
import 'package:quizlet_final_flutter/constant/text_style.dart';

class RecoveyPage extends StatefulWidget {
  const RecoveyPage({Key? key}) : super(key: key);

  @override
  State<RecoveyPage> createState() => _RecoveyPageState();
}

class _RecoveyPageState extends State<RecoveyPage> {
  bool obscureText = true;

  void _toggleObscure() {
    setState(() {
      obscureText = !obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: <Widget>[
                      const Text(
                        "Recovery",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Enter the email you signed up with. We'll send you a link to log in and reset your password",
                        style: TextStyle(fontSize: 15, color: Colors.grey[800]),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ), // Email + Password
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Container(
                    padding: const EdgeInsets.only(top: 3, left: 3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: MaterialButton(
                      minWidth: double.infinity,
                      height: 60,
                      onPressed: () {},
                      color: button,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Text(
                        "Send link",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

                Container(
                  height: 400,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage("assets/forgot-password.png"),
                        fit: BoxFit.fitHeight),
                  ),
                ) // Image
              ],
            ))
          ],
        ),
      ),
    );
  }
}
