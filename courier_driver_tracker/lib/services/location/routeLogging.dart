import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permissions_plugin/permissions_plugin.dart';

// This class is to handle the file operations for route logging.
class routeLogging{

  static void getPermission() async{
    Map<Permission, PermissionState> permission = await PermissionsPlugin
        .requestPermissions([
      Permission.READ_EXTERNAL_STORAGE,
      Permission.WRITE_EXTERNAL_STORAGE
    ]);
  }

    //gets the correct directory path to store the file.
   static Future<String> get localPath async {
    final directory = await getExternalStorageDirectory();
    getPermission();
    return directory.path;
  }
  //returns the file where the location data is written to.
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
    return file.writeAsString('data');
  }
}

