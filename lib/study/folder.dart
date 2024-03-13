import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
        return ListView(
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            return FolderItem(
              folderName: document['name'],
            );
          }).toList(),
        );
      },
    );
  }
}

class FolderItem extends StatelessWidget {
  final String folderName;

  const FolderItem({required this.folderName});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(folderName),
      // Add more customization as needed
    );
  }
}