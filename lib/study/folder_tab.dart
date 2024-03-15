import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quizlet_final_flutter/study/folder_page.dart';
import '../constant/style.dart';

class FolderTab extends StatelessWidget {
  const FolderTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('folders').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (BuildContext context, int index) {
            DocumentSnapshot document = snapshot.data!.docs[index];
            String folderId = document.id;
            String folderName = document['name'];
            String text = document['text'];
            return FolderItem(
              folderName: folderName,
              text: text,
              folderId: folderId,
            );
          },
        );
      },
    );
  }
}

class FolderItem extends StatelessWidget {
  final String folderId;
  final String folderName;
  final String text;

  const FolderItem({
    required this.folderId,
    required this.folderName,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print("object");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FolderPage(
              folderId: folderId,
              folderName: folderName,
            ),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        color: Colors.blue[600],
        elevation: 10,
        child: Container(
          decoration: CustomCardDecoration.cardDecoration,
          child: ListTile(
            leading: const Icon(Icons.topic, size: 60, color: Colors.white),
            title: Text(
              folderName,
              style: const TextStyle(fontSize: 30.0, color: Colors.white),
            ),
            subtitle: Text(
              text,
              style: const TextStyle(fontSize: 15.0, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
