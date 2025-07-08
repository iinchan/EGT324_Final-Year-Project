//import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:elderly_app/model/activity_model.dart';

class ViewPlanned extends StatefulWidget {
  final String caregiver;

  final List<ActivityModel> actRecords;

  const ViewPlanned({super.key, required this.actRecords, required this.caregiver});

  @override
  State<ViewPlanned> createState() => _ViewPlannedState();
}

class _ViewPlannedState extends State<ViewPlanned> {

  // Show an indication that readings has been submitted
  void _showSnackbar(String message) {  
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(width: 10),
            Text(message),
          ],
        ),
        duration: Duration(seconds: 2)
      ),
    );
  } 

  // Remove certain activity for current caregiver
  void removeActivity(ActivityModel activity) async {
    DatabaseReference deleteCertainActRef = FirebaseDatabase.instance.ref("planned_activity/${widget.caregiver}");
    DataSnapshot snapshot = await deleteCertainActRef.get();

    // Check if the data exists
    if (snapshot.exists) {

      // Convert snapshot to map for iteration
      Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;

      // Extract the value from firebase correspond to the data you want to delete in the app
      values.forEach((key, value) {
        if (value["Elderly Name"] == activity.elder && value["Activity Date"] == activity.date &&
          value["Start Time"] == activity.start && value["End Time"] == activity.end &&
          value["Types of Activity"] == activity.type) {
        
          // Remove the extracted activity in reference to the firebase
          deleteCertainActRef.child(key!).remove();
          
          // Update the remove of activity locally
          setState(() {
            widget.actRecords.remove(activity);
          });
          _showSnackbar("Activity Removed!");
        }
      });
    }
  }

  // Remove all activities for current caregiver
  void clearAllActivities() async {
    DatabaseReference deleteAllActRef = FirebaseDatabase.instance.ref("planned_activity/${widget.caregiver}");
    DataSnapshot snapshot = await deleteAllActRef.get();

    if (snapshot.exists) {
      await deleteAllActRef.remove();
    }

    // Update the remove of activity locally
    setState(() {
      widget.actRecords.clear();
    });
    _showSnackbar('All Activities cleared!');
  }

// UI Components
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Scheduled Activities",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.purple,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),

      body: 
        Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 20.0, bottom: 5.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 224, 227, 242),
                  foregroundColor: Colors.black,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  minimumSize: const Size(190, 43),
                ),
                onPressed: () {
                  // Call the remove activity function
                  clearAllActivities();
                },
                child: const Text(
                  "Clear All Activities",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            
            Expanded(
              child: widget.actRecords.isEmpty ? 
              const Center(
                child: Text(
                  "You have yet to plan any activities.",
                  style: TextStyle(
                    fontSize: 16
                  ),
                ),
              )
              : ListView.builder(
                itemCount: widget.actRecords.length,
                itemBuilder: (context, index) {
                  final activity = widget.actRecords[index];
            
                  // Determine the card color based on the activity type
                  Color cardColor;
                  if (activity.type == "Morning Walk") {
                    cardColor = Colors.lightGreen.shade100;
                  } else if (activity.type == "Gardening") {
                    cardColor = Colors.green.shade100;
                  } else if (activity.type == "Taichi") {
                    cardColor = Colors.blue.shade100;
                  } else if (activity.type == "Brisk Walk") {
                    cardColor = Colors.orange.shade100;
                  } else if (activity.type == "Chair Yoga") {
                    cardColor = Colors.purple.shade100;
                  } else if (activity.type == "Reading") {
                    cardColor = Colors.cyan.shade100;
                  } else if (activity.type == "Afternoon Walk") {
                    cardColor = Colors.teal.shade100;
                  } else if (activity.type == "Meditation") {
                    cardColor = Colors.pink.shade100;
                  } else if (activity.type == "Listen to Music") {
                    cardColor = Colors.amber.shade100;
                  } else {
                    cardColor = Colors.yellow.shade100;
                  }
              
                  return Card(
                    elevation: 35,
                    margin: const EdgeInsets.symmetric(
                      vertical: 14, horizontal: 21,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      side: const BorderSide(
                        color: Color.fromARGB(255, 206, 202, 202)
                      ),
                    ),
                  
                    color: cardColor, // Set the card color
                  
                    // Date of Activity section
                    child: Padding(
                      padding: const EdgeInsets.all(20.0), // Set padding in the card
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Elderly name section
                          const Text(
                            "Elderly Name:",
                            style: TextStyle( 
                              fontWeight: FontWeight.bold,
                              fontSize: 16, 
                            ),
                          ),
                          Text(
                            activity.elder,
                            style: const TextStyle(
                              fontSize: 16, 
                              fontWeight: FontWeight.w400
                            ),
                          ),
                  
                          SizedBox(height: 8),
                  
                          // Date of Activity section
                          const Text(
                            "Activity Date:",
                            style: TextStyle( 
                              fontWeight: FontWeight.bold,
                              fontSize: 16, 
                            ),
                          ),
                          Text(
                            activity.date,
                            style: const TextStyle(
                              fontWeight: FontWeight.w400,  
                              fontSize: 16),
                          ),
                  
                          SizedBox(height: 10),
                  
                          // Activity & Time section
                          const Text(
                            "Elderly's Activity:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16, 
                            ),
                          ),
                  
                          Text(
                            "${activity.type} (${activity.start} - ${activity.end})",
                            style: const TextStyle(
                              fontWeight: FontWeight.w400,  
                              fontSize: 16,
                            ),
                          ),

                          SizedBox(height: 10),

                          ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 233, 235, 244),
                            minimumSize: const Size(180, 41),
                          ),
                          onPressed: () {
                            // Call the remove activity function
                            removeActivity(activity);
                          },
                          child: const Text(
                            "Remove Activity",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}