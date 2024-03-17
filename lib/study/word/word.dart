import 'package:flutter/material.dart';

import '../../constant/style.dart';

class WordItem extends StatelessWidget {
  final String word;
  final String definition;

  const WordItem({
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
        color: Color.fromARGB(255, 0, 191, 255),
        elevation: 10,
        margin: const EdgeInsets.all(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  word,
                  style: const TextStyle(fontSize: 18.0, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8), // Adjust the spacing between word and definition
                Text(
                  definition,
                  style: const TextStyle(fontSize: 18.0, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
