import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

Future<List<List<dynamic>>> readCsv(String filePath) async {
  final input = File(filePath).openRead();
  return await input
      .transform(utf8.decoder)
      .transform(const CsvToListConverter())
      .toList();
}

Future<void> writeCsv(String filePath, List<List<dynamic>> rows) async {
  final csv = const ListToCsvConverter().convert(rows);
  await File(filePath).writeAsString(csv);
}

void importCsvFile() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['csv'],
  );

  if (result != null) {
    File file = File(result.files.single.path!);
    String fileContent = await file.readAsString();
    // Now you can process the CSV file content
    // For example, you can parse the CSV data and use it in your app
    List<List<dynamic>> csvData = CsvToListConverter().convert(fileContent);
    // Do something with csvData
  } else {
    // User canceled the picker
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
