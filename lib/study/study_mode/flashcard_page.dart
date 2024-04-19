import 'dart:async';

import 'package:card_swiper/card_swiper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../word/text_to_speech.dart';
import '../firebase_study_page.dart';
import '../word/word.dart';

class FlashCardPage extends StatefulWidget {
  final String topicId;
  final int numberOfWords;

  const FlashCardPage(
      {Key? key, required this.topicId, required this.numberOfWords})
      : super(key: key);

  @override
  State<FlashCardPage> createState() => _FlashCardPageState();
}

class _FlashCardPageState extends State<FlashCardPage> {
  int _currentIndex = 0;
  late List<String> wordStatuses;
  List<DocumentSnapshot> words = [];
  int countLearned = 0;
  int countUnlearned = 0;
  int countMastered = 0;
  bool autoSpeak = true;
  late SwiperController _swiperController;
  Timer? _timer;
  bool autoplay = false;
  GlobalKey _menuKey = GlobalKey();

  void shuffleWords(List<DocumentSnapshot> words) {
    setState(() {
      words.shuffle();
      _currentIndex = 0;
      if (autoSpeak) {
        speak(words[_currentIndex]['word']);
      }
      this.words = words;
    });
  }

  void _checkFinishStudy() {
    if (countLearned + countUnlearned == widget.numberOfWords) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Congratulations!'),
            content: const Text('You have finished studying this topic.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void _updateLearnedStatus(String status) {
    setState(() {
      switch (status) {
        case 'Learned':
          countLearned++;
          break;
        case 'Unlearned':
          countUnlearned++;
          break;
        case 'Mastered':
          countMastered++;
          break;
      }
      _currentIndex = (_currentIndex + 1) % widget.numberOfWords;
      _checkFinishStudy();
    });
  }

  void startAutoPlay() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_swiperController.index < (widget.numberOfWords - 1)) {
        _swiperController.next();
        _swiperController.index++;
      } else {
        _timer?.cancel(); // Stop auto-play if reached the last word
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _swiperController = SwiperController();
    // startAutoPlay();
    fetchWords(widget.topicId).then((List<DocumentSnapshot> fetchedWords) {
      setState(() {
        words = fetchedWords;
        if (words.isNotEmpty) {
          speak(words[_currentIndex]['word']);
        }
      });
    });
    wordStatuses = List.filled(widget.numberOfWords, "");
  }

  @override
  void dispose() {
    _timer?.cancel();
    _swiperController.dispose();
    super.dispose();
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
          const SizedBox(width: 15),
          PopupMenuButton<String>(
            key: _menuKey,
            icon: const Icon(Icons.settings, color: Colors.white, size: 30),
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'auto',
                child: ListTile(
                  leading: const Icon(Icons.auto_mode),
                  title: const Text('Auto'),
                  trailing: Switch(
                    value: autoplay,
                    activeColor: Colors.blue,
                    onChanged: (value) {
                      setState(() {
                        autoplay = value;
                        if (autoplay) {
                          startAutoPlay();
                        } else {
                          _timer?.cancel();
                        }
                        Navigator.of(context).pop();
                        (_menuKey.currentState as dynamic).showButtonMenu();
                      });
                    },
                  ),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'shuffle',
                child: ListTile(
                  leading: Icon(Icons.shuffle),
                  title: Text('Shuffle words'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'switchLanguage',
                child: ListTile(
                  leading: Icon(Icons.switch_camera),
                  title: Text('Switch language'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'learnStar',
                child: ListTile(
                  leading: Icon(Icons.star),
                  title: Text('Learn only star word'),
                ),
              )
            ],
            onSelected: (String choice) {
              if (choice == 'shuffle') {
                shuffleWords(List.from(words));
              } else if (choice == 'switchLanguage') {
              } else if (choice == 'learnStar') {}
            },
          ),
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
                        _updateLearnedStatus('Unlearned');
                        updateWordStatus(widget.topicId,
                            words[_currentIndex].id, 'Unlearned');
                      });
                    },
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.red,
                              width: 3,
                            ),
                          ),
                          child: Center(
                              child: Text(
                            '$countUnlearned',
                            style: const TextStyle(
                                fontSize: 20,
                                color: Colors.red,
                                fontWeight: FontWeight.bold),
                          )),
                        ),
                        const SizedBox(width: 5),
                        const Text(
                          "Unlearned",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red),
                        )
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _updateLearnedStatus('Learned');
                        updateWordStatus(
                            widget.topicId, words[_currentIndex].id, 'Learned');
                      });
                    },
                    child: Row(
                      children: [
                        const Text("Learned",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green)),
                        const SizedBox(width: 5),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.green,
                              width: 3,
                            ),
                          ),
                          child: Center(
                              child: Text(
                            '$countLearned',
                            style: const TextStyle(
                                fontSize: 20,
                                color: Colors.green,
                                fontWeight: FontWeight.bold),
                          )),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 500, // Adjust the height as needed
              child: FutureBuilder(
                future: Future.value(words),
                builder:
                    (context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    words = snapshot.data!;
                    words.forEach((word) {
                      print(word.data());
                    });
                    return Swiper(
                      key: UniqueKey(),
                      controller: _swiperController,
                      index: _currentIndex,
                      onIndexChanged: (index) {
                        setState(() {
                          _currentIndex = index;
                          if (autoSpeak) {
                            speak(words[index]['word']);
                          }
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
                        bool isFavorited = words[index]['isFavorited'];

                        return WordItem(
                          definition: definition,
                          word: word,
                          wordId: words[index].id,
                          topicId: widget.topicId,
                          status: status,
                          isFavorited: isFavorited.toString() ?? '',
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
