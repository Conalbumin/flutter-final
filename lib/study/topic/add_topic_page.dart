import 'package:flutter/material.dart';
import 'package:quizlet_final_flutter/study/firebase_study_page.dart';
import '../word/add_word.dart';
import '../word/word_pages.dart';

class AddTopicPage extends StatefulWidget {
  const AddTopicPage({super.key});

  @override
  _AddTopicPageState createState() => _AddTopicPageState();
}

class _AddTopicPageState extends State<AddTopicPage> {
  final _formKey = GlobalKey<FormState>();
  String _topicName = '';
  String _text = '';
  bool isPrivate = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'Create New Topic',
          style: TextStyle(color: Colors.white),
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
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a topic name';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      _topicName = value;
                    });
                  },
                ),

                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Description'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    _text = value;
                  },
                ),
                const SizedBox(height: 50),
                ...wordPages, // Add existing AddWordPage widgets
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
            wordsData.add({'word': word, 'definition': definition});
          }
        }
      }
      addTopicWithWords(_topicName, _text, isPrivate, wordsData);
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
