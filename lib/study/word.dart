import 'package:flutter/material.dart';

import '../constant/style.dart';

class WordItem extends StatelessWidget {
  final String wordId;
  final String word;
  final String definition;

  const WordItem({
    required this.wordId,
    required this.definition,
    required this.word,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print("object");
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
            title: Text(
              definition,
              style: const TextStyle(fontSize: 30.0, color: Colors.white),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  word,
                  style: const TextStyle(fontSize: 18.0, color: Colors.white),
                ),
                Text(
                  definition,
                  style: const TextStyle(fontSize: 18.0, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
