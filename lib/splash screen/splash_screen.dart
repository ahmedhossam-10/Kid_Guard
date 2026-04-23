import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kid_guard/ui/home/screen/home_screen.dart';
import 'package:kid_guard/login/Login.dart';
import '../core/AssetsManger/AssetsManger.dart';

class SplashScreen extends StatefulWidget {
  static const String routeName = 'splash';
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // 1. جعل الـ Status Bar شفاف ومتناسق مع الخلفية
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    // 2. إعداد الأنيميشن (الظهور التدريجي)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    _controller.forward();
    _navigateToNext();
  }

  void _navigateToNext() async {
    // انتظار 3 ثواني لعرض الـ Splash
    await Future.delayed(const Duration(seconds: 3));

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('user_token');

    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      Navigator.pushReplacementNamed(context, HomeScreen.routeName);
    } else {
      Navigator.pushReplacementNamed(context, LoginScreen.routeName);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF00D2FF), Color(0xFF3A7BD5)],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- تعديل اللوجو ليكون داخل دائرة احترافية ---
              Container(
                width: 180, // حجم الدائرة
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white, // خلفية بيضاء تحت اللوجو لبروزه
                  border: Border.all(color: Colors.white.withOpacity(0.4), width: 5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    AssetsManager.Logo,
                    fit: BoxFit.cover, // يضمن ملء الدائرة بالكامل
                  ),
                ),
              ),
              // -------------------------------------------

              const SizedBox(height: 30),

              const Text(
                "KidGuard Assistant",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black26,
                      offset: Offset(2.0, 2.0),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 60),

              const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}