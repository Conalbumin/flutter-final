import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quizlet_final_flutter/study/topic_page.dart';
import '../constant/style.dart';
import 'folder.dart';

class TopicTab extends StatelessWidget {
  const TopicTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('topics').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (BuildContext context, int index) {
            DocumentSnapshot document = snapshot.data!.docs[index];
            String topicId = document.id; // Extract topicId from DocumentSnapshot
            String topicName = document['name'];
            String text = document['text'];
            int numberOfWords = document['numberOfWords'];

            return TopicItem(
              topicId: topicId,
              topicName: topicName,
              text: text,
              numberOfWords: numberOfWords,
            );
          },
        );
      },
    );
  }
}

class TopicItem extends StatelessWidget {
  final String topicId;
  final String topicName;
  final String text;
  final int numberOfWords;

  const TopicItem({
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
