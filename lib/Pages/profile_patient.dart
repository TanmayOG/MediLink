import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Provider/user_provider.dart';
import 'Auth/login.dart';
import 'Patient/patient_record_details.dart';

class ProfilePagePatient extends StatefulWidget {
  const ProfilePagePatient({super.key});

  @override
  State<ProfilePagePatient> createState() => _ProfilePagePatientState();
}

class _ProfilePagePatientState extends State<ProfilePagePatient> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UserInfo2>(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primColor,
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Name'),
            subtitle: Text(provider.name!),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.phone),
            title: const Text('Phone Number'),
            subtitle: Text(provider.phoneNo!),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.email),
            title: const Text('Email'),
            subtitle: Text(provider.email!),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.medical_services),
            title: Text('Blood Group'),
            subtitle: Text('Blood Group'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.location_on),
            title: const Text('Address'),
            subtitle: Text(provider.homeAddress!),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.wallet_giftcard),
            title: Text('Wallet ID'),
            subtitle: Text('Wallet ID'),
          ),
          const Divider(),
          ListTile(
            onTap: () {
              var address =
                  Provider.of<UserInfo2>(context, listen: false)
                          .walletAddress ??
                      '';
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          MedicalHistory(patientAddress: address)));
            },
            leading: const Icon(Icons.medical_services),
            title: const Text('Medical Records'),
            subtitle: const Text('Medical Records'),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
