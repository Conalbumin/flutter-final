import 'package:flutter/material.dart';
import '../../constant/text_style.dart';

Widget warning() {
  return Container(
    color: Colors.lightBlueAccent,
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Please provide at least',
            style: normalText,
          ),
          Text(
            '3 vocabulary words to start',
            style: normalText,
          ),
          Text(
            'studying',
            style: normalText,
          ),
        ],
      ),
    ),
  );

}