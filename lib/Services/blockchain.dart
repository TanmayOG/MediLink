// ignore_for_file: unused_local_variable

import 'dart:convert';
import 'dart:developer';
import 'dart:math' as m;
import 'package:http/http.dart' as http;

import 'package:cloud_firestore/cloud_firestore.dart' as firstore;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:health/Constant/constant.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:web3dart/web3dart.dart';

import 'en.dart';

Future<DeployedContract> getContract() async {
  String abi = await rootBundle.loadString("assets/abi.json");
  String contractAdd = contract_Address;
  final contract = DeployedContract(ContractAbi.fromJson(abi, 'HealthCare'),
      EthereumAddress.fromHex(contractAdd));
  return contract;
}

Future<String> callFunction(String functionName, List<dynamic> args,
    Web3Client ethClient, String privateKey) async {
  EthPrivateKey credentials = EthPrivateKey.fromHex(privateKey);
  DeployedContract contract = await getContract();
  final ethFunction = contract.function(functionName);
  final result = await ethClient.sendTransaction(
    credentials,
    Transaction.callContract(
      contract: contract,
      function: ethFunction,
      parameters: args,
    ),
    fetchChainIdFromNetworkId: true,
    chainId: null,
  );
  return result;
}

// isPatientRegistered function
Future<bool> isPatient(String patientAddress) async {
  try {
    Web3Client ethClient = Web3Client(infuraUrl, Client());
    DeployedContract contract = await getContract();
    final ethFunction = contract.function(isPatientRegistered);
    List<dynamic> result = await ethClient.call(
      contract: contract,
      function: ethFunction,
      params: [EthereumAddress.fromHex(patientAddress)],
    );
    log(result.toString());

    if (result[0] == true) {
      log("Patient is registered");
    } else {
      log("Patient is not registered");
    }
    log(result[0].toString());
    return result[0];
  } catch (e) {
    log("Error in isPatientRegistered function: $e");
    return false;
  }
}

// registerPatient function

addPatient({
  required String id,
  required String modelData,
  required String patientAddress,
  required String infoUrl,
  required String keyPrivate,
  required GeoFirePoint geoPoint,
}) async {
  // try {

  print("Patient Address: $patientAddress");
  print("Patient Private Key: $keyPrivate");
  Web3Client ethClient = Web3Client(infuraUrl, Client());
  // string[] modelData;
  // string list data in
  DeployedContract contract = await getContract();
  final ethFunction = contract.function(AddPatientFunction);
  final result = await ethClient.sendTransaction(
    EthPrivateKey.fromHex(keyPrivate),
    Transaction.callContract(
      contract: contract,
      function: ethFunction,
      parameters: [
        id,
        modelData,
        EthereumAddress.fromHex(patientAddress),
        infoUrl
      ],
    ),
    fetchChainIdFromNetworkId: true,
    chainId: null,
  );

  final token = await FirebaseMessaging.instance.getToken();

  await firstore.FirebaseFirestore.instance
      .collection('Users')
      .doc(patientAddress)
      .set({
    'wID': patientAddress,
    'token': token,
    'type': 'Patient',
    'location': geoPoint.data,
  });

  log(result.toString());
  // } catch (e) {
  //   log("Error in addPatient function: $e");
  // }
}

// getPatientInfo function

Future<List<dynamic>> getPatientInfo(String patientAddress) async {
  Web3Client ethClient = Web3Client(infuraUrl, Client());
  DeployedContract contract = await getContract();
  final ethFunction = contract.function(GetPatient);
  List<dynamic> result = await ethClient.call(
    contract: contract,
    function: ethFunction,
    params: [EthereumAddress.fromHex(patientAddress)],
  );
  log(result[0].toString());
  return result[0];
}

uploadDocs(
    String id, String infoUrl, String dateTime, String uploaderAddress) async {
  Web3Client ethClient = Web3Client(infuraUrl, Client());
  DeployedContract contract = await getContract();
  final ethFunction = contract.function(UploadRecord);
  var result = await ethClient.sendTransaction(
    EthPrivateKey.fromHex(paitent_private_key),
    Transaction.callContract(
      contract: contract,
      function: ethFunction,
      parameters: [
        id,
        infoUrl,
        dateTime,
        EthereumAddress.fromHex(uploaderAddress)
      ],
    ),
    fetchChainIdFromNetworkId: true,
    chainId: null,
  );
  log(result.toString());
  return result[0];
}

