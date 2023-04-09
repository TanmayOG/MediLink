// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:convert';
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter_string_encryption/flutter_string_encryption.dart';
import 'package:health/Provider/doctor_provider.dart';
import 'package:health/Docs/auth/doc_login.dart';
import 'package:health/Docs/pages/home_page.dart';
import 'package:health/Model/patient_model.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health/Pages/Auth/login.dart';
import 'package:health/services/blockchain.dart';
import 'package:health/services/jsontoIPFS.dart';
import 'package:http/http.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web3dart/web3dart.dart';
import 'Constant/constant.dart';
import 'Pages/Patient/patient_home.dart';
import 'Provider/user_provider.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// final cryptor = new PlatformStringCryptor();

// const string =
//     "Java, android, ios, get the same result by DES encryption and decryption.";
// const key = "u1BvOHzUOcklgNpn1MaWvdn9DT4LyzSX";
// const iv = "12345678";

logout() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.clear();

  await FirebaseAuth.instance.signOut();
}

@pragma('vm:entry-point')
Future<void> backgroundHandler(RemoteMessage event) async {
  print(event.data.toString());
  print(event.notification!.title);
  log("Background Handler");
  log(event.notification!.body.toString());
  await Firebase.initializeApp();
  log("Firebase Initialized");
  log("Notification Title: ${event.notification!.title}");

  BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
    event.notification!.body.toString(),
    htmlFormatBigText: true,
    contentTitle: event.notification!.title,
    htmlFormatContentTitle: true,
    summaryText: event.notification!.title,
    htmlFormatSummaryText: true,
  );

  AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails('test', 'test',
          importance: Importance.max,
          priority: Priority.high,
          styleInformation: bigTextStyleInformation,
          playSound: true);

  NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(0, event.notification!.title,
      event.notification!.body, platformChannelSpecifics,
      payload: event.data['body']);
}

// Define a function to generate a 32-byte key

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();

    FirebaseMessaging.instance.requestPermission();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Foreground message received: ${message.notification!.title}");
      _showNotification(message, context);
      // _startTimer(message);
    });
    FirebaseMessaging.onBackgroundMessage(backgroundHandler);
    FirebaseMessaging.instance.getInitialMessage();
  }

  Future<void> _showNotification(
      RemoteMessage event, BuildContext context) async {
    BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
      event.notification!.body.toString(),
      htmlFormatBigText: true,
      contentTitle: event.notification!.title,
      htmlFormatContentTitle: true,
      summaryText: event.notification!.title,
      htmlFormatSummaryText: true,
    );

    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('test', 'test',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            styleInformation: bigTextStyleInformation,
            playSound: true);

    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(0, event.notification!.title,
        event.notification!.body, platformChannelSpecifics,
        payload: event.notification!.body);

    flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
      onSelectNotification: (String? payload) async {
        log("Payload: $payload");
        log("Event: ${event.notification!.body}");
        navigatorKey.currentState?.push(
            MaterialPageRoute(builder: (context) => const SplashScreen()));
        // if (_allowResponse) {
        // if (event.notification!.body ==
        //     'Your Request is Accepted by the nearest Petrol Pump') {
        //   log("Sankat Seva as Informer");
        //   log("Event: ${event.notification!.body}");
        //   navigatorKey.currentState?.push(
        //       MaterialPageRoute(builder: (context) => const SplashScreen()));
        // } else {
        //   log("Sankat Seva as Responser");
        //   log("Event: ${event.notification!.body}");
        //   navigatorKey.currentState?.push(MaterialPageRoute(
        //       builder: (context) => Page1(
        //             body: event.notification!.body.toString(),
        //           )));
        // }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserInfo2()),
        ChangeNotifierProvider(create: (_) => DoctorInfo()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          appBarTheme: AppBarTheme(
            backgroundColor: primColor,
            elevation: 0,
            // iconTheme: const IconThemeData(color: Colors.black),
          ),
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
          await Provider.of<UserInfo2>(context, listen: false).getData(address);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else if (type == 'doctor') {
          await Provider.of<DoctorInfo>(context, listen: false)
              .getData(address);
          log('doctor');
          if (await isDoctor(address) == true) {
            log('doctor is true');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DoctorHomePage()),
            );
          } else {
            log('doctor is false');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DocLogin()),
            );
          }
        } else {
          if (await isPatient(address) == true) {
            log('patient is true');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          } else {
            log('patient is false');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Login()),
            );
          }
        }
      } else {
        print('isLogin: $isLogin');
        log('Not Login');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
        );
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
      Provider.of<UserInfo2>(context, listen: false)
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

const String AppName = 'MediLink';
