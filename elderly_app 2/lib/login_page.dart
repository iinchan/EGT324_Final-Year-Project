import 'package:elderly_app/model/user.dart';
import 'package:elderly_app/model/usertype.dart';
import 'package:elderly_app/model/userutil.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:elderly_app/caregiver_app/caregiver_homepage.dart';
import 'package:elderly_app/caregiver_app/reg_button.dart';
import 'package:elderly_app/components/textfield.dart';
import 'package:elderly_app/elderly_app/home_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:elderly_app/notifi_service.dart';

import 'admin_app/admin_homepage.dart';

class login_page extends StatefulWidget {
  const login_page({super.key});

  @override
  State<login_page> createState() => _login_pageRegisterState();
}


class _login_pageRegisterState extends State<login_page> {
  //textfield controllers
  final nameController = TextEditingController();
  final DatabaseReference ref = FirebaseDatabase.instance.ref();
  int? roleController = 0;

  addUserDetailsToSF(String name,String userType) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("Name",name);
    prefs.setString("UserType",userType);
    prefs.setBool("isLoggedIn", true);
  }

  void getData(String name, roleController) async {
    var rolelabel = ['elderly','caregivers','admin'];
    String key = name.replaceAll(" ","-");
    if (name == ""){
        showDialog(
            context: context,
            builder: (context) {
              return const AlertDialog(
                backgroundColor: Color.fromARGB(255, 128, 4, 4),
                title: Center(
                  child: Text(
                    'Please key in your name',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              );
            },
          );
      }
    else {
      var format = DateFormat("yyyy-MM-dd");
      DataSnapshot snapshot = await FirebaseDatabase.instance.ref().child(
          "users/$key").get();
      print(snapshot.value.toString());
      var userType = snapshot.child("UserType").value.toString();
      DataSnapshot recordSnapshot = await FirebaseDatabase.instance.ref().child("records/${format.
        format(DateTime.now())}/${snapshot.child("Caregivername").value.toString().replaceAll(" ", "-")}/$key").get();
      
      if (snapshot.exists && roleController == 0 &&
          userType == UserType.Elderly.name) {
        User userDetails = UserUtil.getUserdetails(snapshot);
        userDetails.lastLoginDate = recordSnapshot.child("LastLoginDate").exists?DateTime.parse(recordSnapshot.child("LastLoginDate").value.toString()):null;
        userDetails.lastLogoutDate = recordSnapshot.child("LastLogoutDate").exists?DateTime.parse(recordSnapshot.child("LastLogoutDate").value.toString()):null;
        addUserDetailsToSF(name,userType);
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
            builder: (BuildContext context) => HomePage(fullName: name, user: userDetails)),(Route route) => false);
      }
      else if (snapshot.exists && roleController == 1 &&
          userType == UserType.CareGiver.name) {
        addUserDetailsToSF(name,userType);
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
            builder: (BuildContext context) => caregiverHome(name: name)),(Route route) => false);
      }
      else if (snapshot.exists && roleController == 2 &&
          userType == UserType.Admin.name) {
        addUserDetailsToSF(name,userType);
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
            builder: (BuildContext context) => AdminHome(name: name)),(Route route) => false);
      }
      else {
        print('No data available.');
        showDialog(
          context: context,
          builder: (context) {
            return const AlertDialog(
              backgroundColor: Color.fromARGB(255, 128, 4, 4),
              title: Center(
                child: Text(
                  'User not found!',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            );
          },
        );
      }
    }
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
                'Login as existing user',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                    decoration: TextDecoration.underline),
              ),

              const SizedBox(height: 30),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                ToggleSwitch(
                  initialLabelIndex: 0,
                  totalSwitches: 3,
                  minWidth: 100,
                  labels: const ['Elderly','Caregiver','Admin'],
                  onToggle: (index) {
                    roleController = index;
                    print('switched to: $index');
                  },
                ),
              ]),

              const SizedBox(height: 20),

              // Full Name textfield
              Textfield(
                controller: nameController,
                hintText: 'Full Name',
                obscureText: false,
              ),

              const SizedBox(height: 10),

              const SizedBox(height: 20),

              //register button
              RegButton(
                onTap: () {
                  getData(nameController.text, roleController);
                },
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
