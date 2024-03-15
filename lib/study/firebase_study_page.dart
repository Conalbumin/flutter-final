import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

Future<void> addTopic(String topicName,  String text, int numberOfWords) async {
  try {
    await FirebaseFirestore.instance.collection('topics').add({
      'name': topicName,
      'text': text,
      'numberOfWords': numberOfWords
    });
  } catch (e) {
    print('Error adding topic: $e');
  }
}

Future<void> addFolder(String folderName, String text) async {
  try {
    await FirebaseFirestore.instance.collection('folders').add({
      'name': folderName,
      'text': text
    });
  } catch (e) {
    print('Error adding folder: $e');
  }
}

Future<void> addTopicToFolder(String topicId, String folderId) async {
  try {
    await FirebaseFirestore.instance.collection('folders').doc(folderId).collection('topics').add({
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
  return FirebaseFirestore.instance.collection('folders').doc(folderId).collection('topics').snapshots();
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

// Add other CRUD operations as needed
