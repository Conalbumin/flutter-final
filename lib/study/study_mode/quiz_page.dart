import 'package:flutter/material.dart';
import 'package:quizlet_final_flutter/main.dart';
import 'answer.dart'; // Import the Answer widget

class QuizPage extends StatefulWidget {
  const QuizPage({Key? key}) : super(key: key);

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              "Quiz",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
            Text(
              "number",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("questions"),
                Text("pick the answer:"),
              ],
            ),
            const SizedBox(height: 20), // Add spacing between text and answer options
            // Add your answer options widgets here
            // Answer widget from answer.dart added here
            Answer(), // Include the Answer widget
          ],
        ),
      ),
    );
  }
}
