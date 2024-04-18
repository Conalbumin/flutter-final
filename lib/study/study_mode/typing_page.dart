import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../firebase_study_page.dart';

class TypingPage extends StatefulWidget {
  final String topicId;
  final String topicName;
  final int numberOfWords;
  final int numberOfQuestions;

  const TypingPage(
      {super.key,
      required this.topicId,
      required this.topicName,
      required this.numberOfWords,
      required this.numberOfQuestions});

  @override
  State<TypingPage> createState() => _TypingPageState();
}

class _TypingPageState extends State<TypingPage> {
  int _currentIndex = 0;
  GlobalKey _menuKey = GlobalKey();
  late Future<List<DocumentSnapshot>> wordsFuture;
  List<DocumentSnapshot> questions = [];
  FocusNode _textFocus = FocusNode();
  List<String> correctAnswers = [];
  int numberOfCorrectAns = 0;
  List<String> userAnswers = [];
  String correctAns = '';
  bool showDefinition = false;
  late List<DocumentSnapshot> words;
  String userInput = '';

  void fetchAnswers() async {
    try {
      List<DocumentSnapshot> words = await fetchWords(widget.topicId);
      List<DocumentSnapshot> selectedQuestions =
          words.sublist(0, widget.numberOfQuestions);

      selectedQuestions.forEach((question) {
        String correctAnswer =
            showDefinition ? question['word'] : question['definition'];
        correctAnswers.add(correctAnswer.toLowerCase());
      });

    } catch (error) {
      throw error;
    }
  }

  void checkAnswer(String answer, int questionIndex) {
    String correctAnswer = correctAnswers[questionIndex];
    bool isCorrect = answer.toLowerCase() == correctAnswer;

    setState(() {
      userAnswers.add(userInput);
      numberOfCorrectAns++;
      userInput = '';
    });

    _textFocus.unfocus();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isCorrect ? 'Correct!' : 'Incorrect!'),
          content: Text(isCorrect
              ? 'You chose the correct answer.'
              : 'The correct answer is: $correctAnswer'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (_currentIndex <= widget.numberOfQuestions - 1) {
                  setState(() {
                    _currentIndex++;
                  });
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Quiz Completed!'),
                        content: const Text('You have finished all questions.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    wordsFuture = fetchWords(widget.topicId);
    fetchAnswers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Center(
          child: _currentIndex >= widget.numberOfQuestions
              ? const Text(
                  'Result',
                  style: TextStyle(color: Colors.white, fontSize: 30),
                )
              : Text(
                  "${_currentIndex + 1}/${widget.numberOfWords}",
                  style: const TextStyle(color: Colors.white, fontSize: 30),
                ),
        ),
        actions: [
          const SizedBox(width: 15),
          PopupMenuButton<String>(
            key: _menuKey,
            icon: const Icon(Icons.settings, color: Colors.white, size: 30),
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'switchLanguage',
                child: ListTile(
                  leading: Icon(Icons.switch_camera),
                  title: Text('Switch language'),
                ),
              ),
            ],
            onSelected: (String choice) {
              if (choice == 'switchLanguage') {
                setState(() {
                  showDefinition = !showDefinition;
                  fetchAnswers();
                });
              }
            },
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: FutureBuilder<List<DocumentSnapshot>>(
          future: wordsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              words = snapshot.data ?? [];
              if (words.isEmpty) {
                return const Text('No words found for this topic.');
              }
              if (_currentIndex >= widget.numberOfQuestions) {
                int correctCount = 0;
                String feedback = '';
                Color feedbackColor = Colors.black;
                for (int i = 0; i < widget.numberOfQuestions; i++) {
                  if (userAnswers[i] == correctAnswers[i]) {
                    correctCount++;
                  }
                }
                double percentage =
                    (correctCount / widget.numberOfQuestions) * 100;
                if (percentage > 80) {
                  feedback = 'Excellent';
                  feedbackColor = Colors.green.shade600;
                } else if (percentage < 50) {
                  feedback = 'Practice more';
                  feedbackColor = Colors.red;
                } else {
                  feedback = 'Good job';
                  feedbackColor = Colors.lightGreen.shade400;
                }
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Quiz Completed!',
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Total Score: $correctCount / ${widget.numberOfQuestions}',
                        style: const TextStyle(fontSize: 25),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Feedback: $feedback',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: feedbackColor),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Questions answered correctly:',
                        style: TextStyle(fontSize: 20),
                      ),
                      Column(
                        children: userAnswers.asMap().entries.map((entry) {
                          int index = entry.key;
                          String answer = entry.value;
                          print('answer ${answer}');
                          bool isCorrect = answer.toLowerCase() == userAnswers[index];
                          return ListTile(
                            title: Text(
                              'Question: ${words[index]['word']}',
                              style: TextStyle(
                                  color: isCorrect ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22),
                            ),
                            subtitle: Text(
                              'Your Answer: $answer\nCorrect Answer: ${userAnswers[index]}',
                              style: TextStyle(
                                  color: isCorrect ? Colors.green : Colors.red,
                                  fontSize: 20),
                            ),
                          );
                        }).toList(),
                      )
                    ],
                  ),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          showDefinition
                              ? words[_currentIndex]['definition']
                              : words[_currentIndex]['word'],
                          style: const TextStyle(fontSize: 30),
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            key: UniqueKey(),
                            focusNode: _textFocus,
                            onChanged: (value) {
                              userInput = value;
                            },
                            decoration: const InputDecoration(
                              hintText: 'Type your answer here...',
                              labelText: 'Answer',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            checkAnswer(userInput, _currentIndex);
                          },
                          child: const Icon(Icons.navigate_next, size: 50),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.blue,
                            minimumSize: const Size(10, 60),
                            elevation: 5,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
