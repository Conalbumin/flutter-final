import 'package:flutter/material.dart';

import '../constant/style.dart';
import '../constant/text_style.dart';

class UserItem extends StatelessWidget {
  final String displayName;
  final String avatarURL;
  final DateTime finishedAt;
  final DateTime startAt;
  final int correctAns;
  final int completionCount;

  const UserItem(
      {super.key,
      required this.displayName,
      required this.avatarURL,
      required this.finishedAt,
      required this.startAt,
      required this.correctAns,
      required this.completionCount});

  String computeTimeDifference(DateTime lastStudied, DateTime timeTaken) {
    if (lastStudied.isAfter(timeTaken)) {
      // Swap lastStudied and timeTaken if lastStudied is later
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


  @override
  Widget build(BuildContext context) {
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
              backgroundImage: avatarURL != null && avatarURL.isNotEmpty
                  ? NetworkImage(avatarURL!)
                  : AssetImage('assets/default_avatar.png') as ImageProvider,
            ),
            const SizedBox(height: 10),
            Text(displayName ?? '', style: normalText),
            Text(calculateTime, style: rankText,)
          ],
        ),
      ),
    );
  }
}
