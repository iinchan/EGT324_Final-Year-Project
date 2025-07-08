import 'package:elderly_app/model/status_model.dart';
import 'package:flutter/material.dart';

class ActivityStatus extends StatelessWidget {
  // To display the list of bp records of the elderly
  final List<Status> completionRec;

  const ActivityStatus({super.key, required this.completionRec});

// List of elderly activity status
// UI Components
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Activity Status",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.purple,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
     body: completionRec.isEmpty ? 
        const Center(
          child: Text(
            "No activity completion status.",
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        )
        : ListView.builder(
        itemCount: completionRec.length,
        itemBuilder: (context, index) {
          final com = completionRec[index];

          // Determine card color based on completion status
          Color cardColor = com.completion.toLowerCase() == "yes"
            ? const Color.fromARGB(255, 95, 236, 168) // Green color if completion status is 'yes'
            : const Color.fromARGB(255, 239, 106, 106); // Red color if completion status is 'no'

          return Card(
            elevation: 35,
            margin: const EdgeInsets.symmetric(
              vertical: 14, horizontal: 21,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: const BorderSide(
                color: Color.fromARGB(255, 206, 202, 202)
              ),
            ),
            color: cardColor, // Set card color dynamically

            // Submission Date section
            child: Padding(
              padding: const EdgeInsets.all(20.0), // Set padding in the card
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Elderly name section
                  Text(
                    com.elderly,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20, 
                    ),
                  ),
                                    
                  const SizedBox(height: 10),

                  // Date section
                   const Text(
                    "Submission Date:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18, 
                    ),
                  ),
                  Text(
                    com.subdate,
                    style: const TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Activity Status section
                  const Text(
                    "Completion Status:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18, 
                    ),
                  ),
                  Text(
                    com.completion,
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,  
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}