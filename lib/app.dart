import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:quizlet_final_flutter/constant/text.dart';
import 'package:quizlet_final_flutter/study/firebase_study_page.dart';
import 'study/study.dart';
import 'setting/setting.dart';
import 'home/home.dart';
import 'study/add_topic_page.dart';

class MainApp extends StatefulWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue,
        title: bottomNavigationOptions.elementAt(_selectedIndex),
        actions: [
          if (_selectedIndex == 1)
            IconButton(
            icon: Icon(Icons.add_circle, size: 40, color: Colors.white,),
            onPressed: () {
              _showAddOptionsDialog(context);
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          HomePage(),
          StudyPage(),
          SettingPage(),
        ],
      ),
      bottomNavigationBar: CurvedNavigationBar(
        color: Colors.blue,
        backgroundColor: Colors.white,
        buttonBackgroundColor: Colors.blue,
        items:  <Widget>[
          Icon(Icons.home, size: 40, color: Colors.white),
          Icon(Icons.book, size: 40, color: Colors.white),
          Icon(Icons.settings, size: 40, color: Colors.white),
        ],
        onTap: _onItemTapped,
        index: _selectedIndex,
        height: 50,
        animationDuration: Duration(milliseconds: 300),
      ),
    );
  }

  void _showAddOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Create New'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddTopicPage()),
                    );
                  },
                  child: Text('Create New Topic'),
                ),
                Padding(padding: EdgeInsets.all(8.0)),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    _showNewFolderDialog(context);
                  },
                  child: Text('Create New Folder'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showNewFolderDialog(BuildContext context) {
    String folderName = '';
    String text = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('New Folder'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                decoration: InputDecoration(labelText: 'Folder Name'),
                onChanged: (value) {
                  folderName = value;
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Description'),
                onChanged: (value) {
                  text = value;
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Create'),
              onPressed: () {
                addFolder(folderName, text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
