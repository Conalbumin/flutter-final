import 'package:flutter/material.dart';
import 'package:quizlet_final_flutter/study/statistical/statistical_tab.dart';
import 'package:quizlet_final_flutter/study/topic/topic_tab.dart';

import 'folder/folder_tab.dart'; // Import your Firebase functions here

class StudyPage extends StatefulWidget {
  const StudyPage({super.key});

  @override
  State<StudyPage> createState() => _StudyPageState();
}

class _StudyPageState extends State<StudyPage> {

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: Column(
          children: [
            const Divider(
              indent: 25.0,
              endIndent: 25.0,
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
                  ),
                  Tab(
                    icon: Icon(Icons.bar_chart),
                    text: "Statistical",
                  )
                ],
              ),
            ),
            const Expanded(
              child: TabBarView(
                children: [
                  TopicTab(),
                  FolderTab(),
                  StatisticalTab()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
