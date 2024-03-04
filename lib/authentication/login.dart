import 'package:flutter/material.dart';
import 'package:quizlet_final_flutter/authentication/recovery.dart';
import 'package:quizlet_final_flutter/authentication/signup.dart';
import 'package:quizlet_final_flutter/constant/color.dart';
import 'package:quizlet_final_flutter/constant/text_style.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
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
                 const Column(
                  children: <Widget>[
                    Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),                    ),
                  ],
                ),  // Text Login
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: <Widget>[
                      inputFile(label: "Email", prefixIcon: Icons.email),
                      inputFile(
                        label: "Password",
                        prefixIcon: Icons.lock,
                        suffixIcon: obscureText ? Icons.visibility : Icons.visibility_off,
                        obscureText: obscureText,
                        onSuffixIconPressed: _toggleObscure,
                      ),
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
                        "Login",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ), // Login Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text("Don't have an account?"),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> SignUp()));
                      },
                      child: Text(
                        " Sign up",
                        style: authenticateStyle,
                      ),
                    )
                  ],
                ), // Go to Sign up
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> RecoveyPage()));
                      },
                      child:  Text(
                        "Forgot Password",
                        style: authenticateStyle,
                      ),
                    )
                  ],
                ), // Go to Recovery

                Container(
                  padding: const EdgeInsets.only(top: 100),
                  height: 200,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage("assets/login.png"),
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

  Widget inputFile({
    required String label,
    required IconData prefixIcon,
    IconData? suffixIcon,
    bool obscureText = false,
    Function()? onSuffixIconPressed,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(
          height: 5,
        ),
        TextFormField(
          keyboardType: label == "Email" ? TextInputType.emailAddress : TextInputType.text,
          obscureText: obscureText,
          decoration: InputDecoration(
            labelText: label,
            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            border: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            prefixIcon: Icon(prefixIcon),
            suffixIcon: suffixIcon != null ? IconButton(icon: Icon(suffixIcon),
              onPressed: onSuffixIconPressed as void Function()?,
            ) : null,
          ),
        ),
        const SizedBox(
          height: 10,
        )
      ],
    );
  }
}