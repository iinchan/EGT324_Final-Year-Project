import 'package:elderly_app/model/bprecord_model.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart'; // Import Firebase Realtime Database package

class BPRecord extends StatefulWidget {
  final String elderlyName;
  final String caregiverName;

  const BPRecord({super.key, required this.elderlyName, required this.caregiverName});

  @override
  State<BPRecord> createState() => _BPRecordState();
}

class _BPRecordState extends State<BPRecord> {
  DateTime? selectedDate; // Selected date for journal entries

  // Controllers for text fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _systolicController = TextEditingController();
  final TextEditingController _diastolicController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();

  // Store blood pressure status
  String bpStatus = "";

  // Create a list to store the fetched bp records
  List<BPRecordModel> bpRecords = [];

  // Function to select a date using date picker
  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

     // Update the change in date
    setState(() {
      _dateController.text = picked != null ? picked.toString().split(" ")[0] : " ";
    });
  }

  // Function to select a time using time picker
  Future<void> _selectTime(BuildContext context) async {
    var time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now()
    );

    // Update the change in time
    _timeController.text = time != null ? time.format(context) : " ";
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
        duration: const Duration(seconds: 2)
      ),
    );
  } 

  // Function to calculate the blood pressure range
  static String calculateBPStatus(String systolic, String diastolic) {
    int systolicRange = int.parse(systolic);
    int diastolicRange = int.parse(diastolic);

    if (systolicRange >= 120 && diastolicRange >= 80) {
      return "High";
    }
    else if (systolicRange <= 90 && diastolicRange <= 60) {
      return "Low";
    }
    else if (systolicRange < 120 && diastolicRange < 80) {
      return "Normal";
    }
    else {
      return "Invalid Status";
    }
  }

  // Function to add new blood pressure records
  void _addBPEntry() async {

    // Retrieve data from text field
    String nameRec = _nameController.text;
    String dateRec = _dateController.text;
    String timeRec = _timeController.text;
    String systRec = _systolicController.text;
    String diastRec = _diastolicController.text;
    String pulseRec = _rateController.text;

    if (nameRec.isEmpty || dateRec.isEmpty || timeRec.isEmpty || systRec.isEmpty || diastRec.isEmpty || pulseRec.isEmpty) {
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
      // Calculate blood pressure status
      bpStatus = calculateBPStatus(systRec, diastRec);
      
      // Create a new records object using the bp record model to store the retrieved data
      BPRecordModel newRecords = BPRecordModel(
        fullName: nameRec,
        recordedDate: dateRec,
        recordedTime: timeRec,
        bpSystolic: systRec,
        bpDiastolic: diastRec,
        pulseRate: pulseRec, 
        status: bpStatus,
      );

      // Call the function to add new records data to Firebase
      await BPLog.addData(context, widget.caregiverName, widget.elderlyName, nameRec,
        dateRec, timeRec, systRec, diastRec, pulseRec, bpStatus);
      
      // Add new bp records to the list outside of the class
      setState(() {
        bpRecords.add(newRecords);
      });

      // Call the snackbar function to indicate that the bp records has been submitted
      _showSnackbar("Records submitted!", isSuccess: true);

      // Clear the input fields after submission
      _dateController.clear();
      _timeController.clear();
      _systolicController.clear();
      _diastolicController.clear();
      _rateController.clear();
    }
  }

