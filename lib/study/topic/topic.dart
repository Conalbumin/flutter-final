import 'package:flutter/material.dart';
import 'package:quizlet_final_flutter/study/topic/topic_page.dart';

import '../../constant/style.dart';

class TopicItem extends StatelessWidget {
  final String topicId;
  final String topicName;
  final String text;
  final int numberOfWords;

  const TopicItem({super.key, 
    required this.topicId,
    required this.topicName,
    required this.text,
    required this.numberOfWords,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print("object");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TopicPage(
              topicId: topicId,
              topicName: topicName,
              numberOfWords: numberOfWords,
              text: text,
            ),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        color: Colors.blue[600],
        elevation: 10,
        child: Container(
          decoration: CustomCardDecoration.cardDecoration,
          child: ListTile(
            leading: const Icon(Icons.topic, size: 60, color: Colors.white),
            title: Text(
              topicName,
              style: const TextStyle(fontSize: 30.0, color: Colors.white),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: const TextStyle(fontSize: 18.0, color: Colors.white),
                ),
                Text(
                  '$numberOfWords words',
                  style: const TextStyle(fontSize: 18.0, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
