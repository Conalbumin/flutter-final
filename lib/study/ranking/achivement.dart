import 'package:flutter/material.dart';
import 'package:quizlet_final_flutter/constant/text_style.dart';

class Achievement extends StatelessWidget {
  final String userId;
  final String type;
  final String topicId;
  final String topicName;
  final int rank;

  const Achievement({
    super.key,
    required this.userId,
    required this.type,
    required this.topicId,
    required this.topicName,
    required this.rank,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.blue,
          title: Text('Achievements', style: appBarStyle)),
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
                        Text('Completed in shortest time', style: normalText),
                      ],
                    ),
                  ],
                ),
              ),
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
                        Text('Topics are studied', style: normalText),
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
