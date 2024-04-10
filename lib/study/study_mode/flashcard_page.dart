import 'package:card_swiper/card_swiper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../word/text_to_speech.dart';
import '../firebase_study_page.dart';
import '../word/word.dart';

class FlashCardPage extends StatefulWidget {
  final String topicId;
  final int numberOfWords;

  const FlashCardPage({Key? key, required this.topicId, required this.numberOfWords})
      : super(key: key);

  @override
  State<FlashCardPage> createState() => _FlashCardPageState();
}

class _FlashCardPageState extends State<FlashCardPage> {
  int _currentIndex = 0;
  late List<String> wordStatuses;
  int countLearned = 0;
  int countunLearned = 0;


  Future<List<DocumentSnapshot>> fetchAllWords() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('topics').doc(widget.topicId).collection('words').get();
      return snapshot.docs;
    } catch (error) {
      print('Error fetching words: $error');
      return [];
    }
  }

  void speakWord(String word) {
    speak(word);
  }

  @override
  void initState() {
    super.initState();
    fetchAllWords();
  }

  @override
  Widget build(BuildContext context) {
    // Declare snapshotData variable
    List<DocumentSnapshot> snapshotData = [];

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
          SizedBox(width: 15),
          PopupMenuButton<String>(
            icon: const Icon(Icons.settings, color: Colors.white, size: 30),
            itemBuilder: (BuildContext context) =>
            <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'auto',
                child: ListTile(
                  leading: Icon(Icons.auto_mode),
                  title: Text('Auto'),
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
              if (choice == 'auto') {
                // editAction(context);
              } else if (choice == 'shuffle') {
                // _showFolderTab(context);
              } else if (choice == 'switchLanguage') {
              } else if (choice == 'learnStar') {
              }
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
                        wordStatuses[_currentIndex] = "unLearned";
                        updateWordStatus(widget.topicId, snapshotData[_currentIndex].id, "unLearned");
                        countunLearned++;
                        _currentIndex = (_currentIndex + 1) % widget.numberOfWords;
                      });
                    },
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          child: Center(
                              child: Text('${countunLearned}', style: TextStyle(fontSize: 20, color: Colors.red, fontWeight: FontWeight.bold),)),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.red,
                              width: 3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text("Unlearned",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),)
                      ],
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
                    child: Row(
                      children: [
                        Text("Learned",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                        const SizedBox(width: 5),
                        Container(
                          width: 40,
                          height: 40,
                          child: Center(child: Text('${countLearned}', style: TextStyle(fontSize: 20, color: Colors.green, fontWeight: FontWeight.bold),)),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.green,
                              width: 3,
                            ),
                          ),
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
                future: fetchAllWords(),
                builder: (context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
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
                          speakWord(words[index]['word']);
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
