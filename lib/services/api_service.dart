import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio;

  ApiService({Dio? dio}) : _dio = dio ?? Dio();

  // 1. دالة الـ Cry Detection (الموجودة مسبقاً)
  Future<Map<String, dynamic>> uploadAudioFile(String filePath) async {
    const String url = "https://mohammedelhakim-kidguard-crydetection-cryclassification.hf.space/predict";

    final formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(
        filePath,
        filename: filePath.split('/').last,
        contentType: DioMediaType('audio', 'wav'),
      ),
    });

    try {
      final response = await _dio.post(
        url,
        data: formData,
        queryParameters: {
          "detection_threshold": "0.212",
          "classification_threshold": "0.6",
        },
      );
      return response.data;
    } on DioException catch (e) {
      print("Audio Upload Error: ${e.response?.data}");
      rethrow;
    }
  }

  // 2. دالة الـ ChatBot (Hugging Face)
  Future<String> getChatResponse(String message) async {
    const String url = "https://mohammedelhakim-chatbot-2.hf.space/chat";

    try {
      final response = await _dio.post(
        url,
        data: {"message": message}, // تأكد من المفتاح المطلوب في الـ API بتاعك
      );

      // هنا بنرجع الرد، غالباً بيكون data['response'] أو حسب الـ JSON اللي راجع
      return response.data['response'] ?? "No response from bot";
    } on DioException catch (e) {
      print("ChatBot Error: ${e.message}");
      return "Sorry, I'm having trouble connecting.";
    }
  }

  // 3. دالة الـ Growth Tracker (الوزن والطول)
  Future<Map<String, dynamic>> checkGrowthStatus(double weight, double height) async {
    // حط هنا رابط الـ API الخاص بالوزن والطول لما تجهزه
    const String url = "YOUR_GROWTH_API_URL_HERE";

    try {
      final response = await _dio.post(
        url,
        data: {
          "weight": weight,
          "height": height,
        },
      );
      return response.data;
    } on DioException catch (e) {
      print("Growth Tracker Error: ${e.message}");
      rethrow;
    }
  }
}