import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../home/widget/vaccine_card.dart';

class VaccinesScreen extends StatefulWidget {
  static const String routeName = 'vaccine';
  const VaccinesScreen({super.key});

  @override
  State<VaccinesScreen> createState() => _VaccinesScreenState();
}

class _VaccinesScreenState extends State<VaccinesScreen> {
  String selectedFilter = "All";

  // بيانات Fake للتطعيمات
  final List<Map<String, dynamic>> vaccines = [
    {
      "name": "BCG",
      "date": "2025-01-05",
      "status": "Completed",
    },
    {
      "name": "Polio",
      "date": "2025-12-10",
      "status": "Pending",
    },
    {
      "name": "Measles",
      "date": "2025-11-14",
      "status": "Pending",
    },
    {
      "name": "Hepatitis B",
      "date": "2025-12-20",
      "status": "Pending",
    },
  ];

  List<Map<String, dynamic>> get filteredVaccines {
    if (selectedFilter == "All") return vaccines;
    return vaccines.where((v) => v["status"] == selectedFilter).toList();
  }

  void toggleVaccineStatus(int index) {
    setState(() {
      String currentStatus = vaccines[index]["status"];
      if (currentStatus.toLowerCase() == "completed") {
        vaccines[index]["status"] = "Pending";
      } else {
        vaccines[index]["status"] = "Completed";
      }
    });
  }

  bool isOverdue(String dateStr) {
    DateTime today = DateTime.now();
    DateTime vaccineDate = DateFormat('yyyy-MM-dd').parse(dateStr);
    return vaccineDate.isBefore(today);
  }

  String getTimeLeft(String dateStr) {
    DateTime today = DateTime.now();
    DateTime vaccineDate = DateFormat('yyyy-MM-dd').parse(dateStr);
    Duration diff = vaccineDate.difference(today);

    if (diff.inDays > 0) return "${diff.inDays} days left";
    if (diff.inDays == 0) return "Today";
    return "Overdue";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "Vaccinations",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Color(0xFF3A7BD5), Color(0xFF00D2FF)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // فلتر أعلى الشاشة
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: ["All", "Completed", "Pending", "Missed"].map((filter) {
                    bool isSelected = selectedFilter == filter;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedFilter = filter;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withOpacity(0.9)
                              : Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          filter,
                          style: TextStyle(
                            color: isSelected ? const Color(0xFF3A7BD5) : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 12),

              // قائمة التطعيمات
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredVaccines.length,
                  itemBuilder: (context, index) {
                    final v = filteredVaccines[index];
                    bool overdue = isOverdue(v["date"]!) && v["status"]!.toLowerCase() != "completed";
                    String displayStatus = v["status"];
                    if (overdue) displayStatus = "Missed";

                    return VaccineCard(
                      vaccineName: v["name"]!,
                      date: "${v["date"]} - ${getTimeLeft(v["date"]!)}",
                      status: displayStatus,
                      isTaken: v["status"]!.toLowerCase() == "completed",
                      isOverdue: overdue,
                      onTapIcon: () => toggleVaccineStatus(index),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
