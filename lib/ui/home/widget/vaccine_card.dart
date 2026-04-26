import 'package:flutter/material.dart';

class VaccineCard extends StatelessWidget {
  final String vaccineName;
  final String date;
  final String status;
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
    if (isTaken) return Colors.green.withOpacity(0.15);
    if (isOverdue) return Colors.red.withOpacity(0.15);
    return Colors.white.withOpacity(0.9);
  }

  Color _getBorderColor() {
    if (isTaken) return Colors.green.withOpacity(0.5);
    if (isOverdue) return Colors.red.withOpacity(0.5);
    return Colors.grey.withOpacity(0.2);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: _getStatusColor(),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _getBorderColor(), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vaccineName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isTaken ? Colors.green[900] : Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: isOverdue ? Colors.red[700] : Colors.grey[600],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isOverdue ? Colors.red[700] : Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(50),
              onTap: onTapIcon,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  isTaken ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: isTaken ? Colors.green : (isOverdue ? Colors.red : Colors.grey),
                  size: 30,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}