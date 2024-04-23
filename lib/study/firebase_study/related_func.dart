import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
