import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quizlet_final_flutter/study/statistical/statistical_word.dart';
import '../firebase_study_page.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quizlet_final_flutter/study/statistical/statistical_word.dart';
import '../firebase_study_page.dart';

class StatisticalPage extends StatefulWidget {
  final String topicId;
  final String topicName;
  final int numberOfWords;
  final String text;
  final bool isPrivate;
  final String userId;

  const StatisticalPage({
    Key? key,
    required this.topicId,
    required this.numberOfWords,
    required this.topicName,
    required this.text,
    required this.isPrivate,
    required this.userId,
  }) : super(key: key);

  @override
  State<StatisticalPage> createState() => _StatisticalPageState();
}

class _StatisticalPageState extends State<StatisticalPage> {
  int learnedCount = 0;
  int unlearnedCount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.topicName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
            Text(
              'Number of Words: ${widget.numberOfWords}',
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 600,
              child: FutureBuilder(
                future: fetchWords(widget.topicId),
                builder: (context,
                    AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    List<DocumentSnapshot> words = snapshot.data!;
                    learnedCount = 0;
                    unlearnedCount = 0; // Reset counts before updating
                    for (var wordSnapshot in words) {
                      String status = wordSnapshot['status'];
                      if (status == 'Learned') {
                        learnedCount++;
                      } else {
                        unlearnedCount++;
                      }
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Learned: $learnedCount',
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green
                                ),
                              ),
                              Text(
                                'Unlearned: $unlearnedCount',
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: words.length,
                            itemBuilder: (context, index) {
                              String word = words[index]['word'];
                              String definition = words[index]['definition'];
                              String status = words[index]['status'];
                              return StatisticalWord(
                                word: word,
                                definition: definition,
                                status: status,
                                wordId: words[index].id,
                                topicId: widget.topicId,
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


