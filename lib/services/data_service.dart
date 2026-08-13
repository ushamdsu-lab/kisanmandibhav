import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/crop.dart';
import '../models/fertilizer.dart';
import '../models/scheme.dart';
import '../models/helpline.dart';

class DataService {
  static Future<List<Crop>> loadCrops() async {
    final String jsonStr = await rootBundle.loadString('assets/data/crops.json');
    final List<dynamic> jsonList = json.decode(jsonStr);
    return jsonList.map((e) => Crop.fromJson(e)).toList();
  }

  static Future<List<Fertilizer>> loadFertilizers() async {
    final String jsonStr = await rootBundle.loadString('assets/data/fertilizers.json');
    final List<dynamic> jsonList = json.decode(jsonStr);
    return jsonList.map((e) => Fertilizer.fromJson(e)).toList();
  }

  static Future<List<Scheme>> loadSchemes() async {
    final String jsonStr = await rootBundle.loadString('assets/data/schemes.json');
    final List<dynamic> jsonList = json.decode(jsonStr);
    return jsonList.map((e) => Scheme.fromJson(e)).toList();
  }

  static Future<List<Helpline>> loadHelplines() async {
    final String jsonStr = await rootBundle.loadString('assets/data/helplines.json');
    final List<dynamic> jsonList = json.decode(jsonStr);
    return jsonList.map((e) => Helpline.fromJson(e)).toList();
  }
}
