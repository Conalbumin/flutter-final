import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quizlet_final_flutter/constant/text_style.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:quizlet_final_flutter/study/ranking/user_achievement.dart';
import '../../constant/style.dart';

class Achievement extends StatelessWidget {
  final String userId;

  const Achievement({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('Achievements', style: appBarStyle),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildRankingCard(
                'Most correct answers', 'rank_most_correct_answer'),
            _buildRankingCard(
                'Completed in shortest time', 'rank_shortest_time'),
            _buildRankingCard('Topics studied', 'rank_most_times'),
          ],
        ),
      ),
    );
  }

  Widget _buildRankingCard(String title, String rankingField) {
    double swiperHeight = rankingField == 'rank_shortest_time' ? 250 : 180;
    double swiperWidth = rankingField == 'rank_shortest_time' ? 350 : 300;
    bool hasAchievement = false;

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.indigo,
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Column(
          children: [
            Center(child: Text(title, style: normalText)),
            SizedBox(
              height: swiperHeight,
              width: swiperWidth,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('achievements')
                    .doc(userId)
                    .collection('topics')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return warning();
                  }

                  final rankingDocs = snapshot.data!.docs;
                  final achievements = rankingDocs.map((doc) {
                    final topicId = doc.id;
                    final rank = doc[rankingField];
                    if (rank != 0) {
                      hasAchievement = true;
                    }
                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('topics')
                          .doc(topicId)
                          .get(),
                      builder: (context, topicSnapshot) {
                        if (topicSnapshot.connectionState ==
                            ConnectionState.waiting ||
                            !topicSnapshot.hasData) {
                          return CircularProgressIndicator();
                        }

                        if (!topicSnapshot.hasData) {
                          return warning();
                        }

                        final topicData =
                        topicSnapshot.data!.data() as Map<String, dynamic>;
                        final topicName = topicData['name'];
                        final numberOfWords = topicData['numberOfWords'];

                        return FutureBuilder<QuerySnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('topics')
                              .doc(topicId)
                              .collection('access')
                              .get(),
                          builder: (context, accessSnapshot) {
                            if (accessSnapshot.connectionState ==
                                ConnectionState.waiting ||
                                !accessSnapshot.hasData) {
                              return CircularProgressIndicator();
                            }

                            // Lấy các giá trị từ document trong collection 'access'
                            final accessDocs = accessSnapshot.data!.docs;
                            final accessData =
                            accessDocs.first.data() as Map<String, dynamic>;
                            int completionCount = accessData['completionCount'];
                            int correctAnswers = accessData['correctAnswers'];
                            DateTime lastStudied =
                            accessData['lastStudied'].toDate();
                            DateTime timeTaken =
                            accessData['timeTaken'].toDate();
                            String userAvatar = accessData['userAvatar'];
                            String userName = accessData['userName'];
                            if (rank != 0) {
                              return _buildSwiperItem(
                                topicName,
                                rank,
                                completionCount,
                                correctAnswers,
                                lastStudied,
                                timeTaken,
                                userAvatar,
                                userName,
                                numberOfWords,
                                rankingField,
                              );
                            } else {
                              return SizedBox.shrink(); // Trả về widget trống
                            }
                          },
                        );
                      },
                    );
                  }).toList();

                  if (hasAchievement) {
                    return Swiper(
                      loop: true,
                      autoplay: true,
                      itemCount: achievements.length,
                      itemBuilder: (BuildContext context, int index) {
                        return achievements[index];
                      },
                    );
                  } else {
                    return warning();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwiperItem(
    String topicName,
    int rank,
    int completionCount,
    int correctAnswers,
    DateTime lastStudied,
    DateTime timeTaken,
    String userAvatar,
    String userName,
    int numberOfWords,
    String rankingField,
  ) {
    CardAchievementType cardType;

    switch (rankingField) {
      case 'rank_shortest_time':
        cardType = CardAchievementType.TimeAchievement;
        break;
      case 'rank_most_correct_answer':
        cardType = CardAchievementType.AnswerAchievement;
        break;
      case 'rank_most_times':
        cardType = CardAchievementType.MostTimesAchievement;
        break;
      default:
        cardType = CardAchievementType.TimeAchievement;
    }

    return Container(
      padding: EdgeInsets.all(10),
      child: UserAchievementItem(
          displayName: topicName,
          avatarURL: userAvatar,
          finishedAt: lastStudied,
          startAt: timeTaken,
          correctAns: correctAnswers,
          completionCount: completionCount,
          numberOfWords: numberOfWords,
          cardType: cardType,
          rank: rank),
    );
  }

  Widget warning() {
    return Container(
      decoration: CustomCardDecoration.cardDecoration,
      padding: const EdgeInsets.all(20.0),
      child: Center(
        child: Text(
          "Try harder \nto be in top 3",
          style: rankText,
        ),
      ),
    );
  }
}
