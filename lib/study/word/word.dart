import 'package:flutter/material.dart';
import 'package:flutter_flip_card/controllers/flip_card_controllers.dart';
import 'package:flutter_flip_card/flipcard/flip_card.dart';
import 'package:flutter_flip_card/modal/flip_side.dart';

class WordItem extends StatefulWidget {
  final String word;
  final String definition;

  const WordItem({
    required this.definition,
    required this.word,
  });

  @override
  State<WordItem> createState() => _WordItemState();

  Widget card() {
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
                SizedBox(width: 10),
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
                SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
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
