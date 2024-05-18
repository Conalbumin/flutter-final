import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quizlet_final_flutter/constant/toast.dart';

void deleteFolder(BuildContext context, String folderId) {
  try {
    FirebaseFirestore.instance
        .collection('folders')
        .doc(folderId)
        .collection('topics')
        .get()
        .then((querySnapshot) {
      // Create a list to store all the asynchronous delete operations
      List<Future> deleteOperations = [];

      querySnapshot.docs.forEach((topicDoc) {
        // Delete all words associated with the topic
        deleteOperations.add(FirebaseFirestore.instance
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
        }));

        // Delete the topic document
        deleteOperations.add(topicDoc.reference.delete());
      });

      // Delete the topics collection within the folder
      deleteOperations.add(FirebaseFirestore.instance
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
      }));

      // Delete the folder itself
      deleteOperations.add(FirebaseFirestore.instance
          .collection('folders')
          .doc(folderId)
          .delete()
          .then((_) {
        print('Folder and related topics deleted successfully');
        Navigator.of(context).pop();
      }).catchError((error) {
        print('Error deleting folder: $error');
      }));

      // Wait for all delete operations to complete
      Future.wait(deleteOperations).then((_) {
        print('All delete operations completed successfully');
      }).catchError((error) {
        print('Error completing delete operations: $error');
      });
    }).catchError((error) {
      print('Error fetching topics for deletion: $error');
    });
  } catch (e) {
    print('Error: $e');
  }
}

void deleteTopic(BuildContext context, String topicId) async {
  try {
    String userUid = FirebaseAuth.instance.currentUser!.uid;
    WriteBatch batch = FirebaseFirestore.instance.batch();

    // Delete the topic document
    DocumentReference topicRef =
    FirebaseFirestore.instance.collection('topics').doc(topicId);
    batch.delete(topicRef);

    // Delete the access document for the current user
    DocumentReference accessRef =
    FirebaseFirestore.instance.collection('topics').doc(topicId).collection('access').doc(userUid);
    batch.delete(accessRef);

    // Delete all words related to the topic
    QuerySnapshot wordSnapshot = await FirebaseFirestore.instance
        .collection('topics')
        .doc(topicId)
        .collection('words')
        .get();
    wordSnapshot.docs.forEach((wordDoc) {
      batch.delete(wordDoc.reference);
    });

    // Delete all user progress related to the topic
    QuerySnapshot userProgressSnapshot = await FirebaseFirestore.instance
        .collection('topics')
        .doc(topicId)
        .collection('access')
        .doc(userUid)
        .collection('user_progress')
        .get();
    userProgressSnapshot.docs.forEach((userProgressDoc) {
      batch.delete(userProgressDoc.reference);
    });

    // Delete the access subcollection for all users
    QuerySnapshot accessSnapshot = await FirebaseFirestore.instance
        .collection('topics')
        .doc(topicId)
        .collection('access')
        .get();
    accessSnapshot.docs.forEach((accessDoc) {
      batch.delete(accessDoc.reference);
    });

    // Commit the batch
    await batch.commit();

    // Iterate over all folders to check if the topic exists and delete it
    QuerySnapshot folderSnapshot =
    await FirebaseFirestore.instance.collection('folders').get();
    for (QueryDocumentSnapshot folderDoc in folderSnapshot.docs) {
      DocumentSnapshot topicSnapshot = await FirebaseFirestore.instance
          .collection('folders')
          .doc(folderDoc.id)
          .collection('topics')
          .doc(topicId)
          .get();

      if (topicSnapshot.exists) {
        String folderId = folderDoc.id;
        deleteTopicInFolder(context, topicId, folderId);
        print(
            'Topic, associated words, and access collection deleted successfully');
      }
    }
  } catch (e) {
    print('Error: $e');
  }
}

void deleteTopicInFolder(
    BuildContext context, String topicId, String folderId) {
  try {
    // Delete the topic document from the folder's collection
    DocumentReference topicRef = FirebaseFirestore.instance
        .collection('folders')
        .doc(folderId)
        .collection('topics')
        .doc(topicId);

    topicRef.delete().then((_) {
      // Delete all words associated with the topic within the folder
      FirebaseFirestore.instance
          .collection('folders')
          .doc(folderId)
          .collection('topics')
          .doc(topicId)
          .collection('words')
          .get()
          .then((wordSnapshot) {
        List<Future> deleteOperations = [];

        wordSnapshot.docs.forEach((wordDoc) {
          deleteOperations.add(wordDoc.reference.delete());
        });

        // Wait for all delete operations to complete
        Future.wait(deleteOperations).then((_) {
          showToast(
              'Topic and associated words removed from folder successfully');
          showToast("Please go back to the previous page to see the result");
        }).catchError((error) {
          print('Error completing delete operations: $error');
        });
      }).catchError((error) {
        print('Error fetching words for deletion: $error');
      });
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
