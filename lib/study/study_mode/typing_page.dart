import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quizlet_final_flutter/study/study_mode/result_typing_page.dart';
import '../../constant/text_style.dart';
import '../firebase_study/fetch.dart';
import '../word/text_to_speech.dart';

class TypingPage extends StatefulWidget {
  final String topicId;
  final String topicName;
  final int numberOfWords;
  final int numberOfQuestions;
  final Function(List<String>) onType;

  const TypingPage(
      {super.key,
      required this.topicId,
      required this.topicName,
      required this.numberOfWords,
      required this.numberOfQuestions,
      required this.onType});

  @override
  State<TypingPage> createState() => _TypingPageState();
}

class _TypingPageState extends State<TypingPage> {
  int _currentIndex = 0;
  GlobalKey _menuKey = GlobalKey();
  late Future<List<DocumentSnapshot>> wordsFuture;
  FocusNode _textFocus = FocusNode();
  List<String> correctAnswersInCode = [];
  List<String> correctAnswers = [];
  List<String> newCorrectAnswers = [];
  List<String> newCorrectAnswersInCode = [];
  int numberOfCorrectAns = 0;
  List<String> userAnswers = [];
  List<String> userAnswersInCode = [];
  bool showDefinition = false;
  late List<DocumentSnapshot> words;
  String userInput = '';
  bool hasSpoken = false;

  void shuffleWords() {
    setState(() {
      List<int> indices = List<int>.generate(words.length, (index) => index);
      indices.shuffle();
      List<DocumentSnapshot> shuffledWords = List<DocumentSnapshot>.from(words);
      List<String> shuffledCorrectAnswers = List<String>.from(correctAnswers);
      List<String> shuffledCorrectAnswersInCode =
          List<String>.from(correctAnswersInCode);

      words.clear();
      indices.forEach((index) {
        words.add(shuffledWords[index]);
      });

      correctAnswers.clear();
      correctAnswersInCode.clear();
      indices.forEach((index) {
        correctAnswers.add(shuffledCorrectAnswers[index]);
        correctAnswersInCode.add(shuffledCorrectAnswersInCode[index]);
      });
    });
  }

  void fetchAnswers() async {
    try {
      List<DocumentSnapshot> words = await fetchWords(widget.topicId);
      List<DocumentSnapshot> selectedQuestions =
          words.sublist(0, widget.numberOfQuestions);

      selectedQuestions.forEach((question) {
        String correctAnswer =
            showDefinition ? question['word'] : question['definition'];
        correctAnswers.add(correctAnswer);
        correctAnswersInCode.add(correctAnswer.toLowerCase());
        newCorrectAnswers.add(correctAnswer);
        newCorrectAnswersInCode.add(correctAnswer.toLowerCase());
      });

      setState(() {
        correctAnswers = newCorrectAnswers;
        correctAnswersInCode = newCorrectAnswersInCode;
      });
    } catch (error) {
      throw error;
    }
  }

  void checkAnswer(String answer, int questionIndex) {
    String correctAnswer = correctAnswersInCode[questionIndex];
    bool isCorrect = answer.toLowerCase() == correctAnswer;

    setState(() {
      userAnswers.add(userInput);
      userAnswersInCode.add(userInput.toLowerCase());
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

    widget.onType(userAnswers);

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
              ? Text(
                  'Result',
                  style: appBarStyle,
                )
              : Text(
                  "${_currentIndex + 1}/${widget.numberOfWords}",
                  style: appBarStyle,
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
              const PopupMenuItem<String>(
                value: 'shuffle',
                child: ListTile(
                  leading: Icon(Icons.shuffle),
                  title: Text('Shuffle words'),
                ),
              ),
            ],
            onSelected: (String choice) {
              if (choice == 'switchLanguage') {
                setState(() {
                  showDefinition = !showDefinition;
                  fetchAnswers();
                });
              } else if (choice == 'shuffle') {
                shuffleWords();
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
                for (int i = 0; i < widget.numberOfQuestions; i++) {
                  if (userAnswersInCode[i] == correctAnswersInCode[i]) {
                    correctCount++;
                  }
                }
                return buildTypingResult(correctCount, widget.numberOfQuestions,
                    userAnswers, correctAnswers, words, showDefinition);
              }
              if (!hasSpoken) {
                String wordToSpeak = words[_currentIndex]['word'];
                speak(wordToSpeak);
                hasSpoken = true;
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!showDefinition)
                          IconButton(
                            icon: const Icon(
                              Icons.volume_up,
                              size: 30,
                            ),
                            onPressed: () {
                              String word = showDefinition
                                  ? words[_currentIndex]['definition']
                                  : words[_currentIndex]['word'];
                              speak(word);
                            },
                          ),
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
