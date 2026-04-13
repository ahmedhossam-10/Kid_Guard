import 'package:flutter/material.dart';

class VaccineCard extends StatelessWidget {
  final String vaccineName;
  final String date;
  final String status; // Completed - Pending - Missed
  final bool isTaken;
  final bool isOverdue;
  final VoidCallback? onTapIcon;

  const VaccineCard({
    super.key,
    required this.vaccineName,
    required this.date,
    required this.status,
    required this.isTaken,
    required this.isOverdue,
    this.onTapIcon,
  });

  Color _getStatusColor() {
    if (isTaken) return Colors.green.withOpacity(0.2);
    if (isOverdue) return Colors.red.withOpacity(0.2);
    if (status.toLowerCase() == "pending") return Colors.white;
    return Colors.grey.withOpacity(0.2);
  }

  Color _getIconColor() {
    return isTaken ? Colors.green : Colors.grey;
  }

  IconData _getIconData() {
    return isTaken ? Icons.check_circle : Icons.radio_button_unchecked;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: _getStatusColor(),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // اسم التطعيم + التاريخ + وقت المتبقي/Overdue
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                vaccineName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                date,
                style: TextStyle(
                  fontSize: 14,
                  color: isOverdue ? Colors.red[700] : Colors.grey[800],
                ),
              ),
            ],
          ),

          // أيقونة التفاعل
          GestureDetector(
            onTap: onTapIcon,
            child: Icon(
              _getIconData(),
              color: _getIconColor(),
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}
