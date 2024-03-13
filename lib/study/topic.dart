import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
        return ListView(
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            return TopicItem(
              topicName: document['name'],
            );
          }).toList(),
        );
      },
    );
  }
}

class TopicItem extends StatelessWidget {
  final String topicName;

  const TopicItem({required this.topicName});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(topicName),
      // Add more customization as needed
    );
  }
}