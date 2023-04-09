// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:health/Constant/constant.dart';
import 'package:health/services/blockchain.dart';
import 'package:health/services/jsontoIPFS.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Model/patient_model.dart';

class LocalData {
  static SharedPreferences? prefs;

  static Future<void> saveData(String key, String value) async {
    prefs = await SharedPreferences.getInstance();
    prefs!.setString(key, value);
  }

  static Future<String> getData(String key) async {
    prefs = await SharedPreferences.getInstance();
    return prefs!.getString(key) ?? '';
  }

  static Future<void> saveBool(String key, bool value) async {
    prefs = await SharedPreferences.getInstance();
    prefs!.setBool(key, value);
  }

  static Future<bool> getBool(String key) async {
    prefs = await SharedPreferences.getInstance();
    return prefs!.getBool(key) ?? false;
  }

  static Future<void> clearData() async {
    prefs = await SharedPreferences.getInstance();
    prefs!.clear();
  }
}

