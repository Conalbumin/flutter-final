import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'topic.dart';

class TopicTab extends StatelessWidget {
  const TopicTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('topics').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (BuildContext context, int index) {
            DocumentSnapshot document = snapshot.data!.docs[index];
            String topicId = document.id;
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


