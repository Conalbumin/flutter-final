import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'firebase_study_page.dart';

void pickAndProcessCsvFile(String topicId) async {
  try {
    // Step 1: Pick a CSV file
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result == null) {
      return;
    }

    // Step 2: Read the file content
    String? filePath = result.files.single.path;
    if (filePath == null) {
      print('File path is null');
      return;
    }

    File file = File(filePath);
    String fileContent = await file.readAsString();

    // Step 3: Parse CSV content
    List<List<dynamic>> csvData = CsvToListConverter().convert(fileContent);

    // Step 4: Extract data
    String topicName = csvData[0][0]; // Assuming the topic name is in the first row, first column
    String description = csvData[0][1]; // Assuming the description is in the first row, second column

    // Extracting words
    List<Map<String, String>> words = [];
    for (int i = 1; i < csvData.length; i++) {
      // Assuming each row contains a word and its definition
      String word = csvData[i][0];
      String definition = csvData[i][1];
      // Add word and definition to the list of words
      words.add({'word': word, 'definition': definition});
    }

    addWord(topicId, words);

    print('Topic Name: $topicName');
    print('Description: $description');
    print('Words: $words');
  } catch (e) {
    print('Error picking/processing CSV file: $e');
  }
}

List<Map<String, dynamic>> convertDocumentSnapshotsToMapList(
    List<DocumentSnapshot<Object?>> documentSnapshots) {
  return documentSnapshots.map((snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return {
      'word': data['word'],
      'definition': data['definition'],
      'status': data['status'],
      'isFavorited': data['isFavorited'],
    };
  }).toList();
}


Future<void> exportTopicToCSV(List<Map<String, dynamic>> words, String topicName, BuildContext context) async {
  // Create a header row
  List<List<dynamic>> csvData = [
    ['word', 'definition', 'status', 'isFavorited']
  ];

  // Convert the list of words into a List<List<dynamic>> format for CSV conversion
  csvData.addAll(words.map((word) {
    return [
      word['word'],
      word['definition'],
      word['status'],
      word['isFavorited'],
    ];
  }).toList());

  // Convert the CSV data to a CSV string
  String csvString = const ListToCsvConverter().convert(csvData);

  // Get the downloads directory
  Directory downloadsDirectory = Directory('/storage/emulated/0/Download');

  String downloadsPath = downloadsDirectory.path;

  // Define the file path for the CSV file
  String filePath = '$downloadsPath/$topicName.csv';

  // Write the CSV data to the file
  await File(filePath).writeAsString(csvString);

  // Show a SnackBar to inform the user
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('File exported successfully to: $filePath'),
    ),
  );
}
