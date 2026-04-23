import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

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

  // ================= Auth Methods =================

  Future<Response> login(String email, String password) async {
    try {
      return await _dio.post('Auth/login', data: {
        'EmailOrPhone': email,
        'Password': password,
      });
    } catch (e) {
      debugPrint("Login Error: $e");
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
      debugPrint("Register Error: $e");
      rethrow;
    }
  }

  // --- دالة تغيير رقم الهاتف (التعديل النهائي للـ Key والـ Method) ---
  Future<Response> changePhoneNumber(String token, String newPhone) async {
    try {
      return await _dio.put(
        'Auth/change-phone',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${token.trim()}',
            'Accept': 'application/json',
          },
        ),
        data: {
          'newPhoneNumber': newPhone, // تم التعديل هنا ليطابق طلب السيرفر
        },
      );
    } catch (e) {
      debugPrint("Change Phone Error: $e");
      rethrow;
    }
  }

  // --- دالة تغيير كلمة المرور ---
  Future<Response> changePassword({
    required String token,
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      return await _dio.put(
        'Auth/change-password',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${token.trim()}',
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'oldPassword': oldPassword,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        },
      );
    } catch (e) {
      debugPrint("Change Password Error: $e");
      rethrow;
    }
  }

  // ================= Children & Profile Methods =================

  Future<Response> getParentProfile(String token) async {
    try {
      final String cleanToken = token.trim();
      return await _dio.get(
        'Children/my-children',
        options: Options(
          headers: {
            'Authorization': 'Bearer $cleanToken',
            'Accept': 'application/json',
          },
        ),
      );
    } catch (e) {
      debugPrint("Get Profile API Error: $e");
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
      final String cleanToken = token.trim();
      String shortDate = birthDate.contains('T') ? birthDate.split('T')[0] : birthDate;

      return await _dio.post(
        'Children/add',
        options: Options(
          headers: {
            'Authorization': 'Bearer $cleanToken',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
        data: {
          "fullName": name,
          "dateOfBirth": shortDate,
          "gender": gender,
        },
      );
    } catch (e) {
      debugPrint("Add Child API Error: $e");
      rethrow;
    }
  }

  Future<Response> deleteChild(String token, int childId) async {
    try {
      final String cleanToken = token.trim();
      return await _dio.delete(
        'Children/delete/$childId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $cleanToken',
            'Accept': 'application/json',
          },
        ),
      );
    } catch (e) {
      debugPrint("Delete Child API Error: $e");
      rethrow;
    }
  }

  // ================= AI Methods =================

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
      debugPrint("Audio Upload Error: $e");
      rethrow;
    }
  }

  Future<String> getChatResponse(String message) async {
    const String url = "https://mohammedelhakim-chatbot-2.hf.space/chat";
    try {
      final response = await _dio.post(url, data: {"message": message});
      return response.data['response'] ?? "No response from bot";
    } catch (e) {
      debugPrint("Chatbot Error: $e");
      return "I'm having trouble connecting to my brain right now!";
    }
  }
}