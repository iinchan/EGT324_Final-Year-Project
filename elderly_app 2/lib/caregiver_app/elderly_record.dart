import 'package:elderly_app/caregiver_app/bp_data_analytics.dart';
import 'package:flutter/material.dart';
import 'package:elderly_app/model/bprecord_model.dart'; // Import custom class model

class ElderlyRecords extends StatelessWidget {
  // To display the list of bp records of the elderly
  final List<BPRecordModel> bpRecords;

  const ElderlyRecords({super.key, required this.bpRecords});

  @override
  Widget build(BuildContext context) {
    
    // For the data analytics part
    // Use a set to store unique elderly names
    Set<String> uniqueElderlyNames = {};
    //bpRecords.forEach((record) {
    for (var record in bpRecords) {
      uniqueElderlyNames.add(record.fullName);
    }
    // Convert set to list
    List<String> elderlyNames = uniqueElderlyNames.toList();

    // Elderly bp records
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Elderly BP Records",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.purple,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // View BP Data Analytics Button
          Container(
            margin: const EdgeInsets.only(top: 15.0), // Adjust the top margin as needed
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 218, 217, 217),
                foregroundColor: Colors.black,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                minimumSize: const Size(200, 49), // Adjust width and height
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BpDataAnalytics(elderlyNames: elderlyNames),
                  ),
                );
              }, 
              child: const Text(
                "Data Analytics Report", 
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),

          Expanded(
            child: bpRecords.isEmpty? 
            const Center(
              child: Text(
                "No elderly blood pressure records found.",
                style: TextStyle(fontSize: 16),
              ),
            )

            : ListView.builder(
              itemCount: bpRecords.length,
              itemBuilder: (context, index) {
                BPRecordModel record = bpRecords[index];

                return Card(
                  elevation: 30,
                  margin: const EdgeInsets.symmetric(
                    vertical: 25, horizontal: 21,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(
                        color: Color.fromARGB(255, 206, 202, 202)),
                  ),

                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name section
                        Row(
                          children: [
                            Text(
                              record.fullName,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // Recorded Date section
                        Row(
                          children: [
                            const Text(
                              "Recorded Date:",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                              ),
                            ),

                            const SizedBox(width: 6),
                            Text(
                              record.recordedDate,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // Recorded Time section
                        Row(
                          children: [
                            const Text(
                              "Recorded Time:",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                              ),
                            ),

                            const SizedBox(width: 6),
                            Text(
                              record.recordedTime,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // Systolic Blood Pressure section
                        Row(
                          children: [
                            const Text(
                              "Systolic Blood Pressure:",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                              ),
                            ),
                            
                            const SizedBox(width: 6),
                            Text(
                              "${record.bpSystolic} mmHg",
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // Diastolic Blood Pressure section
                        Row(
                          children: [
                            const Text(
                              "Diastolic Blood Pressure:",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                              ),
                            ),

                            const SizedBox(width: 6),
                            Text(
                              "${record.bpDiastolic} mmHg",
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // Heart Rate section
                        Row(
                          children: [
                            const Text(
                              "Heart Rate:",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                              ),
                            ),
                            
                            const SizedBox(width: 6),
                            Text(
                              "${record.pulseRate} BPM",
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // Blood Pressure Status section
                        Row(
                          children: [
                            const Text(
                              "Blood Pressure Status:",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                              ),
                            ),
                            
                            const SizedBox(width: 6),
                            Text(
                              record.status,
                              style: const TextStyle(
                                //color: record.statusColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
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
