import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quizlet_final_flutter/study/word/word.dart';
import '../firebase_study_page.dart';
import '../study_mode/quiz.dart';
import '../study_mode/flashcard.dart';
import '../study_mode/type.dart';
import 'edit_topic_page.dart';
import 'package:card_swiper/card_swiper.dart';

class TopicPage extends StatelessWidget {
  final String topicId;
  final String topicName;
  final int numberOfWords;
  final String text;

  TopicPage(
      {required this.topicId,
      required this.topicName,
      required this.numberOfWords,
      required this.text});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(topicName,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 25)),
            Text('Number of Words: $numberOfWords',
                style: const TextStyle(color: Colors.white, fontSize: 15)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.delete,
              color: Colors.white,
              size: 35,
            ),
            onPressed: () {
              _showDeleteConfirmationDialog(context, topicId);
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'edit',
                child: ListTile(
                  leading: Icon(Icons.edit),
                  title: Text('Edit'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'addToFolder',
                child: ListTile(
                  leading: Icon(Icons.folder),
                  title: Text('Add to Folder'),
                ),
              ),
            ],
            onSelected: (String choice) {
              if (choice == 'edit') {
                editAction(context, topicName, text);
                print('Edit action');
              } else if (choice == 'addToFolder') {
                // addTopicToFolder(topicId, folderId);
                print('Add to folder action');
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 200, // Adjust the height as needed
              child: FutureBuilder(
                future: _fetchWords(topicId),
                builder:
                    (context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    List<DocumentSnapshot> words = snapshot.data!;
                    return Swiper(
                      pagination: const SwiperPagination(
                        builder: DotSwiperPaginationBuilder(
                          color: Colors.white,
                          activeColor: Colors.indigo,
                          activeSize: 15,
                          size: 10,
                        ),
                      ),
                      scrollDirection: Axis.horizontal,
                      itemCount: words.length,
                      itemBuilder: (context, index) {
                        String word = words[index]['word'];
                        String definition = words[index]['definition'];
                        return WordItem(definition: definition, word: word);
                      },
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Container(
                height: 60,
                width: 300,
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
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
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
            const SizedBox(height: 20),
            FutureBuilder(
              future: _fetchWords(topicId),
              builder:
                  (context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  List<DocumentSnapshot> words = snapshot.data!;
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: words.length,
                    itemBuilder: (context, index) {
                      String word = words[index]['word'];
                      String definition = words[index]['definition'];
                      return WordItem(definition: definition, word: word)
                          .card();
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void editAction(BuildContext context, String initialTopicName,
      String initialDescription) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTopicPage(
          topicId: topicId,
          initialTopicName: initialTopicName,
          initialDescription: initialDescription,
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, String topicId) {
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
                deleteTopic(context, topicId);
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Remove'),
            ),
          ],
        );
      },
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
