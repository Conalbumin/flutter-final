import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quizlet_final_flutter/constant/toast.dart';

Future<void> setPrivateTopic(
    BuildContext context, String topicId, bool isPrivate) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot topicSnapshot = await FirebaseFirestore.instance
          .collection('topics')
          .doc(topicId)
          .get();
      String? ownerId = topicSnapshot['createdBy'];

      if (ownerId == user.uid) {
        await FirebaseFirestore.instance
            .collection('topics')
            .doc(topicId)
            .update({'isPrivate': isPrivate});
        isPrivate
            ? showToast('This topic is set to private')
            : showToast('This topic is set to public');
      } else {
        showToast('You do not have permission to modify this topic');
      }
    } else {
      showToast('Please sign in to modify the topic');
    }
  } catch (e) {
    print('Error updating topic: $e');
  }
}
