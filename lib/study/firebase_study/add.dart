import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quizlet_final_flutter/constant/toast.dart';

Future<void> addTopic(
    String topicName, String text, int numberOfWords, bool isPrivate) async {
  try {
    String userUid =
        FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection('topics').add({
      'name': topicName,
      'text': text,
      'numberOfWords': numberOfWords,
      'isPrivate': isPrivate,
      'createdBy': userUid,
    });
  } catch (e) {
    print('Error adding topic: $e');
  }
}

Future<void> addFolder(String folderName, String text) async {
  try {
    String userUid =
        FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection('folders').add({
      'name': folderName,
      'text': text,
      'createdBy': userUid,
    });
  } catch (e) {
    print('Error adding folder: $e');
  }
}

Future<void> addWord(
    String topicId, List<Map<String, String>> wordsData) async {
  try {
    int totalWordsAdded = wordsData.length;

    for (var wordData in wordsData) {
      String status = wordData['status'] ?? 'Unlearned';
      bool isFavorited = false;

      await FirebaseFirestore.instance
          .collection('topics')
          .doc(topicId)
          .collection('words')
          .add({
        'word': wordData['word'],
        'definition': wordData['definition'],
        'status': status,
        'isFavorited': isFavorited
      });
    }

    // Increment the numberOfWords field in the topic document by the total number of words added
    await FirebaseFirestore.instance.collection('topics').doc(topicId).update({
      'numberOfWords': FieldValue.increment(totalWordsAdded),
    });

    print('Words added successfully');
  } catch (e) {
    print('Error adding words: $e');
  }
}

Future<void> addTopicWithWords(String topicName, String text, bool isPrivate,
    List<Map<String, String>> wordsData) async {
  try {
    String userUid = FirebaseAuth.instance.currentUser!.uid;
    DocumentReference topicRef =
    await FirebaseFirestore.instance.collection('topics').add({
      'name': topicName,
      'text': text,
      'numberOfWords': wordsData.length,
      'isPrivate': isPrivate,
      'createdBy': userUid
    });

    String topicId = topicRef.id;

    for (var wordData in wordsData) {
      String status = wordData['status'] ?? 'unLearned';
      bool isFavorited = false;

      await FirebaseFirestore.instance
          .collection('topics')
          .doc(topicId)
          .collection('words')
          .add({
        'word': wordData['word'],
        'definition': wordData['definition'],
        'status': status,
        'isFavorited': isFavorited
      });
    }

    print('Topic with words added successfully');
  } catch (e) {
    print('Error adding topic with words: $e');
  }
}

Future<void> addTopicToFolder(String topicId, String folderId) async {
  try {
    // Fetch topic details
    DocumentSnapshot topicSnapshot = await FirebaseFirestore.instance
        .collection('topics')
        .doc(topicId)
        .get();
    Map<String, dynamic> topicData =
    topicSnapshot.data() as Map<String, dynamic>;

    // Fetch topic words
    QuerySnapshot wordsSnapshot = await FirebaseFirestore.instance
        .collection('topics')
        .doc(topicId)
        .collection('words')
        .get();

    // Create a batch to perform multiple operations atomically
    WriteBatch batch = FirebaseFirestore.instance.batch();

    // Add topic details to the folder
    DocumentReference topicRef = FirebaseFirestore.instance
        .collection('folders')
        .doc(folderId)
        .collection('topics')
        .doc(topicId);
    batch.set(topicRef, {
      // 'topicId': topicId,
      'name': topicData['name'],
      'text': topicData['text'],
      'numberOfWords': topicData['numberOfWords'],
      'isPrivate': topicData['isPrivate'],
      'createdBy': topicData['createdBy']
    });

    // Add topic words to the folder
    wordsSnapshot.docs.forEach((wordDoc) {
      batch.set(topicRef.collection('words').doc(wordDoc.id), wordDoc.data());
    });

    // Commit the batch
    await batch.commit();

    print('Topic and related data added to folder successfully');
    showToast('Topic and related data added to folder successfully');
  } catch (e) {
    print('Error adding topic to folder: $e');
  }
}