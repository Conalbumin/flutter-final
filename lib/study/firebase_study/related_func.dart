import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quizlet_final_flutter/constant/toast.dart';
import 'fetch.dart';

Future<void> duplicateTopic(String topicId, String userId) async {
  try {
    DocumentSnapshot topicSnapshot = await FirebaseFirestore.instance
        .collection('topics')
        .doc(topicId)
        .get();
    Map<String, dynamic> topicData =
        topicSnapshot.data() as Map<String, dynamic>;
    DateTime currentTime = DateTime.now();

    // Duplicate the topic
    DocumentReference duplicatedTopicRef =
        await FirebaseFirestore.instance.collection('topics').add({
      ...topicData,
      'isPrivate': true,
      'createdBy': userId,
      'timeCreated': currentTime,
      'lastAccess': currentTime,
      'accessPeople': 0,
    });

    // Fetch words from the original topic
    List<DocumentSnapshot> words = await fetchWords(topicId);

    // Add words to the duplicated topic
    CollectionReference wordsCollection =
        duplicatedTopicRef.collection('words');
    words.forEach((wordSnapshot) {
      wordsCollection.doc(wordSnapshot.id).set(wordSnapshot.data());
    });

    print('Topic duplicated successfully');
  } catch (e) {
    print('Error duplicating topic: $e');
  }
}

Future<bool> isTopicCreatedByCurrentUser(String topicId) async {
  try {
    String userUid = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot topicSnapshot = await FirebaseFirestore.instance
        .collection('topics')
        .doc(topicId)
        .get();
    String? ownerId = topicSnapshot['createdBy'];
    return ownerId == userUid;
  } catch (e) {
    print('Error checking if topic is created by current user: $e');
    return false;
  }
}

Future<void> setPrivateTopic(
    BuildContext context, String topicId, bool isPrivate) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      bool createdByCurrentUser = await isTopicCreatedByCurrentUser(topicId);
      if (createdByCurrentUser) {
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
    return timeB.compareTo(timeA);
  });
  return topics;
}

Future<bool> checkAndAddAccess(String topicId) async {
  try {
    DateTime currentTime = DateTime.now();
    await FirebaseFirestore.instance.collection('topics').doc(topicId).update({
      'lastAccess': currentTime,
    });
    String userUid = FirebaseAuth.instance.currentUser!.uid;
    List<DocumentSnapshot> fetchedWords = await fetchWords(topicId);

    // Get all documents inside the "access" collection
    QuerySnapshot accessSnapshot = await FirebaseFirestore.instance
        .collection('topics')
        .doc(topicId)
        .collection('access')
        .get();

    print(accessSnapshot.docs);
    // Check if the user's document exists in the "access" collection
    bool userExists = accessSnapshot.docs.any((doc) => doc.id == userUid);

    if (!userExists) {
      // Add the user's document to the "access" collection
      await FirebaseFirestore.instance
          .collection('topics')
          .doc(topicId)
          .collection('access')
          .doc(userUid)
          .set({});

      // Increment the value of accessPeople
      await FirebaseFirestore.instance
          .collection('topics')
          .doc(topicId)
          .update({'accessPeople': FieldValue.increment(1)});

      // Initialize the "user_progress" collection and add data for each word
      CollectionReference userProgressCollection = FirebaseFirestore.instance
          .collection('topics')
          .doc(topicId)
          .collection('access')
          .doc(userUid)
          .collection('user_progress');

      fetchedWords.forEach((wordSnapshot) {
        userProgressCollection.doc(wordSnapshot.id).set(wordSnapshot.data());
      });

      print('Access added successfully 1');
      return false; // User didn't have access before
    } else {
      // Check if the "user_progress" collection exists
      CollectionReference userProgressCollection = FirebaseFirestore.instance
          .collection('topics')
          .doc(topicId)
          .collection('access')
          .doc(userUid)
          .collection('user_progress');

      QuerySnapshot userProgressSnapshot =
      await userProgressCollection.limit(1).get();

      // If the "user_progress" collection doesn't exist, add data for each word
      if (userProgressSnapshot.docs.isEmpty) {
        fetchedWords.forEach((wordSnapshot) {
          userProgressCollection.doc(wordSnapshot.id).set(wordSnapshot.data());
        });
        print('Access added successfully 2');
      } else {
        print('User already has access');
      }
      return true; // User already had access
    }
  } catch (e) {
    print('Error checking and adding access: $e');
    return false; // Error occurred, treat as if user didn't have access
  }
}
