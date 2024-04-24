import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Future<void> setPrivateTopic(BuildContext context, String topicId, bool isPrivate) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot topicSnapshot = await FirebaseFirestore.instance
          .collection('topics')
          .doc(topicId)
          .get();
      String? ownerId = topicSnapshot['createdBy'];

      // Check if the current user is the owner of the topic
      if (ownerId == user.uid) {
        await FirebaseFirestore.instance
            .collection('topics')
            .doc(topicId)
            .update({'isPrivate': isPrivate});
        print('Topic updated successfully');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: isPrivate ? const Text('This topic is set to private') : const Text('This topic is set to public'),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        print('User does not have permission to modify this topic');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You do not have permission to modify this topic'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      print('User not authenticated');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to modify the topic'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  } catch (e) {
    print('Error updating topic: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error updating topic: $e'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
