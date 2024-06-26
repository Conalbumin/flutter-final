import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quizlet_final_flutter/constant/toast.dart';

// Future<void> addTopic(
//     String topicName, String text, int numberOfWords, bool isPrivate) async {
//   try {
//     String userUid = FirebaseAuth.instance.currentUser!.uid;
//     DateTime currentTime = DateTime.now();
//     await FirebaseFirestore.instance.collection('topics').add({
//       'name': topicName,
//       'text': text,
//       'numberOfWords': numberOfWords,
//       'isPrivate': isPrivate,
//       'createdBy': userUid,
//       'timeCreated': currentTime,
//       'lastAccess': currentTime,
//       'accessPeople': 0
//     });
//   } catch (e) {
//     print('Error adding topic: $e');
//   }
// }

Future<void> addFolder(String folderName, String text) async {
  try {
    String userUid = FirebaseAuth.instance.currentUser!.uid;
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
      int? countLearn;
      if (wordData['countLearn'] is int) {
        countLearn = wordData['countLearn'] as int?;
      } else if (wordData['countLearn'] is String) {
        countLearn = int.tryParse(wordData['countLearn'] as String);
      }
      countLearn ??= 0;
      bool isFavorited = false;

      await FirebaseFirestore.instance
          .collection('topics')
          .doc(topicId)
          .collection('words')
          .add({
        'word': wordData['word'],
        'definition': wordData['definition'],
        'status': status,
        'isFavorited': isFavorited,
        'countLearn': countLearn
      });
    }

    await FirebaseFirestore.instance.collection('topics').doc(topicId).update({
      'numberOfWords': FieldValue.increment(totalWordsAdded),
    });

    print('Words added successfully addWord');
  } catch (e) {
    print('here');
    print('Error adding words: $e');
  }
}

Future<void> addWordIntoUserProgress(
    String topicId, List<Map<String, String>> wordsData) async {
  try {
    int totalWordsAdded = wordsData.length;
    // Get all documents from the 'access' collection for the specified topic
    QuerySnapshot accessSnapshot = await FirebaseFirestore.instance
        .collection('topics')
        .doc(topicId)
        .collection('access')
        .get();

    // Iterate through each document and add new words
    for (DocumentSnapshot doc in accessSnapshot.docs) {
      for (var wordData in wordsData) {
        String status = wordData['status'] ?? 'Unlearned';
        int? countLearn;
        if (wordData['countLearn'] is int) {
          countLearn = wordData['countLearn'] as int?;
        } else if (wordData['countLearn'] is String) {
          countLearn = int.tryParse(wordData['countLearn'] as String);
        }
        countLearn ??= 0;
        bool isFavorited = false;

        // Add new word to the current document in the 'access' collection
        await doc.reference.collection('words').add({
          'word': wordData['word'],
          'definition': wordData['definition'],
          'status': status,
          'isFavorited': isFavorited,
          'countLearn': countLearn
        });
      }
    }

    await FirebaseFirestore.instance.collection('topics').doc(topicId).update({
      'numberOfWords': FieldValue.increment(totalWordsAdded),
    });

    print('Words added successfully to all documents in "access"');
  } catch (e) {
    print('Error adding words: $e');
  }
}


Future<void> addTopicWithWords(String topicName, String text, bool isPrivate,
    List<Map<String, String>> wordsData) async {
  try {
    String userUid = FirebaseAuth.instance.currentUser!.uid;
    DateTime currentTime = DateTime.now();
    DocumentReference topicRef =
        await FirebaseFirestore.instance.collection('topics').add({
      'name': topicName,
      'text': text,
      'numberOfWords': wordsData.length,
      'isPrivate': isPrivate,
      'createdBy': userUid,
      'timeCreated': currentTime,
      'lastAccess': currentTime,
      'accessPeople': 0
    });

    String topicId = topicRef.id;
    for (var wordData in wordsData) {
      String status = wordData['status'] ?? 'Unlearned';
      int countLearn = wordData['countLearn'] as int? ?? 0;
      bool isFavorited = false;
      await FirebaseFirestore.instance
          .collection('topics')
          .doc(topicId)
          .collection('words')
          .add({
        'word': wordData['word'],
        'definition': wordData['definition'],
        'status': status,
        'isFavorited': isFavorited,
        'countLearn': countLearn
      });
    }

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

    print('Topic with words added successfully');
  } catch (e) {
    print('Error adding topic with words: $e');
  }
}

Future<void> addTopicToFolder(String topicId, String folderId) async {
  try {
    DocumentSnapshot topicSnapshot = await FirebaseFirestore.instance
        .collection('topics')
        .doc(topicId)
        .get();
    Map<String, dynamic> topicData =
        topicSnapshot.data() as Map<String, dynamic>;

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
      'name': topicData['name'],
      'text': topicData['text'],
      'numberOfWords': topicData['numberOfWords'],
      'isPrivate': topicData['isPrivate'],
      'createdBy': topicData['createdBy'],
      'timeCreated': topicData['timeCreated'],
      'lastAccess': topicData['lastAccess'],
      'accessPeople': topicData['accessPeople']
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
