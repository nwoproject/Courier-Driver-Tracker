import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'package:permission_handler/permission_handler.dart';

class RouteLogging{

  static void getPermissions() async {
    await Permission.storage.request();
  }

  //Gets the directory path for the file
  static Future<String> get localPath async {

    final directory = await getExternalStorageDirectory();

    return directory.path;
  }

  static Future<File> get localFile async {

    final path = await localPath;

    return File('$path/Download/test.txt');
  }

  static Future<String> readFileContents() async {
    try {
      final file = await localFile;

      // Read the file
      String contents = await file.readAsString();

      return contents;
    } catch (e) {
      // If encountering an error, return 0
      return "";
    }
  }

  static Future<File> writeToFile(String data) async {
    final file = await localFile;

    // Write the file
    return file.writeAsString('data', mode: FileMode.append);
  }
}
