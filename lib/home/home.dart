import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../study/topic/topic.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          child: SearchAnchor(
            builder: (BuildContext context, SearchController controller) {
              return SearchBar(
                controller: controller,
                padding: const MaterialStatePropertyAll<EdgeInsets>(
                  EdgeInsets.symmetric(horizontal: 10.0),
                ),
                onTap: () {
                  controller.openView();
                },
                onChanged: (_) {
                  controller.openView();
                },
                leading: const Icon(Icons.search),
              );
            },
            suggestionsBuilder: (BuildContext context, SearchController controller) {
              return List<ListTile>.generate(5, (int index) {
                final String item = 'item $index';
                return ListTile(
                  title: Text(item),
                  onTap: () {
                    setState(() {
                      controller.closeView(item);
                    });
                  },
                );
              });
            },
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('topics').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (BuildContext context, int index) {
                  DocumentSnapshot document = snapshot.data!.docs[index];
                  String topicId = document.id;
                  String topicName = document['name'];
                  String text = document['text'];
                  int numberOfWords = document['numberOfWords'];
                  bool isPrivate = document['isPrivate'];
                  String userId = document['createdBy'];

                  // Check if the topic is not private
                  if (!isPrivate) {
                    return TopicItem(
                      topicId: topicId,
                      topicName: topicName,
                      text: text,
                      numberOfWords: numberOfWords,
                      isPrivate: isPrivate, userId: userId,
                    );
                  } else {
                    // Return an empty container if the topic is private
                    return Container();
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }
}


