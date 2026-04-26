class FoodModel {
  final int id;
  final String nameAr;
  final int caloriesPer100g;
  final String imageUrl;

  FoodModel({
    required this.id,
    required this.nameAr,
    required this.caloriesPer100g,
    required this.imageUrl,
  });

  factory FoodModel.fromJson(Map<String, dynamic> json) {
    return FoodModel(
      id: json['id'] ?? 0,
      nameAr: json['nameAr'] ?? 'No Name',
      caloriesPer100g: json['caloriesPer100g'] ?? 0,
      imageUrl: json['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nameAr': nameAr,
      'caloriesPer100g': caloriesPer100g,
      'imageUrl': imageUrl,
    };
  }
}