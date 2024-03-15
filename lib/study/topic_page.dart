import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'quiz.dart';
import 'flashcard.dart';
import 'type.dart';

class TopicPage extends StatelessWidget {
  final String topicId;
  final String topicName;
  final int numberOfWords;

  TopicPage({required this.topicId, required this.topicName, required this.numberOfWords});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(topicName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 25)),
            Text('Number of Words: $numberOfWords', style: const TextStyle(color: Colors.white, fontSize: 15)), // Add your subtitle here
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white, size: 35,),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Remove Topic'),
                    content: const Text('Are you sure you want to remove this topic?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
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

        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 200, // Adjust the height as needed
            child: FutureBuilder(
              future: _fetchWords(topicId),
              builder: (context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
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
                        margin: const EdgeInsets.all(8),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(word, style: const TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
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
          const SizedBox(height: 20), // Add some spacing
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20), // Add margin here
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    // Handle onTap for FlashCard
                    print('FlashCard tapped');
                    // Add navigation or other actions as needed
                  },
                  child: const FlashCard(),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    // Handle onTap for Quiz
                    print('Quiz tapped');
                    // Add navigation or other actions as needed
                  },
                  child: const Quiz(),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    // Handle onTap for Type
                    print('Type tapped');
                    // Add navigation or other actions as needed
                  },
                  child: const Type(),
                ),
              ],
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