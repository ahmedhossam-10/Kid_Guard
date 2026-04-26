import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../ui/DailyMealPlan/widget/DailyMealPlan.dart';
import '../ui/home/widget/MedicalItem.dart';
import '../ui/home/widget/food_model.dart';
import '../ui/home/widget/VaccinationModel.dart';

class ApiService {
  final Dio _dio;

  ApiService({Dio? dio}) : _dio = dio ?? Dio(
    BaseOptions(
      baseUrl: 'http://kidguard.runasp.net/api/',
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      validateStatus: (status) => status != null && status < 500,
    ),
  );

  Options _getOptions(String? token) {
    return Options(
      headers: {
        if (token != null) 'Authorization': 'Bearer ${token.trim()}',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );
  }


  Future<DailyMealPlan?> getDailyMealSuggestions(int childId, String token) async {
    try {
      final response = await _dio.get(
        'Nutrition/daily-meals/$childId',
        options: _getOptions(token),
      );
      if (response.statusCode == 200 && response.data != null) {
        return DailyMealPlan.fromJson(response.data);
      }
      return null;
    } catch (e) {
      debugPrint("Error fetching daily meal suggestions: $e");
      return null;
    }
  }

  Future<List<FoodModel>> fetchFoodByCategory(String category) async {
    try {
      final response = await _dio.get(category);
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((json) => FoodModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint("Error fetching $category: $e");
      return [];
    }
  }


  Future<List<MedicalItem>> getMedicalHistory(int childId, String token) async {
    try {
      final response = await _dio.get(
        'MedicalHistory/child-archive/$childId',
        options: _getOptions(token),
      );

      if (response.statusCode == 200 && response.data != null) {
        List<dynamic> data = response.data;
        return data.map((json) => MedicalItem.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint("Error fetching medical history: $e");
      return [];
    }
  }

  Future<List<VaccinationModel>> fetchVaccinations(String token, int childId) async {
    try {
      final response = await _dio.get(
        'Children/$childId/vaccinations',
        options: _getOptions(token),
      );

      if (response.statusCode == 200 && response.data != null) {
        List<dynamic> data = response.data;
        return data.map((json) => VaccinationModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint("Error fetching vaccinations: $e");
      return [];
    }
  }

  Future<Response> updateVaccineStatus(String token, int vaccineId, bool isUsed) async {
    try {
      return await _dio.patch(
        'Children/update-status/$vaccineId',
        queryParameters: {'isUsed': isUsed},
        options: _getOptions(token),
      );
    } catch (e) {
      debugPrint("Error updating vaccine status: $e");
      rethrow;
    }
  }


  Future<Response> login(String email, String password) async {
    try {
      return await _dio.post('Auth/login', data: {
        'EmailOrPhone': email,
        'Password': password,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String age,
  }) async {
    try {
      return await _dio.post('Auth/register', data: {
        'FullName': name,
        'Email': email,
        'PhoneNumber': phone,
        'Password': password,
        'Age': int.tryParse(age) ?? 0,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> changePassword({
    required String token,
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      return await _dio.put(
        'Auth/change-password',
        options: _getOptions(token),
        data: {
          'oldPassword': oldPassword,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> changePhoneNumber(String token, String newPhone) async {
    try {
      return await _dio.put(
        'Auth/change-phone',
        options: _getOptions(token),
        data: {'newPhoneNumber': newPhone},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getParentProfile(String token) async {
    try {
      return await _dio.get('Children/my-children', options: _getOptions(token));
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> addChild({
    required String token,
    required String name,
    required String birthDate,
    required String gender,
  }) async {
    try {
      return await _dio.post(
        'Children/add',
        options: _getOptions(token),
        data: {"fullName": name, "dateOfBirth": birthDate, "gender": gender},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> deleteChild(String token, int childId) async {
    try {
      return await _dio.delete('Children/delete/$childId', options: _getOptions(token));
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getChildMedications(String token, int childId) async {
    try {
      return await _dio.get(
        'Children/$childId/medications',
        options: _getOptions(token),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> addMedication({
    required String token,
    required Map<String, dynamic> medicationData,
  }) async {
    try {
      return await _dio.post(
        'Medications/add',
        options: _getOptions(token),
        data: medicationData,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> updateMedication({
    required String token,
    required int medicationId,
    required Map<String, dynamic> medicationData,
  }) async {
    try {
      return await _dio.put(
        'Medications/update/$medicationId',
        options: _getOptions(token),
        data: medicationData,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> deleteMedication(String token, int medicationId) async {
    try {
      return await _dio.delete(
        'Medications/delete/$medicationId',
        options: _getOptions(token),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> uploadAudioFile(String filePath) async {
    const String url = "https://mohammedelhakim-kidguard-crydetection-cryclassification.hf.space/predict";
    try {
      final formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(
          filePath,
          filename: filePath.split('/').last,
          contentType: DioMediaType('audio', 'wav'),
        ),
      });
      final response = await _dio.post(url, data: formData, queryParameters: {
        "detection_threshold": "0.212",
        "classification_threshold": "0.6",
      });
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> getChatResponse(String message) async {
    const String url = "https://mohammedelhakim-chatbot-2.hf.space/chat";
    try {
      final response = await _dio.post(url, data: {"message": message});
      return response.data['response'] ?? "No response from bot";
    } catch (e) {
      return "Connection error. Please try again later.";
    }
  }

  Future<Response> addGrowthMeasurement({
    required String token,
    required int childId,
    required double weight,
    required double height,
  }) async {
    try {
      return await _dio.post(
        'Growth/$childId/add-measurement',
        options: _getOptions(token),
        data: {"weight": weight, "height": height},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getGrowthHistory(String token, int childId) async {
    try {
      return await _dio.get(
        'Growth/$childId/history',
        options: _getOptions(token),
      );
    } catch (e) {
      rethrow;
    }
  }
}