import 'package:elderly_app/elderly_app/journal_entry.dart';
import 'package:elderly_app/model/activity_model.dart';
import 'package:flutter/material.dart';
import 'package:alarm/alarm.dart';
import 'package:elderly_app/model/user.dart';
import 'package:elderly_app/auth_page.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:elderly_app/elderly_app/blood_pressure.dart';
import 'package:elderly_app/elderly_app/activities_list.dart';

import '../notifi_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.fullName, required this.user});
  final String fullName;
  final User user;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  late bool showLoginButton = true;
  late bool showLogoutButton = false;
  // Create a list to store the fetched activity records
  List<ActivityModel> actRecords = [];

  Future<void> signUserOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("Name");
    prefs.remove("UsertType");
    Alarm.stop(42);
    Alarm.stop(43);
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (BuildContext context) => const AuthPage()));
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    initializeVisibility();
    super.initState();

    _fetchMyActivities();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('state = $state');
    if (state.name == "resumed") {
      initializeVisibility();
    }
  }

  initializeVisibility() {
    setState(() {
      if (widget.user.lastLoginDate == null) {
        showLoginButton = true;
        showLogoutButton = false;
      } else if (widget.user.lastLogoutDate == null &&
          DateTime.now().day == widget.user.lastLoginDate!.day) {
        showLogoutButton = true;
        showLoginButton = false;
      } else if (DateTime.now().day == widget.user.lastLoginDate!.day &&
          DateTime.now().day == widget.user.lastLogoutDate!.day) {
        showLoginButton = false;
        showLogoutButton = false;
      } else if (DateTime.now().day > widget.user.lastLoginDate!.day) {
        showLoginButton = true;
        showLogoutButton = false;
      } else if (DateTime.now().day > widget.user.lastLogoutDate!.day) {
        showLoginButton = false;
        showLogoutButton = true;
      }
    });
  }

  // Fetch the elderly activity from firebase for the currently elderly
  void _fetchMyActivities() async {
    DatabaseReference actRef = FirebaseDatabase.instance.ref("planned_activity/${widget.user.assignedCareGiver}");
    DataSnapshot snapshot = await actRef.get();
    print("Fetching from: planned_activity/${widget.user.assignedCareGiver}");

    // Check if the data exists
    if (snapshot.value != null) {

      // Create a list to store the activity recordsa from firebase
      List<ActivityModel> activity = [];

      // Extract the values
      Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;
      values.forEach((key, value) {
        String Name = value["Elderly Name"] ?? "";
        String Date = value["Activity Date"] ?? "";
        String sTime = value["Start Time"] ?? "";
        String eTime = value["End Time"] ?? "";
        String actType = value["Types of Activity"] ?? "";

        // To store the extracted data using activity model
        ActivityModel plan = ActivityModel(
          elder: Name,
          date: Date,
          start: sTime,
          end: eTime,
          type: actType,
        );

        // Add the fetched activity status to the list
        activity.add(plan); 
      });

      // Update the fetched activity records to the list outside of the class
      setState(() {
        actRecords = activity;
      });
    }
  }

  void addEntryData() async {
    var formatter = DateFormat('yyyy-MM-dd HH:mm');
    var key = DateFormat('yyyy-MM-dd');
    String formattedDate = formatter.format(DateTime.now());
    DatabaseReference userRef = FirebaseDatabase.instance.ref(
        "records/${key.format(DateTime.now())}/${widget.user.assignedCareGiver?.replaceAll(" ", "-")}/${widget.fullName}");
    if (showLoginButton &&
        DateTime.now().hour >= 11 &&
        DateTime.now().hour < 17) {
      userRef.update({"LastLoginDate": formattedDate});
      setState(() {
        showLoginButton = false;
        showLogoutButton = true;
      });
    }
    if (showLogoutButton && DateTime.now().hour >= 17) {
      userRef.update({"LastLogoutDate": formattedDate});
      setState(() {
        showLoginButton = false;
        showLogoutButton = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var formatter = DateFormat('yyyy-MM-dd HH:mm');
    int addMorningDay = DateTime.now().hour < 11 ? 0 : 1;
    String morningTime = getDate(formatter
        .format(DateTime.now().add(Duration(days: addMorningDay)))
        .split(" "));
    int addEveningDay = DateTime.now().hour < 17 ? 0 : 1;
    String eveningTime = getEveDate(formatter
        .format(DateTime.now().add(Duration(days: addEveningDay)))
        .split(" "));
    NotificationService.triggerAlarm(DateTime.parse(morningTime), 42, 0);
    NotificationService.triggerAlarm(DateTime.parse(eveningTime), 43, 0);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue,
        title: const Text(' W E L C O  M E ', 
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),),
        actions: [
          IconButton(onPressed: signUserOut, icon: const Icon(Icons.logout))
        ],
      ),
      body: Center(
          child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  minimumSize: Size(MediaQuery.of(context).size.width * .80,
                      MediaQuery.of(context).size.height * .10),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  )),
              onPressed: (showLoginButton &&
                          DateTime.now().hour >= 11 &&
                          DateTime.now().hour < 17 ||
                      showLogoutButton && DateTime.now().hour >= 17)
                  ? addEntryData
                  : null,
              child: showLoginButton
                  ? const Text('Login Entry Time',
                      style: TextStyle(
                          color: Color.fromARGB(255, 18, 215, 28),
                          fontSize: 30,
                          fontWeight: FontWeight.bold))
                  : const Text('Login Exit Time',
                      style: TextStyle(
                          color: Color.fromARGB(255, 232, 4, 4),
                          fontSize: 30,
                          fontWeight: FontWeight.bold
                      ),
                    ),
            ),

            const SizedBox(height: 25),
            
            // Journal Entry Page
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(
                  MediaQuery.of(context).size.width * .80,
                  MediaQuery.of(context).size.height * .10,
                ),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
              ),
              onPressed: () {
                // Retrieves the elderly users' name from Firebase stored in 'widget.user.name'
                // To view or submit their own journal (part of the access permission)
                String elderly = widget.user.name != null ? widget.user.name! : "Unknown Elderly";

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) => JournalEnt(elderly: elderly),
                  ),
                );
              },
              child: const Text(
                "Journal Entry",
                style: TextStyle(
                  color: Color.fromARGB(255, 18, 215, 28),
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            
            const SizedBox(height: 25),

            // Blood Pressure Submission Page
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(
                  MediaQuery.of(context).size.width * .80,
                  MediaQuery.of(context).size.height * .10,
                ),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
              ),
              onPressed: () {
                // Retrieves the elderly users' name from Firebase stored in 'widget.user.name'
                String elderlyName = widget.user.name != null ? widget.user.name! : "Unknown Elderly";

                // Retrieves the caregiver's name from Firebase stored in 'widget.user.assignedCaregiver'
                // To view their own elderly bp records (part of the access permission)
                String caregiverName = widget.user.assignedCareGiver != null ? widget.user.assignedCareGiver! : "Unknown CareGiver";
                
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) => BPRecord(elderlyName: elderlyName, caregiverName: caregiverName),
                  ),
                );
              },
              child: const Text(
                "BP Tracker",
                style: TextStyle(
                  color: Color.fromARGB(255, 18, 215, 28),
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 25),

            // Daily Activities Page
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(
                  MediaQuery.of(context).size.width * .80,
                  MediaQuery.of(context).size.height * .10,
                ),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
              ),
              onPressed: () {
                // Retrieves the elderly users' name from Firebase stored in 'widget.user.name'
                String elderlyName = widget.user.name != null ? widget.user.name! : "Unknown Elderly";

                // Retrieves the caregiver's name from Firebase stored in 'widget.user.assignedCaregiver'
                // To view their own elderly bp records (part of the access permission)
                String caregiverName = widget.user.assignedCareGiver != null ? widget.user.assignedCareGiver! : "Unknown CareGiver";
                
                _fetchMyActivities(); // fetch the latest activity records
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) => ActivitiesList(elderly: elderlyName, caregiver: caregiverName, actRecords: actRecords),
                  ),
                );
              },
              child: const Text(
                "Daily Activities",
                style: TextStyle(
                  color: Color.fromARGB(255, 18, 215, 28),
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      )),
    );
  }
}

String getDate(List<String> date) {
  date[1] = "11:00";
  return date.join(" ");
}

String getEveDate(List<String> date) {
  date[1] = "17:00";
  return date.join(" ");
}
