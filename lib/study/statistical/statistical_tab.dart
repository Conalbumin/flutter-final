import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../topic/topic.dart'; // Import Firebase Auth

class StatisticalTab extends StatelessWidget {
  const StatisticalTab({Key? key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(), // Listen to authentication state changes
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (userSnapshot.hasError) {
          return Text('Error: ${userSnapshot.error}');
        }

        if (userSnapshot.data == null) {
          // If no user is signed in
          return const Center(
            child: Text('No user signed in.'),
          );
        }

        String currentUserId = userSnapshot.data!.uid; // Get the current user's ID

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('topics')
              .where('createdBy', isEqualTo: currentUserId) // Filter topics by 'createdBy' field
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            if (snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text('No topics created by the user.'),
              );
            }
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (BuildContext context, int index) {
                DocumentSnapshot document = snapshot.data!.docs[index];
                String topicId = document.id;
                String topicName = document['name'];
                String text = document['text'];
                int numberOfWords = document['numberOfWords'];
                bool isPrivate = document['isPrivate'];
                String userId = document['createdBy'];

                return TopicItem(
                  topicId: topicId,
                  topicName: topicName,
                  text: text,
                  numberOfWords: numberOfWords,
                  isPrivate: isPrivate,
                  userId: userId,
                );
              },
            );
          },
        );
      },
    );
  }
}
