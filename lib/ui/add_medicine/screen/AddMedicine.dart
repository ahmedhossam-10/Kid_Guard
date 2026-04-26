import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../services/api_service.dart';

class AddMedicine extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  const AddMedicine({super.key, this.initialData});

  @override
  State<AddMedicine> createState() => _AddMedicinePageState();
}

class _AddMedicinePageState extends State<AddMedicine> {
  final ApiService _apiService = ApiService();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController doseController = TextEditingController();
  final TextEditingController descController = TextEditingController();

  int dosesPerDay = 1;
  List<TimeOfDay?> selectedTimes = <TimeOfDay?>[null];
  List<String> selectedDays = [];
  bool isLoading = false;

  final List<String> allDays = [
    "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      final data = widget.initialData!;
      nameController.text = data["medicationName"] ?? "";
      doseController.text = data["dosage"]?.toString() ?? "";
      descController.text = data["description"] ?? "";
      selectedDays = List<String>.from(data["activeDays"] ?? []);

      List schedules = data["schedules"] ?? [];
      if (schedules.isNotEmpty) {
        dosesPerDay = schedules.length;
        selectedTimes = schedules.map<TimeOfDay?>((s) {
          String time = s["scheduledTime"];
          final parts = time.split(':');
          return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
        }).toList();
      }
    }
  }

  void pickTime(int index) async {
    if (index >= selectedTimes.length) return;

    final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: selectedTimes[index] ?? TimeOfDay.now()
    );
    if (time != null) setState(() => selectedTimes[index] = time);
  }

  void pickDaysPopup() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setPop) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text("Select Days", style: TextStyle(fontWeight: FontWeight.bold)),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView(
                  shrinkWrap: true,
                  children: allDays.map((day) {
                    final isSelected = selectedDays.contains(day);
                    return CheckboxListTile(
                      title: Text(day),
                      activeColor: const Color(0xFF3A7BD5),
                      value: isSelected,
                      onChanged: (value) {
                        setPop(() {
                          if (value == true) selectedDays.add(day);
                          else selectedDays.remove(day);
                        });
                        setState(() {});
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Done"))],
            );
          },
        );
      },
    );
  }

  Future<void> saveMedicine() async {
    if (nameController.text.isEmpty || doseController.text.isEmpty ||
        selectedTimes.any((t) => t == null) || selectedDays.isEmpty) {
      _showError("Please fill all fields");
      return;
    }

    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('user_token');
      final int? childId = prefs.getInt('selected_child_id');

      if (token == null || childId == null) {
        _showError("Session expired or no child selected");
        return;
      }

      List<String> formattedTimes = selectedTimes.map((t) {
        return "${t!.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00";
      }).toList();

      Map<String, dynamic> requestBody = {
        "MedicationName": nameController.text.trim(),
        "Dosage": doseController.text.trim(),
        "Frequency": dosesPerDay,
        "Description": descController.text.trim().isEmpty ? "No description" : descController.text.trim(),
        "ChildId": childId,
        "IsActive": true,
        "IsMonday": selectedDays.contains("Monday"),
        "IsTuesday": selectedDays.contains("Tuesday"),
        "IsWednesday": selectedDays.contains("Wednesday"),
        "IsThursday": selectedDays.contains("Thursday"),
        "IsFriday": selectedDays.contains("Friday"),
        "IsSaturday": selectedDays.contains("Saturday"),
        "IsSunday": selectedDays.contains("Sunday"),
        "Times": formattedTimes,
      };

      final response = widget.initialData == null
          ? await _apiService.addMedication(token: token, medicationData: requestBody)
          : await _apiService.updateMedication(
          token: token,
          medicationId: widget.initialData!["id"],
          medicationData: requestBody
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Success! Medication saved."),
                backgroundColor: Colors.green
            )
        );
        Navigator.pop(context, true);
      } else {
        _showError("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      _showError("An error occurred");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(widget.initialData == null ? "Add Medicine" : "Edit Medicine",
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Color(0xFF3A7BD5), Color(0xFF00D2FF)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
            child: Column(
              children: [
                TextField(controller: nameController, decoration: _inputDecoration("Medicine Name", Icons.medication)),
                const SizedBox(height: 15),
                TextField(controller: doseController, decoration: _inputDecoration("Dose (e.g. 500mg)", Icons.scale)),
                const SizedBox(height: 15),
                TextField(controller: descController, decoration: _inputDecoration("Description / Note", Icons.description)),
                const SizedBox(height: 20),

                if (widget.initialData == null) ...[
                  Row(
                    children: [
                      const Text("Doses per Day:", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(width: 16),
                      DropdownButton<int>(
                        value: dosesPerDay,
                        dropdownColor: Colors.blue[400],
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        items: List.generate(6, (index) => index + 1).map((e) => DropdownMenuItem(value: e, child: Text(e.toString()))).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              dosesPerDay = value;
                              if (selectedTimes.length < dosesPerDay) {
                                while (selectedTimes.length < dosesPerDay) {
                                  selectedTimes.add(null);
                                }
                              } else if (selectedTimes.length > dosesPerDay) {
                                selectedTimes = selectedTimes.take(dosesPerDay).toList().cast<TimeOfDay?>();
                              }
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                ],

                Column(
                  children: List.generate(dosesPerDay, (index) {
                    String timeLabel = "Not selected";
                    if (index < selectedTimes.length && selectedTimes[index] != null) {
                      timeLabel = selectedTimes[index]!.format(context);
                    }

                    return GestureDetector(
                      onTap: () => pickTime(index),
                      child: _pickerCard(
                        title: "Time ${index + 1}",
                        value: timeLabel,
                        icon: Icons.access_time,
                      ),
                    );
                  }),
                ),

                GestureDetector(
                  onTap: pickDaysPopup,
                  child: _pickerCard(
                    title: "Select Days",
                    value: selectedDays.isEmpty ? "No days selected" : selectedDays.join(", "),
                    icon: Icons.calendar_month,
                  ),
                ),
                const SizedBox(height: 30),

                isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF3A7BD5),
                    padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: saveMedicine,
                  child: Text(widget.initialData == null ? "Save Medicine" : "Update Medicine",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white.withOpacity(0.9),
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF3A7BD5)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
    );
  }

  Widget _pickerCard({required String title, required String value, required IconData icon}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF3A7BD5), size: 28),
          const SizedBox(width: 16),
          Expanded(child: Text("$title:  $value", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}