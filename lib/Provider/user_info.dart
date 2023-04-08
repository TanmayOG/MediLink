// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:health/Services/jsontoIPFS.dart';
import 'package:health/services/blockchain.dart';
import 'package:http/http.dart' as http;
import 'package:health/Model/patient_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserInfo extends ChangeNotifier {
  String? _name;
  String? _email;
  String? _phoneNo;
  String? _homeAddress;
  String? _walletAddress;

  String? get name => _name;
  String? get email => _email;
  String? get phoneNo => _phoneNo;
  String? get homeAddress => _homeAddress;
  String? get walletAddress => _walletAddress;

  set name(String? name) {
    _name = name;
    notifyListeners();
  }

  set email(String? email) {
    _email = email;
    notifyListeners();
  }

  set phoneNo(String? phoneNo) {
    _phoneNo = phoneNo;
    notifyListeners();
  }

  set homeAddress(String? homeAddress) {
    _homeAddress = homeAddress;
    notifyListeners();
  }

  set walletAddress(String? walletAddress) {
    _walletAddress = walletAddress;
    notifyListeners();
  }

  UserInfo() {
    fetchDataFromLocalDatabase();
  }

  Future<void> fetchDataFromLocalDatabase() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final patientData = prefs.getString('patient_data');
      if (patientData != null) {
        final patient = PatientModel.fromJson(jsonDecode(patientData));
        name = patient.name;
        email = patient.email;
        phoneNo = patient.phone;
        homeAddress = patient.address;
        walletAddress = patient.wId;

        print('name: $name');
      }
    } catch (e) {
      print('Error fetching data from local database: $e');
    }
  }

  getData(address) async {
    print('getData');
    await getPatientInfo(address).then((value) async {
      print(value[3]);
      var url = '$baseIpfsUrl${value[3]}';
      print(url);

      await setPatientAddress(url);
    }).catchError((e) {
      print(e);
    }).timeout(const Duration(seconds: 5), onTimeout: () {
      print('timeout');
    });
  }

  setPatientAddress(String url) async {
    try {
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final jsonString =
            response.body.replaceAll('\\', ''); // Remove backslashes
        print(jsonString);
        final jsonString1 = jsonString.substring(1, jsonString.length - 1);
        print(jsonString1);
        final patient = PatientModel.fromJson(jsonDecode(jsonString1));

        final prefs = await SharedPreferences.getInstance();
        prefs.setBool('islogin', true);
        prefs.setString('address', patient.wId);
        prefs.setString('patient_data', json.encode(patient.toJson()));

        name = patient.name;
        email = patient.email;
        phoneNo = patient.phone;
        homeAddress = patient.address;
        walletAddress = patient.wId;
      } else {
        print('Failed to fetch data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }
}
