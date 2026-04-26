import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../services/api_service.dart';
import '../../home/widget/vaccine_card.dart';
import '../../home/widget/VaccinationModel.dart';

class VaccinesScreen extends StatefulWidget {
  static const String routeName = 'vaccine';
  const VaccinesScreen({super.key});

  @override
  State<VaccinesScreen> createState() => _VaccinesScreenState();
}

class _VaccinesScreenState extends State<VaccinesScreen> {
  final ApiService _apiService = ApiService();
  List<VaccinationModel> allVaccines = [];
  bool isLoading = true;
  String selectedFilter = "All";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('user_token');
      final int? childId = prefs.getInt('selected_child_id');

      if (token != null && childId != null) {
        final data = await _apiService.fetchVaccinations(token, childId);
        setState(() {
          allVaccines = data;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint("❌ Error loading vaccines: $e");
      setState(() => isLoading = false);
    }
  }

  List<VaccinationModel> get filteredVaccines {
    if (selectedFilter == "All") return allVaccines;
    if (selectedFilter == "Completed") {
      return allVaccines.where((v) => v.isUsed).toList();
    }
    if (selectedFilter == "Pending") {
      return allVaccines.where((v) => !v.isUsed && !v.isOverdue).toList();
    }
    if (selectedFilter == "Missed") {
      return allVaccines.where((v) => v.isOverdue && !v.isUsed).toList();
    }
    return allVaccines;
  }

  Future<void> _toggleStatus(VaccinationModel vaccine) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('user_token');

      if (token != null) {
        final bool newStatus = !vaccine.isUsed;

        final response = await _apiService.updateVaccineStatus(token, vaccine.id, newStatus);

        if (response.statusCode == 200) {
          _loadData();

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(newStatus
                  ? "Vaccine marked as Completed"
                  : "Vaccine marked as Pending"),
              backgroundColor: newStatus ? Colors.green : Colors.orange,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("❌ Toggle Error: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update status")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "Vaccinations",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
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
          child: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                child: Row(
                  children: ["All", "Completed", "Pending", "Missed"].map((filter) {
                    bool isSelected = selectedFilter == filter;
                    return GestureDetector(
                      onTap: () => setState(() => selectedFilter = filter),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
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

              const SizedBox(height: 10),

              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                    : filteredVaccines.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredVaccines.length,
                    itemBuilder: (context, index) {
                      final v = filteredVaccines[index];
                      return VaccineCard(
                        vaccineName: v.vaccineNameEn,
                        date: v.description,
                        status: v.isUsed
                            ? "Completed"
                            : (v.isOverdue ? "Missed" : "Pending"),
                        isTaken: v.isUsed,
                        isOverdue: v.isOverdue && !v.isUsed,
                        onTapIcon: () => _toggleStatus(v),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.verified_outlined, size: 80, color: Colors.white.withOpacity(0.4)),
          const SizedBox(height: 16),
          Text(
            "No $selectedFilter vaccines found",
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}