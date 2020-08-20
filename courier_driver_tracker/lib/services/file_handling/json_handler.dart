import 'package:flutter/services.dart';
import 'dart:convert';

class JsonHandler{
  Future<String>loadJsonFromAsset(String filename) async {
    return await rootBundle.loadString("assets/json/$filename");
  }

  Future parseJson(String filename) async {
    String jsonString = await loadJsonFromAsset(filename);
    final jsonResponse = jsonDecode(jsonString);
    return jsonResponse;
  }
}