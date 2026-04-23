import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 1. ضفنا المكتبة هنا
import '../../services/api_service.dart';
import 'Child Info.dart';

class RegisterScreen extends StatefulWidget {
  static const String routeName = 'register';
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isObscured = true;
  final _formKey = GlobalKey<FormState>();

  // 2. دالة حفظ التوكن في ذاكرة الموبايل (نفس اللي عملناها في اللوج إن)
  Future<void> _saveToken(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_token', token);
    debugPrint("=== [STORAGE] Token Saved from Register ===");
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final response = await _apiService.register(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          password: _passwordController.text.trim(),
          age: _ageController.text.trim(),
        );

        debugPrint("Register Response: ${response.data}");

        if (response.statusCode == 200 || response.statusCode == 201) {
          final responseData = response.data is Map ? response.data : {};
          String? userToken = responseData['token']?.toString();

          // 3. حفظ التوكن فوراً
          if (userToken != null) {
            await _saveToken(userToken);
          }

          if (!mounted) return;

          // الانتقال لصفحة الطفل (دلوقتي الـ ChildInfo تقدر تسحبه من الـ Storage لو حبيت)
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChildInfoScreen(token: userToken),
            ),
          );

          _showSnackBar("Account created! Let's add your baby's info.", Colors.green);
        }
      } on DioException catch (e) {
        String errorMsg = "Registration failed";
        if (e.response?.data != null && e.response?.data is Map) {
          final data = e.response!.data as Map<String, dynamic>;
          if (data.containsKey('message')) {
            errorMsg = data['message'].toString();
          } else if (data.containsKey('errors') && data['errors'] is Map) {
            var errors = data['errors'] as Map;
            var firstKey = errors.keys.first;
            errorMsg = (errors[firstKey] is List)
                ? errors[firstKey][0].toString()
                : errors[firstKey].toString();
          }
        }
        _showSnackBar(errorMsg, Colors.redAccent);
      } catch (e) {
        _showSnackBar("Something went wrong", Colors.red);
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  // --- بقية الـ UI كما هو تماماً ---
  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
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
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    const Icon(Icons.person_add_alt_1_rounded, size: 80, color: Colors.white),
                    const SizedBox(height: 15),
                    const Text(
                      "Create Account",
                      style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 30),

                    _buildTextField(
                      controller: _nameController,
                      hint: "Full Name",
                      icon: Icons.person_outline,
                      validator: (val) => (val == null || val.isEmpty) ? "Enter your name" : null,
                    ),
                    const SizedBox(height: 15),

                    _buildTextField(
                      controller: _emailController,
                      hint: "Email Address",
                      icon: Icons.email_outlined,
                      type: TextInputType.emailAddress,
                      validator: (val) => (val == null || !val.contains('@')) ? "Enter a valid email" : null,
                    ),
                    const SizedBox(height: 15),

                    _buildTextField(
                      controller: _phoneController,
                      hint: "Phone Number",
                      icon: Icons.phone_android_outlined,
                      type: TextInputType.phone,
                      validator: (val) => (val == null || val.length < 11) ? "Enter a valid phone number" : null,
                    ),
                    const SizedBox(height: 15),

                    _buildTextField(
                      controller: _ageController,
                      hint: "Father's Age",
                      icon: Icons.calendar_today_outlined,
                      type: TextInputType.number,
                      validator: (val) {
                        if (val == null || val.isEmpty) return "Enter your age";
                        if (int.tryParse(val) == null) return "Enter a valid number";
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),

                    _buildTextField(
                      controller: _passwordController,
                      hint: "Password",
                      icon: Icons.lock_outline,
                      isPassword: true,
                      validator: (val) => (val == null || val.length < 6) ? "Minimum 6 characters" : null,
                    ),
                    const SizedBox(height: 15),

                    _buildTextField(
                      controller: _confirmPasswordController,
                      hint: "Confirm Password",
                      icon: Icons.lock_reset_rounded,
                      isPassword: true,
                      validator: (val) {
                        if (val != _passwordController.text) return "Passwords don't match";
                        return null;
                      },
                    ),

                    const SizedBox(height: 40),

                    ElevatedButton(
                      onPressed: _isLoading ? null : _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF3A7BD5),
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 5,
                      ),
                      child: _isLoading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Color(0xFF3A7BD5), strokeWidth: 2))
                          : const Text("REGISTER", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account?", style: TextStyle(color: Colors.white70)),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Login Now", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextInputType type = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? _isObscured : false,
      keyboardType: type,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white60),
        prefixIcon: Icon(icon, color: Colors.white),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(_isObscured ? Icons.visibility_off : Icons.visibility, color: Colors.white),
          onPressed: () => setState(() => _isObscured = !_isObscured),
        )
            : null,
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        errorStyle: const TextStyle(color: Colors.white),
      ),
      validator: validator,
    );
  }
}