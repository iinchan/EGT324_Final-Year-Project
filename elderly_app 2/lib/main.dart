// import 'dart:io';
import 'package:elderly_app/caregiver_app/caregiver_homepage.dart';
import 'package:elderly_app/elderly_app/home_page.dart';
import 'package:elderly_app/model/usertype.dart';
import 'package:elderly_app/newuser_login.dart';
import 'package:elderly_app/notifi_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_alarm_background_trigger/flutter_alarm_background_trigger.dart';
import 'package:intl/intl.dart';
import 'admin_app/admin_homepage.dart';
import 'firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_database/firebase_database.dart';
import 'model/user.dart';
import 'model/userutil.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

late String fullName;
late String userType;
late bool isLogged;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setUserData();

  // Check if Firebase has already been initialized
  // if (Firebase.apps.isEmpty) {
  await Firebase.initializeApp(name: "Elderly-App",
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // }

  if(userType == UserType.CareGiver.name){
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  // Initialize notification service
  await NotificationService().initNotification();

  FlutterAlarmBackgroundTrigger.initialize();

  runApp(await getMaterialApp(isLogged,fullName));
} 

Future<void> setUserData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  fullName = (prefs.get("Name") == null?"":prefs.getString("Name"))!;
  userType = (prefs.get("UserType") == null? "":prefs.getString("UserType"))!;
  isLogged=(prefs.getBool("isLoggedIn") ?? false);
}

Future<MaterialApp> getMaterialApp(bool isLoggedIn,String fullName) async {
  if(isLoggedIn){
    var format = DateFormat("yyyy-MM-dd");
    var key = fullName.replaceAll(" ", "-");
    DataSnapshot snapshot = await FirebaseDatabase.instance.ref().child(
        "users/$key").get();
    var userType = snapshot.child("UserType").value.toString();
    DataSnapshot recordSnapshot = await FirebaseDatabase.instance.ref().child("records/${format.
    format(DateTime.now())}/${snapshot.child("Caregivername").value.toString().replaceAll(" ", "-")}/$key").get();
    switch (userType){
      case "Elderly":
        User userDetails = UserUtil.getUserdetails(snapshot);
        userDetails.lastLoginDate = recordSnapshot.child("LastLoginDate").exists?DateTime.parse(recordSnapshot.child("LastLoginDate").value.toString()):null;
        userDetails.lastLogoutDate = recordSnapshot.child("LastLogoutDate").exists?DateTime.parse(recordSnapshot.child("LastLogoutDate").value.toString()):null;
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          initialRoute: 'home_page',
          routes: {'home_page': (context) => HomePage(fullName: fullName,user: userDetails,)},
        );
        // ignore: dead_code
        break;
      case "CareGiver":
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          initialRoute: 'caregiver_homepage',
          routes: {'caregiver_homepage': (context) => caregiverHome(name: fullName)},
        );
        // ignore: dead_code
        break;
      case "Admin":
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          initialRoute: 'admin_homepage',
          routes: {'admin_homepage': (context) => AdminHome(name: fullName)},
        );
        // ignore: dead_code
        break;
      default:
    }
  }
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: 'newuser_login',
    routes: {'newuser_login': (context) => const newuser_login()},
  );
}

// for test folder error
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<MaterialApp>(
      future: getMaterialApp(isLogged, fullName),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        } else if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(child: Text('Error: ${snapshot.error}')),
            ),
          );
        } else {
          return snapshot.data!;
        }
      },
    );
  }
}