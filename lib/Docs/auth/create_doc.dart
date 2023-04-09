// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:convert';
import 'dart:developer';
// import 'dart:math';

// import 'package:facedetectionattandanceapp/Constant/config.dart';
// import 'package:facedetectionattandanceapp/pages/opt_screen.dart';
// import 'package:facedetectionattandanceapp/services/jsontoIPFS.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:health/Constant/constant.dart';
import 'package:health/Provider/doctor_provider.dart';
import 'package:health/Services/jsontoIPFS.dart';
import 'package:health/main.dart';
import 'package:health/services/blockchain.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:web3dart/web3dart.dart';

import '../../Pages/Auth/create_account.dart';

class CreateAccountDoc extends StatefulWidget {
  final wAddress;
  final keyPrivate;
  const CreateAccountDoc({Key? key, this.wAddress, this.keyPrivate})
      : super(key: key);

  @override
  State<CreateAccountDoc> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccountDoc> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _qualificationController =
      TextEditingController();
  final TextEditingController _privateContoller = TextEditingController();

  final TextEditingController age = TextEditingController();
  Web3Client? web3Client;
  Client httpClient = Client();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    web3Client = Web3Client(infuraUrl, httpClient);
    _nameController.text = 'Dr Mike Tawde';
    _emailController.text = 'miketawde@gmail.com';
    _phoneController.text = '7903525278';
    _qualificationController.text = 'MBBS';
    age.text = '38';
    _privateContoller.text = widget.keyPrivate;

    log('private key is ${widget.keyPrivate}');
    log('wallet address is ${widget.wAddress}');
  }

  String? _selectedGender;

  dropdown() {
    // male or female
    return SizedBox(
      height: 80,
      width: 200,
      child: DropdownButtonFormField<String>(
        value: _selectedGender,
        decoration: const InputDecoration(
          labelStyle: TextStyle(color: Colors.black),
          labelText: 'Gender',
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey, width: 1.0),
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black, width: 1.0),
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey, width: 1.0),
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
        items: const [
          DropdownMenuItem(
            value: 'male',
            child: Text('Male'),
          ),
          DropdownMenuItem(
            value: 'female',
            child: Text('Female'),
          ),
        ],
        onChanged: (value) {
          setState(() {
            _selectedGender = value;
          });
        },
      ),
    );
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
                const Text('Create Account',
                    style:
                        TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                const Text('Doctor',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(
                  height: 20,
                ),
                const Text('Please enter your details to create an account',
                    style: TextStyle(
                      fontSize: 16,
                    )),
                const SizedBox(
                  height: 50,
                ),
                _textField('Name', _nameController, 'Enter your name'),
                const SizedBox(
                  height: 20,
                ),
                _textField('Email', _emailController, 'Enter your email'),
                const SizedBox(
                  height: 20,
                ),
                dropdown(),
                const SizedBox(
                  height: 20,
                ),
                _textField('Phone', _phoneController, 'Enter your phone',
                    isPhone: true),
                _textField('Age', age, 'Enter your age', isPhone: false),

                const SizedBox(
                  height: 20,
                ),
                _textField('Qualification', _qualificationController,
                    'Enter your qualification'),
                // _textField('Private Key', _privateContoller,
                //     'Enter your private key'),
                const SizedBox(
                  height: 40,
                ),
                button(() async {
                  await getCurrLocation();
                  try {
                    if (_formKey.currentState!.validate()) {
                      var id = DateTime.now().millisecondsSinceEpoch.toString();
                      var json = {
                        "name": _nameController.text,
                        "email": _emailController.text,
                        "phone": _phoneController.text,
                        "age": age.text,
                        "qualification": _qualificationController.text,
                        "id": id,
                        "wId": PatientAddress
                      };

                      var jsonStr = jsonEncode(json);
                      showLoading(context);

                      var url = await uploadJsonToIpfs(jsonStr);
                      print(url);
                      await otpVerify(url);

                      // await verifyPhone(id: id, infoUrl: url);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Please fill all the fields')));
                    }
                  } catch (e) {
                    print(e);
                  }
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

  GeoFlutterFire geo = GeoFlutterFire();
  GeoFirePoint? _center;

  getCurrLocation() async {
    // check if location is enabled
    bool isLocationEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isLocationEnabled) {
      return showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text('Location is disabled'),
                content: const Text('Please enable location'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Ok'),
                  ),
                  TextButton(
                    onPressed: () async {
                      Geolocator.requestPermission();
                      Position position = await Geolocator.getCurrentPosition(
                          desiredAccuracy: LocationAccuracy.high);
                      print(position.latitude);
                      print(position.longitude);

                      setState(() {
                        _center = geo.point(
                            latitude: position.latitude,
                            longitude: position.longitude);
                      });
                    },
                    child: const Text('Enable'),
                  ),
                ],
              ));
    } else {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      print(position.latitude);
      print(position.longitude);

      setState(() {
        _center = geo.point(
            latitude: position.latitude, longitude: position.longitude);
      });
    }
  }

  otpVerify(url) async {
    // try {
    try {
      await addDoctor(
        id: const Uuid().v4(),
        infoUrl: url,
        geoPoint: _center!,
        keyPrivate: widget.keyPrivate,
        docAddress: widget.wAddress,
      );
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('address', widget.wAddress);
      prefs.setString('key', _privateContoller.text);
      prefs.setBool('islogin', true);
      prefs.setString('type', 'doctor');
      await Provider.of<DoctorInfo>(context, listen: false)
          .getData(widget.wAddress);
      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SplashScreen()),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
      ));
    }
  }

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
