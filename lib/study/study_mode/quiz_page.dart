import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quizlet_final_flutter/study/firebase_study_page.dart';
import 'answer.dart'; // Import the Answer widget

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
  List<String> selectedAnswers = [];
  String correctAns = '';

  void fetchQuestions() async {
    try {
      List<DocumentSnapshot> words = await fetchWords(widget.topicId);

      List<DocumentSnapshot> selectedQuestions =
      words.sublist(0, widget.numberOfQuestions);

      selectedQuestions.forEach((question) {
        String correctAnswer = question['definition'];

        List<String> allOptions = [correctAnswer];

        // Shuffle all the words
        List<DocumentSnapshot> shuffledWords = List.from(words)..shuffle();

        // Select unique options different from the correct answer
        shuffledWords.forEach((word) {
          if (allOptions.length < widget.numberOfQuestions) {
            String option = word['definition'];
            if (option != correctAnswer && !allOptions.contains(option)) {
              allOptions.add(option);
            }
          }
        });

        // Shuffle the options for randomness
        allOptions.shuffle();

        List<bool> selected = List.generate(allOptions.length,
                (index) => false); // Initialize all options as not selected
        setState(() {
          questions.add(question);
          options.add(allOptions);
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

                // Move to the next question if available
                if (_currentIndex < widget.numberOfQuestions - 1) {
                  setState(() {
                    _currentIndex++;
                  });
                } else {
                  // If there are no more questions, you can handle it here
                  // For example, show a dialog indicating the end of the quiz
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Quiz Completed!'),
                        content: Text('You have finished all questions.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              // You can navigate to another page or perform any action here
                            },
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );

    // Ensure that the widget tree is rebuilt after updating _currentIndex
    setState(() {});
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
          child: Text(
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
                if (choice == 'switchLanguage') {}
              }),
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
              List<DocumentSnapshot> words = snapshot.data ?? [];
              if (words.isEmpty) {
                return Text('No words found for this topic.');
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  Center(
                    child: Text(
                      words[_currentIndex]['word'] ?? '',
                      style: TextStyle(fontSize: 30),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 20),
                  ...(options[_currentIndex] ?? []).asMap().entries.map((entry) {
                    int index = entry.key;
                    String option = entry.value;
                    bool isSelected = optionSelected[_currentIndex][index];
                    String correct = correctAns;
                    return GestureDetector(
                      onTap: () => checkAnswer(option, _currentIndex),
                      child: Answer(
                        topicId: widget.topicId,
                        wordId: '',
                        definition: option,
                        isSelected: isSelected,
                        correct: correct,
                      ),
                    );
                  }).toList(),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
