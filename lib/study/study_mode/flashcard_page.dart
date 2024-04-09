import 'package:card_swiper/card_swiper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../firebase_study_page.dart';
import '../word/word.dart';

class FlashCardPage extends StatefulWidget {
  final String topicId;
  final int numberOfWords;

  const FlashCardPage(
      {super.key, required this.topicId, required this.numberOfWords});

  @override
  State<FlashCardPage> createState() => _FlashCardPageState();
}

class _FlashCardPageState extends State<FlashCardPage> {
  int _currentIndex = 0;
  late List<String> wordStatuses;
  int countLearned = 0;
  int countUnlearned = 0;

  @override
  void initState() {
    super.initState();
    wordStatuses = List.filled(widget.numberOfWords, "Unlearned");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Center(
          child: Text(
            "${_currentIndex + 1}/${widget.numberOfWords}",
            style: const TextStyle(color: Colors.white, fontSize: 30),
          ),
        ),
        actions: [
          const Icon(Icons.settings, size: 30),
          const SizedBox(width: 15)
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            SizedBox(
              width: 380,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        wordStatuses[_currentIndex] = "Unlearned";
                        countUnlearned++;
                        _currentIndex = (_currentIndex + 1) % widget.numberOfWords;
                      });
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      child: Center(child: Text('${countUnlearned}', style: TextStyle(fontSize: 20),)),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.red,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        wordStatuses[_currentIndex] = "Learned";
                        countLearned++;
                        _currentIndex = (_currentIndex + 1) % widget.numberOfWords;
                      });
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      child: Center(child: Text('${countLearned}', style: TextStyle(fontSize: 20),)),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.green,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 500, // Adjust the height as needed
              child: FutureBuilder(
                future: fetchWords(widget.topicId),
                builder: (context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    List<DocumentSnapshot> words = snapshot.data!;
                    return Swiper(
                      index: _currentIndex,
                      onIndexChanged: (index) {
                        setState(() {
                          _currentIndex = index;
                          print(_currentIndex);
                          print(index);
                        });
                      },
                      pagination: const SwiperPagination(
                        builder: DotSwiperPaginationBuilder(
                          color: Colors.white,
                          activeColor: Colors.indigo,
                          activeSize: 15,
                          size: 10,
                        ),
                      ),
                      scrollDirection: Axis.horizontal,
                      itemCount: words.length,
                      itemBuilder: (context, index) {
                        String word = words[index]['word'];
                        String definition = words[index]['definition'];
                        String status = words[index]['status'];
                        return WordItem(
                          definition: definition,
                          word: word,
                          wordId: words[index].id,
                          topicId: widget.topicId,
                          status: status,
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
