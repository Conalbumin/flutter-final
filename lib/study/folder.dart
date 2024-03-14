import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
            return Card(
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
                    document['name'],
                    style: const TextStyle(fontSize: 30.0, color: Colors.white),
                  ),
                  subtitle: Text(
                    '${document['text']}',
                    style: const TextStyle(fontSize: 18.0, color: Colors.white),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class FolderItem extends StatelessWidget {
  final String folderName;
  final String text;


  const FolderItem({required this.folderName, required this.text});

  @override
  Widget build(BuildContext context) {
    return Card(
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
    );
  }

}