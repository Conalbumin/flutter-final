import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quizlet_final_flutter/study/statistical/statistical_word.dart';
import '../../constant/text_style.dart';
import '../firebase_study/fetch.dart';
import '../firebase_study/update.dart';

class StatisticalPage extends StatefulWidget {
  final String topicId;
  final String topicName;
  final int numberOfWords;
  final String text;
  final bool isPrivate;
  final String userId;
  final DateTime timeCreated;
  final DateTime lastAccess;

  const StatisticalPage({
    Key? key,
    required this.topicId,
    required this.numberOfWords,
    required this.topicName,
    required this.text,
    required this.isPrivate,
    required this.userId,
    required this.timeCreated,
    required this.lastAccess,
  }) : super(key: key);

  @override
  State<StatisticalPage> createState() => _StatisticalPageState();
}

class _StatisticalPageState extends State<StatisticalPage> {
  int learnedCount = 0;
  int unlearnedCount = 0;
  int masteredCount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.topicName, style: appBarStyle),
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
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: SizedBox(
                child: FutureBuilder(
                  future: fetchWordsInStatistical(widget.topicId),
                  builder: (context,
                      AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else {
                      List<DocumentSnapshot> words = snapshot.data!;
                      learnedCount = 0;
                      unlearnedCount = 0;
                      masteredCount = 0;
                      for (var wordSnapshot in words) {
                        String status = wordSnapshot['status'];
                        if (status == 'Learned') {
                          learnedCount++;
                        } else if (status == 'Unlearned') {
                          unlearnedCount++;
                        } else {
                          masteredCount++;
                        }
                      }

                      Color iconColor = Colors.grey; // Default color

                      // Determine the color based on the highest count
                      if (unlearnedCount >= learnedCount &&
                          unlearnedCount >= masteredCount) {
                        iconColor = Colors.red;
                      } else if (learnedCount >= unlearnedCount &&
                          learnedCount >= masteredCount) {
                        iconColor = Colors.green;
                      } else {
                        iconColor = Colors.green.shade900;
                      }

                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Align(
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.check_circle,
                                  size: 120,
                                  color: iconColor,
                                ),
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                _buildStatRow(
                                    "Unlearned", unlearnedCount, Colors.red),
                                _buildStatRow(
                                    "Learned", learnedCount, Colors.green),
                                _buildStatRow("Mastered", masteredCount,
                                    Colors.green.shade900),
                              ],
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 700,
              child: FutureBuilder(
                future: fetchWordsInStatistical(widget.topicId),
                builder:
                    (context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    List<DocumentSnapshot> words = snapshot.data!;
                    learnedCount = 0;
                    unlearnedCount = 0;
                    masteredCount = 0;
                    for (var wordSnapshot in words) {
                      String status = wordSnapshot['status'];
                      if (status == 'Learned') {
                        learnedCount++;
                      } else if (status == 'Unlearned') {
                        unlearnedCount++;
                      } else {
                        masteredCount++;
                      }
                    }
                    return ListView.builder(
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

  Widget _buildStatRow(String label, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            label,
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(width: 5),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: color,
                width: 3,
              ),
            ),
            child: Center(
              child: Text(
                '$count',
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, color: color),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
