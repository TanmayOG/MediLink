// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_ipfs/flutter_ipfs.dart';
import 'package:health/Model/patient_model.dart';
import 'package:health/Pages/Auth/login.dart';
import 'package:health/Pages/Auth/create_account.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web3dart/web3dart.dart';

import '../../services/blockchain.dart';
import '../../services/jsontoIPFS.dart';

class AddReport extends StatefulWidget {
  final String patientAddress;
  final String doctorAddress;
  final PatientModel? patient;
  const AddReport(
      {super.key,
      required this.patientAddress,
      required this.doctorAddress,
      this.patient});

  @override
  State<AddReport> createState() => _AddReportState();
}

class _AddReportState extends State<AddReport> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _diseaseController = TextEditingController();
  final TextEditingController _symptomsController = TextEditingController();
  final TextEditingController _hostController = TextEditingController();
  final TextEditingController _privateContoller = TextEditingController();

  final TextEditingController age = TextEditingController();
  String reportUrl = '';
  String preUrl = '';
  Web3Client? web3Client;
  Client httpClient = Client();

  @override
  void initState() {
    _nameController.text = widget.patient!.name;
    _phoneController.text = widget.patient!.phone;
    age.text = widget.patient!.age;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          // appBar: AppBar(
          //   title: const Text('Create Account'),
          // ),
          body: Padding(
        padding: const EdgeInsets.only(left: 25.0, right: 25),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 50,
                ),
                const Text('Add Report',
                    style:
                        TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                const SizedBox(
                  height: 20,
                ),
                const Text('Please fill the following details',
                    style: TextStyle(
                      fontSize: 16,
                    )),
                const SizedBox(
                  height: 50,
                ),
                _textField(
                    'Patient Name', _nameController, 'Enter patient name'),
                _textField('Patient Phone', _phoneController, 'Enter phone',
                    isPhone: true),
                _textField('Patient Age', age, 'Enter your age',
                    isPhone: false),
                _textField('Report Type', _typeController, 'Enter Report Type',
                    isPhone: false),
                _textField('Symptoms', _symptomsController, 'Enter Symptoms',
                    isPhone: false),
                _textField('Disease', _diseaseController, 'Enter Disease',
                    isPhone: false),
                _textField('Hosptial', _hostController, 'Enter Hospital',
                    isPhone: false),
                GestureDetector(
                  onTap: () async {
                    try {
                      setState(() {
                        isloading = true;
                      });

                      await ImagePickerService.pickImage(context)
                          .then((value) async {
                        var cid = await FlutterIpfs().uploadToIpfs(value!.path);
                        var infoUrl = '$baseIpfsUrl$cid';

                        setState(() {
                          reportUrl = infoUrl;
                          isloading = false;
                        });
                      });
                    } catch (e) {
                      setState(() {
                        isloading = false;
                      });
                      print(e);
                    }
                    // final path = await _pickerService.pickImage();
                  },
                  child: Container(
                      height: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: primColor),
                      ),
                      child: isloading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: primColor,
                              ))
                          : reportUrl == ''
                              ? Text("Upload Report 📁",
                                  style:
                                      TextStyle(fontSize: 15, color: primColor))
                              : const Text("Change Report 📁",
                                  style: TextStyle(
                                      fontSize: 15, color: Colors.green))),
                ),
                const SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  onTap: () async {
                    try {
                      setState(() {
                        isloading2 = true;
                      });

                      await ImagePickerService.pickImage(context)
                          .then((value) async {
                        var cid = await FlutterIpfs().uploadToIpfs(value!.path);
                        var infoUrl = '$baseIpfsUrl$cid';

                        setState(() {
                          preUrl = infoUrl;
                          isloading2 = false;
                        });
                      });
                    } catch (e) {
                      print(e);
                      setState(() {
                        isloading2 = false;
                      });
                    }
                    // final path = await _pickerService.pickImage();
                  },
                  child: Container(
                      height: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: primColor),
                      ),
                      child: isloading2
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: primColor,
                              ))
                          : preUrl == ''
                              ? Text("Upload Prescription 💉",
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: primColor,
                                      fontWeight: FontWeight.bold))
                              : const Text("Change Prescription 📁",
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold))),
                ),
                const SizedBox(
                  height: 40,
                ),
                button(() async {
                  // await getCurrLocation();
                  // try {
                  if (_formKey.currentState!.validate()) {
                    var id = DateTime.now().millisecondsSinceEpoch.toString();
                    var json = {
                      "name": _nameController.text,
                      "reportType": _typeController.text,
                      "disease": _diseaseController.text,
                      "prescription": preUrl,
                      "phone": _phoneController.text,
                      "age": age.text,
                      "id": id,
                      "hospital": _hostController.text,
                      "symptoms": _symptomsController.text,
                      'doctorId': widget.doctorAddress,
                      "patientId": widget.patientAddress,
                      "reportUrl": reportUrl,
                    };

                    var jsonStr = jsonEncode(json);
                    showLoading(context);

                    var url = await uploadJsonToIpfs(jsonStr);

                    print(url);
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    final key = prefs.getString('key');
                    print("key is $key");

                    await doctorUpload(
                      // key: key,
                      patientId: widget.patientAddress,
                      doctorId: widget.doctorAddress,
                      infoUrl: url,
                    );

                    // await Firebase

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Report Uploaded Successfully')));

                    setState(() {
                      _nameController.text = '';
                      _typeController.text = '';
                      _diseaseController.text = '';
                      _phoneController.text = '';
                      age.text = '';
                      reportUrl = '';
                      preUrl = '';
                    });
                    // await otpVerify(url);

                    // await verifyPhone(id: id, infoUrl: url);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Please fill all the fields')));
                  }
                  // } catch (e) {
                  //   print(e);
                  // }
                }, 'Continue'),
                const SizedBox(
                  height: 30,
                ),
              ],
            ),
          ),
        ),
      )),
    );
  }

  bool isloading = false;
  bool isloading2 = false;

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
