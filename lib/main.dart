import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kid_guard/splash%20screen/splash_screen.dart';
import 'package:kid_guard/login/Login.dart';
import 'package:kid_guard/register/register.dart';
import 'package:kid_guard/register/Child%20Info.dart';
import 'package:kid_guard/ui/home/screen/home_screen.dart';
import 'package:kid_guard/ui/home/widget/MedicalHistory.dart';
import 'package:kid_guard/ui/vaccine/screen/vaccine_screen.dart';
import 'package:kid_guard/ui/home/widget/CartProvider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

      initialRoute: SplashScreen.routeName,

      routes: {
        SplashScreen.routeName: (_) => const SplashScreen(),
        LoginScreen.routeName: (_) => const LoginScreen(),
        RegisterScreen.routeName: (_) => const RegisterScreen(),

        ChildInfoScreen.routeName: (context) {
          final args = ModalRoute.of(context)?.settings.arguments as String?;
          return ChildInfoScreen(token: args);
        },

        HomeScreen.routeName: (_) => const HomeScreen(),


        VaccinesScreen.routeName: (_) => const VaccinesScreen(),

        '/medical-history': (_) => const MedicalHistoryScreen(),
      },

      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (context) => const LoginScreen());
      },
    );
  }
}