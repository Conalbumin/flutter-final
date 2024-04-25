import 'package:flutter/material.dart';
import 'package:quizlet_final_flutter/authentication/signup.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'authentication/login.dart';
import 'app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  runApp(App(isLoggedIn: isLoggedIn));
}

class App extends StatelessWidget {
  final bool isLoggedIn;

  const App({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.white,
        hintColor: Colors.white,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          iconTheme: IconThemeData(color: Colors.white), // Set back button color to white
        ),
        // Add more theme configurations as needed
      ),
      themeMode: ThemeMode.light,
      title: 'QuizPop',
      debugShowCheckedModeBanner: false,
      initialRoute: isLoggedIn ? '/home' : '/login',
      routes: {
        '/': (context) => const Login(),
        '/login': (context) => const Login(),
        '/signUp': (context) => const SignUp(),
        '/home': (context) => const MainApp(),
      },
    );
  }
}
