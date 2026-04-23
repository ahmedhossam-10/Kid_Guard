import 'package:flutter/material.dart';
import 'package:kid_guard/splash%20screen/splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:kid_guard/register/Child%20Info.dart';
import 'package:kid_guard/register/register.dart';
import 'package:kid_guard/ui/home/screen/home_screen.dart';
import 'package:kid_guard/ui/vaccine/screen/vaccine_screen.dart';
import 'package:kid_guard/login/Login.dart';

// Providers
import 'package:kid_guard/ui/home/widget/CartProvider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => CartProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kid Guard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00D2FF),
          primary: const Color(0xFF3A7BD5),
        ),
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),

      // 2. تغيير البداية لتكون من الـ Splash
      initialRoute: SplashScreen.routeName,

      routes: {
        SplashScreen.routeName: (_) => const SplashScreen(), // 3. إضافة الـ Route الجديد
        LoginScreen.routeName: (_) => const LoginScreen(),
        RegisterScreen.routeName: (_) => const RegisterScreen(),

        // تعديل بسيط هنا: لو احتجنا نفتحها بـ Named Route مع Arguments
        ChildInfoScreen.routeName: (context) {
          final args = ModalRoute.of(context)?.settings.arguments as String?;
          return ChildInfoScreen(token: args);
        },

        HomeScreen.routeName: (_) => const HomeScreen(),
        VaccinesScreen.routeName: (_) => const VaccinesScreen(),
      },

      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (context) => const LoginScreen());
      },
    );
  }
}