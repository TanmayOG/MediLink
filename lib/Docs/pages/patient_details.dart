// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:health/Constant/constant.dart';
import 'package:health/Docs/pages/add_report.dart';
import 'package:http/http.dart' as http;
import 'package:health/services/blockchain.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Services/jsontoIPFS.dart';
import '../../Model/patient_model.dart';
import '../../Pages/Auth/login.dart';
import '../../Pages/Patient/patient_record_details.dart';

class PatientDetails extends StatefulWidget {
  final walletId;
  final url;
  const PatientDetails({super.key, this.walletId, this.url});

  @override
  State<PatientDetails> createState() => _PatientDetailsState();
}

class _PatientDetailsState extends State<PatientDetails> {
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

  PatientModel patient = PatientModel(
      address: '',
      age: '',
      bloodGroup: '',
      email: '',
      id: '',
      name: '',
      phone: '',
      wId: '');
  Future<List<PatientModel>> setPatientAddress(String url) async {
    try {
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));

      List<PatientModel> patientList = [];
      if (response.statusCode == 200) {
        final jsonString =
            response.body.replaceAll('\\', ''); // Remove backslashes
        print(jsonString);
        final jsonString1 = jsonString.substring(1, jsonString.length - 1);
        print(jsonString1);
        var patient = PatientModel.fromJson(jsonDecode(jsonString1));

        patientList.add(patient);

        // setState(() {
        //   patient = patient;
        // });
      } else {
        print('Failed to fetch data. Status code: ${response.statusCode}');
      }
      print('patientList $patientList');
      return patientList;

      // Return the list of patients
    } catch (e) {
      print('Error fetching data: $e');
      return []; // Return an empty list on error
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            var doctorAddress = prefs.getString(WalletAddress) ?? '';
            var privkey = prefs.getString('key') ?? '';
            var patient = await setPatientAddress('$baseIpfsUrl${widget.url}');
            PatientModel patient2 = PatientModel(
                address: patient[0].address,
                age: patient[0].age,
                bloodGroup: patient[0].bloodGroup,
                email: patient[0].email,
                id: patient[0].id,
                name: patient[0].name,
                phone: patient[0].phone,
                wId: patient[0].wId);

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddReport(
                  doctorAddress: doctorAddress,
                  patient: patient2,
                  patientAddress: widget.walletId,

                  // key: privkey,
                ),
              ),
            );
          },
          backgroundColor: primColor,
          icon: const Icon(Icons.add_box_sharp),
          label: const Text('Add Report'),
        ),
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: primColor,
          elevation: 0,
          // iconTheme: const IconThemeData(color: Colors.black),
          title: const Text('Patient Details',
              style: TextStyle(color: Colors.white)),
        ),
        body: FutureBuilder(
          future: setPatientAddress('$baseIpfsUrl/${widget.url}'),
          builder: (BuildContext context,
              AsyncSnapshot<List<PatientModel>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                  child: LoadingAnimationWidget.dotsTriangle(
                size: 50,
                color: primColor,
              ));
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData) {
              return const Center(child: Text('No data'));
            }

            // Display the patient details
            final patient = snapshot.data!.first;
            // return Column(
            //   children: [
            //     Text(patient.name),
            //     Text(patient.email),
            //     Text(patient.phone),
            //     Text(patient.bloodGroup),
            //     Text(patient.address),
            //     Text(patient.age),
            //     Text(patient.id),
            //     Text(patient.wId),
            //   ],
            // );
            return Column(
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: primColor,
                    child: const Icon(
                      Icons.person_2,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(patient.name),
                  subtitle: Text(patient.email),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.phone),
                  title: Text(patient.phone),
                  subtitle: const Text('Phone Number'),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.medical_services),
                  title: Text(patient.bloodGroup),
                  subtitle: const Text('Blood Group'),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.location_on),
                  title: Text(patient.address),
                  subtitle: const Text('Address'),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.nature_people_rounded),
                  title: Text(patient.age),
                  subtitle: const Text('Age'),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.wallet_giftcard),
                  title: Text(patient.wId),
                ),
                const Divider(),
                ListTile(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MedicalHistory(
                                  patientAddress: patient.wId,
                                )));
                  },
                  leading: const Icon(Icons.history_edu_rounded),
                  title: const Text("Medical History"),
                  subtitle: Text("View ${patient.name}'s medical history"),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
