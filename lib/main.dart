import 'package:flutter/material.dart';
import 'package:kid_guard/ui/home/widget/CartProvider.dart';
import 'package:provider/provider.dart';

import 'package:kid_guard/ui/home/screen/home_screen.dart';
import 'package:kid_guard/ui/vaccine/screen/vaccine_screen.dart';


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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        useMaterial3: true,
      ),
      initialRoute: HomeScreen.routeName,
      routes: {
        HomeScreen.routeName: (_) => const HomeScreen(),
        VaccinesScreen.routeName: (_) => const VaccinesScreen(),
      },
    );
  }
}
