import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../services/api_service.dart';
import '../widget/DailyMealPlan.dart';

class DailyMealSuggestionsScreen extends StatefulWidget {
  const DailyMealSuggestionsScreen({super.key});

  @override
  State<DailyMealSuggestionsScreen> createState() => _DailyMealSuggestionsScreenState();
}

class _DailyMealSuggestionsScreenState extends State<DailyMealSuggestionsScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  DailyMealPlan? _mealPlan;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSuggestions();
  }

  Future<void> _loadSuggestions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('user_token');
      final int? childId = prefs.getInt('selected_child_id');

      if (token != null && childId != null) {
        final data = await _apiService.getDailyMealSuggestions(childId, token);
        if (mounted) {
          setState(() {
            _mealPlan = data;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _error = "Please select a child first";
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "Connection error. Please try again.";
          _isLoading = false;
        });
      }
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
          "Daily Guide",
          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
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
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.white, fontSize: 16)))
              : _mealPlan == null
              ? const Center(child: Text("No suggestions found.", style: TextStyle(color: Colors.white70)))
              : RefreshIndicator(
            onRefresh: _loadSuggestions,
            color: const Color(0xFF3A7BD5),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_mealPlan!.advice.isNotEmpty)
                    _buildAdviceCard(_mealPlan!.advice),
                  if (_mealPlan!.advice.isNotEmpty)
                    const SizedBox(height: 15),

                  _buildMealSection("Breakfast 🍳", _mealPlan!.breakfast),
                  _buildMealSection("Lunch 🍲", _mealPlan!.lunch),
                  _buildMealSection("Dinner 🌙", _mealPlan!.dinner),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdviceCard(String advice) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const Icon(Icons.star_rounded, color: Color(0xFF3A7BD5), size: 28),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Doctor's Tip",
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  advice,
                  style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealSection(String title, List<Meal> meals) {
    if (meals.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        ...meals.map((meal) => Container(
          margin: const EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              )
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    meal.imageUrl,
                    width: 85,
                    height: 85,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 85,
                      height: 85,
                      color: Colors.grey[100],
                      child: const Icon(Icons.fastfood_outlined, color: Colors.grey, size: 30),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meal.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF2D3436),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        meal.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }
}