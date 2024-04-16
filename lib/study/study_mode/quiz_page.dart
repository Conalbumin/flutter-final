import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quizlet_final_flutter/study/firebase_study_page.dart';
import 'answer.dart';

class QuizPage extends StatefulWidget {
  final String topicId;
  final String topicName;
  final int numberOfWords;
  final int numberOfQuestions;

  const QuizPage({
    Key? key,
    required this.topicId,
    required this.topicName,
    required this.numberOfQuestions,
    required this.numberOfWords,
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

  void fetchQuestions() async {
    try {
      List<DocumentSnapshot> words = await fetchWords(widget.topicId);
      List<DocumentSnapshot> selectedQuestions =
      words.sublist(0, widget.numberOfQuestions);

      List<List<String>> newOptions = []; // New list to hold options

      selectedQuestions.forEach((question) {
        String correctAnswer = showDefinition
            ? question['word']
            : question['definition'];

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
        newOptions.add(allOptions); // Add options for current question
      });

      setState(() {
        questions.clear();
        options = newOptions; // Update options with newOptions
        correctAnswers.clear();
        selectedAnswers.clear();
        optionSelected.clear();

        selectedQuestions.forEach((question) {
          String correctAnswer = showDefinition
              ? question['word']
              : question['definition'];
          List<bool> selected = List.generate(
              options[questions.length].length, (index) => false);
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
  }

  @override
  void initState() {
    super.initState();
    wordsFuture = fetchWords(widget.topicId);
    fetchQuestions();
  }

  @override
  void dispose() {
    super.dispose();
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
                  fetchQuestions();
                });
                // buildQuizOptions(options[_currentIndex], optionSelected[_currentIndex], correctAns, words);
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
                int incorrectCount = widget.numberOfQuestions - correctCount;
                return SingleChildScrollView(
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
                        'Total Score: $correctCount / ${widget.numberOfQuestions}',
                        style: const TextStyle(fontSize: 25),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Questions answered correctly:',
                        style: TextStyle(fontSize: 20),
                      ),
                      Column(
                        children: selectedAnswers.asMap().entries.map((entry) {
                          int index = entry.key;
                          String answer = entry.value;
                          bool isCorrect = answer == correctAnswers[index];
                          return ListTile(
                            title: Text(
                              'Question: ${words[index]['word']}',
                              style: TextStyle(
                                color: isCorrect ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 22
                              ),
                            ),
                            subtitle: Text(
                              'Your Answer: $answer\nCorrect Answer: ${correctAnswers[index]}',
                              style: TextStyle(
                                color: isCorrect ? Colors.green : Colors.red,
                                  fontSize: 20
                              ),
                            ),
                          );
                        }).toList(),
                      ),
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
                          showDefinition ? words[_currentIndex]['definition'] : words[_currentIndex]['word'],
                          style: const TextStyle(fontSize: 30),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        // Add blank space here if needed
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      const SizedBox(height: 20),
                      buildQuizOptions(options[_currentIndex], optionSelected[_currentIndex], correctAns, words),
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

  Widget buildQuizOptions(List<String> options, List<bool> optionSelected, String correctAns, List<DocumentSnapshot> words) {
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
              word: words[index]['word'],
              definition: option,
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
