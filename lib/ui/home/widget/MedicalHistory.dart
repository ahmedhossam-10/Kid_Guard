import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../services/api_service.dart';
import 'MedicalItem.dart';

class MedicalHistoryScreen extends StatefulWidget {
  const MedicalHistoryScreen({super.key});

  @override
  State<MedicalHistoryScreen> createState() => _MedicalHistoryScreenState();
}

class _MedicalHistoryScreenState extends State<MedicalHistoryScreen> {
  final ApiService _apiService = ApiService();
  List<MedicalItem> history = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMedicalHistory();
  }

  Future<void> _loadMedicalHistory() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final int? childId = prefs.getInt('selected_child_id');

      final String? token = prefs.getString('user_token');

      if (childId != null && token != null) {
        final List<MedicalItem> fetchedHistory = await _apiService.getMedicalHistory(childId, token);

        if (mounted) {
          setState(() {
            history = fetchedHistory;
            isLoading = false;
          });
        }
      } else {
        debugPrint("⚠️ Context Missing: childId=$childId, token=${token != null ? 'Found' : 'NULL'}");
        _resetState();
      }
    } catch (e) {
      debugPrint("❌ UI Error: $e");
      _resetState();
    }
  }

  void _resetState() {
    if (mounted) {
      setState(() {
        history = [];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "Medical Archive",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 22),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF00D2FF), Color(0xFF3A7BD5)],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadMedicalHistory,
            color: const Color(0xFF3A7BD5),
            backgroundColor: Colors.white,
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : history.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: history.length,
              itemBuilder: (context, index) {
                return _buildMedicalCard(history[index]);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMedicalCard(MedicalItem item) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      color: Colors.white.withOpacity(0.98),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.medicationName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3A7BD5).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.actionTaken.split('(').first.trim(),
                    style: const TextStyle(
                      color: Color(0xFF3A7BD5),
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 25, thickness: 0.8),
            _buildInfoRow(Icons.scale_outlined, "Dosage", item.dosage),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.calendar_month_outlined, "Start Date", item.startDate),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.access_time_rounded, "Time", item.timesPattern),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.history_toggle_off_rounded, "Usage Period", "${item.actualUsageDays} Days"),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blueGrey.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 16, color: Colors.blueGrey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Days Pattern: ${item.daysPattern}",
                      style: const TextStyle(fontSize: 12, color: Colors.blueGrey, fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF3A7BD5)),
        const SizedBox(width: 10),
        Text("$label: ", style: const TextStyle(color: Colors.grey, fontSize: 13)),
        Expanded(
          child: Text(
            value.isEmpty ? "N/A" : value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Color(0xFF2C3E50),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return LayoutBuilder(
      builder: (context, constraints) => ListView(
        children: [
          Container(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2_outlined, size: 80, color: Colors.white.withOpacity(0.5)),
                const SizedBox(height: 16),
                const Text(
                  "No Medical History Found",
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "Archive of completed medications will appear here.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}