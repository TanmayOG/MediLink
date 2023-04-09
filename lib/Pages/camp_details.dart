import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:health/Pages/uploader_page.dart';

class CampDetails extends StatefulWidget {
  final String name;
  final String city;
  final String date;
  final String url;
  final String address;
  final String id;
  final GeoPoint geoPoint;
  final String typeOfCamp;
  const CampDetails(
      {super.key,
      required this.name,
      required this.city,
      required this.date,
      required this.address,
      required this.id,
      required this.geoPoint,
      required this.typeOfCamp,
      required this.url});

  @override
  State<CampDetails> createState() => _CampDetailsState();
}

class _CampDetailsState extends State<CampDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Camp Details'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const Divider(),
                SizedBox(
                  height: 200,
                  width: 200,
                  child: Image.network(widget.url, fit: BoxFit.cover),
                ),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Title'),
                  subtitle: Text(widget.name),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.location_on),
                  title: const Text('City'),
                  subtitle: Text(widget.city),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.date_range),
                  title: const Text('Date'),
                  subtitle: Text(newDate(widget.date)),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.location_on),
                  title: const Text('Address'),
                  subtitle: Text(widget.address),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.location_on),
                  title: const Text('Type of Camp'),
                  subtitle: Text(widget.typeOfCamp),
                ),
                const Divider(),
                SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: GoogleMap(
                    markers: {
                      Marker(
                          markerId: MarkerId(widget.id),
                          position: LatLng(widget.geoPoint.latitude,
                              widget.geoPoint.longitude))
                    },
                    initialCameraPosition: CameraPosition(
                        target: LatLng(widget.geoPoint.latitude,
                            widget.geoPoint.longitude),
                        zoom: 15),
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
