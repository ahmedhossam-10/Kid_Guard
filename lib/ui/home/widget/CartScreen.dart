import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widget/CartProvider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
            "Daily Nutrition Plate",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          if (cart.items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep, color: Colors.red),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text("Clear Plate?"),
                    content: const Text("Do you want to remove all items from your plate?"),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("No")),
                      TextButton(
                          onPressed: () {
                            cart.clear();
                            Navigator.pop(ctx);
                          },
                          child: const Text("Yes", style: TextStyle(color: Colors.red))
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: cart.items.isEmpty
          ? _buildEmptyState()
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cart.items.length,
              itemBuilder: (context, index) {
                final item = cart.items.values.toList()[index];
                final productId = cart.items.keys.toList()[index];

                return _buildCartItem(
                  context,
                  productId,
                  item.title,
                  item.quantity,
                  item.calories,
                );
              },
            ),
          ),
          _buildTotalSection(cart, context),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant_menu_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            "Your plate is empty",
            style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w500),
          ),
          const Text(
            "Add some healthy food to start tracking",
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalSection(CartProvider cart, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -2))
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total Calories:", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
              Text(
                "${cart.totalCalories.toStringAsFixed(0)} kcal",
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF3A7BD5)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total Items Selected:", style: TextStyle(fontSize: 14, color: Colors.grey)),
              Text(
                  "${cart.items.length} types (${_getTotalQty(cart)} units)",
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3A7BD5),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Daily intake confirmed!"))
                );
                Navigator.pop(context);
              },
              child: const Text(
                  "Confirm Daily Intake",
                  style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _getTotalQty(CartProvider cart) {
    int total = 0;
    cart.items.forEach((key, item) => total += item.quantity);
    return total;
  }

  Widget _buildCartItem(BuildContext context, String id, String name, int qty, double caloriesPerUnit) {
    final cart = Provider.of<CartProvider>(context, listen: false);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
                "${qty}x",
                style: const TextStyle(color: Color(0xFF1976D2), fontWeight: FontWeight.bold, fontSize: 16)
            ),
          ),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text("${caloriesPerUnit.toStringAsFixed(0)} kcal per 100g"),
            Text(
              "Subtotal: ${(caloriesPerUnit * qty).toStringAsFixed(0)} kcal",
              style: const TextStyle(color: Color(0xFF3A7BD5), fontWeight: FontWeight.w600),
            ),
          ],
        ),
        trailing: Wrap(
          spacing: 8,
          children: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: Colors.green, size: 26),
              onPressed: () => cart.addItem(id, name, caloriesPerUnit),
            ),
            IconButton(
              icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 26),
              onPressed: () => cart.removeSingleItem(id),
            ),
          ],
        ),
      ),
    );
  }
}