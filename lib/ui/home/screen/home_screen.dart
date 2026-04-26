import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/AssetsManger/AssetsManger.dart';
import '../tabs/home_tab/home_tab.dart';
import '../tabs/medicine_tab/medicine_tab.dart';
import '../tabs/profile_tab/profile_tab.dart';
import '../tabs/restaurant_tab/restaurant_tab.dart';
import '../../../../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = 'home';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;
  final ApiService _apiService = ApiService();

  late List<Widget> tabs;

  @override
  void initState() {
    super.initState();
    tabs = const [
      HomeTab(),
      MedicineTab(),
      RestaurantTab(),
      ProfileTab(),
    ];
    _setupSelectedChild();
  }

  Future<void> _setupSelectedChild() async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey('selected_child_id')) {
      debugPrint("=== [HOME] Child already in storage: ${prefs.getInt('selected_child_id')} ===");
      return;
    }

    try {
      String? token = prefs.getString('user_token');
      if (token == null) return;

      final response = await _apiService.getParentProfile(token);

      if (response.statusCode == 200) {
        final dynamic rawData = response.data;
        List<dynamic> childrenList = [];

        if (rawData is Map && rawData['children'] != null) {
          childrenList = rawData['children'];
        } else if (rawData is List) {
          childrenList = rawData;
        }

        if (childrenList.isNotEmpty) {
          final firstChild = childrenList[0];
          int id = firstChild['id'];
          String name = firstChild['fullName'] ?? "Unknown";

          await prefs.setInt('selected_child_id', id);
          await prefs.setString('selected_child_name', name);

          debugPrint("=== [HOME] Auto-Selected Child: $name (ID: $id) ===");

          if (mounted) setState(() {});
        } else {
          debugPrint("=== [HOME] Server returned empty children list ===");
        }
      }
    } catch (e) {
      debugPrint("=== [HOME] Auto-Selection Error: $e ===");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: tabs[selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF6EC6FF).withOpacity(0.9),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: AssetsManager.home_unselected,
                selectedIcon: AssetsManager.home_selected,
                isActive: selectedIndex == 0,
                label: "",
                onTap: () => setState(() => selectedIndex = 0),
              ),
              _NavItem(
                icon: AssetsManager.medicine_unselected,
                selectedIcon: AssetsManager.medicine_selected,
                isActive: selectedIndex == 1,
                label: "",
                onTap: () => setState(() => selectedIndex = 1),
              ),
              _NavItem(
                icon: AssetsManager.restaurant_unselected,
                selectedIcon: AssetsManager.restaurant_selected,
                isActive: selectedIndex == 2,
                label: "",
                onTap: () => setState(() => selectedIndex = 2),
              ),
              _NavItem(
                icon: AssetsManager.profile_unselected,
                selectedIcon: AssetsManager.profile_selected,
                isActive: selectedIndex == 3,
                label: "",
                onTap: () => setState(() => selectedIndex = 3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String icon;
  final String selectedIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            isActive ? selectedIcon : icon,
            height: 26,
            width: 26,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}