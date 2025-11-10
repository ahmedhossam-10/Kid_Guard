import 'package:flutter/material.dart';

class FoodCard extends StatelessWidget {
  final String title;
  final String imageAsset; // placeholder الآن، بعدين هتتبعت من API
  final VoidCallback? onTap;

  const FoodCard({
    super.key,
    required this.title,
    required this.imageAsset,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 140,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // صورة الأكل
            Container(
              height: 100,
              width: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
                color: Colors.white,
              ),
              clipBehavior: Clip.hardEdge,
              child: Image.asset(
                imageAsset,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(Icons.fastfood, size: 40, color: Colors.grey),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // اسم الأكلة
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
