import 'package:cloud_firestore/cloud_firestore.dart';

// Function to add a topic to Firestore
Future<void> addTopic(String topicName) async {
  try {
    await FirebaseFirestore.instance.collection('topics').add({
      'name': topicName,
    });
  } catch (e) {
    print('Error adding topic: $e');
  }
}

Future<void> addFolder(String folderName) async {
  try {
    await FirebaseFirestore.instance.collection('folders').add({
      'name': folderName,
    });
  } catch (e) {
    print('Error adding folder: $e');
  }
}

// Function to add a topic to a folder in Firestore
Future<void> addTopicToFolder(String topicId, String folderId) async {
  try {
    await FirebaseFirestore.instance.collection('folders').doc(folderId).collection('topics').add({
      'topicId': topicId,
    });
  } catch (e) {
    print('Error adding topic to folder: $e');
  }
}

// Function to retrieve topics from Firestore
Stream<QuerySnapshot> getTopics() {
  return FirebaseFirestore.instance.collection('topics').snapshots();
}

// Function to retrieve topics in a folder from Firestore
Stream<QuerySnapshot> getTopicsInFolder(String folderId) {
  return FirebaseFirestore.instance.collection('folders').doc(folderId).collection('topics').snapshots();
}

// Add other CRUD operations as needed
