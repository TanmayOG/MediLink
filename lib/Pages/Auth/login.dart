// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:health/Constant/constant.dart';
import 'package:health/Docs/auth/doc_login.dart';
import 'package:health/main.dart';
import 'package:health/Pages/Auth/create_account.dart';
import 'package:health/Pages/Patient/patient_home.dart';
import 'package:health/services/blockchain.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web3dart/web3dart.dart';

import '../../Provider/user_provider.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  late Web3Client client;
  @override
  void initState() {
    client = Web3Client(infuraUrl, Client());

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
          key: _navigatorKey,
          body: Padding(
            padding: EdgeInsets.only(
              left: w * 0.08,
              right: w * 0.08,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 40,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DocLogin(),
                      ),
                    );
                  },
                  child: const Text(
                    AppName,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  height: h * 0.42,
                  child: Image.asset(
                    "assets/images/main.png",
                    fit: BoxFit.contain,
                  ),
                ),
                const Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Track all your medical records in one place",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Get your medical records in one place and share them with your doctor easily and securely",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                customButton(
                  isLogin: false,
                  context: context,
                  onTap: () async {
                    // showLoginBotton();
                    loginSheet(context: context, key: _navigatorKey);
                  },
                  text: "Create free account",
                  icon: const Icon(Icons.login),
                  color: Colors.blue,
                ),
                Container(
                  // ----- or ----
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: const [
                      Expanded(
                        child: Divider(
                          color: Colors.grey,
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          "OR",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Colors.grey,
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                customButton(
                  context: context,
                  onTap: () async {
                    // showLoginBotton();
                    loginSheet(context: context, key: _navigatorKey);
                  },
                  text: "Login with Metamask",
                  icon: const Icon(Icons.login),
                  color: Colors.blue,
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          )),
    );
  }

  Future<dynamic> loginSheet({required BuildContext context, key}) {
    return showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: isSelect ? MediaQuery.of(context).size.height * 0.47 : 300,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(
                    height: 30,
                  ),
                  Container(
                    height: 5,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Center(
                    child: Text(
                      "Connect with Metamask",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  ListTile(
                    trailing: acc == 'Account 1'
                        ? const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          )
                        : null,
                    leading: CircleAvatar(
                      backgroundColor: primColor,
                      child:
                          const Icon(Icons.wallet_rounded, color: Colors.white),
                    ),
                    title: const Text("Account 1"),
                    subtitle: const Text(
                        '0xa1750f255587834af5A78Fa69646f317d90b1E25'),
                    onTap: () async {
                      setState(() {
                        isSelect = true;
                      });
                      setState(() {
                        acc = 'Account 1';
                        address1 = '0xa1750f255587834af5A78Fa69646f317d90b1E25';
                        privateKey =
                            'de0eb1beaef64d6109902951da2f69a0103aab87afdeb94cdefbca585d2d9fd9';
                      });

                      print(privateKey);
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ListTile(
                    trailing: acc == 'Account 2'
                        ? const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          )
                        : null,
                    leading: const CircleAvatar(
                      backgroundColor: Colors.limeAccent,
                      child: Icon(Icons.wallet_rounded, color: Colors.white),
                    ),
                    title: const Text("Account 2"),
                    subtitle: const Text(
                        '0xB72FAA0759E043B80A0F14c705D1db05987723e4'),
                    onTap: () async {
                      setState(() {
                        isSelect = true;
                        acc = 'Account 2';
                        address1 = '0xB72FAA0759E043B80A0F14c705D1db05987723e4';
                        privateKey =
                            '1ef6b7f5c0cc1e0d4c6c24c39516c289d715385a23205407e39e31964e1492b9';
                      });
                      print(privateKey);
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  !isSelect
                      ? Container()
                      : Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: selectBtn(
                                    text: 'Cancel',
                                    onTap: () {},
                                    isCan: true,
                                    context: context),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Expanded(
                                child: selectBtn(
                                    text: 'Connect',
                                    onTap: () async {
                                      SharedPreferences prefs =
                                          await SharedPreferences.getInstance();

                                      print("Login Address $address1");
                                      print("Login Private Key $privateKey");

                                      try {
                                        showLoading(context);
                                        if (await isPatient(address1) == true) {
                                          await prefs.setString(
                                              WalletAddress, address1);
                                          await prefs.setString(
                                              'key', privateKey);
                                          prefs.setBool('islogin', true);
                                          prefs.setString('type', 'patient');
                                          await Provider.of<UserInfo2>(context,
                                                  listen: false)
                                              .getData(address1);

                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const HomeScreen()),
                                          );
                                        } else {
                                          await prefs.setString(
                                              WalletAddress, address1);
                                          await prefs.setString(
                                              'key', privateKey);

                                          prefs.setString('type', 'patient');

                                          Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      CreateAccount(
                                                        keyPrivate: privateKey,
                                                        wAddress: address1,
                                                      )));
                                        }
                                      } catch (e) {
                                        print(e);
                                      }
                                      key(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const HomeScreen()),
                                      );

                                      Navigator.pop(context);
                                    },
                                    isCan: false,
                                    context: context),
                              )
                            ],
                          ),
                        ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  bool isLogin = false;
  bool isSelect = false;
  String address1 = '';
  String privateKey = '';
  String acc = '';

  selectBtn({isCan = false, text, required BuildContext context, onTap}) {
    return GestureDetector(
      onTap: () async {
        if (isCan) {
          isSelect = false;
          acc = '';

          Navigator.pop(context);
        } else {
          onTap();
        }
      },
      child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: isCan ? Colors.white : primColor,
              border: isCan
                  ? Border.all(
                      color: primColor,
                      width: 1,
                    )
                  : null),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          // width: 400,
          child: Text(
            text,
            style: TextStyle(
                color: isCan ? const Color(0xFF0F0BDB) : Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold),
          )),
    );
  }
}

customButton({context, onTap, text, icon, color, isLogin = true}) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: isLogin ? Colors.white : primColor,
            border: isLogin
                ? Border.all(
                    color: primColor,
                    width: 1,
                  )
                : null),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        // width: 400,
        child: Text(
          text,
          style: TextStyle(
              color: isLogin ? primColor : Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold),
        ),
      ),
    ),
  );
}

checkDoctorOrPatient({address}) async {
  final doctor = await isDoctor(address);
  final patient = await isPatient(address);

  if (doctor == true) {
    return 'doctor';
  } else if (patient == true) {
    return 'patient';
  } else {
    return 'none';
  }
}

var primColor = const Color(0xFF0F0BDB);
