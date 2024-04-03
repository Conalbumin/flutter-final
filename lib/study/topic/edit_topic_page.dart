import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quizlet_final_flutter/study/firebase_study_page.dart';

List<Widget> wordPages = [];

class EditTopicPage extends StatefulWidget {
  final String topicId;
  final String initialTopicName;
  final String initialDescription;

  const EditTopicPage({
    Key? key,
    required this.initialTopicName,
    required this.initialDescription,
    required this.topicId,
  }) : super(key: key);

  @override
  _EditTopicPageState createState() => _EditTopicPageState();
}

class _EditTopicPageState extends State<EditTopicPage> {
  final _formKey = GlobalKey<FormState>();
  late String topicId;
  late String _topicName;
  late String _description;
  late List<Map<String, String>> wordsData; // Define wordsData here

  @override
  void initState() {
    super.initState();
    _topicName = widget.initialTopicName;
    _description = widget.initialDescription;
    topicId = widget.topicId;
    _fetchCurrentWords(topicId);
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      updateTopic(topicId, _topicName, _description);
      // updateWords(topicId, wordsData);
      Navigator.of(context).pop();
    }
  }

  void _fetchCurrentWords(String topicId) async {
    try {
      List<DocumentSnapshot> snapshots = await fetchWords(topicId);
      List<Map<String, String>> wordsData = snapshots.map((snapshot) {
        String initialWord = snapshot['word'];
        String initialDefinition = snapshot['definition'];
        return {'word': initialWord, 'definition': initialDefinition};
      }).toList();
      print("wordsData ${wordsData}");

      setState(() {
        wordPages = wordsData.map((data) {
          return Card(
            child: ListTile(
              title: Text(data['word'] ?? ''),
              subtitle: Text(data['definition'] ?? ''),
            ),
          );
        }).toList();

        if (wordPages.isEmpty) {
          wordPages.add(const SizedBox(height: 20));
        }
      });

      print('wordPages after setState: $wordPages');
    } catch (e) {
      print('Error fetching current words: $e');
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'Edit Topic',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          const SizedBox(width: 10),
          IconButton(
            icon: const Icon(Icons.check, color: Colors.white, size: 40),
            onPressed: _submitForm,
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                initialValue: _topicName,
                decoration: const InputDecoration(labelText: 'Topic Name'),
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
                initialValue: _description,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _description = value;
                  });
                },
              ),
              const SizedBox(height: 32),
              ...wordPages,
            ],
          ),
        ),
      ),
    );
  }
}
