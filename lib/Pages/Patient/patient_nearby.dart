import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:health/Pages/camp_details.dart';

class PatientNearby extends StatefulWidget {
  const PatientNearby({super.key});

  @override
  State<PatientNearby> createState() => _PatientNearbyState();
}

class _PatientNearbyState extends State<PatientNearby> {
  getDataLocationBySorted() async {
    final curr = Geolocator.getCurrentPosition().then((value) async {
      final lat = value.latitude;
      final long = value.longitude;
      List data = [];
      var doc = await FirebaseFirestore.instance.collection('camp').get();

      for (var i in doc.docs) {
        data.add(i.data());
      }

      data.sort((a, b) {
        final aLat = a['location'].latitude;
        final aLong = a['location'].longitude;
        final bLat = b['location'].latitude;
        final bLong = b['location'].longitude;

        final aDistance = Geolocator.distanceBetween(lat, long, aLat, aLong);
        final bDistance = Geolocator.distanceBetween(lat, long, bLat, bLong);

        return aDistance.compareTo(bDistance);
      });
      return data;
    });

    // sort data by distance from user
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campaign'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('camp').snapshots(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data.docs.length,
              itemBuilder: (context, index) {
                var data = snapshot.data.docs[index];
                return ListTile(
                  onTap: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CampDetails(
                                  name: data['title'],
                                  city: data['city'],
                                  date: data['date'].toDate().toString(),
                                  address: data['address'],
                                  id: data['id'],
                                  geoPoint: data['GeoPoint'],
                                  typeOfCamp: data['typeOfCamp'],
                                  url: data['url'],
                                )));
                  },
                  title: Text(data['title']),
                  subtitle: Text(data['doctorName']),
                );
              },
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
