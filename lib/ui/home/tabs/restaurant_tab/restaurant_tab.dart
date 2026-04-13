import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widget/CartProvider.dart';
import '../../widget/CartScreen.dart';
import '../../widget/food_card.dart';

class RestaurantTab extends StatelessWidget {
  const RestaurantTab({super.key});

  static const Map<String, String> categoryImages = {
    "Carbs": "https://images.unsplash.com/photo-1586201375761-83865001e31c?q=80&w=500",
    "Proteins": "https://images.unsplash.com/photo-1532550907401-a500c9a57435?q=80&w=500",
    "Vegetables": "https://images.unsplash.com/photo-1540420773420-3366772f4999?q=80&w=500",
    "Fruits": "https://images.unsplash.com/photo-1619566636858-adf3ef46400b?q=80&w=500",
  };

  List<String> sampleFoods(String category) {
    return List.generate(6, (i) => "$category Food ${i + 1}");
  }

  // ---------------------------------------------------------
  // دالة إظهار الـ Bottom Sheet لإدخال الوزن والطول
  // ---------------------------------------------------------
  void _showGrowthTrackerSheet(BuildContext context) {
    final TextEditingController weightController = TextEditingController();
    final TextEditingController heightController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // عشان الكيبورد م يغطيش الكلام
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20, // مسافة للكيبورد
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
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Baby Growth Tracker",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3A7BD5),
              ),
            ),
            const SizedBox(height: 10),
            const Text("Enter weight and height to check health status"),
            const SizedBox(height: 25),
            TextField(
              controller: weightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Weight (kg)",
                prefixIcon: const Icon(Icons.monitor_weight_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: heightController,
              keyboardType: TextInputType.number,
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
                // هنا هتعمل الـ Logic بتاع إرسال البيانات للـ API
                String w = weightController.text;
                String h = heightController.text;
                debugPrint("Weight: $w, Height: $h");

                Navigator.pop(context); // قفل الشيت

                // ممكن هنا تظهر Loading لغاية ما الـ API يرد
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
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // أيقونة الـ Growth Tracker الجديدة
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
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            children: [
              categorySection(context, "Carbs", sampleFoods("Carb"), categoryImages["Carbs"]!),
              const SizedBox(height: 18),
              categorySection(context, "Proteins", sampleFoods("Protein"), categoryImages["Proteins"]!),
              const SizedBox(height: 18),
              categorySection(context, "Vegetables", sampleFoods("Veg"), categoryImages["Vegetables"]!),
              const SizedBox(height: 18),
              categorySection(context, "Fruits", sampleFoods("Fruit"), categoryImages["Fruits"]!),
            ],
          ),
        ),
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
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen()));
                },
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

  Widget categorySection(BuildContext context, String title, List<String> items, String imageUrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return FoodCard(
                title: items[index],
                imageAsset: imageUrl,
                onTap: () {
                  Provider.of<CartProvider>(context, listen: false).addItem(
                    items[index],
                    items[index],
                    10.0,
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