import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase_study_page.dart';

class FolderPage extends StatelessWidget {
  final String folderId;
  final String folderName;

  const FolderPage({super.key, required this.folderId, required this.folderName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(folderName,
              style:
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                          'Are you sure you want to remove this topic?'),
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
        body: FutureBuilder(
          future: _fetchTopics(folderId),
          builder: (context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
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
                String topicName = topics[index]['name'];
                String text = topics[index]['text'];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(topicName,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(text),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ));
  }

  Future<List<DocumentSnapshot>> _fetchTopics(String folderId) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('folders') // Assuming 'topics' are stored under 'folders'
          .doc(folderId)
          .collection(
              'topics') // Assuming 'topics' is a subcollection of 'folders'
          .get();
      return querySnapshot.docs;
    } catch (e) {
      print('Error fetching topics: $e');
      rethrow;
    }
  }
}
