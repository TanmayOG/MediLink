import 'package:flutter/material.dart';
import 'package:health/Docs/pages/patient_details.dart';
import 'package:health/Pages/Auth/login.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../services/blockchain.dart';

class PatientScreen extends StatefulWidget {
  const PatientScreen({super.key});

  @override
  State<PatientScreen> createState() => _PatientScreenState();
}

class _PatientScreenState extends State<PatientScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = '0xa1750f255587834af5A78Fa69646f317d90b1E25';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          // const SizedBox(height: 100),
          Padding(
            padding: const EdgeInsets.only(left: 0.0, right: 0.0),
            child: SizedBox(
              height: 100,
              // width:  ,
              child: TextFormField(
                cursorHeight: 20,
                controller: _controller,
                onChanged: (value) async {
                  setState(() {
                    _controller.text = value;
                  });
                },
                cursorColor: Colors.black,
                decoration: const InputDecoration(
                  hintText: 'Enter Patient ID',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.qr_code_scanner),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),
          FutureBuilder(
              future: getPatientInfo(_controller.text),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.1,
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.2,
                        child: Center(
                            child: LoadingAnimationWidget.dotsTriangle(
                          size: 50,
                          color: primColor,
                        )),
                      ),
                      const Text('Searching for Patient'),
                    ],
                  );
                }
                if (snapshot.hasData) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: primColor,
                      child: const Icon(
                        Icons.wallet,
                        color: Colors.white,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PatientDetails(
                            walletId: _controller.text,
                            url: snapshot.data![3].toString(),
                          ),
                        ),
                      );
                    },
                    subtitle: const Text("Tap to view Patient Details"),
                    title: Text(snapshot.data![2].toString()),
                  );
                } else {
                  return const Text('No data');
                }
              }),
        ],
      ),
    );
  }
}
