import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../services/api_service.dart';

class GrowthHistoryScreen extends StatefulWidget {
  const GrowthHistoryScreen({super.key});

  @override
  State<GrowthHistoryScreen> createState() => _GrowthHistoryScreenState();
}

class _GrowthHistoryScreenState extends State<GrowthHistoryScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> history = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('user_token');
      final int? childId = prefs.getInt('selected_child_id');

      if (token != null && childId != null) {
        final response = await _apiService.getGrowthHistory(token, childId);

        if (response.statusCode == 200) {
          if (mounted) {
            setState(() {
              history = response.data ?? [];
              isLoading = false;
            });
          }
          return;
        }
      }
      _resetState();
    } catch (e) {
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
          "Growth History",
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
            onRefresh: _loadHistory,
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
                final item = history[index] as Map<String, dynamic>;
                return _buildGrowthCard(item);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGrowthCard(Map<String, dynamic> item) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      color: Colors.white.withOpacity(0.98),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (item['createdAt'] != null)
                  Row(
                    children: [
                      Icon(Icons.calendar_month_outlined, size: 16, color: Colors.grey[500]),
                      const SizedBox(width: 6),
                      Text(
                        item['createdAt'].toString().split('T')[0],
                        style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                if (item['ageInMonths'] != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3A7BD5).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "${item['ageInMonths']} Mo",
                      style: const TextStyle(color: Color(0xFF3A7BD5), fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
              ],
            ),
            const Divider(height: 30, thickness: 0.8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if (item['weight'] != null)
                  _buildMetricTile(Icons.monitor_weight_outlined, "Weight", "${item['weight']} kg"),
                if (item['height'] != null)
                  _buildMetricTile(Icons.straighten_rounded, "Height", "${item['height']} cm"),
              ],
            ),
            if (item['weightStatus'] != null || item['heightStatus'] != null) ...[
              const SizedBox(height: 15),
              if (item['weightStatus'] != null) _buildStatusChip("Weight", item['weightStatus']),
              if (item['heightStatus'] != null) _buildStatusChip("Height", item['heightStatus']),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF3A7BD5), size: 26),
        const SizedBox(height: 6),
        Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
        Text(value, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
      ],
    );
  }

  Widget _buildStatusChip(String title, String status) {
    Color color = Colors.green;
    String statusLower = status.toLowerCase();

    if (statusLower.contains("زيادة") || statusLower.contains("overweight") || statusLower.contains("obese")) {
      color = Colors.orange;
    } else if (statusLower.contains("نقص") || statusLower.contains("underweight") || statusLower.contains("stunted")) {
      color = Colors.redAccent;
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Icon(Icons.analytics_outlined, size: 14, color: color),
          const SizedBox(width: 8),
          Text("$title: ", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          Expanded(
            child: Text(
              status,
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
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
                Icon(Icons.history_toggle_off, size: 80, color: Colors.white.withOpacity(0.5)),
                const SizedBox(height: 16),
                const Text(
                  "No Growth Records Yet",
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "Records will appear here after status checks.",
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