// getPatientRecord function

Future<List<dynamic>> getPatientRecord(String patientAddress) async {
  Web3Client ethClient = Web3Client(infuraUrl, Client());
  DeployedContract contract = await getContract();
  final ethFunction = contract.function('GetRecordByPatient');
  List<dynamic> result = await ethClient.call(
    contract: contract,
    function: ethFunction,
    params: [EthereumAddress.fromHex(patientAddress)],
  );
  log(result[0].toString());

  return result[0];
}

// getPatientRecordByUploader function

getDocs(String address) async {
  Web3Client ethClient = Web3Client(infuraUrl, Client());
  DeployedContract contract = await getContract();
  final ethFunction = contract.function(GetUploadRecordByUploader);
  List<dynamic> result = await ethClient.call(
    contract: contract,
    function: ethFunction,
    params: [EthereumAddress.fromHex(address)],
  );
  log(result.toString());
  return result;
}

addDoctor({
  required String id,
  required String docAddress,
  required String infoUrl,
  required GeoFirePoint geoPoint,
  required String keyPrivate,
}) async {
  Web3Client ethClient = Web3Client(infuraUrl, Client());
  // string[] modelData;
  // string list data in
  DeployedContract contract = await getContract();
  final ethFunction = contract.function('AddDoctor');
  final result = await ethClient.sendTransaction(
    EthPrivateKey.fromHex(keyPrivate),
    Transaction.callContract(
      contract: contract,
      function: ethFunction,
      parameters: [id, EthereumAddress.fromHex(docAddress), infoUrl],
    ),
    fetchChainIdFromNetworkId: true,
    chainId: null,
  );

  final token = await FirebaseMessaging.instance.getToken();

  await firstore.FirebaseFirestore.instance
      .collection('Users')
      .doc(docAddress)
      .set({
    'wID': docAddress,
    'token': token,
    'type': 'Doctor',
    'location': geoPoint.data,
  });

  log(result.toString());
}

Future<bool> isDoctor(String patientAddress) async {
  try {
    Web3Client ethClient = Web3Client(infuraUrl, Client());
    DeployedContract contract = await getContract();
    final ethFunction = contract.function('isDoctorRegistered');
    log("isPatientRegistered function: ${ethFunction.name}");
    List<dynamic> result = await ethClient.call(
      contract: contract,
      function: ethFunction,
      params: [EthereumAddress.fromHex(patientAddress)],
    );
    log(result.toString());

    if (result[0] == true) {
      log("isDoctor is registered");
    } else {
      log("isDoctor is not registered");
    }
    log(result[0].toString());
    return result[0];
  } catch (e) {
    log("Error in isPatientRegistered function: $e");
    return false;
  }
}

Future<List<dynamic>> getDoctorInfo(String patientAddress) async {
  Web3Client ethClient = Web3Client(infuraUrl, Client());
  DeployedContract contract = await getContract();
  final ethFunction = contract.function(GetDoctor);
  List<dynamic> result = await ethClient.call(
    contract: contract,
    function: ethFunction,
    params: [EthereumAddress.fromHex(patientAddress)],
  );
  log(result[0].toString());
  return result[0];
}

doctorUpload({patientId, doctorId, infoUrl, Web3Client? ethClient}) async {
  log("Patient ID: $patientId");
  log("Doctor ID: $doctorId");
  var id = const Uuid().v1();
  DeployedContract contract = await getContract();
  SharedPreferences prefs = await SharedPreferences.getInstance();

  var key = generateRandomString(32);
  var encryptedKey = encryptWithAESKey(infoUrl, key);
  var pvtKey = prefs.getString('key');
  log("pvtKey: $pvtKey");
  log("Type of pvtKey: $pvtKey");
  var result = await callFunction(
      'DoctorUploadRecord',
      [
        id,
        EthereumAddress.fromHex(patientId),
        EthereumAddress.fromHex(doctorId),
        infoUrl,
        DateTime.now().toString()
      ],
      ethClient!,
      pvtKey!);
  log(result.toString());

  await firstore.FirebaseFirestore.instance.collection("Keys").doc(id).set({
    'key': key,
    'patientId': patientId,
    'id': id,
  }).then((value) {
    log("Key added to database");
  });

  return result[0];
}

