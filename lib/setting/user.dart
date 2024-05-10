import 'package:flutter/material.dart';

import '../constant/style.dart';
import '../constant/text_style.dart';

class UserItem extends StatelessWidget {
  final String displayName;
  final String avatarURL;

  const UserItem(
      {super.key, required this.displayName, required this.avatarURL});

  @override
  Widget build(BuildContext context) {
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
          ],
        ),
      ),
    );
  }
}
