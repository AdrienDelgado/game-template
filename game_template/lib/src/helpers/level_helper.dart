import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

abstract class LevelHelper {
  static const String nColumns = 'nColumns';
  static const String nRows = 'nRows';
  static const String seed = 'seed';

  static Future<Map<String, dynamic>> getLevelDetails(int level) async {
    final String response =
        await rootBundle.loadString('assets/json/levels.json');
    final map = jsonDecode(response)["levels"][level.toString()]
        as Map<String, dynamic>;
    return map;
  }
}
