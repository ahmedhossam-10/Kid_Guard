import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kid_guard/ui/home/screen/home_screen.dart';
import '../../services/api_service.dart';

class ChildInfoScreen extends StatefulWidget {
  static const String routeName = 'child-info';
  final String? token;

  const ChildInfoScreen({super.key, this.token});

  @override
  State<ChildInfoScreen> createState() => _ChildInfoScreenState();
}

class _ChildInfoScreenState extends State<ChildInfoScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _nameController = TextEditingController();
  DateTime? _selectedDate;
  String _gender = "Boy";
  bool _isLoading = false;

  void _finishSetup() async {
    if (_isLoading) return;

    if (_nameController.text.trim().isEmpty || _selectedDate == null) {
      _showSnackBar("Please enter baby's name and birth date", Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? finalToken = widget.token ?? prefs.getString('user_token');

      if (finalToken == null || finalToken.isEmpty) {
        _showSnackBar("Session error, please login again", Colors.redAccent);
        return;
      }

      String formattedDate = _selectedDate!.toIso8601String();

      final response = await _apiService.addChild(
        token: finalToken.trim(),
        name: _nameController.text.trim(),
        birthDate: formattedDate,
        gender: _gender,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;

        int newChildId = responseData['childId'];
        String newChildName = responseData['childname'];

        await prefs.setInt('selected_child_id', newChildId);
        await prefs.setString('selected_child_name', newChildName);

        if (!mounted) return;
        _showSnackBar(responseData['message'] ?? "Profile Created Successfully!", Colors.green);

        Navigator.pushNamedAndRemoveUntil(
          context,
          HomeScreen.routeName,
              (route) => false,
        );
      } else if (response.statusCode == 401) {
        _showSnackBar("Unauthorized (401). Please login again.", Colors.redAccent);
      } else {
        _showSnackBar("Error: ${response.statusCode}", Colors.redAccent);
      }
    } on DioException catch (e) {
      String message = "Connection error";
      if (e.response?.statusCode == 401) message = "Session expired, login again";
      _showSnackBar(message, Colors.redAccent);
    } catch (e) {
      _showSnackBar("An unexpected error occurred", Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF00D2FF), Color(0xFF3A7BD5)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.child_care_rounded, size: 100, color: Colors.white),
                  const SizedBox(height: 20),
                  const Text("Baby's Profile",
                      style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 40),
                  TextFormField(
                    controller: _nameController,
                    enabled: !_isLoading,
                    style: const TextStyle(color: Colors.white),
                    decoration: _buildInputDecoration("Child's Name", Icons.person_outline),
                  ),
                  const SizedBox(height: 20),
                  InkWell(
                    onTap: _isLoading ? null : _presentDatePicker,
                    borderRadius: BorderRadius.circular(15),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined, color: Colors.white),
                          const SizedBox(width: 15),
                          Text(
                            _selectedDate == null
                                ? "Date of Birth"
                                : "${_selectedDate!.day} / ${_selectedDate!.month} / ${_selectedDate!.year}",
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(child: _buildGenderCard("Boy", Icons.male)),
                      const SizedBox(width: 15),
                      Expanded(child: _buildGenderCard("Girl", Icons.female)),
                    ],
                  ),
                  const SizedBox(height: 60),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _finishSetup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF3A7BD5),
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 5,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF3A7BD5)))
                        : const Text("FINISH SETUP", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _presentDatePicker() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) setState(() => _selectedDate = pickedDate);
  }

  Widget _buildGenderCard(String type, IconData icon) {
    bool isSelected = _gender == type;
    return GestureDetector(
      onTap: _isLoading ? null : () => setState(() => _gender = type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? const Color(0xFF3A7BD5) : Colors.white, size: 30),
            Text(type,
                style: TextStyle(
                    color: isSelected ? const Color(0xFF3A7BD5) : Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white60),
      prefixIcon: Icon(icon, color: Colors.white),
      filled: true,
      fillColor: Colors.white.withOpacity(0.2),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
    );
  }
}