import 'package:flutter/material.dart';

class Answer extends StatefulWidget {
  final String topicId;
  final String wordId;
  final String definition;
  final bool isSelected;
  final String correct;

  Answer({
    Key? key,
    required this.topicId,
    required this.wordId,
    required this.definition,
    required this.isSelected,
    required this.correct,
  }) : super(key: key);

  @override
  State<Answer> createState() => _AnswerState();
}

class _AnswerState extends State<Answer> {
  @override
  Widget build(BuildContext context) {
    Color borderColor = Colors.grey;
    if (widget.isSelected && widget.definition == widget.correct) {
      borderColor = Colors.green;
    } else if (widget.isSelected &&
        widget.definition != widget.correct) {
      borderColor = Colors
          .red;
    }

    return FractionallySizedBox(
      widthFactor: 1,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue[100],
          border: Border.all(color: borderColor, width: 3),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            widget.definition,
            style: const TextStyle(
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }
}
