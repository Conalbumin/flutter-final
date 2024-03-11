import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:quizlet_final_flutter/home/home.dart';
import 'package:quizlet_final_flutter/setting/setting.dart';
import 'package:quizlet_final_flutter/study/study.dart';
import 'package:quizlet_final_flutter/authentication/signup.dart';
import 'authentication/login.dart';
import 'app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.system,
      title: 'QuizPop',
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => Login(),
        '/login': (context) => Login(),
        '/signUp': (context) => SignUp(),
        '/home': (context) => MainApp(),
      },
    );
  }
}
