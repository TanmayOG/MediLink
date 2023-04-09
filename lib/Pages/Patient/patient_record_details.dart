import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:health/Pages/Patient/patient_records.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:http/http.dart' as http;
import '../../Services/jsontoIPFS.dart';
import '../../Docs/pages/patient_details.dart';
import '../../Model/medical_record.dart';
import '../../services/blockchain.dart';
import '../Auth/login.dart';

class MedicalHistory extends StatefulWidget {
  final patientAddress;
  const MedicalHistory({super.key, this.patientAddress});

  @override
  State<MedicalHistory> createState() => _MedicalHistoryState();
}

class _MedicalHistoryState extends State<MedicalHistory> {
  Future<List<Patient>>? _recordFuture;

  String dateTime = '';

  @override
  void initState() {
    super.initState();
    _recordFuture = fetchPatientData(widget.patientAddress);
  }

  Future<List<Patient>> fetchPatientData(String patientId) async {
    List<dynamic> result = await getPatientRecord(patientId);
    print("result: $result");
    var token = result[0][1];
    print("token: $token");
    var url = '$baseIpfsUrl/$token';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // final json = jsonDecode(response.body);
      final jsonString =
          response.body.replaceAll('\\', ''); // Remove backslashes
      print(jsonString);
      final jsonString1 = jsonString.substring(1, jsonString.length - 1);
      print(jsonString1);
      final json = jsonDecode(jsonString1);
      print(json);
      final patient = Patient.fromJson(json);
      print(patient);
      return [patient];
    } else {
      throw Exception('Failed to load patient data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primColor,
        title: const Text(
          'Patient Records',
        ),
      ),
      body: FutureBuilder<List<Patient>>(
        future: _recordFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: LoadingAnimationWidget.bouncingBall(
              size: 50,
              color: primColor,
            ));
          } else if (snapshot.hasError) {
            print(snapshot.error);
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No records found'));
          } else {
            List<Patient> records = snapshot.data!;
            return ListView.builder(
              itemCount: records.length,
              itemBuilder: (context, index) {
                Patient record = records[index];
                return ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MedicalRecordDetails(
                                record: record,
                              )),
                    );
                  },
                  leading: CircleAvatar(
                    backgroundColor: primColor,
                    child: const Icon(
                      Icons.medical_services,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(record.disease),
                  // subtitle: Text(newDate(record.doctorId))
                  subtitle: Text(record.hospital),
                );
              },
            );
          }
        },
      ),
    );
  }
}
