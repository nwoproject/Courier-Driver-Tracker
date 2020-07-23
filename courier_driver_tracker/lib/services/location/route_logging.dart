import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'package:permission_handler/permission_handler.dart';

class RouteLogging{

  final String locationPath ="/Download/test.txt";
  final String deliveriesPath = "/Download/deliveries.json";

  static void getPermissions() async {
    await Permission.storage.request();
  }

  //Gets the directory path for the file
  Future<String> get localPath async {

    final directory = await getExternalStorageDirectory();

    return directory.path;
  }

  Future<File> get locationFile async {

    final path = await localPath;

    return File(path + locationPath);
  }

  Future<File> get deliveriesFile async {

    final path = await localPath;

    return File(path + deliveriesPath);
  }

  Future<String> readFileContents(String text) async {
    try {
      File file;
      if(text == "locationFile") {
        file = await locationFile;
      }
      else {
        file = await deliveriesFile;
      }
      // Read the file
      String contents = await file.readAsString();

      return contents;
    } catch (e) {
      // If encountering an error, return 0
      return "";
    }
  }

  Future<File> writeToFile(String data, String text) async {
    File file;
    if(text == "locationFile") {
      file = await locationFile;
    }
    else {
      file = await deliveriesFile;
    }

    // Write the file
    return file.writeAsString('data', mode: FileMode.append);
  }
}
