// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:convert';
import 'dart:developer';

// import 'package:facedetectionattandanceapp/Constant/config.dart';
// import 'package:facedetectionattandanceapp/pages/opt_screen.dart';
// import 'package:facedetectionattandanceapp/services/jsontoIPFS.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:health/Services/jsontoIPFS.dart';
import 'package:health/Pages/Auth/login.dart';
import 'package:health/Pages/opt_screen.dart';
import 'package:http/http.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:web3dart/web3dart.dart';
import '../../Constant/constant.dart';

class CreateAccount extends StatefulWidget {
  final wAddress;
  final keyPrivate;
  const CreateAccount({Key? key, this.wAddress, this.keyPrivate})
      : super(key: key);

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _homeAdressController = TextEditingController();

  final TextEditingController _blo = TextEditingController();
  final TextEditingController _privateContoller = TextEditingController();

  final TextEditingController age = TextEditingController();
  Web3Client? web3Client;
  Client httpClient = Client();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    web3Client = Web3Client(infuraUrl, httpClient);
    _nameController.text = 'Tanmay ';
    _emailController.text = 'tanmay25@gmail.com';
    _phoneController.text = '7903525279';
    _homeAdressController.text = 'Mira Road';
    _blo.text = 'A';

    print('wallet address: ${widget.wAddress}');

    age.text = '20';
    _privateContoller.text = widget.keyPrivate;
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
                _textField('Blood Group', _blo, 'Enter your blood group',
                    isPhone: false),
                const SizedBox(
                  height: 20,
                ),
                _textField('Home Address', _homeAdressController,
                    'Enter your home address'),
                // _textField('Private Key', _privateContoller,
                //     'Enter your private key'),
                const SizedBox(
                  height: 40,
                ),
                button(() async {
                  try {
                    if (_formKey.currentState!.validate()) {
                      var id = DateTime.now().millisecondsSinceEpoch.toString();
                      var json = {
                        "name": _nameController.text,
                        "email": _emailController.text,
                        "phone": _phoneController.text,
                        "Blood Group": _blo.text,
                        "address": _homeAdressController.text,
                        "age": age.text,
                        "id": id,
                        "wId": widget.wAddress
                      };

                      await getCurrLocation();

                      var jsonStr = jsonEncode(json);
                      showLoading(context);

                      var url = await uploadJsonToIpfs(jsonStr);
                      print(url);

                      verifyPhone(id: id, infoUrl: url);

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
                    onPressed: () {
                      Geolocator.requestPermission();
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

  verifyPhone({infoUrl, id}) async {
    log("verify phone");
    log("Private key: ${_privateContoller.text} ");

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+91${_phoneController.text}',
        verificationCompleted: (PhoneAuthCredential credential) {},
        verificationFailed: (FirebaseAuthException e) {
          Navigator.pop(context);
          if (e.code == 'invalid-phone-number') {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('The provided phone number is not valid')));
          } else if (e.code == 'invalid-verification-code') {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('The verification code is invalid')));
          }
        },
        timeout: const Duration(minutes: 2),
        codeSent: (String verificationId, int? resendToken) async {
          // String addres = await LocalData.getData('');
          log("code sent");
          Navigator.pop(context);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => OptScreen(
                        verificationId: verificationId,
                        phone: '+91${_phoneController.text}',
                        name: _nameController.text,
                        email: _emailController.text,
                        id: id,
                        geoPoint: _center,
                        infoUrl: infoUrl,
                        private: widget.keyPrivate,
                        walletAddress: widget.wAddress,
                        address: _homeAdressController.text,
                      )));
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // timer

          // chnage the state of the button to resend otp

          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                duration: Duration(seconds: 3),
                backgroundColor: Colors.red,
                content: Text('Time out, please try again')));
          }
          // Auto-resolution timed out...
        },
      );
    } catch (e) {
      Navigator.pop(context);
      log(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          duration: Duration(seconds: 3),
          backgroundColor: Colors.red,
          content: Text('Something went wrong, please try again')));
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

Widget button(OnTap, text) {
  return SizedBox(
    width: double.infinity,
    height: 50,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: primColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
      ),
      onPressed: OnTap,
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}

showLoading(context) {
  // show loading dialog
  // if loading is true then show loading dialog else hide loading dialog

  return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Center(
          child: SizedBox(
              // color: Colors.white,
              height: 100,
              width: 250,
              child: LoadingAnimationWidget.dotsTriangle(
                  color: Colors.white, size: 60)),
        );
      });
}
