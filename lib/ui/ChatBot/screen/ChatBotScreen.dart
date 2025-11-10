import 'package:flutter/material.dart';

class ChatBotScreen extends StatelessWidget {
  static const String routeName = 'chatBot';

  const ChatBotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Chat Bot",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF3A7BD5),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: const Center(
        child: Text(
          "🤖 Chat Bot Coming Soon...",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
