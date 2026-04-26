class DailyMealPlan {
  final String advice;
  final List<Meal> breakfast;
  final List<Meal> lunch;
  final List<Meal> dinner;

  DailyMealPlan({required this.advice, required this.breakfast, required this.lunch, required this.dinner});

  factory DailyMealPlan.fromJson(Map<String, dynamic> json) {
    var parseMeal = (List? list) => list?.map((m) => Meal.fromJson(m)).toList() ?? [];
    return DailyMealPlan(
      advice: json['medicalAdvice'] ?? "",
      breakfast: parseMeal(json['breakfast']),
      lunch: parseMeal(json['lunch']),
      dinner: parseMeal(json['dinner']),
    );
  }
}

class Meal {
  final String name;
  final String description;
  final String imageUrl;

  Meal({required this.name, required this.description, required this.imageUrl});

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      name: json['name'] ?? "",
      description: json['description'] ?? "",
      imageUrl: json['imageUrl'] ?? "",
    );
  }
}