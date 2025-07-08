class BPRecordModel {
  String fullName;
  String recordedDate;
  String recordedTime;
  String bpSystolic;
  String bpDiastolic;
  String pulseRate;
  String status;
  //Color statusColor;

  BPRecordModel ({
    required this.fullName,
    required this.recordedDate,
    required this.recordedTime,
    required this.bpSystolic,
    required this.bpDiastolic,
    required this.pulseRate,
    required this.status,
    //required this.statusColor,
  });
}
