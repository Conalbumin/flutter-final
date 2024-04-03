import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

Future<void> addTopic(String topicName, String text, int numberOfWords) async {
  try {
    await FirebaseFirestore.instance
        .collection('topics')
        .add({'name': topicName, 'text': text, 'numberOfWords': numberOfWords});
  } catch (e) {
    print('Error adding topic: $e');
  }
}

Future<void> addFolder(String folderName, String text) async {
  try {
    await FirebaseFirestore.instance
        .collection('folders')
        .add({'name': folderName, 'text': text});
  } catch (e) {
    print('Error adding folder: $e');
  }
}

Future<void> addTopicWithWords(
    String topicName, String text, List<Map<String, String>> wordsData) async {
  try {
    DocumentReference topicRef =
        await FirebaseFirestore.instance.collection('topics').add({
      'name': topicName,
      'text': text,
      'numberOfWords': wordsData.length,
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
    await FirebaseFirestore.instance
        .collection('folders')
        .doc(folderId)
        .collection('topics')
        .add({
      'topicId': topicId,
    });
  } catch (e) {
    print('Error adding topic to folder: $e');
  }
}

Stream<QuerySnapshot> getTopics() {
  return FirebaseFirestore.instance.collection('topics').snapshots();
}

Stream<QuerySnapshot> getTopicsInFolder(String folderId) {
  return FirebaseFirestore.instance
      .collection('folders')
      .doc(folderId)
      .collection('topics')
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

Future<void> updateTopic(
    String topicId, String newTopicName, String newDescription) async {
  try {
    await FirebaseFirestore.instance.collection('topics').doc(topicId).update({
      'name': newTopicName,
      'text': newDescription,
    });
    print("name ${newTopicName}");
    print("text ${newDescription}");
    print('Topic updated successfully');
  } catch (e) {
    print('Error updating topic: $e');
  }
}

Future<void> updateWords(
    String topicId, List<Map<String, String>> wordsData) async {
  try {
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
