import 'package:flutter/material.dart';
import 'package:quizlet_final_flutter/constant/text.dart';
import 'tab_in_study/topic.dart';
import 'tab_in_study/folder.dart';

class StudyPage extends StatefulWidget {
  const StudyPage({Key? key}) : super(key: key);

  @override
  State<StudyPage> createState() => _StudyPageState();
}

class _StudyPageState extends State<StudyPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: null,
        body: Column(
          children: [
            Divider(
              indent: 25.0,
              endIndent: 25.0,
              color: Colors.grey.withOpacity(1),
              height: 0.8,
            ),
            Container(
              color: Colors.blue,
              child: const TabBar(
                unselectedLabelColor: Colors.blueGrey,
                labelColor: Colors.white,
                tabs: [
                  Tab(
                    icon: Icon(Icons.chat_bubble),
                    text: "Topic",
                  ),
                  Tab(
                    icon: Icon(Icons.folder),
                    text: "Folder",
                  )
                ],
              ),
            ),
            const Expanded(
              child: TabBarView(children: [
                TopicTab(),
                FolderTab()
              ]),
            )
          ],
        ),
      ),
    );
  }
}
