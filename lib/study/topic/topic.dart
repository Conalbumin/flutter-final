import 'package:flutter/material.dart';
import 'package:quizlet_final_flutter/study/topic/topic_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../constant/style.dart';
import '../firebase_study/related_func.dart';

class TopicItem extends StatefulWidget {
  final String topicId;
  final String topicName;
  final String text;
  final int numberOfWords;
  final bool isPrivate;
  final String userId;
  final DateTime timeCreated;
  final DateTime lastAccess;
  final int accessPeople;

  const TopicItem({
    Key? key,
    required this.topicId,
    required this.topicName,
    required this.text,
    required this.numberOfWords,
    required this.isPrivate,
    required this.userId,
    required this.timeCreated,
    required this.lastAccess,
    required this.accessPeople,
  }) : super(key: key);

  @override
  _TopicItemState createState() => _TopicItemState();
}

class _TopicItemState extends State<TopicItem> {
  late GlobalKey _key;

  @override
  void initState() {
    super.initState();
    _key = GlobalKey();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        DateTime currentTime = DateTime.now();
        try {
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
        key: _key,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        color: Colors.blue[600],
        elevation: 10,
        child: Container(
          decoration: CustomCardDecoration.cardDecoration,
          child: ListTile(
            leading: const Icon(Icons.topic, size: 60, color: Colors.white),
            title: Text(
              widget.topicName,
              style: const TextStyle(fontSize: 30.0, color: Colors.white),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.text,
                  style: const TextStyle(fontSize: 18.0, color: Colors.white),
                ),
                Text(
                  '${widget.numberOfWords} words',
                  style: const TextStyle(fontSize: 18.0, color: Colors.white),
                ),
              ],
            ),
            trailing: Visibility(
              visible: widget.isPrivate,
              child: const Icon(Icons.lock, size: 30, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
