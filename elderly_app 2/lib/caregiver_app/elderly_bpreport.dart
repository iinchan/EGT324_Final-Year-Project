import 'package:flutter/material.dart';

// Blood Pressure report page template
class ElderlyBpReport extends StatefulWidget {
  const ElderlyBpReport({super.key, required String elderlyName});

  @override
  State<ElderlyBpReport> createState() => _ElderlyBpReportState();
}

class _ElderlyBpReportState extends State<ElderlyBpReport> {
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
    );
  }
}