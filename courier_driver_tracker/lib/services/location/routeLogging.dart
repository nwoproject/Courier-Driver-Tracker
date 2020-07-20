import 'dart:async';
import 'dart:io';
import 'package:courier_driver_tracker/services/location/TrackingData.dart';
import 'package:courier_driver_tracker/services/location/location_service.dart';
import 'package:path_provider/path_provider.dart';

class RouteLogging{
  TrackingData location;

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/test.txt');
  }

  static Future<String> readFileContents() async {
    try {
      final file = await _localFile;

      // Read the file
      String contents = await file.readAsString();

      return contents;
    } catch (e) {
      // If encountering an error, return 0
      return "";
    }
  }

  static Future<File> writeToFile(String data) async {
    final file = await _localFile;

    // Write the file
    return file.writeAsString('data');
  }
}

}