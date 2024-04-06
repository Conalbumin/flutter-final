import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase_study_page.dart';
import '../topic/topic.dart';

class FolderPage extends StatelessWidget {
  final String folderId;
  final String folderName;
  final String text;

  const FolderPage({Key? key, required this.folderId, required this.folderName, required this.text});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              folderName,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: Colors.blue[600],
        actions: [
          IconButton(
            icon: const Icon(
              Icons.delete,
              color: Colors.white,
              size: 35,
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Remove Topic'),
                    content: const Text(
                      'Are you sure you want to remove this topic?',
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          deleteFolder(context, folderId);
                          // Here you can add the logic to remove the topic
                          // Once the topic is removed, you might want to navigate back or perform any other action
                          Navigator.of(context).pop(); // Close the dialog
                        },
                        child: const Text('Remove'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.edit,
              color: Colors.white,
              size: 35,
            ),
            onPressed: () {},
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Center(
            child: Container(
              height: 60,
              width: 350,
              decoration: BoxDecoration(
                color: Colors.indigo,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  "Description: $text",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: FutureBuilder<List<DocumentSnapshot>>(
              future: fetchTopics(folderId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No data available'));
                }
                List<DocumentSnapshot> topics = snapshot.data!;
                return ListView.builder(
                  itemCount: topics.length,
                  itemBuilder: (BuildContext context, int index) {
                    DocumentSnapshot document = snapshot.data![index];
                    String topicId = document.id;
                    String topicName = document['name'];
                    String text = document['text'];
                    int numberOfWords = document['numberOfWords'];

                    return TopicItem(
                      topicId: topicId,
                      topicName: topicName,
                      text: text,
                      numberOfWords: numberOfWords,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