String generateRandomString(int length) {
  const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  final random = m.Random.secure();
  final codeUnits = List.generate(
    length,
    (index) => chars.codeUnitAt(random.nextInt(chars.length)),
  );
  return String.fromCharCodes(codeUnits);
}

getRecordPatient(String address) async {
  Web3Client ethClient = Web3Client(infuraUrl, Client());
  DeployedContract contract = await getContract();
  final ethFunction = contract.function('GetRecordByPatient');
  List<dynamic> result = await ethClient.call(
    contract: contract,
    function: ethFunction,
    params: [EthereumAddress.fromHex(address)],
  );
  log(result[0].toString());
  return result[0];
}

sendNotification(List<String>? Ids, message, type, docId, patId) async {
  var body = {
    "registration_ids": Ids,
    "notification": {
      "title": "MediLink",
      "body": message,
      "sound": true,
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
      "data": {
        "type": type,
        "sender": docId,
        "receiver": patId,
        "message": message,
        "time": DateTime.now().millisecondsSinceEpoch.toString(),
      }
    }
  };
  var serverKey =
      'AAAAODbD6dE:APA91bHGu9AVmhwZ7e6BToR4rarck8zRIgCMpWXsRMxDzeUAE0D1t0mPWJ-9mqLzbmNA2cU_axb4l7QdeauXxmfuewLV6Wn-GnQByKfgFaOn_CBxXmyqDMFTSMh3Xyg1vqKAkzZ0CE67';

  Map<String, String> userHeader = {
    "Content-Type": "application/json",
    "Authorization":
        "key=AAAAODbD6dE:APA91bHGu9AVmhwZ7e6BToR4rarck8zRIgCMpWXsRMxDzeUAE0D1t0mPWJ-9mqLzbmNA2cU_axb4l7QdeauXxmfuewLV6Wn-GnQByKfgFaOn_CBxXmyqDMFTSMh3Xyg1vqKAkzZ0CE67"
  };
  var url = Uri.parse('https://fcm.googleapis.com/fcm/send');
  Response res =
      await http.post(url, body: jsonEncode(body), headers: userHeader);

  if (res.statusCode == 200) {
    log(res.body);
    log(res.request.toString());
    print('Notification Send');
  } else {
    print('Notification Not Send');
  }
}

getRecordByDoctor({doctorId}) async {
  Web3Client ethClient = Web3Client(infuraUrl, Client());
  DeployedContract contract = await getContract();
  final ethFunction = contract.function('GetRecordByDoctor');
  List<dynamic> result = await ethClient.call(
    contract: contract,
    function: ethFunction,
    params: [EthereumAddress.fromHex(doctorId)],
  );
  log(result[0].toString());
  return result[0];
}

campNoti(List<String>? Ids, message, geoPoint, id) async {
  var body = {
    "registration_ids": Ids,
    "notification": {
      "title": "MediLink",
      "body": message,
      "sound": true,
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
      "data": {
        "message": message,
        "id": id,
        "lat": geoPoint.latitude,
        "long": geoPoint.longitude,
        "time": DateTime.now().toString(),
      }
    }
  };
  var serverKey =
      'AAAAODbD6dE:APA91bHGu9AVmhwZ7e6BToR4rarck8zRIgCMpWXsRMxDzeUAE0D1t0mPWJ-9mqLzbmNA2cU_axb4l7QdeauXxmfuewLV6Wn-GnQByKfgFaOn_CBxXmyqDMFTSMh3Xyg1vqKAkzZ0CE67';

  Map<String, String> userHeader = {
    "Content-Type": "application/json",
    "Authorization":
        "key=AAAAODbD6dE:APA91bHGu9AVmhwZ7e6BToR4rarck8zRIgCMpWXsRMxDzeUAE0D1t0mPWJ-9mqLzbmNA2cU_axb4l7QdeauXxmfuewLV6Wn-GnQByKfgFaOn_CBxXmyqDMFTSMh3Xyg1vqKAkzZ0CE67"
  };
  var url = Uri.parse('https://fcm.googleapis.com/fcm/send');
  Response res =
      await http.post(url, body: jsonEncode(body), headers: userHeader);

  if (res.statusCode == 200) {
    log(res.body);
    log(res.request.toString());
    print('Notification Send');
  } else {
    print('Notification Not Send');
  }
}
