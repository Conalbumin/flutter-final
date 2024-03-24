import 'package:flutter/material.dart';
import 'package:quizlet_final_flutter/study/firebase_study_page.dart';
import '../word/add_word.dart';

class AddTopicPage extends StatefulWidget {
  const AddTopicPage({super.key});

  @override
  _AddTopicPageState createState() => _AddTopicPageState();
}

class _AddTopicPageState extends State<AddTopicPage> {
  final _formKey = GlobalKey<FormState>();

  String _topicName = '';
  String _text = '';
  List<Widget> wordPages = [];

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

  void _submitForm(){
    if (_formKey.currentState!.validate()) {
      // Create a list to store the word data
      List<Map<String, String>> wordsData = [];

      // Iterate through each widget in the wordPages list
      for (Widget wordPage in wordPages) {
        // Check if the widget is an instance of AddWordPage
        if (wordPage is AddWordPage) {
          // Retrieve the state of AddWordPage using key
          AddWordPageState? wordPageState = (wordPage.key as GlobalKey<AddWordPageState>).currentState;

          // Check if the wordPageState is not null before accessing properties
          if (wordPageState != null) {
            // Access word and definition data using the state object
            String? word = wordPageState.getWord();
            String? definition = wordPageState.getDefinition();
            print("Word: $word, Definition: $definition");

            // Add the word data to the list
            wordsData.add({'word': word, 'definition': definition});
                    }
        }
      }

      // Call the function to add the topic with words
      addTopicWithWords(_topicName, _text, wordsData);
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