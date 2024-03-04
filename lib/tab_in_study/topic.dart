import 'package:flutter/material.dart';

class TopicTab extends StatelessWidget {
  const TopicTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          _topicItem('Topic Tab', 2),
          _topicItem('Topic Tab', 3),
          _topicItem('Topic Tab', 4),
        ],
      ),
    );
  }

  Widget _topicItem(String text, int numberOfWords) {
    return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        color: Colors.blue[600],
        elevation: 10,
        child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          ListTile(
            leading: const Icon(Icons.topic, size: 60, color: Colors.white,),
            title: Text(text, style: const TextStyle(fontSize: 30.0, color: Colors.white)),
            subtitle: Text('${numberOfWords} words', style: const TextStyle(fontSize: 18.0, color: Colors.white)),

    )
        ]));
  }
}
