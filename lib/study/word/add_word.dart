import 'package:flutter/material.dart';

class AddWordPage extends StatefulWidget {
  final String? initialWord;
  final String? initialDefinition;
  final String? initialStatus;

  const AddWordPage({
    Key? key,
    this.initialWord,
    this.initialDefinition,
    this.initialStatus,
  }) : super(key: key);

  @override
  AddWordPageState createState() => AddWordPageState();

  // Generate a unique key for each instance of AddWordPage
  static GlobalKey<AddWordPageState> generateUniqueKey() {
    return GlobalKey<AddWordPageState>();
  }
}

class AddWordPageState extends State<AddWordPage> {
  late String word;
  late String definition;
  late String status = 'unLearned';

  @override
  void initState() {
    super.initState();
    word = widget.initialWord ?? '';
    definition = widget.initialDefinition ?? '';
    status = 'unLearned';
  }

  String getWord() {
    return word;
  }

  String getDefinition() {
    return definition;
  }

  String getStatus() {
    status = 'unLearned';
    return status;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: Colors.blueGrey[100],
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: TextFormField(
              decoration: const InputDecoration(
                labelText: 'Word',
                contentPadding: EdgeInsets.only(left: 10),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a word';
                }
                return null;
              },
              onChanged: (value) {
                setState(() {
                  word = value;
                  print('Word updated: $word');
                });
              },
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: TextFormField(
              decoration: const InputDecoration(
                labelText: 'Definition',
                contentPadding: EdgeInsets.only(left: 10),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a definition';
                }
                return null;
              },
              onChanged: (value) {
                setState(() {
                  definition = value;
                  print('Definition updated: $definition');
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
