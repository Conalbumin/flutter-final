import 'package:flutter/material.dart';
import 'package:quizlet_final_flutter/authentication/signup.dart';
import '../authentication/login.dart';
import 'app.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.system,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: const Login(),
    );
  }
}
