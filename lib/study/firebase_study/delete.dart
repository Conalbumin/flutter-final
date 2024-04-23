import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

void deleteFolder(BuildContext context, String folderId) {
  try {
    // Delete all topics within the folder and their associated words
    FirebaseFirestore.instance
        .collection('folders')
        .doc(folderId)
        .collection('topics')
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((topicDoc) {
        // Delete all words associated with the topic
        FirebaseFirestore.instance
            .collection('topics')
            .doc(topicDoc.id)
            .collection('words')
            .get()
            .then((wordsSnapshot) {
          wordsSnapshot.docs.forEach((wordDoc) {
            wordDoc.reference.delete();
          });
        }).catchError((error) {
          print('Error fetching words for deletion: $error');
        });

        // Delete the topic document
        topicDoc.reference.delete();
      });

      // Delete the topics collection within the folder
      FirebaseFirestore.instance
          .collection('folders')
          .doc(folderId)
          .collection('topics')
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          doc.reference.delete();
        });
      }).catchError((error) {
        print('Error deleting topics collection: $error');
      });

      // Delete the folder itself
      FirebaseFirestore.instance
          .collection('folders')
          .doc(folderId)
          .delete()
          .then((_) {
        print('Folder and related topics deleted successfully');
        Navigator.of(context).pop();
      }).catchError((error) {
        print('Error deleting folder: $error');
      });
    }).catchError((error) {
      print('Error fetching topics for deletion: $error');
    });
  } catch (e) {
    print('Error: $e');
  }
}

void deleteTopic(BuildContext context, String topicId) {
  try {
    // Create a batch to perform multiple delete operations atomically
    WriteBatch batch = FirebaseFirestore.instance.batch();

    // Delete the topic document
    DocumentReference topicRef =
    FirebaseFirestore.instance.collection('topics').doc(topicId);
    batch.delete(topicRef);

    // Delete all words associated with the topic
    FirebaseFirestore.instance
        .collection('topics')
        .doc(topicId)
        .collection('words')
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((wordDoc) {
        batch.delete(wordDoc.reference);
      });

      // Commit the batch
      batch.commit().then((_) {
        print('Topic and associated words deleted successfully');
        Navigator.of(context).pop();
      }).catchError((error) {
        print('Error committing batch delete: $error');
      });
      Navigator.of(context).pop();
    }).catchError((error) {
      print('Error fetching words for deletion: $error');
    });
  } catch (e) {
    print('Error: $e');
  }
}

void deleteTopicInFolder(
    BuildContext context, String topicId, String folderId) {
  try {
    // Fetch the reference of the topic in the folder's collection
    DocumentReference topicRef = FirebaseFirestore.instance
        .collection('folders')
        .doc(folderId)
        .collection('topics')
        .doc(topicId);

    // Delete the reference of the topic from the folder
    topicRef.delete().then((_) {
      print('Topic removed from folder successfully');
    }).catchError((error) {
      print('Error removing topic from folder: $error');
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