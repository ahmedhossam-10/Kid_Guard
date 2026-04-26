class MedicalItem {
  final int id;
  final String medicationName;
  final String dosage;
  final String actionTaken;
  final String startDate;
  final String daysPattern;
  final String timesPattern;
  final int actualUsageDays;

  MedicalItem({
    required this.id,
    required this.medicationName,
    required this.dosage,
    required this.actionTaken,
    required this.startDate,
    required this.daysPattern,
    required this.timesPattern,
    required this.actualUsageDays,
  });

  factory MedicalItem.fromJson(Map<String, dynamic> json) {
    return MedicalItem(
      id: json['id'] ?? 0,
      medicationName: json['medicationName'] ?? "Unknown",
      dosage: json['dosage'] ?? 'N/A',
      actionTaken: json['actionTaken'] ?? 'Archived',
      startDate: json['startDate'] != null
          ? json['startDate'].toString().split('T')[0]
          : 'N/A',
      daysPattern: json['daysPattern'] ?? 'N/A',
      timesPattern: json['timesPattern'] ?? 'N/A',
      actualUsageDays: json['actualUsageDays'] ?? 0,
    );
  }
}