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
                    decoration: rankingDecoration,
                    child: Column(
                      children: [
                        Center(
                          child: Text('Most correct answer', style: normalText),
                        ),
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
                                  return Text(
                                      "No users found in access sub-collection",
                                      style: normalText);
                                } else {
                                  users.sort((a, b) {
                                    bool aHasCorrectAnswers =
                                    (a.data() as Map<String, dynamic>)
                                        .containsKey('correctAnswers');
                                    bool bHasCorrectAnswers =
                                    (b.data() as Map<String, dynamic>)
                                        .containsKey('correctAnswers');

                                    if (!aHasCorrectAnswers &&
                                        bHasCorrectAnswers) {
                                      return 1;
                                    } else if (aHasCorrectAnswers &&
                                        !bHasCorrectAnswers) {
                                      return -1;
                                    }
                                    int correctAnswersComparison = (b['correctAnswers'] as int)
                                        .compareTo(a['correctAnswers'] as int);
                                    if (correctAnswersComparison != 0) {
                                      return correctAnswersComparison;
                                    } else {
                                      bool aHasTimeTaken =
                                      (a.data() as Map<String, dynamic>)
                                          .containsKey('timeTaken');
                                      bool bHasTimeTaken =
                                      (b.data() as Map<String, dynamic>)
                                          .containsKey('timeTaken');

                                      if (!aHasTimeTaken && bHasTimeTaken) {
                                        return 1;
                                      } else if (aHasTimeTaken &&
                                          !bHasTimeTaken) {
                                        return -1;
                                      }
                                      return (a['timeTaken'] as Timestamp)
                                          .compareTo(b['timeTaken'] as Timestamp);
                                    }
                                  });

                                  List<DocumentSnapshot> mostCorrectAnsUser =
                                  users
                                      .take(users.length > 3
                                      ? 3
                                      : users.length)
                                      .toList();
                                  for (int i = 0;
                                  i < mostCorrectAnsUser.length;
                                  i++) {
                                    String userId = mostCorrectAnsUser[i].id;
                                    int rank = i + 1;
                                    FirebaseFirestore.instance
                                        .collection('achievements')
                                        .doc(userId)
                                        .collection('topics')
                                        .doc(widget.topicId)
                                        .set({
                                      'rank_most_correct_answer': rank,
                                    }, SetOptions(merge: true));
                                  }
                                  if (mostCorrectAnsUser.isNotEmpty) {
                                    return Swiper(
                                      loop: false,
                                      autoplay: true,
                                      scrollDirection: Axis.horizontal,
                                      itemCount: mostCorrectAnsUser.length,
                                      viewportFraction: 0.6,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        final userData = mostCorrectAnsUser
                                            .toList()[index]
                                            .data() as Map<String, dynamic>;
                                        if (userData.isNotEmpty &&
                                            userData.containsKey(
                                                'correctAnswers')) {
                                          return UserItem(
                                            displayName: userData['userName'],
                                            avatarURL: userData['userAvatar'],
                                            finishedAt: userData['lastStudied']
                                                .toDate(),
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
                                          return warning();
                                        }
                                      },
                                    );
                                  } else {
                                    return warning();
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
                    decoration: rankingDecoration,
                    child: Column(
                      children: [
                        Center(
                          child: Text('Completed in shortest time',
                              style: normalText),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 340,
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
                                  return Text(
                                      "No users found in access sub-collection",
                                      style: normalText);
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
                                  if (users.isEmpty) {
                                    List<DocumentSnapshot> users = snapshot.data!.docs;
                                    users.forEach((user) {
                                      String userId = user.id;
                                      FirebaseFirestore.instance
                                          .collection('achievements')
                                          .doc(userId)
                                          .collection('topics')
                                          .doc(widget.topicId)
                                          .set({
                                        'rank_shortest_time': 0,
                                      }, SetOptions(merge: true));
                                    });
                                    return Swiper(
                                      loop: false,
                                      autoplay: true,
                                      scrollDirection: Axis.horizontal,
                                      itemCount: 1,
                                      viewportFraction: 0.6,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                          return warning();
                                      },
                                    );
                                  }
                                  Duration computeTimeDifference(DateTime lastStudied, DateTime timeTaken) {
                                    if (lastStudied.isAfter(timeTaken)) {
                                      final temp = lastStudied;
                                      lastStudied = timeTaken;
                                      timeTaken = temp;
                                    }
                                    return timeTaken.difference(lastStudied);
                                  }
                                  users.sort((a, b) {
                                    DateTime aLastStudied = (a.data() as Map<String, dynamic>)['lastStudied'].toDate();
                                    DateTime aTimeTaken = (a.data() as Map<String, dynamic>)['timeTaken'].toDate();
                                    DateTime bLastStudied = (b.data() as Map<String, dynamic>)['lastStudied'].toDate();
                                    DateTime bTimeTaken = (b.data() as Map<String, dynamic>)['timeTaken'].toDate();

                                    Duration aDifference = computeTimeDifference(aLastStudied, aTimeTaken);
                                    Duration bDifference = computeTimeDifference(bLastStudied, bTimeTaken);

                                    return aDifference.compareTo(bDifference);
                                  });
                                  List<DocumentSnapshot> fastestUsers = users
                                      .take(users.length > 3 ? 3 : users.length)
                                      .toList();
                                  for (int i = 0;
                                      i < fastestUsers.length;
                                      i++) {
                                    String userId = fastestUsers[i].id;
                                    int rank = i + 1;
                                    FirebaseFirestore.instance
                                        .collection('achievements')
                                        .doc(userId)
                                        .collection('topics')
                                        .doc(widget.topicId)
                                        .set({
                                      'rank_shortest_time': rank,
                                    }, SetOptions(merge: true));
                                  }
                                  return Swiper(
                                    loop: false,
                                    autoplay: true,
                                    scrollDirection: Axis.horizontal,
                                    itemCount: fastestUsers.length,
                                    viewportFraction: 0.6,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      final userData = fastestUsers
                                          .toList()[index]
                                          .data() as Map<String, dynamic>;
                                      if (fastestUsers.isNotEmpty) {
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
                                      } else {
                                        return warning();
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
                    decoration: rankingDecoration,
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
                                  return Text(
                                      "No users found in access sub-collection",
                                      style: normalText);
                                } else {
                                  users.sort((a, b) {
                                    bool acompletionCount =
                                        (a.data() as Map<String, dynamic>)
                                            .containsKey('completionCount');
                                    bool bcompletionCount =
                                        (b.data() as Map<String, dynamic>)
                                            .containsKey('completionCount');

                                    if (!acompletionCount && bcompletionCount) {
                                      return 1;
                                    } else if (acompletionCount &&
                                        !bcompletionCount) {
                                      return -1;
                                    }
                                    return (b['completionCount'] as int)
                                        .compareTo(a['completionCount'] as int);
                                  });
                                  List<DocumentSnapshot> mostTimesUser = users
                                      .take(users.length > 3 ? 3 : users.length)
                                      .toList();
                                  for (int i = 0;
                                      i < mostTimesUser.length;
                                      i++) {
                                    String userId = mostTimesUser[i].id;
                                    int rank = i + 1;
                                    FirebaseFirestore.instance
                                        .collection('achievements')
                                        .doc(userId)
                                        .collection('topics')
                                        .doc(widget.topicId)
                                        .set({
                                      'rank_most_times': rank,
                                    }, SetOptions(merge: true));
                                  }
                                  return Swiper(
                                    loop: false,
                                    autoplay: true,
                                    scrollDirection: Axis.horizontal,
                                    itemCount: mostTimesUser.length,
                                    viewportFraction: 0.6,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      final userData = mostTimesUser
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
                                          cardType: CardType.MostTimes,
                                          numberOfWords: widget.numberOfWords,
                                        );
                                      } else {
                                        return warning();
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

  Widget warning() {
    return Container(
      decoration: CustomCardDecoration
          .cardDecoration,
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
              "Let become one of the first 3 users who study this topic",
              style: normalText),
        ],
      ),
    );
  }
  
}
