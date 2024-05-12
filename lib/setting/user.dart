import 'package:flutter/material.dart';
import '../constant/style.dart';
import '../constant/text_style.dart';

enum CardType {
  Time,
  Answer,
  MostTimes,
}

class UserItem extends StatelessWidget {
  final String displayName;
  final String avatarURL;
  final DateTime finishedAt;
  final DateTime startAt;
  final int correctAns;
  final int completionCount;
  final int numberOfWords;
  final CardType cardType;

  const UserItem({
    Key? key,
    required this.displayName,
    required this.avatarURL,
    required this.finishedAt,
    required this.startAt,
    required this.correctAns,
    required this.completionCount,
    required this.cardType, required this.numberOfWords,
  }) : super(key: key);

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

    String formattedDifference = '$hours hours,\n$minutes minutes,\n$seconds seconds';

    return formattedDifference;
  }

  String computeMostCorrectAns() {
    return '';
  }

  Widget buildCard(BuildContext context) {
    switch (cardType) {
      case CardType.Time:
        String calculateTime = computeTimeDifference(finishedAt, startAt);
        return Card(
          color: Colors.transparent,
          child: Container(
            decoration: CustomCardDecoration.cardDecoration,
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: avatarURL.isNotEmpty
                      ? NetworkImage(avatarURL)
                      : const AssetImage('assets/default_avatar.png') as ImageProvider,
                ),
                const SizedBox(height: 10),
                Text(displayName ?? '', style: normalText),
                Text(calculateTime, style: rankText)
              ],
            ),
          ),
        );
      case CardType.Answer:
        return Card(
          color: Colors.transparent,
          child: Container(
            decoration: CustomCardDecoration.cardDecoration,
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: avatarURL.isNotEmpty
                      ? NetworkImage(avatarURL)
                      : const AssetImage('assets/default_avatar.png') as ImageProvider,
                ),
                const SizedBox(height: 10),
                Text(displayName ?? '', style: normalText),
                Text('$correctAns / $numberOfWords', style: rankText)
              ],
            ),
          ),
        );
      case CardType.MostTimes:
        return Card(
          color: Colors.transparent,
          child: Container(
            decoration: CustomCardDecoration.cardDecoration,
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: avatarURL.isNotEmpty
                      ? NetworkImage(avatarURL)
                      : const AssetImage('assets/default_avatar.png') as ImageProvider,
                ),
                const SizedBox(height: 10),
                Text(displayName ?? '', style: normalText),
                Text('$completionCount times', style: rankText)
              ],
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return buildCard(context);
  }
}