// UI Components
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Blood Pressure Tracker",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      resizeToAvoidBottomInset: true, // To avoid bottom overflow
      body: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name Field
              SizedBox(
                width: 370,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 25.0, left: 25.0, bottom: 2.0),
                      child: Text(
                        "Full Name:",
                         style: TextStyle(
                          color: Color.fromARGB(255, 2, 2, 2), 
                          fontWeight: FontWeight.w500, 
                          fontSize: 15.0
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 25.0),
                      child: TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          filled: true,
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ]
                ),
              ),

              const SizedBox(height: 15),

              // Date & Time Selection
              Padding(
                padding: const EdgeInsets.only(bottom: 2.0),
                child: Row(
                  children: [
                    // Date Field
                    SizedBox(
                      width: 198,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 25.0, bottom: 2.0),
                            child: Text("Recorded Date:",
                              style: TextStyle(
                                color: Color.fromARGB(255, 2, 2, 2), 
                                fontWeight: FontWeight.w500, 
                                fontSize: 15.0
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 25.0),
                            child: TextField(
                              controller: _dateController,
                              decoration: const InputDecoration(
                                filled: true,
                                border: InputBorder.none,
                                prefixIcon: Icon(Icons.calendar_today),
                              ),
                              style: const TextStyle(fontSize: 18),
                              readOnly: true, // Disable typing keyboard
                              onTap: () {
                                _selectDate(context); // Show date picker when tap
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
                            child: Text("Recorded Time:",
                              style: TextStyle(
                                color: Color.fromARGB(255, 2, 2, 2), 
                                fontWeight: FontWeight.w500, 
                                fontSize: 15.0
                              ),
                            ),
                          ),
                          TextField(
                            controller: _timeController,
                            decoration: const InputDecoration(
                              filled: true,
                              border: InputBorder.none,
                              prefixIcon: Icon(Icons.access_time_filled_rounded)
                            ),
                            style: const TextStyle(fontSize: 18),
                            readOnly: true, // Disable typing keyboard
                            onTap: () {
                              _selectTime(context);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20), // Set a space before next widget

              // Blood Pressure Inputs
              // Systolic Blood Pressure
              Row(
                children: [
                  SizedBox(
                    width: 300,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 25.0, bottom: 2.0),
                          child: Text("Systolic Blood Pressure:",
                            style: TextStyle(
                              color: Color.fromARGB(255, 2, 2, 2), 
                              fontWeight: FontWeight.w500, 
                              fontSize: 15.0
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 25.0),
                          child: TextField(
                            controller: _systolicController,
                            decoration: const InputDecoration(
                              filled: true,
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12), // Add spaces
                  const Padding(
                    padding: EdgeInsets.only(left: 5.0, top: 20.0),
                    child: Text(
                      "mmHg",
                      style: TextStyle(
                        fontSize: 15, 
                        fontWeight: FontWeight.w500
                      ),
                    ),
                  ),
                ],
              ),

              // Diastolic Blood Pressure
              Row(
                children: [
                  SizedBox(
                    width: 300,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(
                              top: 20.0, left: 25.0, bottom: 2.0),
                          child: Text("Diastolic Blood Pressure:",
                            style: TextStyle(
                              color: Color.fromARGB(255, 2, 2, 2), 
                              fontWeight: FontWeight.w500, 
                              fontSize: 15.0
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 25.0),
                          child: TextField(
                            controller: _diastolicController,
                            decoration: const InputDecoration(
                              filled: true,
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12), // Add spaces
                  const Padding(
                    padding: EdgeInsets.only(left: 5.0, top: 40.0),
                    child: Text(
                      "mmHg",
                      style: TextStyle(
                        fontSize: 15, 
                        fontWeight: 
                        FontWeight.w500
                      ),
                    ),
                  ),
                ],
              ),

              // Heart Rate
              Row(
                children: [
                  SizedBox(
                    width: 300,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 20.0, left: 25.0, bottom: 2.0),
                          child: Text("Heart Rate:",
                            style: TextStyle(
                              color: Color.fromARGB(255, 2, 2, 2), 
                              fontWeight: FontWeight.w500, 
                              fontSize: 15.0
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 25.0),
                          child: TextField(
                            controller: _rateController,
                            decoration: const InputDecoration(
                              filled: true,
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12), // Add spaces
                  const Padding(
                    padding: EdgeInsets.only(left: 5.0, top: 40.0),
                    child: Text(
                      "BPM",
                      style: TextStyle(
                        fontSize: 15, 
                        fontWeight: FontWeight.w500
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20), // Add spaces before next widget

              // Submit and Clear button
              Padding(
                padding: const EdgeInsets.only(top: 10.0, left: 25.0),
                child: Row(
                  children: [
                    // Submit Button
                    Align(
                      alignment: Alignment.centerLeft, // Align button to the left
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 202, 200, 200),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.0)),
                          minimumSize: const Size(48, 48),
                          textStyle: const TextStyle(
                            fontSize: 15, 
                            fontWeight: FontWeight.w500
                          ),
                        ),
                        onPressed: () {
                           // Call the add bp records function
                          _addBPEntry();
                        },

                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
                          child: Text("Submit", style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 20), // Add space between buttons

                    // Clear Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 202, 200, 200),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.0)),
                        minimumSize: const Size(48, 48),
                        textStyle: const TextStyle(
                          fontSize: 15, 
                          fontWeight: FontWeight.w500
                        ),
                      ),
                      onPressed: () {
                        // Clear the values from the text controllers
                        _systolicController.clear();
                        _diastolicController.clear();
                        _rateController.clear();
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
                        child: Text(
                          "Clear", 
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Create a class to handle the data on bp records in the database
class BPLog {
  static Future<void> addData(BuildContext context, String caregiverName, String elderlyName, String name, 
    String date, String time, String systolic, String diastolic, String rate, String bpStatus) async {
    
    // // Print the data on the console (for checking purpose)
    // print("Full Name: $name");
    // print("Date: $date");
    // print("Time: $time");
    // print("Systolic Blood Pressure: $systolic mmHg");
    // print("Diastolic Blood Pressure: $diastolic mmHg");
    // print("Heart Rate: $rate BPM");
    // print("Blood Pressure Status: $bpStatus");
    // print("Caregiver Name: $caregiverName");

    // Upload to database
    DatabaseReference ref = FirebaseDatabase.instance.ref("bp_records/$caregiverName"); // Firebase reference (elderly bp records reference to assigned caregiver)
    DatabaseReference newRef = ref.push(); // Generate a new unique key for the record
    
    // Store the data in firebase under the unique key
    await newRef.set({
      "Elderly Name": name,
      "Recorded Date": date,
      "Recorded Time": time,
      "Systolic Blood Pressure": systolic,
      "Diastolic Blood Pressure": diastolic,
      "Heart Rate": rate,
      "Blood Pressure Status": bpStatus,
    }); 
  }
}