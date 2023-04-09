import 'package:flutter/material.dart';
import 'package:health/services/blockchain.dart';
import 'package:intl/intl.dart';

import '../Model/patient_record.dart';

class RecordPage extends StatefulWidget {
  final String patientAddress;

  const RecordPage({super.key, required this.patientAddress});

  @override
  _RecordPageState createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  Future<List<Record>>? _recordFuture;

  @override
  void initState() {
    super.initState();
    _recordFuture = fetchAndDisplayRecord(widget.patientAddress);
  }

  Future<List<Record>> fetchAndDisplayRecord(String patientAddress) async {
    List<dynamic> result = await getPatientRecord(patientAddress);
    print("result: $result");
    List<Record> records = result.map((e) => Record.fromList(e)).toList();
    return records;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Records'),
      ),
      body: FutureBuilder<List<Record>>(
        future: _recordFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print(snapshot.error);
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No records found'));
          } else {
            List<Record> records = snapshot.data!;
            return ListView.builder(
              itemCount: records.length,
              itemBuilder: (context, index) {
                Record record = records[index];
                return ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewReport(src: record.infoUrl),
                      ),
                    );
                  },
                  leading: const Icon(Icons.medical_services),
                  title: Text("Record ${index + 1}"),
                  subtitle: Text(newDate(record.dateTime)),
                );
              },
            );
          }
        },
      ),
    );
  }
}

newDate(String date) {
  DateTime dateTime = DateTime.parse(date);
  String formattedDateTime = DateFormat('MM/dd/yy hh:mm a').format(dateTime);
  return formattedDateTime;
}

class ViewReport extends StatefulWidget {
  final String src;
  const ViewReport({super.key, required this.src});

  @override
  State<ViewReport> createState() => _ViewReportState();
}

class _ViewReportState extends State<ViewReport> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // full screen image
        body: Center(
      child: Image(
        image: NetworkImage(widget.src),
      ),
    ));
  }
}
