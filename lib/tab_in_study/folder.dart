import 'package:flutter/material.dart';

class FolderTab extends StatelessWidget {
  const FolderTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          _folderItem('Folder Tab'),
          _folderItem('Folder Tab'),
          _folderItem('Folder Tab'),
        ],
      ),
    );
  }

  Widget _folderItem(String text) {
    return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        color: Colors.blue[600],
        elevation: 10,
        child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          ListTile(
            leading: const Icon(Icons.folder, size: 60, color: Colors.white,),
            title: Text(text, style: const TextStyle(fontSize: 30.0, color: Colors.white)),
          )
        ]));
  }

}
