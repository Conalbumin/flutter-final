import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TopicPage extends StatelessWidget {
  final String topicId;
  final String topicName;
  final int numberOfWords;

  TopicPage({required this.topicId, required this.topicName, required this.numberOfWords});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(topicName),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {
              // Add your action here
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Number of Words: $numberOfWords',
              style: TextStyle(fontSize: 16),
            ),
          ),
          SizedBox(
            height: 200, // Adjust the height as needed
            child: FutureBuilder(
              future: _fetchWords(topicId),
              builder: (context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  List<DocumentSnapshot> words = snapshot.data!;
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: words.length,
                    itemBuilder: (context, index) {
                      String word = words[index]['word'];
                      String definition = words[index]['definition'];
                      return Card(
                        margin: EdgeInsets.all(8),
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(word, style: TextStyle(fontWeight: FontWeight.bold)),
                              SizedBox(height: 4),
                              Text(definition),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<List<DocumentSnapshot>> _fetchWords(String topicId) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('topics')
          .doc(topicId)
          .collection('words')
          .get();
      return querySnapshot.docs;
    } catch (e) {
      print('Error fetching words: $e');
      throw e;
    }
  }
}
