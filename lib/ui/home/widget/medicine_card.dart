import 'package:flutter/material.dart';

class MedicineCard extends StatelessWidget {
  final String name;
  final String dose;
  final String time;
  final String days;
  final VoidCallback? onTap;

  const MedicineCard({
    super.key,
    required this.name,
    required this.dose,
    required this.time,
    required this.days,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFFFFF), Color(0xFFF3F8FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          leading: CircleAvatar(
            radius: 26,
            backgroundColor: const Color(0xFF3A7BD5),
            child: const Icon(
              Icons.medication_outlined,
              color: Colors.white,
              size: 28,
            ),
          ),
          title: Text(
            name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Dose: $dose mg",
                style: const TextStyle(fontSize: 15, color: Colors.black54),
              ),
              Text(
                "Time: $time",
                style: const TextStyle(fontSize: 15, color: Colors.black54),
              ),
              Text(
                "Days: $days",
                style: const TextStyle(fontSize: 15, color: Colors.black54),
              ),
            ],
          ),
          trailing: const Icon(
            Icons.notifications_active_outlined,
            color: Color(0xFF3A7BD5),
          ),
        ),
      ),
    );
  }
}
