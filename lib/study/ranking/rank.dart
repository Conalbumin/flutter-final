import 'package:card_swiper/card_swiper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quizlet_final_flutter/constant/text_style.dart';
import 'package:quizlet_final_flutter/setting/user.dart';

class RankingPage extends StatefulWidget {
  final String topicId;

  const RankingPage({super.key, required this.topicId});

  @override
  State<RankingPage> createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('Rank', style: appBarStyle),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.indigo, // Background color
                  border: Border.all(color: Colors.black), // Border color
                  borderRadius:
                      BorderRadius.circular(15.0), // Optional: border radius
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text('Most correct answer', style: normalText),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.indigo, // Background color
                      border: Border.all(color: Colors.black), // Border color
                      borderRadius: BorderRadius.circular(
                          15.0), // Optional: border radius
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text('Completed in shortest time',
                                style: normalText),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 330,
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('topics')
                        .doc(widget.topicId)
                        .collection('access')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        List<DocumentSnapshot> users = snapshot.data!.docs;
                        if (users.isEmpty) {
                          return Text(
                              "No users found in access sub-collection");
                        } else {
                          return Swiper(
                            scrollDirection: Axis.horizontal,
                            itemCount: users.length > 5 ? 5 : users.length,
                            viewportFraction: 0.6,
                            itemBuilder: (BuildContext context, int index) {
                              final userData =
                                  users[index].data() as Map<String, dynamic>;
                              return UserItem(
                                displayName: userData['userName'],
                                avatarURL: userData['userAvatar'],
                                finishedAt: userData['lastStudied'].toDate(),
                                startAt: userData['timeTaken'].toDate(),
                                correctAns: userData['correctAnswers'],
                                completionCount: userData['completionCount'],
                              );
                            },
                          );
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.indigo, // Background color
                  border: Border.all(color: Colors.black), // Border color
                  borderRadius:
                      BorderRadius.circular(15.0), // Optional: border radius
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text('Study the most times', style: normalText),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
