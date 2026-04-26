class VaccinationModel {
  final int id;
  final String vaccineName;
  final String vaccineNameEn;
  final int ageMonths;
  final String description;
  final bool isUsed;
  final bool isOverdue;

  VaccinationModel({
    required this.id,
    required this.vaccineName,
    required this.vaccineNameEn,
    required this.ageMonths,
    required this.description,
    required this.isUsed,
    required this.isOverdue,
  });

  factory VaccinationModel.fromJson(Map<String, dynamic> json) {
    return VaccinationModel(
      id: json['id'] ?? 0,
      vaccineName: json['vaccineName'] ?? '',
      vaccineNameEn: json['vaccineNameEn'] ?? '',
      ageMonths: json['ageMonths'] ?? 0,
      description: json['description'] ?? '',
      isUsed: json['isUsed'] ?? false,
      isOverdue: json['isOverdue'] ?? false,
    );
  }
}