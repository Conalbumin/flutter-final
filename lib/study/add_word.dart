import 'package:flutter/material.dart';

class AddWordPage extends StatefulWidget {
  const AddWordPage({super.key});

  @override
  State<AddWordPage> createState() => _AddWordPageState();
}

class _AddWordPageState extends State<AddWordPage> {
  String word = '';
  String definition = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: Colors.blueGrey[100],
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: TextFormField(
              decoration: const InputDecoration(
                labelText: 'Word',
                contentPadding: EdgeInsets.only(left: 10),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a word';
                }
                return null;
              },
              onChanged: (value) {
                word = value;
              },
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: TextFormField(
              decoration: const InputDecoration(
                labelText: 'Definition',
                contentPadding: EdgeInsets.only(left: 10),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a definition';
                }
                return null;
              },
              onChanged: (value) {
                definition = value;
              },
            ),
          ),
        ],
      ),
    );
  }
}
