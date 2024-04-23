import 'package:flutter/material.dart';

class StatisticalWord extends StatelessWidget {
  final String word;
  final String definition;
  final String status;
  final String wordId;
  final String topicId;

  const StatisticalWord({
    Key? key,
    required this.word,
    required this.definition,
    required this.status,
    required this.wordId,
    required this.topicId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      key: const ValueKey('front'),
      color: const Color.fromARGB(255, 0, 191, 255),
      elevation: 10,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    word,
                    style: const TextStyle(fontSize: 25, color: Colors.white),
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 10,
                  ),
                  Text(
                    definition,
                    style: const TextStyle(fontSize: 20, color: Colors.white),
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 10,
                  ),
                ],
              ),
            ),
            Text(
              status,
              style: const TextStyle(fontSize: 20, color: Colors.white),
              textAlign: TextAlign.end,
            ),
          ],
        ),
      ),
    );
  }
}
