import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Future<void> addTopic(
    String topicName, String text, int numberOfWords, bool isPrivate) async {
  try {
    String userUid =
        FirebaseAuth.instance.currentUser!.uid; // Get current user's UID
    await FirebaseFirestore.instance.collection('topics').add({
      'name': topicName,
      'text': text,
      'numberOfWords': numberOfWords,
      'isPrivate': isPrivate,
      'createdBy': userUid, // Store user UID along with the topic
    });
  } catch (e) {
    print('Error adding topic: $e');
  }
}

Future<void> addFolder(String folderName, String text) async {
  try {
    String userUid =
        FirebaseAuth.instance.currentUser!.uid; // Get current user's UID
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
      await FirebaseFirestore.instance
          .collection('topics')
          .doc(topicId)
          .collection('words')
          .add({
        'word': wordData['word'],
        'definition': wordData['definition'],
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
      await FirebaseFirestore.instance
          .collection('topics')
          .doc(topicId)
          .collection('words')
          .add({
        'word': wordData['word'],
        'definition': wordData['definition'],
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
      'topicId': topicId,
      'name': topicData['name'],
      'text': topicData['text'],
      'numberOfWords': topicData['numberOfWords'],
    });

    // Add topic words to the folder
    wordsSnapshot.docs.forEach((wordDoc) {
      batch.set(topicRef.collection('words').doc(wordDoc.id), wordDoc.data());
    });

    // Commit the batch
    await batch.commit();

    print('Topic and related data added to folder successfully');
  } catch (e) {
    print('Error adding topic to folder: $e');
  }
}

Stream<QuerySnapshot> getTopics() {
  String userUid = FirebaseAuth.instance.currentUser!.uid;
  return FirebaseFirestore.instance
      .collection('topics')
      .where('isPrivate', isEqualTo: false)
      .where('createdBy', isEqualTo: userUid)
      .snapshots();
}

Stream<QuerySnapshot> getTopicsInFolder(String folderId) {
  String userUid = FirebaseAuth.instance.currentUser!.uid;
  return FirebaseFirestore.instance
      .collection('folders')
      .doc(folderId)
      .collection('topics')
      .where('isPrivate', isEqualTo: false)
      .where('createdBy', isEqualTo: userUid)
      .snapshots();
}

Future<List<DocumentSnapshot>> fetchWords(String topicId) async {
  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('topics')
        .doc(topicId)
        .collection('words')
        .get();
    return querySnapshot.docs;
  } catch (e) {
    print('Error fetching words: $e');
    rethrow;
  }
}

Future<List<DocumentSnapshot>> fetchTopics(String folderId) async {
  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('folders')
        .doc(folderId)
        .collection('topics')
        .get();
    return querySnapshot.docs;
  } catch (e) {
    print('Error fetching topics: $e');
    rethrow;
  }
}

Future<void> updateTopic(
    String topicId, String newTopicName, String newDescription) async {
  try {
    await FirebaseFirestore.instance.collection('topics').doc(topicId).update({
      'name': newTopicName,
      'text': newDescription,
    });
    print('Topic updated successfully');
  } catch (e) {
    print('Error updating topic: $e');
  }
}

Future<void> setPrivateTopic(String topicId, bool isPrivate) async {
  try {
    await FirebaseFirestore.instance
        .collection('topics')
        .doc(topicId)
        .update({'isPrivate': isPrivate});
    print('Topic updated successfully');
  } catch (e) {
    print('Error updating topic: $e');
  }
}

Future<void> updateFolder(
    String folderId, String newFolderName, String newDescription) async {
  try {
    await FirebaseFirestore.instance
        .collection('folders')
        .doc(folderId)
        .update({
      'name': newFolderName,
      'text': newDescription,
    });
    print('Folder updated successfully');
  } catch (e) {
    print('Error updating folder: $e');
  }
}

Future<void> updateWords(
    String topicId, List<Map<String, String>> wordsData) async {
  try {
    for (var wordData in wordsData) {
      // Get the document ID of the word
      String wordId =
          wordData['id'] ?? ''; // Assuming 'id' is the key for the document ID
      // Update the document with the new data
      await FirebaseFirestore.instance
          .collection('topics')
          .doc(topicId)
          .collection('words')
          .doc(wordId)
          .set({
        'word': wordData['word'],
        'definition': wordData['definition'],
      });
    }
    print('Words updated successfully');
  } catch (e) {
    print('Error updating words: $e');
  }
}

void deleteFolder(BuildContext context, String folderId) {
  try {
    FirebaseFirestore.instance
        .collection('folders')
        .doc(folderId)
        .delete()
        .then((_) {
      print('Folder deleted successfully');
      Navigator.of(context).pop();
    }).catchError((error) {
      print('Error deleting folder: $error');
    });
  } catch (e) {
    print('Error: $e');
  }
}

void deleteTopic(BuildContext context, String topicId) {
  try {
    FirebaseFirestore.instance
        .collection('topics')
        .doc(topicId)
        .delete()
        .then((_) {
      print('Topic deleted successfully');
      Navigator.of(context).pop();
    }).catchError((error) {
      print('Error deleting topic: $error');
    });
  } catch (e) {
    print('Error: $e');
  }
}

void deleteTopicInFolder(
    BuildContext context, String topicId, String folderId) {
  try {
    FirebaseFirestore.instance
        .collection('folders')
        .doc(folderId)
        .collection('topics')
        .doc(topicId)
        .delete()
        .then((_) {
      print('Topic deleted successfully');
      Navigator.of(context).pop();
    }).catchError((error) {
      print('Error deleting topic: $error');
    });
  } catch (e) {
    print('Error: $e');
  }
}

void deleteWord(BuildContext context, String topicId, String wordId) {
  try {
    FirebaseFirestore.instance
        .collection('topics')
        .doc(topicId)
        .collection('words')
        .doc(wordId)
        .delete()
        .then((_) {
      // Update the number of words in the topic document
      FirebaseFirestore.instance.collection('topics').doc(topicId).update({
        'numberOfWords': FieldValue.increment(-1),
      }).then((_) {
        print('Number of words updated successfully');
        Navigator.of(context).pop();
      }).catchError((error) {
        print('Error updating number of words: $error');
      });
    }).catchError((error) {
      print('Error deleting word: $error');
    });
  } catch (e) {
    print('Error: $e');
  }
}
