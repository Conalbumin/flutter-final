import 'package:flutter/material.dart';

class Answer extends StatefulWidget {
  const Answer({super.key});

  @override
  State<Answer> createState() => _AnswerState();
}

class _AnswerState extends State<Answer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue[100],
        border: Border.all(color: Colors.indigo, width: 3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Padding(
        padding: EdgeInsets.all(8.0), // Add padding to make space between border and text
        child: Text(
          "Fwaddwdwdwdwdwdw",
          style: TextStyle(
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
