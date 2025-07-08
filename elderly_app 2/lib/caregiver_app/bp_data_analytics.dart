import 'package:elderly_app/caregiver_app/elderly_bpreport.dart';
import 'package:elderly_app/caregiver_app/elderly_bpreport_bob.dart';
import 'package:elderly_app/caregiver_app/elderly_bpreport_sarah.dart';
import 'package:flutter/material.dart';

class BpDataAnalytics extends StatelessWidget {
  // To display the list of elderly names
  final List<String> elderlyNames;

  const BpDataAnalytics({super.key,required this.elderlyNames});

  // UI Components
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Data Analytics Reports",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.purple,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      
      body: Center(
        child: ListView.builder(
          itemCount: elderlyNames.length,
          itemBuilder: (context, index) {
            String elderlyName = elderlyNames[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 50.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 229, 226, 226),
                  foregroundColor: Colors.black,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  minimumSize: const Size(20, 70),
                ),
                onPressed: () {
                  switch (elderlyName) {
                    // If the elderly name is "Sarah Toh"
                    case "Sarah Toh":
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ElderlyBpReportSarah(elderlyName: elderlyName),
                        ),
                      );
                      break;
                    // If the elderly name is "Bob Tan"
                    case "Bob Tan":
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ElderlyBpReportBob(elderlyName: elderlyName),
                        ),
                      );
                      break;
                    // If elderly is other people
                    default:
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ElderlyBpReport(elderlyName: elderlyName),
                        ),
                      );
                  }
                },
                child: Text(
                  elderlyName,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
