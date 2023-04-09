import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ipfs/flutter_ipfs.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:health/Pages/Auth/login.dart';
import 'package:health/Pages/uploader_page.dart';
import 'package:health/services/blockchain.dart';
import 'package:uuid/uuid.dart';

import '../../../Model/firebase_patient_model.dart';
import '../../../Services/jsontoIPFS.dart';

class CreateCamp extends StatefulWidget {
  const CreateCamp({super.key});

  @override
  State<CreateCamp> createState() => _CreateCampState();
}

class _CreateCampState extends State<CreateCamp> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController typeOfCamp = TextEditingController();
  final TextEditingController hospital = TextEditingController();
  final TextEditingController radius = TextEditingController();
  final TextEditingController date = TextEditingController();
  final TextEditingController doctorName = TextEditingController();

  DateTime? _selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      print(_selectedDate);

      var newDte = newDate(_selectedDate.toString());
      print(newDte);
      log(newDte.toString());
    }

    log(_selectedDate.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Campaign'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Fill the details for campaign',
                  style: TextStyle(fontSize: 18)),
              const SizedBox(height: 20),
              _textField("Title", _name, "Enter title of the camp"),
              _textField("Type of Camp", typeOfCamp, "Enter type of the camp"),
              _textField(
                  "Doctor Name", doctorName, "Enter the name of the doctor"),
              _textField("Hospital / Charity", hospital,
                  "Enter the name of the hospital"),

              // _textField("Campaign Name", _name, "Enter name of the camp"),
              GestureDetector(
                onTap: () {
                  log('hello');
                  _selectDate(context);
                },
                child: Container(
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    margin: const EdgeInsets.only(top: 20),
                    child: _selectedDate != null
                        ? Text(newDate(_selectedDate.toString()))
                        : const Text(
                            "Select Date for Camp 📅") // ElevatedButton )
                    ),
              ),
              GestureDetector(
                onTap: () async {
                  await ImagePickerService.pickImage(context)
                      .then((value) async {
                    var cid = await FlutterIpfs().uploadToIpfs(value!.path);
                    var infoUrl = '$baseIpfsUrl$cid';

                    setState(() {
                      url = infoUrl;
                    });
                  });
                },
                child: Container(
                  height: url == null ? 50 : 200,
                  width: double.infinity,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  margin: const EdgeInsets.only(top: 20),
                  child: url == null
                      ? const Text("Select Image for Camp 📷")
                      : Image.network(url,
                          fit: BoxFit.cover, height: 200, width: 200),
                ),
              ),
              const SizedBox(height: 20),
              customButton(
                  text: 'Create',
                  onTap: () async {
                    final curr = Geolocator();
                    final position = await Geolocator.getCurrentPosition(
                        desiredAccuracy: LocationAccuracy.high);
                    final lat = position.latitude;
                    final long = position.longitude;
                    GeoFlutterFire geo = GeoFlutterFire();

                    GeoFirePoint point =
                        geo.point(latitude: lat, longitude: long);

                    double radius = 5;
                    // double radius = 5;
                    Stream<List<DocumentSnapshot>> patientsStream = geo
                        .collection(
                            collectionRef: FirebaseFirestore.instance
                                .collection('patients'))
                        .within(
                            center: point,
                            radius: radius,
                            field: 'location',
                            strictMode: true);

                    patientsStream
                        .listen((List<DocumentSnapshot> patientsList) {
                      for (int i = 0; i < patientsList.length; i++) {
                        DocumentSnapshot patientDoc = patientsList[i];
                        FirebasePatient patient = FirebasePatient.fromJson(
                            json.decode(patientDoc.data() as String));
                        print(patient.token);
                        // ... do something with the patient data ...
                      }
                    });

                    if (_name.text.isNotEmpty &&
                        typeOfCamp.text.isNotEmpty &&
                        hospital.text.isNotEmpty &&
                        _selectedDate != null &&
                        doctorName.text.isNotEmpty &&
                        url != null) {
                      var id = const Uuid().v4();

                      final curr = Geolocator();
                      final position = await Geolocator.getCurrentPosition(
                          desiredAccuracy: LocationAccuracy.high);
                      final lat = position.latitude;
                      final long = position.longitude;

                      List<Placemark> placemarks =
                          await placemarkFromCoordinates(
                              position.latitude, position.longitude);

                      Placemark place = placemarks[0];

                      final city = place.locality;
                      final state = place.administrativeArea;
                      final address =
                          '${place.name}, ${place.locality} ${place.administrativeArea} ${place.country} ${place.postalCode}';
                      GeoFlutterFire geo = GeoFlutterFire();

                      GeoFirePoint point =
                          geo.point(latitude: lat, longitude: long);

                      await FirebaseFirestore.instance
                          .collection('camp')
                          .doc(id)
                          .set({
                        'id': id,
                        'title': _name.text,
                        'typeOfCamp': typeOfCamp.text,
                        'city': city,
                        'url': url,
                        'doctorName': doctorName.text,
                        'date': _selectedDate,
                        'state': state,
                        'address': address,
                        'location': point.data,
                        'views': [],
                        'GeoPoint': GeoPoint(lat, long),
                      }).then((value) async {
                        double radius = 5;
                        // double radius = 5;
                        Stream<List<DocumentSnapshot>> patientsStream = geo
                            .collection(
                                collectionRef: FirebaseFirestore.instance
                                    .collection('Users')
                                    .where('type', isEqualTo: 'Patient'))
                            .within(
                                center: point,
                                radius: radius,
                                field: 'location',
                                strictMode: true);

                        log('hello');

                        patientsStream.listen(
                            (List<DocumentSnapshot> patientsList) async {
                          log('hello');
                          log("Found ${patientsList.length} patients");
                          for (int i = 0; i < patientsList.length; i++) {
                            DocumentSnapshot patientDoc = patientsList[i];
                            log("Patient ${patientDoc.id} is within $radius km");
                            FirebasePatient patient = FirebasePatient.fromJson(
                                patientDoc.data() as Map<String, dynamic>);

                            log('hello');
                            print(patient.token);

                            await FirebaseFirestore.instance
                                .collection('Users')
                                .doc(patient.wId)
                                .collection('notifications')
                                .add({
                              'title':
                                  "${typeOfCamp.text} camp is going to be held on ${newDate(_selectedDate.toString())}",
                              'date': DateTime.now(),
                              'type': 'camp',
                              'campId': id,
                              'isRead': false,
                            });

                            campNoti([
                              patient.token!
                            ], "${typeOfCamp.text} camp is going to be held on ${newDate(_selectedDate.toString())}",
                                GeoPoint(lat, long), id);

                            // campNoti([patient.token!], "", , id)
                            // ... do something with the patient data ...
                          }
                        });

                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => const UploaderPage(),
                        //   ),
                        // );
                      });
                    }
                  }),
            ],
          ),
        ),
      ),
    );
  }

  var url;

  Widget _textField(name, controller, hint,
      {bool isPhone = false, bool isPassword = false}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        name,
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: TextFormField(
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please fill this box';
            }
            return null;
          },
          maxLength: isPhone ? 10 : null,
          obscureText: isPassword ? true : false,
          controller: controller,
          cursorColor: Colors.black,
          keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
          decoration: InputDecoration(
            counter: const Offstage(),
            prefixText: isPhone ? '+91 ' : '',
            border: const OutlineInputBorder(),
            enabled: true,
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 1.0),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 1.0),
            ),
            hintText: hint,
          ),
        ),
      ),
    );
  }
}
