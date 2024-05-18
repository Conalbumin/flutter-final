import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quizlet_final_flutter/constant/text_style.dart';
import 'package:quizlet_final_flutter/study/topic/topic_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../constant/style.dart';
import '../firebase_study/related_func.dart';
import '../ranking/user_performance.dart';

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
  String userUid = FirebaseAuth.instance.currentUser!.uid;
  String? userName = FirebaseAuth.instance.currentUser!.displayName;
  late String userAvatar;
  late int correctAnswers;

  @override
  void initState() {
    super.initState();
    fetchDisplayName();
    fetchCorrectAnswers();
    FirebaseFirestore.instance
        .collection('users')
        .doc(userUid)
        .get()
        .then((DocumentSnapshot userSnapshot) {
      setState(() {
        userAvatar = userSnapshot['avatarURL'];
      });
    });
  }

  Future<int> getCorrectAnswer() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('topics')
          .doc(widget.topicId)
          .collection('access')
          .doc(userUid)
          .get();

      if (snapshot.exists) {
        // Check if the document exists
        var data = snapshot.data() as Map<String, dynamic>;
        if (data.containsKey('correctAnswers')) {
          // Check if the correctAnswers field exists
          int correctAnswersValue = data['correctAnswers'];
          return correctAnswersValue;
        } else {
          return 0;
        }
      } else {
        return 0;
      }
    } catch (error) {
      print('Error retrieving correctAnswers: $error');
      return 0;
    }
  }

  Future<void> fetchCorrectAnswers() async {
    try {
      int correctAnswersValue = await getCorrectAnswer();
      setState(() {
        correctAnswers = correctAnswersValue;
      });
    } catch (error) {
      print('Error fetching correct answers: $error');
    }
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
          bool hasAccess = await checkAndAddAccess(widget.topicId);
          if (hasAccess) {
            bool updateCompletionCount = false;
            print('correctAnswers topic public $correctAnswers');
            saveUserPerformance(widget.topicId, userUid, userName!, userAvatar,
                currentTime, correctAnswers,
                updateCompletionCount: updateCompletionCount);
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
                  lastAccess: widget.lastAccess,
                  accessPeople: widget.accessPeople,
                ),
              ),
            );
          } else {
            if (user != null && user?.uid != widget.userId) {
              _showStudyConfirmationDialog(context);
            }
          }
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
                Flexible(
                  child: Text(
                    'Joined: ${widget.accessPeople.toString()}',
                    style: const TextStyle(fontSize: 15, color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            title: Text(
              widget.topicName,
              style: const TextStyle(
                  fontSize: 30.0,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName.isNotEmpty ? displayName : 'Anonymous',
                  style: normalSubText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${widget.numberOfWords} words',
                  style: const TextStyle(fontSize: 15.0, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showStudyConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Study Topic'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'If you access then this topic will go into your personal list'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                // duplicateTopic(widget.topicId, user!.uid);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
