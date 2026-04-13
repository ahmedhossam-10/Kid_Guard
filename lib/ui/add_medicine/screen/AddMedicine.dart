import 'package:flutter/material.dart';

class AddMedicine extends StatefulWidget {
  const AddMedicine({super.key});

  @override
  State<AddMedicine> createState() => _AddMedicinePageState();
}

class _AddMedicinePageState extends State<AddMedicine> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController doseController = TextEditingController();

  int dosesPerDay = 1; // عدد الجرعات الافتراضي
  List<TimeOfDay?> selectedTimes = [null]; // أوقات كل جرعة

  List<String> selectedDays = [];
  final List<String> allDays = [
    "Saturday",
    "Sunday",
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday"
  ];

  // ----------------------
  // PICK TIME
  // ----------------------
  void pickTime(int index) async {
    final TimeOfDay? time =
    await showTimePicker(context: context, initialTime: TimeOfDay.now());

    if (time != null) {
      setState(() => selectedTimes[index] = time);
    }
  }

  // ----------------------
  // PICK DAYS POPUP
  // ----------------------
  void pickDaysPopup() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setPop) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                "Select Days",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
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
                          if (value == true) {
                            selectedDays.add(day);
                          } else {
                            selectedDays.remove(day);
                          }
                        });
                        setState(() {});
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Done"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ----------------------
  // SAVE MEDICINE
  // ----------------------
  void saveMedicine() {
    // تحقق من تعبئة جميع الحقول
    if (nameController.text.isEmpty ||
        doseController.text.isEmpty ||
        selectedTimes.any((t) => t == null) ||
        selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // ارجع البيانات ك Map<String, dynamic>
    Navigator.pop(context, {
      "name": nameController.text.trim(),
      "dose": doseController.text.trim(),
      "times": selectedTimes.map((t) => t!.format(context)).toList(),
      "days": List<String>.from(selectedDays),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "Add Medicine",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Color(0xFF3A7BD5), Color(0xFF00D2FF)],
          ),
        ),
        child: SafeArea(
          child: ListView(
            children: [
              // NAME
              TextField(
                controller: nameController,
                decoration: _inputDecoration("Medicine Name", Icons.medication),
              ),
              const SizedBox(height: 20),

              // DOSE
              TextField(
                controller: doseController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration("Dose (mg)", Icons.scale),
              ),
              const SizedBox(height: 20),

              // NUMBER OF DOSES PER DAY
              Row(
                children: [
                  const Text(
                    "Doses per Day:",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                  const SizedBox(width: 16),
                  DropdownButton<int>(
                    value: dosesPerDay,
                    dropdownColor: Colors.blue[100],
                    items: List.generate(6, (index) => index + 1)
                        .map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(e.toString()),
                    ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          dosesPerDay = value;
                          // تعديل حجم قائمة الأوقات على حسب عدد الجرعات
                          if (selectedTimes.length < dosesPerDay) {
                            selectedTimes.addAll(
                                List.filled(dosesPerDay - selectedTimes.length, null));
                          } else if (selectedTimes.length > dosesPerDay) {
                            selectedTimes.removeRange(dosesPerDay, selectedTimes.length);
                          }
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // PICK TIMES
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(dosesPerDay, (index) {
                  return GestureDetector(
                    onTap: () => pickTime(index),
                    child: _pickerCard(
                      title: "Pick Time ${index + 1}",
                      value: selectedTimes[index] == null
                          ? "Not selected"
                          : selectedTimes[index]!.format(context),
                      icon: Icons.access_time,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),

              // DAYS PICKER
              GestureDetector(
                onTap: pickDaysPopup,
                child: _pickerCard(
                  title: "Select Days",
                  value: selectedDays.isEmpty
                      ? "No days selected"
                      : selectedDays.join(", "),
                  icon: Icons.calendar_month,
                ),
              ),
              const SizedBox(height: 40),

              // SAVE BUTTON
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF3A7BD5),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 60, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: saveMedicine,
                  child: const Text(
                    "Save Medicine",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 90),
            ],
          ),
        ),
      ),
    );
  }

  // ----------------------
  // INPUT FIELD DECORATION
  // ----------------------
  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white.withOpacity(0.9),
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF3A7BD5)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  }

  // ----------------------
  // PICKER CARD UI
  // ----------------------
  Widget _pickerCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF3A7BD5), size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              "$title:  $value",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
