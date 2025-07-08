import 'package:flutter/material.dart';
import 'package:elderly_app/model/journal_model.dart';

class RecordsList extends StatelessWidget {
  final List<Entry> journalEntries;

  const RecordsList({super.key, required this.journalEntries});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Journal Histories",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),

      body: journalEntries.isEmpty ? 
        const Center(
          child: Text(
            "You have yet to write any journal.",
            style: TextStyle(
              fontSize: 16
            ),
          ),
        )
        : ListView.builder(
        itemCount: journalEntries.length,
        itemBuilder: (context, index) {
          final entry = journalEntries[index];
          
          return Card(
            elevation: 35,
            color: const Color.fromARGB(255, 219, 253, 255),
            margin: const EdgeInsets.symmetric(
              vertical: 14, horizontal: 21,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: const BorderSide(
                color: Color.fromARGB(255, 206, 202, 202)
              ),
            ),

            // Journal Date section
            child: Padding(
              padding: const EdgeInsets.all(20.0), // Set padding in the card
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.date,
                    style: const TextStyle(
                      fontSize: 20, 
                      fontWeight: FontWeight.bold
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Question 1 section
                  const Text(
                    "Daily Reflections:",
                    style: TextStyle( 
                      fontWeight: FontWeight.bold,
                      fontSize: 16, 
                    ),
                  ),
                  Text(
                    entry.question1,
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,  
                      fontSize: 16),
                  ),

                  const SizedBox(height: 10),

                  // Question 2 section
                  const Text(
                    "Memories and Moments:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16, 
                    ),
                  ),
                  Text(
                    entry.question2,
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,  
                      fontSize: 16),
                  ),

                  const SizedBox(height: 10),

                  // Question 3 section
                  const Text(
                    "Self-Reminders and Notes:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16, 
                    ),
                  ),
                  Text(
                    entry.question3,
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,  
                      fontSize: 16),
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