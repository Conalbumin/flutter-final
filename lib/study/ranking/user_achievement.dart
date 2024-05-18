import 'package:flutter/material.dart';
import 'package:quizlet_final_flutter/icons/app_icons_icons.dart';

import '../../constant/style.dart';
import '../../constant/text_style.dart';

enum CardAchievementType {
  TimeAchievement,
  AnswerAchievement,
  MostTimesAchievement,
}

class UserAchievementItem extends StatelessWidget {
  final String displayName;
  final String avatarURL;
  final DateTime finishedAt;
  final DateTime startAt;
  final int correctAns;
  final int completionCount;
  final int numberOfWords;
  final CardAchievementType cardType;
  final int rank;

  const UserAchievementItem(
      {super.key,
      required this.displayName,
      required this.avatarURL,
      required this.finishedAt,
      required this.startAt,
      required this.correctAns,
      required this.completionCount,
      required this.numberOfWords,
      required this.cardType,
      required this.rank});

  String computeTimeDifference(DateTime lastStudied, DateTime timeTaken) {
    if (lastStudied.isAfter(timeTaken)) {
      final temp = lastStudied;
      lastStudied = timeTaken;
      timeTaken = temp;
    }

    Duration difference = timeTaken.difference(lastStudied);

    int hours = difference.inHours;
    int minutes = difference.inMinutes.remainder(60);
    int seconds = difference.inSeconds.remainder(60);

    String formattedDifference =
        '$hours hours, $minutes minutes \n$seconds seconds';

    return formattedDifference;
  }

  Widget buildCard(BuildContext context) {
    switch (cardType) {
      case CardAchievementType.TimeAchievement:
        String calculateTime = computeTimeDifference(finishedAt, startAt);
        return Card(
          color: Colors.transparent,
          child: Container(
            decoration: CustomCardDecoration.cardDecoration,
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 35,
                  width: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Colors.indigo,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center, // Center the row horizontally
                    children: [
                      Text('Rank: $rank', style: rankText),
                      const SizedBox(width: 10),
                      Icon(
                        AppIcons.award,
                        color: _getIconColor(rank),
                      ),
                    ],
                  ),
                ),
                Text('Topic: $displayName', style: normalText),
                Text(calculateTime, style: rankText),
              ],
            ),
          ),
        );
      case CardAchievementType.AnswerAchievement:
        return Card(
          color: Colors.transparent,
          child: Container(
            decoration: CustomCardDecoration.cardDecoration,
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 35,
                  width: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Colors.indigo,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center, // Center the row horizontally
                    children: [
                      Text('Rank: $rank', style: rankText),
                      const SizedBox(width: 10),
                      Icon(
                        AppIcons.award,
                        color: _getIconColor(rank),
                      ),
                    ],
                  ),
                ),
                Text('Topic: $displayName', style: normalText),
                Text('$correctAns / $numberOfWords', style: rankText)
              ],
            ),
          ),
        );
      case CardAchievementType.MostTimesAchievement:
        return Card(
          color: Colors.transparent,
          child: Container(
            decoration: CustomCardDecoration.cardDecoration,
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 35,
                  width: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Colors.indigo,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center, // Center the row horizontally
                    children: [
                      Text('Rank: $rank', style: rankText),
                      const SizedBox(width: 10),
                      Icon(
                        AppIcons.award,
                        color: _getIconColor(rank),
                      ),
                    ],
                  ),
                ),
                Text('Topic: $displayName', style: normalText),
                Text('$completionCount times', style: rankText)
              ],
            ),
          ),
        );
    }
  }

  Color _getIconColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.yellow;
      case 2:
        return Colors.grey;
      case 3:
        return Colors.brown;
      default:
        return Colors.black; // Default color if rank is not 1, 2, or 3
    }
  }


  @override
  Widget build(BuildContext context) {
    return buildCard(context);
  }
}
