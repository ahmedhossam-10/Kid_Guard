import 'package:flutter/material.dart';

class CartItem {
  final String id;
  final String title;
  final double calories;
  int quantity;

  CartItem({
    required this.id,
    required this.title,
    required this.calories,
    this.quantity = 1,
  });
}

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => {..._items};

  int get itemCount => _items.length;

  double get totalCalories {
    double total = 0.0;
    _items.forEach((key, cartItem) {

      total += cartItem.calories * cartItem.quantity;
    });
    return total;
  }

  void addItem(String productId, String title, double caloriesPer100g) {
    if (_items.containsKey(productId)) {
      _items.update(
        productId,
            (existingItem) => CartItem(
          id: existingItem.id,
          title: existingItem.title,
          calories: existingItem.calories,
          quantity: existingItem.quantity + 1,
        ),
      );
    } else {
      _items.putIfAbsent(
        productId,
            () => CartItem(
          id: productId,
          title: title,
          calories: caloriesPer100g,
          quantity: 1,
        ),
      );
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) return;

    if (_items[productId]!.quantity > 1) {
      _items.update(
        productId,
            (existingItem) => CartItem(
          id: existingItem.id,
          title: existingItem.title,
          calories: _items[productId]!.calories,
          quantity: _items[productId]!.quantity - 1,
        ),
      );
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}