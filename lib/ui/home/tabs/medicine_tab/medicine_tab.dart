import 'package:flutter/material.dart';
import '../../../add_medicine/screen/AddMedicine.dart';
import '../../../vaccine/screen/vaccine_screen.dart';
import '../../widget/medicine_card.dart';

class MedicineTab extends StatefulWidget {
  const MedicineTab({super.key});

  @override
  State<MedicineTab> createState() => _MedicineTabState();
}

class _MedicineTabState extends State<MedicineTab> {
  // القائمة الابتدائية
  List<Map<String, dynamic>> medicines = [
    {
      "name": "Paracetamol",
      "dose": "500",
      "time": "8:00 AM",
      "days": "Monday, Wednesday, Friday"
    },
    {
      "name": "Vitamin C",
      "dose": "1000",
      "time": "1:00 PM",
      "days": "Tuesday, Thursday"
    },
  ];

  Future<void> navigateToAddMedicine() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddMedicine()),
    );

    // التحقق من أن النتيجة ليست null وأنها Map
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        // استخراج الأوقات وتحويلها لنص واحد مفصول بفاصلة
        // لأن result["times"] عبارة عن List<String>
        List<String> timesList = List<String>.from(result["times"] ?? []);
        String formattedTimes = timesList.isNotEmpty ? timesList.join(", ") : "Not set";

        // إضافة الدواء الجديد للقائمة
        medicines.add({
          "name": result["name"] ?? "Unknown",
          "dose": result["dose"] ?? "0",
          "time": formattedTimes, // هنا حلينا مشكلة المفتاح والنوع
          "days": (result["days"] as List<String>).join(", "),
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
            icon: const Icon(Icons.vaccines_outlined, color: Colors.white, size: 28),
            onPressed: () {
              Navigator.pushNamed(context, VaccinesScreen.routeName);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 60, right: 8),
        child: FloatingActionButton(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          onPressed: navigateToAddMedicine,
          child: const Icon(Icons.add, color: Color(0xFF3A7BD5), size: 30),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
              : ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
            itemCount: medicines.length,
            separatorBuilder: (context, index) => const SizedBox(height: 15),
            itemBuilder: (context, index) {
              final med = medicines[index];
              return MedicineCard(
                name: med["name"],
                dose: med["dose"],
                time: med["time"],
                days: med["days"],
                onTap: () {
                  // أكشن عند الضغط على الكارت
                },
              );
            },
          ),
        ),
      ),
    );
  }
}