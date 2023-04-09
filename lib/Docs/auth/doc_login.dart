// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:health/Constant/constant.dart';
import 'package:health/Provider/doctor_provider.dart';
import 'package:health/Docs/auth/create_doc.dart';
import 'package:health/Docs/pages/home_page.dart';
import 'package:health/Pages/Auth/login.dart';
import 'package:health/Pages/Auth/create_account.dart';
import 'package:health/services/blockchain.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web3dart/web3dart.dart';

class DocLogin extends StatefulWidget {
  const DocLogin({super.key});

  @override
  State<DocLogin> createState() => _LoginState();
}

class _LoginState extends State<DocLogin> {
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
                const Text(
                  "TeleMedicine",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  "Doctor",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: h * 0.48,
                  child: Image.asset(
                    "assets/images/main.png",
                    fit: BoxFit.contain,
                  ),
                ),
                const Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Track Patient's Health Records and Medical History",
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
                    "Get Patient's Health Records and Medical History in one place and make your work easier and faster",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.05,
                ),
                customButton(
                  context: context,
                  onTap: () async {
                    // showLoginBotton();
                    loginSheet(context: context, key: _navigatorKey);
                  },
                  text: "Connect with Metamask",
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
                        '0x7eB996e0268FB479172B5D4c06314922dF362c1B'),
                    onTap: () async {
                      setState(() {
                        isSelect = true;
                      });
                      // Navigator.pop(context);

                      setState(() {
                        acc = 'Account 1';
                        address1 = '0x7eB996e0268FB479172B5D4c06314922dF362c1B';
                        privateKey =
                            '981572013bb68198f0e22b5e933beb8856b833189e77b5381f54d8c1f8390430';
                      });
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
                        '0x2aF19fFD645Ba5601e6864Fe15AF2EbE805e5fF8'),
                    onTap: () async {
                      setState(() {
                        isSelect = true;
                        acc = 'Account 2';
                        address1 = '0x2aF19fFD645Ba5601e6864Fe15AF2EbE805e5fF8';
                        privateKey =
                            '627849ab01f4e5ca89de30f32c80b75cbfc15f4de820b1e6d4b1156c804c22e3';
                      });

                      // loginUsingMetamask(context);
                    },
                  ),
                  const SizedBox(
                    height: 10,
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

                                      try {
                                        showLoading(context);
                                        if (await isDoctor(address1) == true) {
                                          await prefs.setString(
                                              WalletAddress, address1);
                                          await prefs.setString(
                                              'key', privateKey);
                                          prefs.setBool('islogin', true);
                                          prefs.setString('type', 'doctor');
                                          await Provider.of<DoctorInfo>(context,
                                                  listen: false)
                                              .getData(address1);

                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const DoctorHomePage()),
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
                                                      CreateAccountDoc(
                                                        wAddress: address1,
                                                        keyPrivate: privateKey,
                                                      )));
                                        }
                                      } catch (e) {
                                        print(e);
                                      }
                                      key(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const DoctorHomePage()),
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
