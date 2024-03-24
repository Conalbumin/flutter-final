import 'package:flutter/material.dart';
import 'package:flutter_flip_card/controllers/flip_card_controllers.dart';
import 'package:flutter_flip_card/flipcard/flip_card.dart';
import 'package:flutter_flip_card/modal/flip_side.dart';
import 'package:quizlet_final_flutter/study/firebase_study_page.dart';

class WordItem extends StatefulWidget {
  final String word;
  final String definition;
  final String wordId;
  final String topicId;

  const WordItem({
    Key? key,
    required this.word,
    required this.definition,
    required this.wordId,
    required this.topicId,
  }) : super(key: key);

  @override
  State<WordItem> createState() => _WordItemState();

  Widget card(BuildContext context) {
    return Card(
      color: Colors.indigo[900],
      elevation: 5,
      margin: const EdgeInsets.all(15),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  word,
                  style: const TextStyle(fontSize: 35, color: Colors.white),
                  textAlign: TextAlign.start,
                ),
                Text(
                  definition,
                  style: const TextStyle(fontSize: 35, color: Colors.white),
                  textAlign: TextAlign.start,
                ),
              ],
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    print("0 icon clicked");
                  },
                  child: const Icon(
                    Icons.volume_down_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    print("First icon clicked");
                  },
                  child: const Icon(
                    Icons.edit,
                    color: Colors.white,
                    size: 35,
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    showDeleteConfirmationDialog(context, topicId, wordId);
                    print("Second icon clicked");
                  },
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                    size: 35,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void showDeleteConfirmationDialog(BuildContext context, String topicId, String wordId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove word'),
          content: const Text('Are you sure you want to remove this word?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                print("wordId ${wordId}");
                print("topicId ${topicId}");
                deleteWord(context, topicId, wordId);
                Navigator.of(context).pop();
              },
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }
}

class _WordItemState extends State<WordItem> {
  final flip = FlipCardController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print("object");
      },
      child: FlipCard(
        controller: flip,
        onTapFlipping: true,
        rotateSide: RotateSide.bottom,
        frontWidget: _buildFront(),
        backWidget: _buildBack(),
      ),
    );
  }

  Widget _buildFront() {
    return Card(
      key: const ValueKey('front'),
      color: const Color.fromARGB(255, 0, 191, 255),
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
                widget.word,
                style: const TextStyle(fontSize: 35, color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBack() {
    return Card(
      key: const ValueKey('back'),
      color: const Color.fromARGB(255, 0, 191, 255),
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
                widget.definition,
                style: const TextStyle(fontSize: 35, color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

