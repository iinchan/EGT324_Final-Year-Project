import 'dart:async';
import 'package:flutter/material.dart';
import 'package:elderly_app/model/journal_model.dart'; // Import custom class model
import 'records_list.dart';
import 'package:firebase_database/firebase_database.dart'; // Import Firebase Realtime Database package

class JournalEnt extends StatefulWidget {
  final String elderly;

  const JournalEnt({super.key, required this.elderly});

  @override
  State<JournalEnt> createState() => _JournalEntState();
}

class _JournalEntState extends State<JournalEnt> {
  DateTime? selectedDate; // Selected date for journal entries

  // Controllers for text fields
  final TextEditingController dateCon = TextEditingController();
  final TextEditingController ques1Con = TextEditingController();
  final TextEditingController ques2Con = TextEditingController();
  final TextEditingController ques3Con = TextEditingController();

  // Create a list to store the fetched journal entries
  List<Entry> journalEntries = [];

  // Function to select a date using date picker
  Future<void> _dateSelector(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    // Update the change in date
    setState(() {
      dateCon.text = picked != null ? picked.toString().split(" ")[0] : " ";
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchJournalEntries();
  }

  // Fetch journal entries from firebase for the current elderly user
  void _fetchJournalEntries() async {
    DatabaseReference recRef = FirebaseDatabase.instance.ref(
      "journal_records/${widget.elderly}");
    DataSnapshot snapshot = await recRef.get();

    // Check if the data exists
    if (snapshot.value != null) {
      
      // Create a list to store the journal entries from firebase
      List<Entry> jrecords = []; 

      // Extract the values
      Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;
      values.forEach((key, value) {
        String date = value["Journal Date"] ?? "";
        String q1 = value["Daily Reflections"] ?? "";
        String q2 = value["Memories and Moments"] ?? "";
        String q3 = value["Self-Reminders and Notes"] ?? "";

        // To store the extracted data using journal model
        Entry entry = Entry(
          date: date,
          question1: q1,
          question2: q2,
          question3: q3,
        );

        // Add the fetched journal entries to the list
        jrecords.add(entry); 
      });

      // Update the fetched journal entries to the list outside of the class
      setState(() {
        journalEntries = jrecords;
      });
    }
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

  // Function to add new journal entry
  void _addJournalEntry() async {

    // Retrieve data from text field
    String dateEnt = dateCon.text;
    String ques1Ent = ques1Con.text;
    String ques2Ent = ques2Con.text;
    String ques3Ent = ques3Con.text;

    if (dateEnt.isEmpty || ques1Ent.isEmpty || ques2Ent.isEmpty || ques3Ent.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            backgroundColor: Color.fromARGB(255, 128, 4, 4),
            title: Center(
              child: Text(
                "Error Saving Journal !",
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        },
      );
    }
    else {
      // Create a new entry object using the journal model to store the retrieved data
      Entry newEntry = Entry(
        date: dateEnt,
        question1: ques1Ent,
        question2: ques2Ent,
        question3: ques3Ent,
      );

      // Call the function to add new entry data to Firebase
      await JRec.addData(context, widget.elderly, dateEnt, ques1Ent, ques2Ent, ques3Ent);
      
      // Add new journal entry to the list outside of the class
      setState(() {
        journalEntries.add(newEntry); 
      });

      // Show success message
      _showSnackbar("Journal has been saved!", isSuccess: true);

      // Clear the text fields after saving
      dateCon.clear();
      ques1Con.clear();
      ques2Con.clear();
      ques3Con.clear();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Journal Entry", 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Field
            const Padding(
              padding: EdgeInsets.only(top: 25.0, left: 25.0, bottom: 2.0),
              child: Text(
                "Journal Date:",
                style: TextStyle(
                  color: Color.fromARGB(255, 2, 2, 2), 
                  fontWeight: FontWeight.w500, 
                  fontSize: 15.0
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(left: 25.0),
              child: SizedBox(
                width: 340,
                child: TextField(
                  controller: dateCon,
                  decoration: const InputDecoration(
                    filled: true,
                    border: InputBorder.none,
                    suffixIcon: Icon(Icons.calendar_today),
                    hintText: "-- Select a Date --",
                    hintStyle: TextStyle(
                      fontSize: 14.0, 
                      color: Color.fromARGB(255, 110, 107, 107),
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                  readOnly: true,
                  onTap: () {
                    _dateSelector(context);
                  },
                ),
              ),
            ),

            const SizedBox(height: 15),

            // Question 1 Field
            const Padding(
              padding: EdgeInsets.only(left: 25.0, bottom: 2.0),
              child: Text(
                "Daily Reflections:", 
                style: TextStyle(
                  color: Color.fromARGB(255, 2, 2, 2), 
                  fontWeight: FontWeight.w500, 
                  fontSize: 15.0
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(left: 25.0),
              child: SizedBox(
                width: 340,
                child: TextField(
                  maxLines: 3, // Make the field longer
                  controller: ques1Con,
                  decoration: const InputDecoration(
                    filled: true,
                    border: InputBorder.none,
                    hintText: "E.g. Today's highlights and feelings.",
                    hintStyle: TextStyle(
                      fontSize: 15.0, 
                      color: Color.fromARGB(255, 110, 107, 107),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // Question 2 Field
            const Padding(
              padding: EdgeInsets.only(left: 25.0, bottom: 2.0),
              child: Text("Memories and Moments:",
                style: TextStyle(
                  color: Color.fromARGB(255, 2, 2, 2), 
                  fontWeight: FontWeight.w500, 
                  fontSize: 15.0
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(left: 25.0),
              child: SizedBox(
                width: 340,
                child: TextField(
                  maxLines: 3, // Make the field longer
                  controller: ques2Con,
                  decoration: const InputDecoration(
                    filled: true,
                    border: InputBorder.none,
                    hintText: "E.g. Your favourite childhood/experiences.",
                    hintStyle: TextStyle(
                      fontSize: 15.0, 
                      color: Color.fromARGB(255, 110, 107, 107),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // Question 3 Field
            const Padding(
              padding: EdgeInsets.only(left: 25.0, bottom: 2.0),
              child: Text("Self-Reminders and Notes:",
                style: TextStyle(
                  color: Color.fromARGB(255, 2, 2, 2), 
                  fontWeight: FontWeight.w500, 
                  fontSize: 15.0
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(left: 25.0),
              child: SizedBox(
                width: 340,
                child: TextField(
                  maxLines: 3, // Make the field longer
                  controller: ques3Con,
                  decoration: const InputDecoration(
                    filled: true,
                    border: InputBorder.none,
                    hintText: "E.g. Things to remind and note.",
                    hintStyle: TextStyle(
                      fontSize: 15.0, 
                      color:  Color.fromARGB(255, 110, 107, 107),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                Padding(
                    padding: const EdgeInsets.only(left: 25.0, top: 15.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 202, 200, 200),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.0)),
                        // minimumSize: const Size(48, 48),
                        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 52.0),
                        textStyle:const TextStyle(
                          fontSize: 15, 
                          fontWeight: FontWeight.w500
                        ),
                      ),
                      onPressed: () {
                        // Call the add journal entry function
                        _addJournalEntry();
                      },
                      child: const Text("Save"),
                    ),
                  ),
                
                  Padding(
                    padding: const EdgeInsets.only(left: 25.0, top: 15.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 202, 200, 200),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.0)),
                        // minimumSize: const Size(48, 48),
                        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 28.0),
                        textStyle: const TextStyle(
                          fontSize: 15, 
                          fontWeight: FontWeight.w500
                        ),
                      ),
                      onPressed: () async {
                        _fetchJournalEntries(); // Fetch the latest journal entries
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RecordsList(journalEntries: journalEntries),
                          
                          ),
                        );
                      },
                      child: const Text("View History"),
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

// Create a class to handle the data on journal entries in the database
class JRec {
  static Future<void> addData(BuildContext context, String elderly, String dateEnt, 
    String ques1Ent, String ques2Ent, String ques3Ent) async {
    
    // // Print the data on the console (for checking purpose)
    // print("Journal Date: $dateEnt");
    // print("Daily Reflections: $ques1Ent");
    // print("Memories and Moments: $ques2Ent");
    // print("Self-Reminders and Notes: $ques3Ent");
    
    // Upload to database
    DatabaseReference ref = FirebaseDatabase.instance.ref("journal_records/$elderly"); // Firebase reference
    DatabaseReference newRef = ref.push(); // Generate a new unique key for the record
    
    // Store the data in firebase under the unique key
    await newRef.set({
      "Journal Date": dateEnt,
      "Daily Reflections": ques1Ent,
      "Memories and Moments": ques2Ent,
      "Self-Reminders and Notes": ques3Ent,
    }); 
  }
}