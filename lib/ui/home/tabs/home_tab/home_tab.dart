import 'dart:io';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../services/api_service.dart';
import '../../../ChatBot/screen/ChatBotScreen.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with SingleTickerProviderStateMixin {
  final AudioRecorder _recorder = AudioRecorder();
  bool isRecording = false;
  bool isUploading = false;
  String? audioPath;
  late AnimationController _animationController;

  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
      lowerBound: 1.0,
      upperBound: 1.15,
    )..repeat(reverse: true);
  }

  Future<void> _makeEmergencyCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        debugPrint("Could not launch $launchUri");
      }
    } catch (e) {
      debugPrint("Error launching dialer: $e");
    }
  }

  Future<void> toggleRecording() async {
    if (isRecording) {
      final path = await _recorder.stop();
      setState(() {
        isRecording = false;
        audioPath = path;
      });
      _animationController.stop();
      _animationController.value = 1.0;

      if (audioPath != null) {
        setState(() => isUploading = true);
        try {
          final result = await _apiService.uploadAudioFile(audioPath!);
          debugPrint("Full API Response: $result");
          if (!mounted) return;
          _showResultDialog(result);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("An error occurred during connection: $e")),
          );
        } finally {
          setState(() => isUploading = false);
        }
      }
    } else {
      var status = await Permission.microphone.request();
      if (!status.isGranted) return;

      final dir = await getTemporaryDirectory();
      final filePath = "${dir.path}/record_${DateTime.now().millisecondsSinceEpoch}.wav";

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 44100,
          numChannels: 1,
          bitRate: 128000,
        ),
        path: filePath,
      );

      setState(() => isRecording = true);
      _animationController.repeat(reverse: true);
    }
  }

  void _showResultDialog(Map<String, dynamic> result) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Analysis Result", textAlign: TextAlign.center),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.baby_changing_station, size: 60, color: Colors.blue),
              const SizedBox(height: 15),
              Text(
                "Status: ${result['result']?.toString().toUpperCase() ?? 'Unknown'}",
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              if (result['confidence'] != null)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "Confidence Percentage: ${(result['confidence'] * 100).toStringAsFixed(1)}%",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                )
              else
                const Text("Confidence Percentage: Not Available"),
            ],
          ),
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              onPressed: () => Navigator.pop(context),
              child: const Text("OK", style: TextStyle(color: Colors.white)),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _recorder.dispose();
    super.dispose();
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
          "Kid Guard",
          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone, color: Colors.red, size: 28),
            onPressed: () => _makeEmergencyCall("123"),
          ),

          IconButton(
            icon: const Icon(Icons.message_outlined, color: Colors.white, size: 28),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ChatBotScreen()),
            ),
          ),
          const SizedBox(width: 8),
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
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: isUploading ? null : toggleRecording,
                  child: ScaleTransition(
                    scale: _animationController,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isRecording ? Colors.redAccent : Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: isRecording ? Colors.red.withOpacity(0.6) : Colors.black26,
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 110,
                        backgroundColor: Colors.transparent,
                        child: isUploading
                            ? const CircularProgressIndicator(color: Color(0xFF3A7BD5), strokeWidth: 6)
                            : Icon(
                          isRecording ? Icons.mic : Icons.mic_none,
                          size: 100,
                          color: isRecording ? Colors.white : const Color(0xFF3A7BD5),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  isUploading ? "Loading.." : (isRecording ? "Listening" : "click to start"),
                  style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}