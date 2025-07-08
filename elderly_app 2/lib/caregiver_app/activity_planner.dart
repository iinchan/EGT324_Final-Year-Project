import 'package:elderly_app/caregiver_app/activity_status.dart';
import 'package:elderly_app/caregiver_app/view_planact.dart';
import 'package:elderly_app/model/activity_model.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:elderly_app/model/status_model.dart';

class ActivityPlanner extends StatefulWidget {
  final String elderly;
  final String caregiverName;

  const ActivityPlanner({super.key, required this.elderly, required this.caregiverName});

  @override
  State<ActivityPlanner> createState() => _ActivityPlannerState();
}

class _ActivityPlannerState extends State<ActivityPlanner> {
  DateTime? selectedDate; // Selected date for activity

  // Controllers for text field
  final TextEditingController _elderlyNameCon = TextEditingController();
  final TextEditingController _actDateCon = TextEditingController();
  final TextEditingController _startTimeCon = TextEditingController();
  final TextEditingController _endTimeCon = TextEditingController();
  //final TextEditingController _descCon = TextEditingController();

  // Dropdown list for activity
  List<String> activities = <String>["Morning Walk", "Gardening", "Taichi", "Brisk Walk", "Chair Yoga", "Reading", "Afternoon Walk", 
    "Meditation", "Listen to Music", "Gentle Stretching", "Video Calls"];
  String? selectedActivity;
  
  // Create a list to store the fetched activity records
  List<ActivityModel> actRecords = [];

  // Create a list to store the fetched activity status
  List<Status> completionRec = [];

  // Function to select a date using date picker
  Future<void> _actDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

