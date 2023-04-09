import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:health/Pages/Auth/login.dart';
import 'package:health/Pages/uploader_page.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'create_camp.dart';

class Campaign extends StatefulWidget {
  const Campaign({super.key});

  @override
  State<Campaign> createState() => _CampaignState();
}

class _CampaignState extends State<Campaign> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campaign'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateCamp(),
            ),
          );
        },
        label: const Text('New Campaign'),
        icon: const Icon(Icons.add),
        backgroundColor: primColor,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('camp').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingAnimationWidget.dotsTriangle(
              size: 50,
              color: primColor,
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No Campaigns'),
            );
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text('Error'),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot camp = snapshot.data!.docs[index];
              return Card(
                child: ListTile(
                  title: Row(
                    children: [
                      Text(camp['title']),
                      const Spacer(),
                      Text(camp['doctorName']),
                    ],
                  ),
                  subtitle: Text(newDate(camp['date'].toDate().toString())),
                  // trailing: Text(camp['location']),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
