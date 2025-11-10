import 'package:flutter/material.dart';
import '../../widget/food_card.dart';

class RestaurantTab extends StatelessWidget {
  const RestaurantTab({super.key});

  List<String> sampleFoods(String category) {
    return List.generate(
        6, (i) => "$category Food ${i + 1}"); // Food names placeholder
  }

  @override
  Widget build(BuildContext context) {
    const placeholder = 'assets/image/food_placeholder.png';

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
            shadows: [Shadow(color: Colors.black26, blurRadius: 6)],
          ),
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
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  children: [
                    // Helper to build each category section
                    categorySection("Carbs", sampleFoods("Carb"), placeholder),
                    const SizedBox(height: 18),
                    categorySection("Proteins", sampleFoods("Protein"), placeholder),
                    const SizedBox(height: 18),
                    categorySection("Vegetables", sampleFoods("Veg"), placeholder),
                    const SizedBox(height: 18),
                    categorySection("Fruits", sampleFoods("Fruit"), placeholder),
                    const SizedBox(height: 12),
                    const SizedBox(height: 8),
                    // فاصل قبل ال dashboard
                    const SizedBox(height: 8),
                  ],
                ),
              ),

              // Dashboard (UI only) — يعرض العناصر المختارة (مؤقت)
              Container(
                width: double.infinity,
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, -3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Dashboard (Selected)",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // مثال عناصر مختارة ثابتة (UI only)
                    Row(
                      children: [
                        Expanded(
                          child: selectedFoodTile("Rice", "100 g", "130 kcal"),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: selectedFoodTile("Chicken", "100 g", "165 kcal"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // زر إجرائي (مؤقت)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            // لاحقًا: تفتح صفحة تفصيلية للحسابات
                          },
                          child: const Text(
                            "View details",
                            style: TextStyle(
                                color: Color(0xFF3A7BD5),
                                fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // يبني كل قسم تصنيف (عنوان + افقي list)
  Widget categorySection(
      String title, List<String> items, String placeholderImage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // heading
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 10),

        // horizontal list
        SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return FoodCard(
                title: items[index],
                imageAsset: placeholderImage,
                onTap: () {
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget selectedFoodTile(String name, String qty, String kcal) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 6),
          Text(qty, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 6),
          Text(kcal,
              style:
              const TextStyle(color: Colors.black54, fontSize: 12)),
        ],
      ),
    );
  }
}