     // Update the change in date
    setState(() {
      _actDateCon.text = picked != null ? picked.toString().split(" ")[0] : " ";
    });
  }

  // Need create seperate time function because it will overwrite
  // Function to select a time using time picker (start time)
  Future<void> _startTime(BuildContext context) async {
    var time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now()
    );
    // Update the change in start time
    _startTimeCon.text = time != null ? time.format(context) : " ";
  }

  // Function to select a time using time picker (end time)
  Future<void> _endTime(BuildContext context) async {
    var time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now()
    );

    // Update the change in end time
    _endTimeCon.text = time != null ? time.format(context) : " ";
  }

  // Show an indication that readings has been submitted
  void _showSnackbar(String message, {bool isSuccess = true}) {
    final IconData icon = isSuccess ? Icons.check_circle : Icons.error;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
             Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Text(message),
          ],
        ),
        duration: Duration(seconds: 2)
      ),
    );
  } 

  // Function to add new activities
  void _addScheduledAct() async {

    // Retrieve data from text field
    String elderRec = _elderlyNameCon.text;
    String dateRec = _actDateCon.text;
    String startRec = _startTimeCon.text;
    String endRec = _endTimeCon.text;
    String? typeRec = selectedActivity;

    if (elderRec.isEmpty || dateRec.isEmpty || startRec.isEmpty || endRec.isEmpty || typeRec == null) {
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            backgroundColor: Color.fromARGB(255, 128, 4, 4),
            title: Center(
              child: Text(
                "Please fill in the required fields!",
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        },
      );
    }
    else {    
      // Create a new records object using the activity model to store the retrieved data
      ActivityModel newAct = ActivityModel(
        elder: elderRec,
        date: dateRec,
        start: startRec,
        end: endRec,
        type: typeRec,
      );

      // Call the function to add new records data to Firebase
      await PlannedAct.addData(context, widget.elderly, elderRec, dateRec, startRec, endRec, typeRec);
      
      // Add new activity records to the list outside of the class
      setState(() {
        actRecords.add(newAct);
      });

      // Call the snackbar function to indicate that the bp records has been submitted
      _showSnackbar("Activities Scheduled!", isSuccess: true);

      // Clear the input fields after submission
      _elderlyNameCon.clear();
      _actDateCon.clear();
      _startTimeCon.clear();
      _endTimeCon.clear();
      setState(() {
        selectedActivity = null;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchActivityRecords();
    _fetchStatusRecords();
  }

  // Elderly Activity 
  // Fetch elderly activity records
  void _fetchActivityRecords() async {
    DatabaseReference act1Ref = FirebaseDatabase.instance.ref("planned_activity/${widget.caregiverName}");
    DataSnapshot snapshot = await act1Ref.get();

    // Check if the data exists
    if (snapshot.value != null) {

      // Create a list to store the activity recordsa from firebase
      List<ActivityModel> activityRecords = [];

      // Extract the values
      Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;
      values.forEach((key, value) {
        String elderName = value["Elderly Name"] ?? "";
        String actDate = value["Activity Date"] ?? "";
        String startTime = value["Start Time"] ?? "";
        String endTime = value["End Time"] ?? "";
        String activityType = value["Types of Activity"] ?? "";

        // To store the extracted data using activity model
        ActivityModel planned = ActivityModel(
          elder: elderName,
          date: actDate,
          start: startTime,
          end: endTime,
          type: activityType,
        );

        // Add the fetched activity status to the list
        activityRecords.add(planned); 
      });

      // Update the fetched activity records to the list outside of the class
      setState(() {
        actRecords = activityRecords;
      });
    }
  }

  // Activity Status
  // Fetch elderly activity status data
  void _fetchStatusRecords() async {
    DatabaseReference statRef = FirebaseDatabase.instance.ref("activity_completion/${widget.elderly}");
    DataSnapshot snapshot = await statRef.get();

    // Check if the data exists
    if (snapshot.value != null) {

      // Create a list to store the activity status data from firebase
      List<Status> comRecords = [];

      // Extract the values
      Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;
      values.forEach((key, value) {
        String submissionDate = value["Submission Date"] ?? "";
        String elderly = value["Elderly Name"] ?? "";
        String status = value["Confirmation Status"] ?? "";

        // To store the extracted data using status model
        Status completed = Status(
          subdate: submissionDate,
          elderly: elderly,
          completion: status,
        );

        // Add the fetched activity status to the list
        comRecords.add(completed); 
      });

      // Update the fetched bp records to the list outside of the class
      setState(() {
        completionRec = comRecords;
      });
    }
  }

  // UI Components
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Activity Planner",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.purple,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 15.0, left: 170.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 197, 245, 214),
                foregroundColor: Colors.black,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                minimumSize: const Size(180, 43),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) => ActivityStatus(completionRec: completionRec),
                  ),
                );
              },
              child: const Text(
                "Activity Status",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          
          const SizedBox(height: 3),
          // Name Field
          SizedBox(
            width: 340,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 15.0, left: 5.0, bottom: 3.0),
                  child: Text(
                    "Elderly Name:",
                      style: TextStyle(
                      color: Color.fromARGB(255, 2, 2, 2), 
                      fontWeight: FontWeight.w500, 
                      fontSize: 15.0
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 5.0),
                  child: TextField(
                    controller: _elderlyNameCon,
                    decoration: const InputDecoration(
                      filled: true,
                      border: InputBorder.none,
                      //hintText: "Your Elderly Name"
                    ),
                  ),
                ),
              ]
            ),
          ),

          const SizedBox(height: 5),
          // Activity Date Field
          SizedBox(
            width: 340,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 15.0, left: 5.0, bottom: 3.0),
                  child: Text(
                    "Activity Date:",
                      style: TextStyle(
                      color: Color.fromARGB(255, 2, 2, 2), 
                      fontWeight: FontWeight.w500, 
                      fontSize: 15.0
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 5.0),
                  child: TextField(
                    controller: _actDateCon,
                    decoration: const InputDecoration(
                      filled: true,
                      border: InputBorder.none,
                      suffixIcon: Icon(Icons.calendar_today),
                      //hintText: "-- Select a Date --",
                    ),
                    style: const TextStyle(fontSize: 18),
                    readOnly: true, // Disable typing keyboard
                    onTap: () {
                      _actDate(context); // Show date picker when tap
                    },
                  ),
                ),
              ]
            ),
          ),

          const SizedBox(height: 20),
          // Time Field
          Padding(
            padding: const EdgeInsets.only(bottom: 2.0),
            child: Row(
              children: [
                // Start Time
                SizedBox(
                  width: 195,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 30.0, bottom: 2.0),
                        child: Text("Start Time:",
                          style: TextStyle(
                            color: Color.fromARGB(255, 2, 2, 2), 
                            fontWeight: FontWeight.w500, 
                            fontSize: 15.0
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 30.0),
                        child: TextField(
                          controller: _startTimeCon,
                          decoration: const InputDecoration(
                            filled: true,
                            border: InputBorder.none,
                            prefixIcon: Icon(Icons.access_time_filled_rounded),
                          ),
                          style: const TextStyle(fontSize: 18),
                          readOnly: true, // Disable typing keyboard
                          onTap: () {
                            _startTime(context); // Show date picker when tap
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 15), // Add spaces between date and time field

                // Time Field
                SizedBox(
                  width: 156,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(bottom: 2.0),
                        child: Text("End Time:",
                          style: TextStyle(
                            color: Color.fromARGB(255, 2, 2, 2), 
                            fontWeight: FontWeight.w500, 
                            fontSize: 15.0
                          ),
                        ),
                      ),
                      TextField(
                        controller: _endTimeCon,
                        decoration: const InputDecoration(
                          filled: true,
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.access_time_filled_rounded)
                        ),
                        style: const TextStyle(fontSize: 18),
                        readOnly: true, // Disable typing keyboard
                        onTap: () {
                          _endTime(context);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 5),
          // Activity Field
          SizedBox(
            width: 340,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 15.0, left: 5.0, bottom: 3.0),
                  child: Text(
                    "Types of Activity:",
                      style: TextStyle(
                      color: Color.fromARGB(255, 2, 2, 2), 
                      fontWeight: FontWeight.w500, 
                      fontSize: 15.0
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 5.0),
                  child: DropdownButtonFormField<String>(
                    //isExpanded: true,
                    decoration: const InputDecoration(
                      filled: true,
                      border: InputBorder.none,
                    ),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedActivity = newValue!;
                      });
                    },
                    value: selectedActivity,
                    items: activities.map<DropdownMenuItem<String>>(
                      (String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value), // Display text for each item
                        );
                      },
                    ).toList(),
                  ),
                ),
              ]
            ),
          ),

          const SizedBox(height: 25),

            Row(
              children: [
                Padding(
                    padding: const EdgeInsets.only(left: 30.0, top: 15.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 202, 200, 200),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                        // minimumSize: const Size(48, 48),
                        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 47.0),
                        textStyle:const TextStyle(
                          fontSize: 15, 
                          fontWeight: FontWeight.w500
                        ),
                      ),
                      onPressed: () {
                        // Call the add planned activity function
                        _addScheduledAct();
                      },
                      child: const Text("Schedule"),
                    ),
                  ),
                
                  Padding(
                    padding: const EdgeInsets.only(left: 25.0, top: 15.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 202, 200, 200),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 40.0),
                        textStyle: const TextStyle(
                          fontSize: 15, 
                          fontWeight: FontWeight.w500
                        ),
                      ),
                      onPressed: () async {
                        // Retrieves the caregiver's name from Firebase
                        String caregiver = widget.caregiverName;

                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (BuildContext context) => ViewPlanned(actRecords: actRecords, caregiver: caregiver),
                          ),
                        );
                      },
                      child: const Text("View Plans"),
                    ),
                  ),
              ],
            ),
            ], 
          ),
        ),
      ),   
    );
  }
}

// Create a class to handle the data on planned activity in the database
class PlannedAct {
  static Future<void> addData(BuildContext context, String caregiverName, String elder, 
    String date, String start, String end, String type) async {
    
    // // Print the data on the console (for checking purpose)
    // print("Elderly Name: $elder");
    // print("Activity Date: $date");
    // print("Types of Activity: $type");
    // print("Start Time: $start");
    // print("End Time: $end");
    // print("Caregiver Name: $caregiverName");

    // Upload to database
    DatabaseReference ref = FirebaseDatabase.instance.ref("planned_activity/$caregiverName"); // Firebase reference
    DatabaseReference newRef = ref.push(); // Generate a new unique key for the record
    
    // Store the data in firebase under the unique key
    await newRef.set({
      "Elderly Name": elder,
      "Activity Date": date,
      "Types of Activity": type,
      "Start Time": start,
      "End Time": end,
    }); 
  }
}