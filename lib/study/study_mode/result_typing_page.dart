import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../ranking/user_performance.dart';

class TypingResultPage extends StatefulWidget {
  final int correctCount;
  final int numberOfQuestions;
  final List<String> userAnswers;
  final List<String> correctAnswers;
  final List<DocumentSnapshot> words;
  final bool showDefinition;
  final String topicId;
  final DateTime lastAccess;

  const TypingResultPage({
    Key? key,
    required this.correctCount,
    required this.numberOfQuestions,
    required this.userAnswers,
    required this.correctAnswers,
    required this.words,
    required this.showDefinition,
    required this.topicId,
    required this.lastAccess,
  }) : super(key: key);

  @override
  _TypingResultPageState createState() => _TypingResultPageState();
}

class _TypingResultPageState extends State<TypingResultPage> {
  String userUid = FirebaseAuth.instance.currentUser!.uid;
  String? userName = FirebaseAuth.instance.currentUser!.displayName;
  late String userAvatar;

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection('users')
        .doc(userUid)
        .get()
        .then((DocumentSnapshot userSnapshot) {
      setState(() {
        userAvatar = userSnapshot['avatarURL'];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    String getFeedback(int correctCount) {
      double percentage = (correctCount / widget.numberOfQuestions) * 100;
      String feedback = '';
      if (percentage > 80) {
        feedback = 'Excellent';
      } else if (percentage < 50) {
        feedback = 'Practice more';
      } else {
        feedback = 'Good job';
      }
      return feedback;
    }

    Color getFeedbackColor(int correctCount) {
      double percentage = (correctCount / widget.numberOfQuestions) * 100;
      if (percentage > 80) {
        return Colors.green.shade600;
      } else if (percentage < 50) {
        return Colors.red;
      } else {
        return Colors.lightGreen.shade400;
      }
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          int numberOfCorrectAnswers = widget.correctCount;
          saveUserPerformance(widget.topicId, userUid, userName!, userAvatar,
              widget.lastAccess, numberOfCorrectAnswers,
              updateCompletionCount: true);
          Navigator.pop(context);
        },
        child: const Icon(Icons.save),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Quiz Completed!',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Total Score: ${widget.correctCount} / ${widget.numberOfQuestions}',
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              'Feedback: ${getFeedback(widget.correctCount)}',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: getFeedbackColor(widget.correctCount)),
            ),
            const SizedBox(height: 20),
            const Text(
              'Questions answered correctly:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Column(
              children: widget.userAnswers.asMap().entries.map((entry) {
                int index = entry.key;
                String answer = entry.value;
                bool isCorrect = answer.toLowerCase() ==
                    widget.correctAnswers[index].toLowerCase();
                return ListTile(
                  title: Text(
                    widget.showDefinition
                        ? 'Question: ${widget.words[index]['definition']}'
                        : 'Question: ${widget.words[index]['word']}',
                    style: TextStyle(
                        color: isCorrect ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 22),
                  ),
                  subtitle: Text(
                    'Your Answer: $answer\nCorrect Answer: ${widget.correctAnswers[index]}',
                    style: TextStyle(
                        color: isCorrect ? Colors.green : Colors.red,
                        fontSize: 20),
                  ),
                );
              }).toList(),
            )
          ],
        ),
      ),
    );
  }
}
