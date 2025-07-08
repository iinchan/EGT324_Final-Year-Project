import 'package:elderly_app/components/register_button.dart';
import 'package:elderly_app/components/textfield.dart';
import 'package:elderly_app/elderly_app/home_page.dart';
import 'package:elderly_app/elderly_app/registrationpage.dart';
import 'package:elderly_app/langauages/chinese_page.dart';
import 'package:elderly_app/langauages/tamil_page.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../model/user.dart';
import '../model/usertype.dart';

class MalayPage extends StatefulWidget {
  const MalayPage({super.key});

  @override
  State<MalayPage> createState() => _MalayPageState();
}

class _MalayPageState extends State<MalayPage> {
  //textfield controllers
  final fullnameController = TextEditingController();
  final emailController = TextEditingController();
  final ageController = TextEditingController();
  int? genderController = 0;
  int? stayingaloneController =0 ;
  final blknumberController = TextEditingController();
  final streetnumberController = TextEditingController();
  final unitnumberController = TextEditingController();
  final postalcodeController = TextEditingController();
  final caregivernameController = TextEditingController();

  late User userDetails;

  Future<void> addData(String name,email, age, gender, blknumber, streetnumber, unitnumber, postalcode, stayingalone,caregivername) async {
    String key = name.replaceAll(" ","-");
    String userType = UserType.Elderly.name;
    DatabaseReference ref = FirebaseDatabase.instance.ref("users/$key");
    var genderlist = ['Male','Female'];
    var stayingalonelist = ['Yes','No'];
    ref.set({
      "Name": name,
      "Age": age,
      "Gender": genderlist[gender],
      "Address":{
        "BlockNumber": blknumber,
        "StreetNumber": streetnumber,
        "UnitNumber": unitnumber,
        "PostalCode": postalcode
      },
      "StayingAlone": stayingalonelist[stayingalone],
      "Caregivername": caregivername,
      "UserType": userType
    });
    userDetails = User(name, age, genderlist[gender], stayingalonelist[stayingalone], blknumber,
        unitnumber, postalcode, userType, caregivername, null, null, email, null);
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
              const SizedBox(height: 15),
              //logo
              const Icon(
                Icons.app_registration,
                size: 100,
                color: Colors.blue,
              ),
              const SizedBox(height: 5),

              //Register title
              const Text(
                'Daftar akaun',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
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
                            'Language:',
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
                                          const register()));
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
                                          const MalayPage()));
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
                                          const ChinesePage()));
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
                                          const TamilPage()));
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
                hintText: 'Nama Penuh',
                obscureText: false,
              ),

              const SizedBox(height: 10),

              //age textfield
              Textfield(
                controller: ageController,
                hintText: 'Umur',
                obscureText: false,
              ),

              const SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text('Jantina: '),
                ToggleSwitch(
                  initialLabelIndex: 0,
                  totalSwitches: 2,
                  labels: const [
                    'Lelaki',
                    'Perempuan',
                  ],
                  onToggle: (index) {
                    print('switched to: $index');
                  },
                ),
              ]),

              const SizedBox(height: 10),

              //number textfield
              Textfield(
                controller: blknumberController,
                hintText: 'Nombor Blok',
                obscureText: false,
              ),

              const SizedBox(height: 10),

              //address texfield
              Textfield(
                controller: unitnumberController,
                hintText: 'Nombor Unit',
                obscureText: false,
              ),

              const SizedBox(height: 10),

              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text('Tinggal sendiri?'),
                ToggleSwitch(
                  initialLabelIndex: 0,
                  totalSwitches: 2,
                  labels: const [
                    'Ya',
                    'Bukan',
                  ],
                  onToggle: (index) {
                    print('switched to: $index');
                  },
                ),
              ]),
              const SizedBox(height: 10),
              //address texfield
              Textfield(
                controller: caregivernameController,
                hintText: 'Nama Penjaga',
                obscureText: false,
              ),

              const SizedBox(height: 10),
              //register button
              RegisterButton(
                onTap: () {
                  addData(fullnameController.text,emailController.text, ageController.text, genderController, blknumberController.text,
                      streetnumberController.text, unitnumberController.text, postalcodeController.text,
                      stayingaloneController, caregivernameController.text);
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (BuildContext context) => HomePage(fullName : fullnameController.text,user: userDetails,)));
                },
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
