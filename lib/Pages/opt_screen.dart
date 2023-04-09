// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:developer';

// import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:health/Constant/constant.dart';
import 'package:health/Pages/Auth/create_account.dart';
import 'package:health/Pages/Patient/patient_home.dart';
import 'package:health/Provider/user_provider.dart';
import 'package:health/main.dart';
import 'package:health/services/blockchain.dart';
import 'package:health/services/local_storage.dart';
import 'package:provider/provider.dart';

class OptScreen extends StatefulWidget {
  final String? phone;
  final String? name;
  final String? infoUrl;
  final String? id;

  final String? address;
  final String? email;
  final String? walletAddress;
  final String? verificationId;
  final GeoFirePoint? geoPoint;
  final private;
  const OptScreen(
      {Key? key,
      this.phone,
      this.private,
      this.name,
      this.address,
      this.email,
      this.walletAddress,
      this.verificationId,
      this.infoUrl,
      this.id,
      this.geoPoint})
      : super(key: key);

  @override
  State<OptScreen> createState() => _OptScreenState();
}

class _OptScreenState extends State<OptScreen> {
  final TextEditingController _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          // appBar: AppBar(
          //   centerTitle: true,
          //   title: const Text('OTP',
          //       style: TextStyle(
          //           color: Colors.black, fontWeight: FontWeight.bold)),
          // ),
          body: Padding(
        padding: const EdgeInsets.only(left: 25.0, right: 25),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(
                  height: 50,
                ),
                const CircleAvatar(
                  radius: 100,
                  backgroundColor: Colors.blue,
                  child: Icon(
                    Icons.verified_user,
                    size: 100,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(
                  height: 80,
                ),
                const Text('Verification Code',
                    style:
                        TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  'We have sent a verification code to your phone number',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 50,
                ),
                const Text('Enter the code',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(
                  height: 20,
                ),
                _textField("Enter 6 digit OTP", _otpController, "Enter OTP"),
                const SizedBox(
                  height: 50,
                ),
                button(() async {
                  await otpVerify();
                }, "Verify")
              ],
            ),
          ),
        ),
      )),
    );
  }

  otpVerify() async {
    showLoading(context);
    log(widget.verificationId!);
    log(_otpController.text);
    // try {
    try {
      await FirebaseAuth.instance
          .signInWithCredential(PhoneAuthProvider.credential(
        verificationId: widget.verificationId!,
        smsCode: _otpController.text,
      ));
      var model = '';
      print(widget.private);
      print(widget.walletAddress);
      await addPatient(
        id: widget.id!,
        infoUrl: widget.infoUrl!,
        modelData: model,
        geoPoint: widget.geoPoint!,
        keyPrivate: widget.private,
        patientAddress: widget.walletAddress!,
      );
      await LocalData.saveData(Name, widget.name!);

      await LocalData.saveData(Email, widget.email!);
      await LocalData.saveData(Phone, widget.phone!);
      await LocalData.saveData(Address, widget.address!);
      await LocalData.saveData('key', widget.private!);
      await LocalData.saveData(WalletAddress, widget.walletAddress!);
      await LocalData.saveBool(isLogin, true);

      await getPatientInfo(widget.walletAddress!).then((value) {
        var token = value[2];
        print("token is $token");
      });
      await Provider.of<UserInfo2>(context, listen: false)
          .getData(widget.walletAddress);
      Navigator.pop(context);
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const SplashScreen()),
          (route) => false);
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
      ));
    }
  }

  // block of code for text field
  Widget _textField(
      String label, TextEditingController controller, String validationText) {
    return SizedBox(
      // height: 55,
      width: MediaQuery.of(context).size.width * 0.8,
      child: TextFormField(
        maxLength: 6,
        controller: controller,
        cursorColor: Colors.black,
        textAlign: TextAlign.center,
        style: const TextStyle(
            fontSize: 17, fontWeight: FontWeight.bold, letterSpacing: 35),
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          counter: const Offstage(),
          contentPadding: const EdgeInsets.fromLTRB(20, 20, 0, 15),
          hintText: label,
          hintStyle: const TextStyle(
              fontSize: 17, fontWeight: FontWeight.bold, letterSpacing: 1),
          border: const OutlineInputBorder(),
          enabled: true,
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey, width: 1.0),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black, width: 1.0),
          ),
        ),
        validator: (value) {
          if (value!.isEmpty) {
            return validationText;
          }
          return null;
        },
      ),
    );
  }
}
