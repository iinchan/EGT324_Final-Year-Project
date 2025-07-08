import 'package:flutter/material.dart';

class ElderlyBpReportBob extends StatefulWidget {
  const ElderlyBpReportBob({super.key, required String elderlyName});

  @override
  State<ElderlyBpReportBob> createState() => _ElderlyBpReportBobState();
}

class _ElderlyBpReportBobState extends State<ElderlyBpReportBob> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Blood Pressure Reports",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.purple,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),  // Add padding for better appearance
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,  // Align text to the start
          children: [
            const Text(
              "Dashboard",
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            
            const SizedBox(height: 15),

            const Text(
              "July's Report Summary:",
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w600,
                color: Color.fromARGB(255, 34, 43, 48),
              ),
            ),

            const SizedBox(height: 5),

            // Graph of the elderly blood pressure
            Center(
              child: Image.asset(
                "assets/bob_data.png",
                width: 600,
                height: 230,
                fit: BoxFit.contain,
              ),
            ),

            // Observation section
            const Text(
              "\nObservations on the Graph:",
              style: TextStyle(
                fontSize: 18,
                color: Colors.black,
                fontWeight: FontWeight.w500
              ),
            ),

            const SizedBox(height: 5),

            const Text(
              "1. Spikes Observed:",
              style: TextStyle(
                fontSize: 17,
                color: Colors.black,
                fontWeight: FontWeight.w500
              ),
            ),

            const SizedBox(height: 6),
            const Text(
              "- Significant spikes were noted across dates for both systolic and diastolic blood pressure.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 5),
            const Text(
              "- The highest spike occured on the 5th and 29th of July, reaching 130 mmHg for systolic and 85 mmHg for diastolic.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 5),
            const Text(
              "- The lowest spike occured on the 16th of July (85/55 mmHg), and 29th of July (89/59 mmHg).",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "2. Normal Threshold:",
              style: TextStyle(
                fontSize: 17,
                color: Colors.black,
                fontWeight: FontWeight.w500
              ),
            ),

            const SizedBox(height: 6),
            const Text(
              "- The red and green dashed lines represents the normal systolic and diastolic threshold, which are 120 mmHg and 80 mmHg respectively",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 5),
            const Text(
              "- Readings above these lines indicate periods of elevated systolic and diastolic blood pressure.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 8),

            // Divide the sections
            const Divider(
              color: Colors.grey,
              thickness: 1,
            ),

            // Actions to take section
            const Text(
              "\nAppropriate Actions to Take:",
              style: TextStyle(
                fontSize: 18,
                color: Colors.black,
                fontWeight: FontWeight.w500
              ),
            ),

            const SizedBox(height: 8),
            
            // First point
            const Text(
              "1. Immediate Actions:",
              style: TextStyle(
                fontSize: 17,
                color: Colors.black,
                fontWeight: FontWeight.w500
              ),
            ),
            
            const SizedBox(height: 3),
            const Text(
              "• Schedule a medical check-up if the spikes are recurrent or concerning.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 8),
            
            // Second point
            const Text(
              "2. Consult Healthcare Professional:",
              style: TextStyle(
                fontSize: 17,
                color: Colors.black,
                fontWeight: FontWeight.w500
              ),
            ),
            
            const SizedBox(height: 3),
            const Text(
              "• Report any concerning trends to a healthcare professional for further advice and management.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 5),

            // Third point
            const Text(
              "3. Contact the Elderly:",
              style: TextStyle(
                fontSize: 17,
                color: Colors.black,
                fontWeight: FontWeight.w500
              ),
            ),

            const SizedBox(height: 3),
            const Text(
              "• Check on your elderly current state and any symptoms they might be experiencing.\n• Advise them to rest, hydrate, and avoid stress or strenuous activities.\n• Ensure that they are following a healthy diet as planned for them.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            
            const SizedBox(height: 8),
          ]
        ),
      ),
    );
  }
}