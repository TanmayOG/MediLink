import 'package:flutter/material.dart';
import 'package:health/Provider/doctor_provider.dart';
import 'package:provider/provider.dart';

import '../../Pages/Auth/login.dart';

class DoctorProfile extends StatefulWidget {
  const DoctorProfile({super.key});

  @override
  State<DoctorProfile> createState() => _DoctorProfileState();
}

class _DoctorProfileState extends State<DoctorProfile> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DoctorInfo>(context);
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
          ListTile(
            leading: const Icon(Icons.location_on),
            title: const Text('Qualification'),
            subtitle: Text(provider.qualification!),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.wallet_giftcard),
            title: Text('Wallet ID'),
            subtitle: Text('Wallet ID'),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
