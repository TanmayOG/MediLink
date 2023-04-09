import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:http/http.dart' as http;
import '../../Services/jsontoIPFS.dart';
import '../../Docs/pages/patient_details.dart';
import '../../Model/medical_record.dart';
import '../../services/blockchain.dart';
import '../Auth/login.dart';
import '../uploader_page.dart';

class MedicalRecordDetails extends StatefulWidget {
  final Patient record;
  const MedicalRecordDetails({super.key, required this.record});

  @override
  State<MedicalRecordDetails> createState() => _MedicalRecordDetailsState();
}

class _MedicalRecordDetailsState extends State<MedicalRecordDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: primColor,
          title: const Text('Medical Record Details',
              style: TextStyle(color: Colors.white)),
        ),
        body: Column(
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundColor: primColor,
                child: const Icon(
                  Icons.wallet,
                  color: Colors.white,
                ),
              ),
              title: Text(widget.record.patientId),
              subtitle: const Text("Patient ID"),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.phone),
              title: Text(widget.record.reportType),
              subtitle: const Text('Report Type'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.dock),
              title: Text(widget.record.doctorId),
              subtitle: const Text('Doctor ID'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.local_hospital_outlined),
              title: Text(widget.record.hospital),
              subtitle: const Text('Hospital Name'),
            ),
            const Divider(),
            ListTile(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ViewReport(
                            src: widget.record.prescription,
                          ))),
              leading: const Icon(Icons.precision_manufacturing),
              title: const Text("Prescription"),
              subtitle: const Text('Tap to view prescription'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.back_hand_rounded),
              title: Text(widget.record.symptoms),
              subtitle: const Text('Symptoms'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.file_present),
              title: const Text("Report"),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ViewReport(
                              src: widget.record.reportUrl,
                            )));
              },
              subtitle: const Text('Tap to view report'),
            ),
            const Divider(),
          ],
        ));
  }
}
