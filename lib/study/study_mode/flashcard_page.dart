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
  int countLearned = 0;
  int countunLearned = 0;
  bool autoSpeak = true;
  late List<DocumentSnapshot> snapshotData;

  void shuffleWords() {
    setState(() {
      if (snapshotData.isNotEmpty) {
        snapshotData.shuffle();
        _currentIndex = 0;
        countLearned = 0;
        countunLearned = 0;
        if (autoSpeak) {
          speak(snapshotData[_currentIndex]['word']);
        }
      }
    });
  }

  void _checkFinishStudy() {
    if (countLearned + countunLearned == widget.numberOfWords) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Congratulations!'),
            content: Text('You have finished studying this topic.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void _updateLearnedStatus(bool learned) {
    setState(() {
      if (learned) {
        wordStatuses[_currentIndex] = "Learned";
        countLearned++;
      } else {
        wordStatuses[_currentIndex] = "unLearned";
        countunLearned++;
      }
      _currentIndex = (_currentIndex + 1) % widget.numberOfWords;
      _checkFinishStudy();
    });
  }

  @override
  void initState() {
    super.initState();
    fetchWords(widget.topicId).then((words) {
      setState(() {
        snapshotData = words;
        if (words.isNotEmpty) {
          speak(words[_currentIndex]['word']);
        }
      });
    });
    wordStatuses = List.filled(widget.numberOfWords, "");
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
            icon: const Icon(Icons.settings, color: Colors.white, size: 30),
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'auto',
                child: ListTile(
                  leading: const Icon(Icons.auto_mode),
                  title: const Text('Auto'),
                  trailing: Switch(
                      value: autoSpeak,
                      onChanged: (value) {
                        setState(() {
                          autoSpeak = !autoSpeak;
                          Navigator.of(context).pop();
                        });
                      }),
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
                shuffleWords();
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
                        _updateLearnedStatus(false); // Mark as unlearned
                        updateWordStatus(widget.topicId, snapshotData[_currentIndex].id, 'unLearned');
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
                            '$countunLearned',
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
                        _updateLearnedStatus(true); // Mark as learned
                        updateWordStatus(widget.topicId, snapshotData[_currentIndex].id, 'Learned');
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
                future: fetchWords(widget.topicId),
                builder:
                    (context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    List<DocumentSnapshot> words = snapshot.data!;
                    // Assign snapshot data to local variable
                    snapshotData = words;
                    return Swiper(
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
