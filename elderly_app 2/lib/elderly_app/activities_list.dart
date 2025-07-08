import 'package:elderly_app/model/activity_model.dart';
import "package:flutter/material.dart";
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class ActivitiesList extends StatefulWidget {
  final String elderly;
  final String caregiver;

  final List<ActivityModel> actRecords;
  
  const ActivitiesList({super.key, required this.elderly, required this.caregiver, required this.actRecords});

  @override
  State<ActivitiesList> createState() => _ActivitiesListState();
}

class _ActivitiesListState extends State<ActivitiesList> {

   // Controllers for text fields
  final TextEditingController confirmController = TextEditingController();
  
// Elderly List of Activities
// UI Components
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Activities",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: Column(
          children: [
            const Text(
              '"It\'s never too late to start,\n and every step forward is a victory."',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
            Container(
              margin: const EdgeInsets.only(top: 23.0),
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
                  showDialog(
                    context: context, 
                    builder: (context) => AlertDialog(
                      actions: [
                        TextButton(
                          onPressed: () async {
                            // Call the addData function and clear the text field
                            await addData(context, widget.elderly, widget.caregiver, confirmController.text);
                            confirmController.clear();

                            // Close the alert dialog
                            Navigator.of(context).pop();

                            // Show Snackbar
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Activity status submitted!'),
                                duration: Duration(seconds: 2), // Adjust as needed
                            ),
                          );
                        }, 
                          child: const Text("Submit")
                        )
                      ],
                      title: const Text("Have you completed today's activities?"),
                      contentPadding: const EdgeInsets.all(20.0),
                      content: TextField(
                        controller: confirmController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: '"Yes" or "No"?  If no, state activity.',
                          hintStyle: TextStyle(
                            fontSize: 15.0, 
                            color: Color.fromARGB(255, 110, 107, 107),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey), 
                          ),
                        ),
                      ),
                    ),
                  );
                },
                child: const Text(
                  "Mark Completion",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: widget.actRecords.length,
                itemBuilder: (context, index) {

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        side: const BorderSide(
                            color: Color.fromARGB(255, 206, 202, 202)
                        ),
                      ),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Activity Date: ${widget.actRecords[index].date}",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              "${widget.actRecords[index].type} (${widget.actRecords[index].start} - ${widget.actRecords[index].end})",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

Future<void> addData(BuildContext context, String elderly, String caregiver, String confirm) async {
  
  // Get current date and time in completion
  DateTime now = DateTime.now();
  String formatDate = DateFormat("yyyy-MM-dd").format(now); // Format the date
  
  // // Print the data on the console (for checking purpose)
  // print("Submission Date: $formatDate");
  // print("Name: $elderly");
  // print("Completion Status: $confirm");
  // print("Caregiver Name: $caregiver");

  // Upload to database
  DatabaseReference ref = FirebaseDatabase.instance.ref("activity_completion/$caregiver"); // Firebase reference
  DatabaseReference newRef = ref.push(); // Generate a new unique key for the record
  
  // Store the data in firebase under the unique key
  await newRef.set({
    "Submission Date": formatDate,
    "Elderly Name": elderly,
    "Confirmation Status": confirm
  }); 
}