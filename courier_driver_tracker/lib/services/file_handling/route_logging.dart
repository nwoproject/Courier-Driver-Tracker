import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:courier_driver_tracker/services/location/geolocator_service.dart';
import 'package:geolocator/geolocator.dart';

class RouteLogging{

  final String locationPath ="/Download/test.json";
  final String deliveriesPath = "deliveries.json";
  String name = "";
  bool first = true;
  String time = "";
  var driverID;

  GeolocatorService geolocatorService = new GeolocatorService();
  Position position;
  final storage = new FlutterSecureStorage();

  static Future<bool> checkPermissions() async {
    return await Permission.storage.isGranted;
  }

  static Future<bool> getPermissions() async {
    PermissionStatus permissionStatus = await Permission.storage.request();
    if(permissionStatus == PermissionStatus.granted){
      return true;
    }
    return false;
  }

  Future getFileNameData() async{
  position = await geolocatorService.getPosition();
  driverID = await storage.read(key: 'id');
  driverID = driverID.toString();
  time = position.timestamp.toString();

  }

  String getFileName(){
    getFileNameData();
    if (first == true) {
      name = (driverID + "_" + time + ".txt");
      first = false;
    }
    print(name);
    return name;
  }


  //Gets the directory path for the file
  Future<String> get localPath async {

    final directory = await getExternalStorageDirectory();
    final directoryFolder = Directory(directory.path + "/Download/" +"/CourierDriverTracker/");

    if(await directoryFolder.exists()){
      return directoryFolder.path;
    }
    else {
      final directoryNewFolder = await directoryFolder.create(recursive: true);
      return directoryNewFolder.path;
    }

  }

  Future<File> get locationFile async {
    String fileName = getFileName();
    final path = await localPath;
    print(name);

    return File(path + fileName);
  }

  Future<File> get deliveriesFile async {

    final path = await localPath;

    return File(path + deliveriesPath);
  }

  Future<String> readFileContents(String text) async {
    try {
      File file;
      if(text != "deliveries") {
        file = await deliveriesFile;
      }
      else {
        file = await locationFile;
      }
      // Read the file
      String contents = await file.readAsString();

      return contents;
    } catch (e) {
      // If encountering an error, return 0
      return "";
    }
  }

  Future<File> writeToFile(String data, String fileType) async {
    File file;
    if(fileType == "locationFile") {
      file = await locationFile;
    }
    else if(fileType == "deliveriesFile"){
      file = await deliveriesFile;
    }

    // Write the file
    return file.writeAsString(data, mode: FileMode.append);
  }
}
