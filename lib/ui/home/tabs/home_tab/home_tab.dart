import 'package:flutter/material.dart';

import '../../../ChatBot/screen/ChatBotScreen.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar:
      true, // علشان الخلفية تبان ورا الـ AppBar وتكمل لحد تحت الـ navigation bar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Ahmed",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.message_outlined,
              color: Colors.white,
              size: 28,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatBotScreen()),
              );
            },
          ),
        ],

        iconTheme: const IconThemeData(color: Colors.white),
      ),

      drawer: Drawer(
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // اسم المستخدم والإيميل
              const Text(
                "Ahmed Mohamed",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "ahmed.mohamed@email.com",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),
              const Divider(
                color: Colors.grey,
                thickness: 0.5,
              ),
              const SizedBox(height: 20),

              // أماكن فاضية للقوايم المستقبلية
              ListTile(
                leading: const Icon(Icons.settings, color: Colors.black54),
                title: const Text(
                  "Settings",
                  style: TextStyle(fontSize: 18, color: Colors.black87),
                ),
                onTap: () {
                  // بعدين هنضيف التنقل
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline, color: Colors.black54),
                title: const Text(
                  "About",
                  style: TextStyle(fontSize: 18, color: Colors.black87),
                ),
                onTap: () {},
              ),
              const Spacer(),
              const Divider(thickness: 0.5, color: Colors.grey),
              const SizedBox(height: 10),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                title: const Text(
                  "Logout",
                  style: TextStyle(fontSize: 18, color: Colors.redAccent),
                ),
                onTap: () {
                  // بعدين هنضيف وظيفة تسجيل الخروج
                },
              ),
            ],
          ),
        ),
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Color(0xFF3A7BD5),
              Color(0xFF00D2FF),
            ],
          ),
        ),
        child: SafeArea(
          top: false, // علشان الخلفية تكمل فوق كمان
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // الدايرة الكبيرة
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 25,
                        spreadRadius: 4,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const CircleAvatar(
                    radius: 110, // صغّرناها شويه
                    backgroundColor: Colors.white,
                    child: Text(
                      '😄',
                      style: TextStyle(
                        fontSize: 100,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
                const Text(
                  "Happy",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
