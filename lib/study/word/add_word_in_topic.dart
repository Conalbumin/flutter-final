import 'package:flutter/material.dart';
import 'package:quizlet_final_flutter/study/firebase_study/add.dart';
import '../../constant/text_style.dart';
import '../word/add_word.dart';
import '../word/word_pages.dart';

class AddWordInTopic extends StatefulWidget {
  final String topicId;

  const AddWordInTopic({Key? key, required this.topicId}) : super(key: key);

  @override
  _AddWordInTopicState createState() => _AddWordInTopicState();
}

class _AddWordInTopicState extends State<AddWordInTopic> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          'Add new Word',
          style: appBarStyle
        ),
        actions: [
          const SizedBox(width: 10),
          IconButton(
            icon: const Icon(Icons.check, color: Colors.white, size: 40),
            onPressed: () {
              _submitForm();
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addWordPage();
        },
        child: const Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...wordPages,
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      List<Map<String, String>> wordsData = [];

      for (Widget wordPage in wordPages) {
        if (wordPage is AddWordPage) {
          AddWordPageState? wordPageState =
              (wordPage.key as GlobalKey<AddWordPageState>).currentState;

          if (wordPageState != null) {
            String? word = wordPageState.getWord();
            String? definition = wordPageState.getDefinition();
            String? status = wordPageState.getStatus();
            bool? isFavorited = wordPageState.getIsFavorited();
            wordsData.add({
              'word': word,
              'definition': definition,
              'status': status,
              'isFavorited': isFavorited.toString() ?? ''
            });
          }
        }
      }
      addWord(widget.topicId, wordsData);
      Navigator.of(context).pop();
    }
  }

  void addWordPage() {
    setState(() {
      if (wordPages.isNotEmpty) {
        wordPages.add(const SizedBox(height: 20));
      }
      wordPages.add(AddWordPage(key: AddWordPage.generateUniqueKey()));
    });
  }
}
