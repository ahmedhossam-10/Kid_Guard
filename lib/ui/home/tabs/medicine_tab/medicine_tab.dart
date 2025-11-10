import 'package:flutter/material.dart';

import '../../widget/medicine_card.dart';

class MedicineTab extends StatelessWidget {
  const MedicineTab({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> medicines = [
      {"name": "Paracetamol", "time": "8:00 AM"},
      {"name": "Vitamin C", "time": "1:00 PM"},
      {"name": "Cough Syrup", "time": "9:00 PM"},
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Medicine",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(color: Colors.black26, blurRadius: 6)],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.vaccines_outlined,
              color: Colors.white,
              size: 28,
            ),
            onPressed: () {
              // TODO: Navigate to vaccinations page
            },
          ),
          const SizedBox(width: 8),
        ],
      ),

      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 60, right: 8),
        child: FloatingActionButton(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          onPressed: () {
            // TODO: Navigate to add medicine page
          },
          child: const Icon(Icons.add, color: Color(0xFF3A7BD5), size: 30),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Color(0xFF3A7BD5), Color(0xFF00D2FF)],
          ),
        ),
        child: SafeArea(
          child: medicines.isEmpty
              ? const Center(
                  child: Text(
                    "No medicines added yet",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 25,
                  ),
                  itemCount: medicines.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 15),
                  itemBuilder: (context, index) {
                    final med = medicines[index];
                    return MedicineCard(
                      name: med["name"]!,
                      time: med["time"]!,
                      onTap: () {},
                    );
                  },
                ),
        ),
      ),
    );
  }
}
