import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quizlet_final_flutter/constant/text_style.dart';
import '../study/firebase_study/related_func.dart';
import '../study/topic/topic.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _sortBy = 'timeCreated';

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
            suggestionsBuilder:
                (BuildContext context, SearchController controller) {
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
        Container(
            child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Sort by:', style: normalTextBlack),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Center(
                      child: DropdownButton<String>(
                        dropdownColor: Colors.blue,
                        value: _sortBy,
                        onChanged: (String? newValue) {
                          setState(() {
                            _sortBy = newValue!;
                          });
                        },
                        items: <String>['timeCreated', 'lastAccess']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                value == 'timeCreated'
                                    ? 'Creation time'
                                    : 'Last access',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        )),
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

              List<DocumentSnapshot> sortedTopics =
                  sortTopicsByTime(snapshot.data!.docs, _sortBy);

              return ListView.builder(
                itemCount: sortedTopics.length > 5 ? 5 : sortedTopics.length,
                itemBuilder: (BuildContext context, int index) {
                  DocumentSnapshot document = sortedTopics[index];
                  String topicId = document.id;
                  String topicName = document['name'];
                  String text = document['text'];
                  int numberOfWords = document['numberOfWords'];
                  bool isPrivate = document['isPrivate'];
                  String userId = document['createdBy'];
                  DateTime timeCreated =
                      (document['timeCreated'] as Timestamp).toDate();
                  DateTime lastAccess =
                      (document['lastAccess'] as Timestamp).toDate();

                  if (!isPrivate) {
                    return TopicItem(
                      topicId: topicId,
                      topicName: topicName,
                      text: text,
                      numberOfWords: numberOfWords,
                      isPrivate: isPrivate,
                      userId: userId,
                      timeCreated: timeCreated,
                      lastAccess: lastAccess,
                    );
                  } else {
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
