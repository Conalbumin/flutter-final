import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quizlet_final_flutter/study/study_mode/result_quiz_page.dart';
import '../../constant/text_style.dart';
import '../firebase_study/fetch.dart';
import '../word/text_to_speech.dart';
import 'answer.dart';

class QuizPage extends StatefulWidget {
  final String topicId;
  final String topicName;
  final int numberOfWords;
  final int numberOfQuestions;
  final Function(List<String>) onSelectAnswer;

  const QuizPage({
    Key? key,
    required this.topicId,
    required this.topicName,
    required this.numberOfQuestions,
    required this.numberOfWords,
    required this.onSelectAnswer,
  }) : super(key: key);

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int _currentIndex = 0;
  GlobalKey _menuKey = GlobalKey();
  late Future<List<DocumentSnapshot>> wordsFuture;
  List<DocumentSnapshot> questions = [];
  List<List<String>> options = [];
  List<List<bool>> optionSelected = [];
  List<String> correctAnswers = [];
  int numberOfCorrectAns = 0;
  List<String> selectedAnswers = [];
  String correctAns = '';
  bool showDefinition = false;
  late List<DocumentSnapshot> words;
  bool hasSpoken = false;

  void shuffleQuestionsAndOptions() {
    setState(() {
      List<int> indices = List<int>.generate(words.length, (index) => index);
      indices.shuffle();
      List<DocumentSnapshot> shuffledWords = List<DocumentSnapshot>.from(words);
      List<List<String>> shuffledOptions = List<List<String>>.from(options);
      List<String> shuffledCorrectAnswers = List<String>.from(correctAnswers);

      words.clear();
      options.clear();
      correctAnswers.clear();

      indices.forEach((index) {
        words.add(shuffledWords[index]);
        options.add(shuffledOptions[index]);
        correctAnswers.add(shuffledCorrectAnswers[index]);
      });
    });
  }

  void fetchQuestions() async {
    try {
      List<DocumentSnapshot> words = await fetchWords(widget.topicId);
      List<DocumentSnapshot> selectedQuestions =
          words.sublist(0, widget.numberOfQuestions);

      List<List<String>> newOptions = [];

      selectedQuestions.forEach((question) {
        String correctAnswer =
            showDefinition ? question['word'] : question['definition'];

        List<String> allOptions = [correctAnswer];

        List<DocumentSnapshot> shuffledWords = List.from(words)..shuffle();

        shuffledWords.forEach((word) {
          if (allOptions.length < 4) {
            String option = showDefinition ? word['word'] : word['definition'];
            if (option != correctAnswer && !allOptions.contains(option)) {
              allOptions.add(option);
            }
          }
        });

        allOptions.shuffle();
        newOptions.add(allOptions);
      });

      setState(() {
        questions.clear();
        options = newOptions;
        correctAnswers.clear();
        selectedAnswers.clear();
        optionSelected.clear();

        selectedQuestions.forEach((question) {
          String correctAnswer =
              showDefinition ? question['word'] : question['definition'];
          List<bool> selected =
              List.generate(options[questions.length].length, (index) => false);
          questions.add(question);
          correctAnswers.add(correctAnswer);
          selectedAnswers.add('');
          optionSelected.add(selected);
        });
      });
    } catch (error) {
      throw error;
    }
  }

  void checkAnswer(String selectedOption, int questionIndex) {
    String correctAnswer = correctAnswers[questionIndex];
    bool isCorrect = selectedOption == correctAnswer;
    setState(() {
      correctAns = correctAnswer;
      numberOfCorrectAns++;
      selectedAnswers[questionIndex] = selectedOption;
      optionSelected[questionIndex] = List.generate(
        optionSelected[questionIndex].length,
        (index) => options[questionIndex][index] == selectedOption,
      );
    });

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
    setState(() {});
    // Call the onSelectAnswer callback with the selected answers
    widget.onSelectAnswer(selectedAnswers);
  }

  @override
  void initState() {
    super.initState();
    wordsFuture = fetchWords(widget.topicId);
    fetchQuestions();
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
                  fetchQuestions();
                });
              } else if (choice == 'shuffle') {
                shuffleQuestionsAndOptions();
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
                for (int i = 0; i < selectedAnswers.length; i++) {
                  if (selectedAnswers[i] == correctAnswers[i]) {
                    correctCount++;
                  }
                }
                return buildQuizResult(correctCount, widget.numberOfQuestions,
                    selectedAnswers, correctAnswers, words, showDefinition);
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
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      const SizedBox(height: 20),
                      buildQuizOptions(options[_currentIndex],
                          optionSelected[_currentIndex], correctAns, words),
                    ],
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget buildQuizOptions(List<String> options, List<bool> optionSelected,
      String correctAns, List<DocumentSnapshot> words) {
    return Column(
      children: options.asMap().entries.map((entry) {
        int index = entry.key;
        String option = entry.value;
        bool isSelected = optionSelected[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: GestureDetector(
            onTap: () => checkAnswer(option, _currentIndex),
            child: Answer(
              topicId: widget.topicId,
              word: showDefinition ? option : words[index]['word'],
              definition: showDefinition ? words[index]['definition'] : option,
              isSelected: isSelected,
              correct: correctAns,
              showDefinition: showDefinition,
            ),
          ),
        );
      }).toList(),
    );
  }
}
