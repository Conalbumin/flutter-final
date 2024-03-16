import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../word/add_word.dart';

class AddTopicPage extends StatefulWidget {
  const AddTopicPage({Key? key}) : super(key: key);

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
          _addWordPage();
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
                  // onChanged: (value) { _topicName = value; }, // Remove this line
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
    print("Context: $context");
    if (_formKey.currentState!.validate()) {
      // Create a list to store the word data
      List<Map<String, String>> wordsData = [];

      // Loop through each AddWordPage and extract the word and definition
      for (Widget wordPage in wordPages) {
        if (wordPage is AddWordPage) {
          // Extract the word and definition using the of() method
          print("Attempting to get word and definition...");
          String? word = AddWordPage.of(context)?.getWord();
          String? definition = AddWordPage.of(context)?.getDefinition();
          print("Word: $word, Definition: $definition");

          // Add the word data to the list
          if (word != null && definition != null) {
            wordsData.add({'word': word, 'definition': definition});
          }
        }
      }

      // Now you have the list of word data, you can add it to Firestore
      addTopicWithWords(_topicName, _text, wordsData);
      print("click");
    }
  }


// Function to add a topic to Firestore along with the words
  void addTopicWithWords(String topicName, String text, List<Map<String, String>> wordsData) async {
    try {
      // Add the topic to Firestore
      DocumentReference topicRef = await FirebaseFirestore.instance.collection('topics').add({
        'name': topicName,
        'text': text,
        'numberOfWords': wordsData.length,
      });

      // Loop through each word data and add it to Firestore
      for (var wordData in wordsData) {
        await topicRef.collection('words').add({
          'word': wordData['word'],
          'definition': wordData['definition'],
        });
      }

      // Navigate back to the previous page
      Navigator.pop(context);
    } catch (e) {
      print('Error adding topic with words: $e');
    }
  }

  // Function to add a new AddWordPage widget
  void _addWordPage() {
    setState(() {
      if (wordPages.isNotEmpty) {
        wordPages.add(const SizedBox(height: 20)); // Add space only if there are existing AddWordPage widgets
      }
      wordPages.add(const AddWordPage());
    });
  }

  // Function to show the confirmation dialog for removing the topic
}
