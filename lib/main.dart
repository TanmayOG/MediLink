// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:convert';
import 'dart:developer';
import 'package:health/Provider/doctor_provider.dart';
import 'package:health/Provider/user_info.dart';

import 'package:health/Model/patient_model.dart';

import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:health/services/blockchain.dart';

import 'package:http/http.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web3dart/web3dart.dart';
import 'Constant/constant.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserInfo()),
        ChangeNotifierProvider(create: (_) => DoctorInfo()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: GoogleFonts.montserrat().fontFamily,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Web3Client? client;
  @override
  void initState() {
    client = Web3Client(infuraUrl, Client());
    final context = this.context;
    // test();
    init();
    super.initState();
  }

  init() async {
    Future.delayed(const Duration(seconds: 2), () async {
      log('initState');
      late final SharedPreferences prefs;
      try {
        prefs = await SharedPreferences.getInstance();
        print('prefs: $prefs');
      } catch (e) {
        log('Error getting SharedPreferences: $e');
        return;
      }

      final isLogin = prefs.getBool('islogin') ?? false;
      final address = prefs.getString(WalletAddress) ?? '';
      final type = prefs.getString('type') ?? '';
      print('isLogin: $isLogin');
      print('address: $address');
      if (isLogin) {
        print(await isPatient(address));
        print('isLogin: $isLogin');
        log('login');

        if (type == 'patient') {
          // getData(address);
          // Navigator.pushReplacement(
          //   context,
          //   MaterialPageRoute(builder: (context) => const HomeScreen()),
          // );
        } else if (type == 'doctor') {
          log('doctor');
          if (await isDoctor(address) == true) {
            log('doctor is true');
            // Navigator.pushReplacement(
            //   context,
            //   MaterialPageRoute(builder: (context) => const DoctorHomePage()),
            // );
          } else {
            log('doctor is false');
            // Navigator.pushReplacement(
            //   context,
            //   MaterialPageRoute(builder: (context) => const DocLogin()),
            // );
          }
        } else {
          if (await isPatient(address) == true) {
            log('patient is true');
            // Navigator.pushReplacement(
            //   context,
            //   MaterialPageRoute(builder: (context) => const HomeScreen()),
            // );
          } else {
            log('patient is false');
            // Navigator.pushReplacement(
            //   context,
            //   MaterialPageRoute(builder: (context) => const Login()),
            // );
          }
        }
      } else {
        print('isLogin: $isLogin');
        log('Not Login');
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (context) => const Login()),
        // );
      }
    });
  }

  getData(address) async {
    print('getData');
    await getPatientInfo(address).then((value) {
      print(value[3]);
      var url = '$baseIpfsUrl${value[3]}';
      print(url);

      fetchDataAndStoreInLocalStorage(url);
      Provider.of<UserInfo>(context, listen: false)
          .fetchDataFromLocalDatabase();
    }).catchError((e) {
      print(e);
    }).timeout(const Duration(seconds: 5), onTimeout: () {
      print('timeout');
    });
  }

  void fetchDataAndStoreInLocalStorage(url) async {
    try {
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final jsonString =
            response.body.replaceAll('\\', ''); // Remove backslashes
        print(jsonString);
        final jsonString1 = jsonString.substring(1, jsonString.length - 1);
        print(jsonString1);
        final patient = PatientModel.fromJson(jsonDecode(jsonString1));

        final prefs = await SharedPreferences.getInstance();
        prefs.setString('patient_data', json.encode(patient.toJson()));
      } else {
        print('Failed to fetch data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            LoadingAnimationWidget.dotsTriangle(color: Colors.black, size: 55),
            const SizedBox(height: 20),
            const Text(
              AppName,
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

const String AppName = 'MediBlock';
