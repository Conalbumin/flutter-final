import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../constant/text_style.dart';
import '../firebase_study/fetch.dart';
import '../firebase_study/update.dart';
import 'edit_word_dialog.dart';

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
  late List<Map<String, String>> wordsData = [];

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
      updateTopic(topicId, _topicName, _description).then((_) {
        updateWords(topicId, wordsData).then((_) {
          // Pop with data to update the TopicPage
          Navigator.pop(context, {'topicName': _topicName, 'description': _description});
        }).catchError((error) {
          print('Error updating words: $error');
        });
      }).catchError((error) {
        print('Error updating topic: $error');
      });
    }
  }

  void _fetchCurrentWords(String topicId) async {
    try {
      List<DocumentSnapshot> snapshots = await fetchWords(topicId);
      wordsData = snapshots.map((snapshot) {
        String wordId = snapshot.id; // Get the document ID
        String initialWord = snapshot['word'];
        String initialDefinition = snapshot['definition'];
        return {
          'id': wordId, // Include the document ID in the data
          'word': initialWord,
          'definition': initialDefinition,
        };
      }).toList();

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
    } catch (e) {
      print('Error fetching current words: $e');
      // Handle error
    }
  }

  void _editWord(int index) async {
    Map<String, String> wordData = wordsData[index];
    String editedWord = wordData['word'] ?? '';
    String editedDefinition = wordData['definition'] ?? '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditWordDialog(
          initialWord: editedWord,
          initialDefinition: editedDefinition,
          onSave: (String newWord, String newDefinition) {
            setState(() {
              // Update the word data in the list
              wordsData[index]['word'] = newWord;
              wordsData[index]['definition'] = newDefinition;
              // Update the UI
              wordPages = wordsData.map((data) {
                return Card(
                  child: ListTile(
                    title: Text(data['word'] ?? ''),
                    subtitle: Text(data['definition'] ?? ''),
                  ),
                );
              }).toList();
            });
          },
        );
      },
    );
  }

  @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: Text(
            'Edit Topic',
            style: appBarStyle,
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
                ...wordsData.asMap().entries.map((entry) {
                  int index = entry.key;
                  Map<String, String> data = entry.value;
                  return GestureDetector(
                    onTap: () => _editWord(index),
                    child: Card(
                      child: ListTile(
                        title: Text(data['word'] ?? ''),
                        subtitle: Text(data['definition'] ?? ''),
                      ),
                    ),
                  );
                }).toList(),

              ],
            ),
          ),
        ),
      );
    }
  }
