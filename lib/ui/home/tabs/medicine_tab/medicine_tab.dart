import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../../add_medicine/screen/AddMedicine.dart';
import '../../../vaccine/screen/vaccine_screen.dart';
import '../../widget/medicine_card.dart';
import '../../../../services/api_service.dart';
import '../../widget/MedicalHistory.dart';

class MedicineTab extends StatefulWidget {
  const MedicineTab({super.key});

  @override
  State<MedicineTab> createState() => _MedicineTabState();
}

class _MedicineTabState extends State<MedicineTab> {
  final ApiService _apiService = ApiService();

  List<dynamic> medicines = [];
  bool isLoading = true;
  String? _userToken;
  int? _selectedChildId;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  String formatTimeString(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return "N/A";
    try {
      DateTime tempDate = DateFormat("HH:mm:ss").parse(timeStr);
      return DateFormat("hh:mm a").format(tempDate);
    } catch (e) {
      return timeStr;
    }
  }

  Future<void> _loadInitialData() async {
    final prefs = await SharedPreferences.getInstance();
    _userToken = prefs.getString('user_token');
    _selectedChildId = prefs.getInt('selected_child_id');

    if (_userToken != null && _selectedChildId != null) {
      await _fetchMedications();
    } else {
      if (mounted) setState(() => isLoading = false);
      _showSnackBar("Please select a child first");
    }
  }

  Future<void> _fetchMedications() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      final response = await _apiService
          .getChildMedications(_userToken!, _selectedChildId!)
          .timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        setState(() {
          medicines = response.data;
        });
      } else {
        _showSnackBar("Server Error");
      }
    } catch (e) {
      _showSnackBar("Failed to load medicines");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _handleDelete(int medId) async {
    bool? confirm = await _showConfirmDialog();
    if (confirm != true) return;
    try {
      final response = await _apiService.deleteMedication(_userToken!, medId);
      if (response.statusCode == 200 || response.statusCode == 204) {
        _showSnackBar("Medication deleted successfully");
        _fetchMedications();
      } else {
        _showSnackBar("Failed to delete from server");
      }
    } catch (e) {
      _showSnackBar("Error deleting medication");
    }
  }

  Future<void> _handleEdit(Map<String, dynamic> medData) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddMedicine(initialData: medData)),
    );
    if (result == true) _fetchMedications();
  }

  Future<bool?> _showConfirmDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Delete"),
        content: const Text("Are you sure you want to delete this medicine?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.history_edu_outlined, color: Colors.white, size: 28),
          onPressed: () {
            if (_selectedChildId != null) {
              Navigator.pushNamed(context, '/medical-history');
            } else {
              _showSnackBar("Please select a child first");
            }
          },
        ),
        title: const Text(
          "Medicine",
          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.vaccines_outlined, color: Colors.white, size: 28),
            onPressed: () => Navigator.pushNamed(context, VaccinesScreen.routeName),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 60, right: 8),
        child: FloatingActionButton(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          onPressed: () async {
            final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddMedicine()));
            if (result == true) _fetchMedications();
          },
          child: const Icon(Icons.add, color: Color(0xFF3A7BD5), size: 30),
        ),
      ),
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
          child: isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : RefreshIndicator(
            onRefresh: _fetchMedications,
            child: medicines.isEmpty
                ? const Center(child: Text("No medicines added yet", style: TextStyle(color: Colors.white, fontSize: 18)))
                : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              itemCount: medicines.length,
              separatorBuilder: (context, index) => const SizedBox(height: 15),
              itemBuilder: (context, index) {
                final med = medicines[index];
                String medName = med["medicationName"] ?? "Unknown";
                String dosage = med["dosage"]?.toString() ?? "N/A";
                List activeDays = med["activeDays"] ?? [];
                String daysText = activeDays.join(", ");
                List schedules = med["schedules"] ?? [];
                String timeText = schedules.map((s) => formatTimeString(s["scheduledTime"])).join(" | ");

                return MedicineCard(
                  name: medName,
                  dose: dosage,
                  time: timeText,
                  days: daysText,
                  onTap: () => _showOptionsBottomSheet(med),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _showOptionsBottomSheet(Map<String, dynamic> med) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: const Text("Edit Medication"),
              onTap: () {
                Navigator.pop(context);
                _handleEdit(med);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text("Delete Medication"),
              onTap: () {
                Navigator.pop(context);
                _handleDelete(med["id"]);
              },
            ),
            const SizedBox(height: 10),
          ],
        );
      },
    );
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}