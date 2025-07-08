import 'package:alarm/alarm.dart';
import 'package:elderly_app/caregiver_app/activity_planner.dart';
//import 'package:elderly_app/caregiver_app/bp_data_analytics.dart';
import 'elderly_record.dart';
import 'package:elderly_app/model/usertype.dart';
import 'package:flutter/material.dart';
import 'package:elderly_app/auth_page.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:elderly_app/model/bprecord_model.dart'; // Import the custom class model

import '../notifi_service.dart';

import 'work_manager.dart'; //added 15th Aug

class caregiverHome extends StatefulWidget {
  const caregiverHome({super.key, required this.name});
  final String name;
  @override
  State<caregiverHome> createState() => _caregiverHomeState();
}

class _caregiverHomeState extends State<caregiverHome>
    with WidgetsBindingObserver {
  var format = DateFormat("yyyy-MM-dd");
  List<DataSnapshot> records = List.empty(growable: true);
  Map<String?, DataSnapshot> recordsMap = {};
  List<String> elders = List.empty(growable: true);
  List<BPRecordModel> bpRecords = [];

  
  Future<void> signUserOut() async {
    Alarm.stop(44);
    Alarm.stop(45);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("Name");
    prefs.remove("UserType");
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (BuildContext context) => const AuthPage()));
  }

  @override
  void initState() {
    setUserData();
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    WidgetsFlutterBinding.ensureInitialized();

    var workManager = WorkManager();
    workManager.initialization();
    set_workManagerName(widget.name);

    _fetchElderlyRecords();
  }

  // Fetch the elderly bp records from firebase for the assigned caregiver
  void _fetchElderlyRecords() async {
    DatabaseReference bpRef = FirebaseDatabase.instance.ref("bp_records/${widget.name}");
    DataSnapshot snapshot = await bpRef.get();
    //print("Fetching from: bp_records/${widget.name}");

    // Check if the data exists
    if (snapshot.value != null) {

      // Create a list to store the bp records from firebase
      List<BPRecordModel> eRecords = [];

      // Extract the values
      Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;
      values.forEach((key, value) {
        String fullName = value["Elderly Name"] ?? "";
        String dates = value["Recorded Date"] ?? "";
        String time = value["Recorded Time"] ?? "";
        String syst = value["Systolic Blood Pressure"] ?? "";
        String diast = value["Diastolic Blood Pressure"] ?? "";
        String pulse = value["Heart Rate"] ?? "";
        String group = value["Blood Pressure Status"] ?? "";
        //String colorStatus = value["Blood Pressure Color"] ?? "";

        // To store the extracted data using bp record model
        BPRecordModel records = BPRecordModel(
          fullName: fullName,
          recordedDate: dates,
          recordedTime: time,
          bpSystolic: syst,
          bpDiastolic: diast,
          pulseRate: pulse,
          status: group, 
          //statusColor: Colors.red,
        );

        // Add the fetched bp records to the list
        eRecords.add(records); 
      });

      // Update the fetched bp records to the list outside of the class
      setState(() {
        bpRecords = eRecords;
      });
    }
  }

  void setUserData() async {
    DatabaseEvent recordSnapshot = await FirebaseDatabase.instance
        .reference()
        .child(
            "records/${format.format(DateTime.now())}/${widget.name.replaceAll(" ", "-")}")
        .once()
        .then((value) => value);
    DatabaseEvent elderSnapshot = await FirebaseDatabase.instance
        .reference()
        .child("users")
        .once()
        .then((value) => value);
    setState(() {
      for (var element in recordSnapshot.snapshot.children) {
        recordsMap.putIfAbsent(element.key, () => element);
      }
      for (var element in elderSnapshot.snapshot.children) {
            if (element.child("Caregivername").value.toString() ==
                    widget.name.replaceAll("-", " ") &&
                element.child("UserType").value.toString() ==
                    UserType.Elderly.name &&
                !recordsMap.containsKey(element.child("Name").value.toString()))
              {elders.add(element.child("Name").value.toString());}
          }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var formatter = DateFormat('yyyy-MM-dd HH:mm');
    int addMorningDay =
        DateTime.now().hour < 11 && DateTime.now().minute < 15 ? 0 : 1;
    String morningTime = getDate(formatter
        .format(DateTime.now().add(Duration(days: addMorningDay)))
        .split(" "));
    print("morningtime$morningTime"); //2024-01-16 11:15

    int addEveningDay =
        DateTime.now().hour < 17 && DateTime.now().minute < 15 ? 0 : 1;
    String eveningTime = getEveDate(formatter
        .format(DateTime.now().add(Duration(days: addEveningDay)))
        .split(" "));
    print("eveningtime$eveningTime"); //2024-01-16 17:15

    NotificationService.triggerAlarm(DateTime.parse(morningTime), 44, 1);
    // NotificationService.triggerAlarm(DateTime.parse(eveningTime), 45, 1);
    
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.blue,
          title: const Text(' W E L C O M E ',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),),
          actions: [
            IconButton(onPressed: signUserOut, icon: const Icon(Icons.logout))
          ],
        ),
        body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            physics: const ScrollPhysics(),
            padding: const EdgeInsets.only(top: 10.0),
            child: Column(
              children: [
                const Text(
                  "Assigned Elders",
                  style: TextStyle(
                      color: Colors.green,
                      fontSize: 30,
                      fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 15),

                // Features Button
                Padding(
                  padding: const EdgeInsets.only(left: 40.0),
                  child: Row(
                    children: [
                      // View BP Records
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 218, 217, 217),
                          foregroundColor: Colors.black,
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                          minimumSize: const Size(30, 48), // Adjust width and height
                        ),
                        onPressed: () async {
                          _fetchElderlyRecords(); // Fetch the latest bp records
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ElderlyRecords(bpRecords: bpRecords),
                            ),
                          );
                        }, 
                        child: const Text(
                          "BP Records", 
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(width: 15),

                      // Activity Planner Button
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 218, 217, 217),
                          foregroundColor: Colors.black,
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                          minimumSize: const Size(20, 49), // Adjust width and height
                        ),
                        onPressed: () {
                          // Retrieves the elderly users' name from Firebase stored in 'widget.user.name'
                          String elderly = widget.name;
                          //String caregiver = widget.name;
                          
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ActivityPlanner(elderly: elderly, caregiverName: widget.name),
                            ),
                          );
                        }, 
                        child: const Text(
                          "Activity Planner", 
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),

                // Assigned Elderly Login & Log Out
                ListView.builder(
                    padding: const EdgeInsets.only(
                        top: 20, bottom: 20, left: 15, right: 15),
                    shrinkWrap: true,
                    itemCount: recordsMap.length,
                    physics: const ScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {

                      return GestureDetector(
                        child: Card(
                          elevation: 20,
                          shadowColor: Colors.lightBlueAccent,
                          borderOnForeground: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 15, top: 15, bottom: 10),
                                child: Text(
                                  recordsMap.entries
                                      .elementAt(index)
                                      .key!
                                      .toString(),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 25,
                                      color: Colors.pink),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 20, top: 10, bottom: 10),
                                child: Text(
                                  "Logged in morning - " +
                                      getLoggedInvalue(recordsMap.entries
                                          .elementAt(index)
                                          .value
                                          .child("LastLoginDate")),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Colors.blue),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 20, top: 10, bottom: 20),
                                child: Text(
                                  "Logged in evening - " +
                                      getLoggedInvalue(recordsMap.entries
                                          .elementAt(index)
                                          .value
                                          .child("LastLogoutDate")),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Colors.blue),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    
                  ListView.builder(
                    padding: const EdgeInsets.only(
                    top: 5, bottom: 20, left: 15, right: 15),
                    shrinkWrap: true,
                    itemCount: elders.length,
                    physics: const ScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        child: Card(
                          elevation: 20,
                          shadowColor: Colors.lightBlueAccent,
                          borderOnForeground: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 15, top: 15, bottom: 10),
                                child: Text(
                                  elders.elementAt(index),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 25,
                                      color: Colors.pink),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(
                                    left: 20, top: 10, bottom: 10),
                                child: Text(
                                  "Logged in morning - " "No",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Colors.blue),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(
                                    left: 20, top: 10, bottom: 20),
                                child: Text(
                                  "Logged in evening - " "No",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Colors.blue),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    })
              ],
            )));
  }

  getLoggedInvalue(DataSnapshot logDate) {
    if (logDate.exists) {
      var date = DateTime.parse(logDate.value.toString());
      if (date.day == DateTime.now().day &&
          date.month == DateTime.now().month &&
          date.year == DateTime.now().year) {
        return "Yes";
      }
    }
    return "No";
  }

  String getDate(List<String> date) {
    date[1] = "11:15";
    return date.join(" ");
  }

  String getEveDate(List<String> date) {
    date[1] = "17:15";
    return date.join(" ");
  }
}
