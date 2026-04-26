import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../login/Login.dart';
import '../../../../register/Child Info.dart';
import '../../../../services/api_service.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});
  static const String routeName = 'profileTab';

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final ApiService _apiService = ApiService();

  Map<String, dynamic>? userData;
  List<dynamic> childrenList = [];
  bool isLoading = true;
  String? _userToken;
  int? selectedChildId;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      _userToken = prefs.getString('user_token');
      selectedChildId = prefs.getInt('selected_child_id');

      if (_userToken == null || _userToken!.isEmpty) {
        _logout();
        return;
      }

      final response = await _apiService.getParentProfile(_userToken!)
          .timeout(const Duration(seconds: 12));

      if (!mounted) return;

      if (response.statusCode == 200 && response.data != null) {
        setState(() {
          userData = response.data;
          childrenList = response.data['children'] ?? [];

          bool childExists = childrenList.any((child) => child['id'] == selectedChildId);

          if ((selectedChildId == null || !childExists) && childrenList.isNotEmpty) {
            _saveSelectedChild(childrenList[0]['id'], childrenList[0]['fullName'] ?? "Child", silent: true);
          }
        });
      } else if (response.statusCode == 401) {
        _logout();
      } else {
        _showSnackBar("Server Error");
      }
    } on TimeoutException {
      _showSnackBar("Connection timed out. Pull down to retry.");
    } catch (e) {
      _showSnackBar("Failed to load profile data.");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _saveSelectedChild(int childId, String childName, {bool silent = false}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selected_child_id', childId);
    await prefs.setString('selected_child_name', childName);

    if (!mounted) return;
    setState(() {
      selectedChildId = childId;
    });

    if (!silent) {
      _showSnackBar("Selected: $childName");
    }
  }

  Future<void> _handlePhoneUpdate(String newPhone) async {
    setState(() => isLoading = true);
    try {
      final response = await _apiService.changePhoneNumber(_userToken!, newPhone)
          .timeout(const Duration(seconds: 15));

      if (!mounted) return;

      if (response.statusCode == 200) {
        _showSnackBar("Phone updated successfully");
        await _fetchProfileData();
      } else {
        _showSnackBar("Update failed");
        setState(() => isLoading = false);
      }
    } catch (e) {
      _showSnackBar("Connection error");
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _handlePasswordUpdate(String oldP, String newP, String confirmP) async {
    setState(() => isLoading = true);
    try {
      final response = await _apiService.changePassword(
        token: _userToken!,
        oldPassword: oldP,
        newPassword: newP,
        confirmPassword: confirmP,
      ).timeout(const Duration(seconds: 15));

      if (!mounted) return;

      if (response.statusCode == 200) {
        _showSnackBar("Password changed successfully");
      } else {
        _showSnackBar("Failed to update password");
      }
    } catch (e) {
      _showSnackBar("Error connecting to server");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _handleDelete(int id) async {
    setState(() => isLoading = true);
    try {
      final response = await _apiService.deleteChild(_userToken!, id);
      if (response.statusCode == 200 || response.statusCode == 204) {
        if (selectedChildId == id) {
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.remove('selected_child_id');
          await prefs.remove('selected_child_name');
          selectedChildId = null;
        }
        await _fetchProfileData();
        _showSnackBar("Deleted successfully");
      }
    } catch (e) {
      _showSnackBar("Failed to delete child");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, LoginScreen.routeName, (route) => false);
  }

  void _showChangePhoneDialog() {
    final TextEditingController phoneController = TextEditingController(text: userData?['parentPhone']);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Update Phone Number"),
        content: TextField(
          controller: phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(labelText: "New Phone Number", hintText: "01xxxxxxxxx"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (phoneController.text.isNotEmpty) {
                Navigator.pop(context);
                _handlePhoneUpdate(phoneController.text);
              }
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final oldPass = TextEditingController();
    final newPass = TextEditingController();
    final confirmPass = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Change Password"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: oldPass, obscureText: true, decoration: const InputDecoration(labelText: "Old Password")),
              TextField(controller: newPass, obscureText: true, decoration: const InputDecoration(labelText: "New Password")),
              TextField(controller: confirmPass, obscureText: true, decoration: const InputDecoration(labelText: "Confirm Password")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (newPass.text == confirmPass.text && newPass.text.isNotEmpty) {
                Navigator.pop(context);
                _handlePasswordUpdate(oldPass.text, newPass.text, confirmPass.text);
              } else {
                _showSnackBar("Passwords don't match");
              }
            },
            child: const Text("Change"),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(int id, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Delete Child"),
        content: Text("Are you sure you want to delete $name?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _handleDelete(id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : SafeArea(
          child: RefreshIndicator(
            onRefresh: _fetchProfileData,
            color: const Color(0xFF3A7BD5),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Profile", style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
                      IconButton(onPressed: _logout, icon: const Icon(Icons.logout, color: Colors.white, size: 28)),
                    ],
                  ),
                  const SizedBox(height: 30),
                  _buildSectionTitle("Parent Information"),
                  const SizedBox(height: 15),
                  _buildGlassInfoCard(Icons.person, "Name", userData?['parentName'] ?? "N/A"),
                  _buildGlassInfoCard(Icons.email, "Email", userData?['parentEmail'] ?? "N/A"),
                  _buildGlassInfoCard(
                    Icons.phone,
                    "Phone",
                    userData?['parentPhone'] ?? "N/A",
                    trailing: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white70, size: 20),
                      onPressed: _showChangePhoneDialog,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: _showChangePasswordDialog,
                      icon: const Icon(Icons.lock_outline, color: Colors.white, size: 18),
                      label: const Text("Change Password", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionTitle("Children"),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ChildInfoScreen(token: _userToken)),
                          ).then((_) { if (mounted) _fetchProfileData(); });
                        },
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text("Add", style: TextStyle(color: Colors.white)),
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  childrenList.isEmpty
                      ? const Text("No children added yet", style: TextStyle(color: Colors.white70))
                      : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: childrenList.length,
                    itemBuilder: (context, index) {
                      final child = childrenList[index];
                      return _buildChildCard(
                        id: child['id'],
                        name: child['fullName'] ?? "Unknown",
                        gender: child['gender'] ?? "Boy",
                        isSelected: selectedChildId == child['id'],
                        onTap: () => _saveSelectedChild(child['id'], child['fullName'] ?? "Unknown"),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChildCard({required int id, required String name, required String gender, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(15),
          border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: isSelected ? const Color(0xFF3A7BD5) : Colors.white24,
              child: Icon(
                  gender.toLowerCase() == "boy" ? Icons.boy : Icons.girl,
                  color: isSelected ? Colors.white : Colors.white70
              ),
            ),
            const SizedBox(width: 15),
            Text(
                name,
                style: TextStyle(
                    color: isSelected ? const Color(0xFF3A7BD5) : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18
                )
            ),
            const Spacer(),
            IconButton(
              icon: Icon(Icons.delete_outline, color: isSelected ? Colors.red : Colors.white70),
              onPressed: () => _confirmDelete(id, name),
            ),
            if (isSelected) const Icon(Icons.check_circle, color: Color(0xFF3A7BD5)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
        alignment: Alignment.centerLeft,
        child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))
    );
  }

  Widget _buildGlassInfoCard(IconData icon, String label, String value, {Widget? trailing}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 24),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
                Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3A7BD5))),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
        width: 250,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}