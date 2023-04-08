import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../Model/doctor_model.dart';
import '../Services/blockchain.dart';

class DoctorInfo extends ChangeNotifier {
  String? _name;
  String? _email;
  String? _phoneNo;
  String? _age;
  String? _qualification;
  String? _id;
  String? _walletId;

  String? get name => _name;
  String? get email => _email;
  String? get phoneNo => _phoneNo;
  String? get age => _age;
  String? get qualification => _qualification;
  String? get id => _id;
  String? get walletId => _walletId;

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

  set age(String? age) {
    _age = age;
    notifyListeners();
  }

  set qualification(String? qualification) {
    _qualification = qualification;
    notifyListeners();
  }

  set id(String? id) {
    _id = id;
    notifyListeners();
  }

  set walletId(String? walletId) {
    _walletId = walletId;
    notifyListeners();
  }

  DoctorInfo() {
    fetchDataFromLocalDatabase();
  }

  Future<void> fetchDataFromLocalDatabase() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final doctorData = prefs.getString('doctor_data');
      if (doctorData != null) {
        final doctor = Doctor.fromJson(jsonDecode(doctorData));
        name = doctor.name;
        email = doctor.email;
        phoneNo = doctor.phone;
        age = doctor.age;
        qualification = doctor.qualification;
        id = doctor.id;
        walletId = doctor.wId;

        print('name: $name');
      }
    } catch (e) {
      print('Error fetching data from local database: $e');
    }
  }

  getData(walletId) async {
    print('getData');
    await getDoctorInfo(walletId).then((value) async {
      print('value: $value');
      var url = '$baseIpfsUrl${value[2]}';
      print('val: $url');

      await setDoctorAddress(url);
    }).catchError((e) {
      print(e);
    }).timeout(const Duration(seconds: 5), onTimeout: () {
      print('timeout');
    });
  }

  setDoctorAddress(String url) async {
    try {
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final jsonString =
            response.body.replaceAll('\\', ''); // Remove backslashes
        print(jsonString);
        final jsonString1 = jsonString.substring(1, jsonString.length - 1);
        print(jsonString1);
        final doctor = Doctor.fromJson(jsonDecode(jsonString1));

        print('value: ${doctor.toJson()}');
        final prefs = await SharedPreferences.getInstance();
        prefs.setBool('islogin', true);
        prefs.setString('address', doctor.wId);
        prefs.setString('doctor_data', json.encode(doctor.toJson()));

        name = doctor.name;
        print('name: $name');
        email = doctor.email;
        phoneNo = doctor.phone;
        age = doctor.age;
        qualification = doctor.qualification;
        id = doctor.id;
        walletId = doctor.wId;
      } else {
        print('Failed to fetch data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }
}
