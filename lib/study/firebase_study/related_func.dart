import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quizlet_final_flutter/constant/toast.dart';

import 'fetch.dart';

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

List<DocumentSnapshot> sortTopicsByTime(
    List<DocumentSnapshot> topics, String sortBy) {
  topics.sort((a, b) {
    DateTime timeA = (a[sortBy] as Timestamp).toDate();
    DateTime timeB = (b[sortBy] as Timestamp).toDate();
    return timeB
        .compareTo(timeA);
  });
  return topics;
}

Future<bool> checkAndAddAccess(String topicId) async {
  try {
    String userUid = FirebaseAuth.instance.currentUser!.uid;
    List<DocumentSnapshot> fetchedWords = await fetchWords(topicId);

    DocumentSnapshot accessSnapshot = await FirebaseFirestore.instance
        .collection('topics')
        .doc(topicId)
        .collection('access')
        .doc(userUid)
        .get();

    CollectionReference userProgressCollection =
    FirebaseFirestore.instance
        .collection('topics')
        .doc(topicId)
        .collection('access')
        .doc(userUid)
        .collection('user_progress');

    fetchedWords.forEach((wordSnapshot) {
      userProgressCollection.add(wordSnapshot.data());
    });

    if (!accessSnapshot.exists) {
      await FirebaseFirestore.instance
          .collection('topics')
          .doc(topicId)
          .collection('access')
          .doc(userUid)
          .set({});

      await FirebaseFirestore.instance
          .collection('topics')
          .doc(topicId)
          .update({'accessPeople': FieldValue.increment(1)});

      print('Access added successfully');
      return false; // User didn't have access before
    } else {
      print('User already has access');
      return true; // User already had access
    }
  } catch (e) {
    print('Error checking and adding access: $e');
    return false; // Error occurred, treat as if user didn't have access
  }
}
