import 'package:elderly_app/caregiver_app/caregiver_homepage.dart';
import 'package:elderly_app/caregiver_app/reg_button.dart';
import 'package:elderly_app/components/textfield.dart';
import 'package:elderly_app/caregiver_app/caregiver_register.dart';
import 'package:elderly_app/langauages/malay_page_caregiver.dart';
import 'package:elderly_app/langauages/tamil_page_caregiver.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/usertype.dart';

class ChinesePageCaregiver extends StatefulWidget {
  const ChinesePageCaregiver({super.key});

  @override
  State<ChinesePageCaregiver> createState() => _ChinesePageCaregiverState();
}

class _ChinesePageCaregiverState extends State<ChinesePageCaregiver> {
  //textfield controllers
  final fullnameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmpasswordController = TextEditingController();
  final numberController = TextEditingController();
  final addressController = TextEditingController();

  Future<void> addData(String name, String email, number) async {
    String key = name.replaceAll(" ","-");
    String userType = UserType.CareGiver.name;
    DatabaseReference ref = FirebaseDatabase.instance.ref("users/$key");

    await ref.set({
      "Name": name,
      "Email": email,
      "PhoneNumber": number,
      "UserType": userType
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("Name",name);
    prefs.setString("UserType",userType);
    prefs.setBool("isLoggedIn", true);
  }

  void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const SizedBox(height: 10),
              //logo
              Icon(
                Icons.app_registration,
                size: 200,
                color: Colors.deepPurple.shade300,
              ),
              const SizedBox(height: 5),

              //Register title
              const Text(
                '注册账号',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                    decoration: TextDecoration.underline),
              ),

              const SizedBox(height: 30),

              //Language choice
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Text(
                            '语言:',
                            style: TextStyle(color: Colors.black, fontSize: 14),
                          ),
                          const SizedBox(width: 2),

                          //english language
                          GestureDetector(
                            child: const Text(
                              'English',
                              style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline),
                            ),
                            onTap: () {
                              Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          const caregiverRegister()));
                            },
                          ),

                          const SizedBox(width: 14),

                          //malay language
                          GestureDetector(
                            child: const Text(
                              'Bahasa Melayu',
                              style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline),
                            ),
                            onTap: () {
                              Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          const MalayPageCaregiver()));
                            },
                          ),

                          const SizedBox(width: 14),

                          //chinese language
                          GestureDetector(
                            child: const Text(
                              '中文',
                              style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline),
                            ),
                            onTap: () {
                              Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          const ChinesePageCaregiver()));
                            },
                          ),

                          const SizedBox(width: 16),
                          //tamil language
                          GestureDetector(
                            child: const Text(
                              'தமிழ்',
                              style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline),
                            ),
                            onTap: () {
                              Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          const TamilPageCaregiver()));
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              //Full name textfield
              Textfield(
                controller: fullnameController,
                hintText: '全名',
                obscureText: false,
              ),

              const SizedBox(height: 10),

              //email textfield
              Textfield(
                controller: emailController,
                hintText: '电邮地址',
                obscureText: false,
              ),

              const SizedBox(height: 10),

              //number textfield
              Textfield(
                controller: numberController,
                hintText: '联络号码',
                obscureText: false,
              ),

              const SizedBox(height: 20),

              //register button
              RegButton(
                onTap: () {
                  addData(fullnameController.text, emailController.text, numberController.text);
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (BuildContext context) => caregiverHome(name : fullnameController.text)));
                },
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
