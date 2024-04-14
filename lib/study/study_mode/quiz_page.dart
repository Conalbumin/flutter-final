import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quizlet_final_flutter/study/firebase_study_page.dart';
import 'answer.dart'; // Import the Answer widget

class QuizPage extends StatefulWidget {
  final String topicId;
  final String topicName;
  final int numberOfWords;
  final String text;
  final bool isPrivate;
  final String userId;

  const QuizPage(
      {super.key,
      required this.topicId,
      required this.topicName,
      required this.numberOfWords,
      required this.text,
      required this.isPrivate,
      required this.userId});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int _currentIndex = 0;
  GlobalKey _menuKey = GlobalKey();
  late Future<List<DocumentSnapshot>> wordsFuture;

  @override
  void initState() {
    super.initState();
    wordsFuture = fetchWords(widget.topicId);
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
              return const CircularProgressIndicator(); // Show a loading indicator while fetching data
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
                  Answer(
                    definition: words[_currentIndex]['definition'] ?? '',
                    topicId: '',
                    wordId: '',
                  ), // Pass the definition to the Answer widget
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
