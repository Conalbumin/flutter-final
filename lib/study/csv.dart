import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';

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
  print("click");

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
