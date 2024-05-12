import 'package:card_swiper/card_swiper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:quizlet_final_flutter/constant/text_style.dart';
import 'package:quizlet_final_flutter/setting/user.dart';

import '../../constant/style.dart';

class RankingPage extends StatefulWidget {
  final String topicId;
  final int numberOfWords;

  const RankingPage(
      {super.key, required this.topicId, required this.numberOfWords});

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
                        Center(
                          child: Text('Most correct answer', style: normalText),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 250,
                          child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('topics')
                                .doc(widget.topicId)
                                .collection('access')
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              }
                              if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else {
                                List<DocumentSnapshot> users =
                                    snapshot.data!.docs;
                                if (users.isEmpty) {
                                  return const Text(
                                      "No users found in access sub-collection");
                                } else {
                                  users.sort((a, b) => b['correctAnswers']
                                      .compareTo(a['correctAnswers']));
                                  users.sort((a, b) =>
                                      b['timeTaken'].compareTo(a['timeTaken']));

                                  List<DocumentSnapshot> mostCorrectAnsUser =
                                      users
                                          .take(users.length > 3
                                              ? 3
                                              : users.length)
                                          .toList();

                                  return Swiper(
                                    loop: false,
                                    autoplay: true,
                                    scrollDirection: Axis.horizontal,
                                    itemCount: mostCorrectAnsUser.length,
                                    viewportFraction: 0.6,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      final userData = mostCorrectAnsUser
                                          .reversed
                                          .toList()[index]
                                          .data() as Map<String, dynamic>;
                                      if (userData.isNotEmpty) {
                                        return UserItem(
                                          displayName: userData['userName'],
                                          avatarURL: userData['userAvatar'],
                                          finishedAt:
                                              userData['lastStudied'].toDate(),
                                          startAt:
                                              userData['timeTaken'].toDate(),
                                          correctAns:
                                              userData['correctAnswers'],
                                          completionCount:
                                              userData['completionCount'],
                                          cardType: CardType.Answer,
                                          numberOfWords: widget.numberOfWords,
                                        );
                                      } else {
                                        return Container(
                                          decoration: CustomCardDecoration
                                              .cardDecoration,
                                          padding: const EdgeInsets.all(20.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                  "Let become one of the first user study this topic",
                                                  style: normalText),
                                            ],
                                          ),
                                        );
                                      }
                                    },
                                  );
                                }
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ],
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
                        Center(
                          child: Text('Completed in shortest time',
                              style: normalText),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 320,
                          child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('topics')
                                .doc(widget.topicId)
                                .collection('access')
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              }
                              if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else {
                                List<DocumentSnapshot> users =
                                    snapshot.data!.docs;
                                if (users.isEmpty) {
                                  return const Text(
                                      "No users found in access sub-collection");
                                } else {
                                  users = users
                                      .where((user) => (user.data()
                                                  as Map<String, dynamic>)
                                              .containsKey('correctAnswers')
                                          ? (user.data() as Map<String,
                                                  dynamic>)['correctAnswers'] ==
                                              widget.numberOfWords
                                          : false)
                                      .toList();
                                  users.sort((a, b) =>
                                      a['timeTaken'].compareTo(b['timeTaken']));

                                  List<DocumentSnapshot> fastestUsers = users
                                      .take(users.length > 3 ? 3 : users.length)
                                      .toList();
                                  print("users $users");

                                  if(fastestUsers.isNotEmpty) {
                                    return Swiper(
                                      loop: false,
                                      autoplay: true,
                                      scrollDirection: Axis.horizontal,
                                      itemCount: fastestUsers.length,
                                      viewportFraction: 0.6,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        final userData = fastestUsers.reversed
                                            .toList()[index]
                                            .data() as Map<String, dynamic>;
                                        return UserItem(
                                          displayName: userData['userName'],
                                          avatarURL: userData['userAvatar'],
                                          finishedAt:
                                          userData['lastStudied'].toDate(),
                                          startAt:
                                          userData['timeTaken'].toDate(),
                                          correctAns:
                                          userData['correctAnswers'],
                                          completionCount:
                                          userData['completionCount'],
                                          cardType: CardType.Time,
                                          numberOfWords: widget.numberOfWords,
                                        );

                                      },
                                    );
                                  } else {
                                    return Container(
                                      decoration: CustomCardDecoration
                                          .cardDecoration,
                                      padding: const EdgeInsets.all(20.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                              "Let become one of the first user study this topic",
                                              style: normalText),
                                        ],
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ],
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
                        Center(
                            child: Text('Study the most times',
                                style: normalText)),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 300,
                          child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('topics')
                                .doc(widget.topicId)
                                .collection('access')
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              }
                              if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else {
                                List<DocumentSnapshot> users =
                                    snapshot.data!.docs;
                                if (users.isEmpty) {
                                  return const Text(
                                      "No users found in access sub-collection");
                                } else {
                                  List<DocumentSnapshot> mostTimesUser = users
                                      .take(users.length > 3 ? 3 : users.length)
                                      .toList();

                                  return Swiper(
                                    loop: false,
                                    autoplay: true,
                                    scrollDirection: Axis.horizontal,
                                    itemCount: mostTimesUser.length,
                                    viewportFraction: 0.6,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      final userData = mostTimesUser.reversed
                                          .toList()[index]
                                          .data() as Map<String, dynamic>;
                                      if(userData.isNotEmpty) {
                                        return UserItem(
                                          displayName: userData['userName'],
                                          avatarURL: userData['userAvatar'],
                                          finishedAt:
                                          userData['lastStudied'].toDate(),
                                          startAt: userData['timeTaken'].toDate(),
                                          correctAns: userData['correctAnswers'],
                                          completionCount:
                                          userData['completionCount'],
                                          cardType: CardType.MostTimes,
                                          numberOfWords: widget.numberOfWords,
                                        );
                                      } else {
                                        return Container(
                                          decoration: CustomCardDecoration
                                              .cardDecoration,
                                          padding: const EdgeInsets.all(20.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                  "Let become one of the first user study this topic",
                                                  style: normalText),
                                            ],
                                          ),
                                        );
                                      }
                                    },
                                  );
                                }
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
