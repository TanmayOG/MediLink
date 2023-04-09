// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:convert';
import 'dart:developer';
// import 'dart:math';

import 'package:flutter/material.dart';
import 'package:health/Pages/Patient/patient_records.dart';
import 'package:health/Provider/user_provider.dart';
import 'package:health/main.dart';
import 'package:health/pages/Patient/patient_nearby.dart';
import 'package:http/http.dart' as http;
import 'package:health/Pages/Auth/login.dart';
import 'package:health/Pages/Docs/upload_docs.dart';
import 'package:health/Pages/profile_patient.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Model/medical_record.dart';
import '../../Services/jsontoIPFS.dart';
import '../../services/blockchain.dart';
// import 'package:telemedicine/providers/user_info.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Future<List<Patient>>? _recordFuture;

  String dateTime = '';

  @override
  void initState() {
    super.initState();
    // decryptWithAESKey();
    // _recordFuture = fetchPatientData(widget.patientAddress);
  }

  

  Future<List<Patient>> fetchPatientData(String patientId) async {
    log('fetchPatientData: $patientId');
    List<dynamic> result = await getPatientRecord(patientId);
    print("result: $result");
    var token = result[0][3];
    print("token: $token");
    // var url2 = decryptWithAESKey(token);
    // print("url2: $url2");

    // String token2 = MyEncriptionDecription.decryptAES(token, 'fj197x7zu6nnb5qvmhq9k3u6vzuyz55n');
    // print("token2: $token2");
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
    final user = Provider.of<UserInfo2>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          AppName,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Home',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 20,
            ),
            Consumer<UserInfo2>(
              builder: (context, userInfo, child) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, ${userInfo.name ?? ''}!',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${userInfo.homeAddress}🚂',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // customButton(
            //     color: Colors.white,
            //     text: 'Upload Report',
            //     onTap: () async {
            //       SharedPreferences prefs =
            //           await SharedPreferences.getInstance();
            //       var name22 =
            //           Provider.of<UserInfo>(context, listen: false).name ?? '';
            //       var key2 = prefs.getString('key');
            //       var address = Provider.of<UserInfo>(context, listen: false)
            //               .walletAddress ??
            //           '';
            //       var phone =
            //           Provider.of<UserInfo>(context, listen: false).email ?? '';
            //       // var name = Provider.of<UserInfo>(context, listen: false)
            FutureBuilder<List<Patient>>(
              future: fetchPatientData(user.walletAddress ?? ''),
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
                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    shrinkWrap: true,
                    itemCount: records.length,
                    itemBuilder: (context, index) {
                      Patient record = records[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MedicalRecordDetails(
                                      record: record,
                                    )),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: primColor,
                                child: const Icon(
                                  Icons.file_present_sharp,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(record.disease),
                              // ListTile(
                              // onTap: () {
                              //   Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (context) =>
                              //             MedicalRecordDetails(
                              //               record: record,
                              //             )),
                              //   );
                              // },
                              //   leading: CircleAvatar(
                              //     backgroundColor: primColor,
                              //     child: const Icon(
                              //       Icons.medical_services,
                              //       color: Colors.white,
                              //     ),
                              //   ),
                              //   title: Text(record.disease),
                              //   // subtitle: Text(newDate(record.doctorId))
                              //   subtitle: Text(record.hospital),
                              // ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
            //       // await getPatientRecord(address);
            //       Navigator.push(
            //           context,
            //           MaterialPageRoute(
            //               builder: (context) => UploadReportPage(
            //                   wId: address, privateKey: key2!, name: name22)));
            //     }),
            // const SizedBox(height: 20),
            // customButton(
            //     color: Colors.white,
            //     text: 'Upload Docs',
            //     onTap: () async {
            //       var address = Provider.of<UserInfo>(context, listen: false)
            //               .walletAddress ??
            //           '';
            //       Navigator.push(
            //           context,
            //           MaterialPageRoute(
            //               builder: (context) =>
            //                   MedicalHistory(patientAddress: address)));
            //       // ImagePickerService.pickImage(context).then((value) async {
            //       //   print('Uploading');
            //       //   print('Value: $value');
            //       //   var cid = await FlutterIpfs().uploadToIpfs(value!.path);
            //       //   print('CID: $cid');
            //       //   var id = const Uuid().v4();
            //       //   var infoUrl = '$baseIpfsUrl$cid';
            //       //   await uploadDocs(
            //       //     id,
            //       //     infoUrl,
            //       //     DateTime.now().toString(),
            //       //     address,
            //       //   );
            //       //   print('Uploaded');
            //       // });
            //     }),
          ],
        ),
      ),
      drawer: customDrawer(context),
    );
  }

  int page = 0;
  Drawer customDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: primColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: Container(
              decoration: BoxDecoration(
                color: primColor,
                borderRadius: BorderRadius.circular(
                  10,
                ),
              ),
              height: 50,
              child: const Center(
                  child: Text(
                AppName,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              )),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          ListTile(
            leading: const Icon(Icons.home_filled, color: Colors.white),
            title: const Text(
              'Home',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            onTap: () {
              setState(() {
                page = 0;
              });
              Navigator.pop(context);
            },
          ),
          const SizedBox(
            height: 20,
          ),
          ListTile(
            leading: const Icon(Icons.home_repair_service_sharp,
                color: Colors.white),
            title: const Text(
              'Upload Reports',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            onTap: () async {
              setState(() {
                page = 1;
              });
              Navigator.pop(context);
              SharedPreferences prefs = await SharedPreferences.getInstance();
              var name22 =
                  Provider.of<UserInfo2>(context, listen: false).name ?? '';
              var key2 = prefs.getString('key') ?? '';
              var address = Provider.of<UserInfo2>(context, listen: false)
                      .walletAddress ??
                  '';
              var phone =
                  Provider.of<UserInfo2>(context, listen: false).email ?? '';
              // var name = Provider.of<UserInfo>(context, listen: false)

              // await getPatientRecord(address);

              log('name: $name22');
              log('key: $key2');
              log('address: $address');
              log('phone: $phone');

              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => UploadReportPage(
                          wId: address, privateKey: key2, name: name22)));
              // Navigator.push(
              //     context,
              //     MaterialPageRoute
              //         builder: (context) => const PatientScreen()));
            },
          ),
          const SizedBox(
            height: 20,
          ),
          ListTile(
            leading: const Icon(Icons.campaign, color: Colors.white),
            title: const Text(
              'Nearby Camaigns',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            onTap: () {
              setState(() {
                page = 2;
              });
              Navigator.pop(context);

              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PatientNearby()));
            },
          ),
          const SizedBox(
            height: 20,
          ),
          ListTile(
            leading: const Icon(Icons.person_2, color: Colors.white),
            title: const Text(
              'Profile',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            onTap: () {
              setState(() {
                page = 3;
              });
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ProfilePagePatient()),
              );
            },
          ),
          const SizedBox(
            height: 20,
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.white),
            title: const Text(
              'Logout',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            onTap: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.clear();
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const Login()),
                  (route) => false);
            },
          ),
        ],
      ),
    );
  }
}

emptyPage() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(
          height: 200,
          width: 200,
        ),
        LoadingAnimationWidget.dotsTriangle(color: Colors.black, size: 55),
        const SizedBox(height: 20),
        const Text(
          'Server Unavailable',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        const Padding(
          padding: EdgeInsets.all(30.0),
          child: Text(
            'Currently we are not able to connect to the server. Please try again later.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
            ),
          ),
        ),
      ],
    ),
  );
}
