import 'package:flutter/material.dart';
import 'package:quizlet_final_flutter/constant/color.dart';
import 'package:quizlet_final_flutter/constant/text_style.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  bool obscureText = true;

  void _toggleObscure() {
    setState(() {
      obscureText = !obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          height: MediaQuery.of(context).size.height - 50,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.only(top: 100),
                height: 200,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/signup.png"),
                      fit: BoxFit.fitHeight),
                ),
              ), // Image
              const Column(
                children: <Widget>[
                  Text(
                    "Sign up",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Create an account, It's free ",
                    style: TextStyle(fontSize: 15, color: Colors.grey),
                  )
                ],
              ), // Sign up Text
              Column(
                children: <Widget>[
                  inputFile(label: "Username", prefixIcon: Icons.person),
                  inputFile(label: "Email", prefixIcon: Icons.email),
                  inputFile(
                    label: "Password",
                    prefixIcon: Icons.lock,
                    suffixIcon: obscureText ? Icons.visibility : Icons.visibility_off,
                    obscureText: obscureText,
                    onSuffixIconPressed: _toggleObscure,
                  ),
                ],
              ), // 4 fields to sign up
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                ),
                child: MaterialButton(
                  minWidth: double.infinity,
                  height: 60,
                  onPressed: () {},
                  color: Colors.blue,
                  // Change this color to your desired color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Text(
                    "Sign up",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ), // Sign Up button
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text("Already have an account?"),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      " Login",
                      style: authenticateStyle,
                    ),
                  )
                ],
              ) // Back to Login
            ],
          ),
        ),
      ),
    );
  }
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


