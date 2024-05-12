import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quizlet_final_flutter/constant/text_style.dart';
import 'package:quizlet_final_flutter/study/topic/topic_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../constant/style.dart';
import '../firebase_study/related_func.dart';

class TopicPublicItem extends StatefulWidget {
  final String topicId;
  final String topicName;
  final String text;
  final int numberOfWords;
  final bool isPrivate;
  final String userId;
  final DateTime timeCreated;
  final DateTime lastAccess;
  final int accessPeople;

  const TopicPublicItem({
    super.key,
    required this.topicId,
    required this.topicName,
    required this.text,
    required this.numberOfWords,
    required this.isPrivate,
    required this.userId,
    required this.timeCreated,
    required this.lastAccess,
    required this.accessPeople,
  });

  @override
  State<TopicPublicItem> createState() => _TopicPublicItemState();
}

class _TopicPublicItemState extends State<TopicPublicItem> {
  final user = FirebaseAuth.instance.currentUser;
  String displayName = '';

  @override
  void initState() {
    super.initState();
    fetchDisplayName();
  }

  Future<void> fetchDisplayName() async {
    try {
      DocumentSnapshot topicSnapshot = await FirebaseFirestore.instance
          .collection('topics')
          .doc(widget.topicId)
          .get();

      if (topicSnapshot.exists) {
        String createdBy = topicSnapshot['createdBy'];

        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(createdBy)
            .get();

        if (userSnapshot.exists) {
          setState(() {
            displayName = userSnapshot['displayName'];
          });
        } else {
          print('User not found');
        }
      } else {
        print('Topic not found');
      }
    } catch (error) {
      print('Error fetching display name: $error');
    }
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        DateTime currentTime = DateTime.now();
        try {
          await FirebaseFirestore.instance
              .collection('topics')
              .doc(widget.topicId)
              .update({
            'lastAccess': currentTime,
          });
          checkAndAddAccess(widget.topicId);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TopicPage(
                  topicId: widget.topicId,
                  topicName: widget.topicName,
                  numberOfWords: widget.numberOfWords,
                  text: widget.text,
                  isPrivate: widget.isPrivate,
                  userId: widget.userId,
                  refreshCallback: () {},
                  timeCreated: widget.timeCreated,
                  lastAccess: currentTime,
                  accessPeople: widget.accessPeople,
                ),
              ),
            );
        } catch (error) {
          print('Error updating lastAccess: $error');
        }
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        color: Colors.blue[600],
        elevation: 10,
        child: Container(
          decoration: CustomCardDecoration.cardDecoration,
          child: ListTile(
            leading: const Icon(Icons.topic, size: 60, color: Colors.white),
            trailing: Column(
              children: [
                Text(displayName.isNotEmpty ? displayName : 'Anonymous',
                    style: normalSubText),
                Text('People joined: ${widget.accessPeople.toString()}',
                    style: const TextStyle(fontSize: 18, color: Colors.white))
              ],
            ),
            title: Text(
              widget.topicName,
              style: const TextStyle(
                  fontSize: 30.0,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.text,
                  style: const TextStyle(fontSize: 20.0, color: Colors.white),
                ),
                Text(
                  '${widget.numberOfWords} words',
                  style: const TextStyle(fontSize: 20.0, color: Colors.white),
                ),
              ],
            ),
            // trailing:,
          ),
        ),
      ),
    );
  }
}
