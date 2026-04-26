import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widget/CartProvider.dart';
import '../../widget/CartScreen.dart';
import '../../widget/food_card.dart';
import '../../../../services/api_service.dart';
import '../../widget/growth_history.dart';

class RestaurantTab extends StatelessWidget {
  const RestaurantTab({super.key});

  static final ApiService _apiService = ApiService();

  void _showGrowthTrackerSheet(BuildContext context) {
    final TextEditingController weightController = TextEditingController();
    final TextEditingController heightController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
            ),
            const SizedBox(height: 20),
            const Text(
              "Growth Tracker",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF3A7BD5)),
            ),
            const SizedBox(height: 25),
            TextField(
              controller: weightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: "Weight (kg)",
                prefixIcon: const Icon(Icons.monitor_weight_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: heightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: "Height (cm)",
                prefixIcon: const Icon(Icons.height),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3A7BD5),
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: () {
                String w = weightController.text;
                String h = heightController.text;
                Navigator.pop(sheetContext);
                _handleGrowthCheck(context, w, h);
              },
              child: const Text(
                "Check Status",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleGrowthCheck(BuildContext context, String w, String h) async {
    if (w.isEmpty || h.isEmpty) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (loadingContext) => const Center(child: CircularProgressIndicator(color: Colors.white)),
    );
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('user_token');
      final int? childId = prefs.getInt('selected_child_id');

      if (token == null || childId == null) {
        if (context.mounted) Navigator.pop(context);
        _showStatusDialog(context, "Error", "Please select a child first.");
        return;
      }

      final response = await _apiService.addGrowthMeasurement(
        token: token,
        childId: childId,
        weight: double.parse(w),
        height: double.parse(h),
      );

      if (context.mounted) Navigator.pop(context);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (context.mounted) {
          _showStatusDialog(context, "Health Status", "Weight: ${data['weightStatus']}\nHeight: ${data['heightStatus']}");
        }
      } else {
        if (context.mounted) _showStatusDialog(context, "Error", "Failed to process growth data.");
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        _showStatusDialog(context, "Error", "Connection error. Please try again.");
      }
    }
  }

  void _showStatusDialog(BuildContext context, String title, String message) {
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3A7BD5))),
        content: Text(message, style: const TextStyle(fontSize: 16)),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))],
      ),
    );
  }

  Widget _buildCartBadge(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, child) {
        return Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_basket_outlined, color: Colors.white, size: 30),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen())),
              ),
              if (cart.itemCount > 0)
                Positioned(
                  right: 5,
                  top: 5,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                    child: Text(
                      cart.itemCount.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
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
        title: const Text(
          "Nutrition",
          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_outlined, color: Colors.white, size: 28),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const GrowthHistoryScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.scale_outlined, color: Colors.white, size: 28),
            onPressed: () => _showGrowthTrackerSheet(context),
          ),
          _buildCartBadge(context),
        ],
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                _buildCategorySection(context, "Carbs", "Carbohydrates"),
                const SizedBox(height: 18),
                _buildCategorySection(context, "Proteins", "Proteins"),
                const SizedBox(height: 18),
                _buildCategorySection(context, "Vegetables", "Vegetables"),
                const SizedBox(height: 18),
                _buildCategorySection(context, "Fruits", "Fruits"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection(BuildContext context, String endpoint, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 200,
          child: FutureBuilder(
            future: _apiService.fetchFoodByCategory(endpoint),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.white));
              }
              if (snapshot.hasError || !snapshot.hasData || (snapshot.data as List).isEmpty) {
                return const Center(child: Text("No items available", style: TextStyle(color: Colors.white70)));
              }

              final items = snapshot.data as List;

              return ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final food = items[index];
                  return FoodCard(
                    title: food.nameAr,
                    imageAsset: food.imageUrl,
                    calories: food.caloriesPer100g,
                    onTap: () {
                      String uniqueKey = "${endpoint}_${food.id}";

                      Provider.of<CartProvider>(context, listen: false).addItem(
                        uniqueKey,
                        food.nameAr,
                        food.caloriesPer100g.toDouble(),
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Added ${food.nameAr} to plate"),
                          duration: const Duration(seconds: 1),
                          backgroundColor: const Color(0xFF3A7BD5),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}