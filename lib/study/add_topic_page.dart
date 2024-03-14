import 'package:flutter/material.dart';

import 'add_word.dart';

class AddTopicPage extends StatefulWidget {
  const AddTopicPage({Key? key}) : super(key: key);

  @override
  _AddTopicPageState createState() => _AddTopicPageState();
}

class _AddTopicPageState extends State<AddTopicPage> {
  final _formKey = GlobalKey<FormState>();

  String _topicName = '';
  String _text = '';
  List<Widget> wordPages = []; // List to hold AddWordPage widgets

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
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white, size: 40),
            onPressed: () {
              _showConfirmationDialog();
            },
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: const Icon(Icons.check, color: Colors.white, size: 40),
            onPressed: () {
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
                    _topicName = value;
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
    // Handle form submission here, e.g., call a function to add the topic to Firestore
    // addTopic(_topicName, _text, _numberOfWords);
    // Then navigate back to the previous page
    Navigator.pop(context);
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
  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Remove Topic"),
          content: const Text("Are you sure you want to remove this topic?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                // Perform the action to remove the topic here
                // For now, let's just close the dialog
                Navigator.of(context).pop();
              },
              child: const Text("Remove"),
            ),
          ],
        );
      },
    );
  }
}
