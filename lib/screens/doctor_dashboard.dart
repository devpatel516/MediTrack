import 'package:flutter/material.dart';
import 'package:internship/screens/login_screen.dart';
import 'package:provider/provider.dart';
import '../auth_provider.dart';
// import 'api_service.dart'; // Adjust path if needed
import 'login_screen.dart';
class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({super.key});

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  final patientEmailController = TextEditingController();
  final notesController = TextEditingController();

  // DYNAMIC LIST to hold multiple medicines
  List<Map<String, TextEditingController>> medicines = [];

  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    // Start with one empty medicine block by default
    addMedicine();
  }

  @override
  void dispose() {
    // Clean up all controllers to prevent memory leaks
    patientEmailController.dispose();
    notesController.dispose();
    for (var med in medicines) {
      med['name']?.dispose();
      med['timing']?.dispose();
      med['schedule']?.dispose();
    }
    super.dispose();
  }

  // --- DYNAMIC FORM LOGIC ---
  void addMedicine() {
    setState(() {
      medicines.add({
        'name': TextEditingController(),
        'timing': TextEditingController(),
        'schedule': TextEditingController(),
      });
    });
  }

  void removeMedicine(int index) {
    setState(() {
      // Dispose controllers before removing to free memory
      medicines[index]['name']?.dispose();
      medicines[index]['timing']?.dispose();
      medicines[index]['schedule']?.dispose();
      medicines.removeAt(index);
    });
  }

  // --- SUBMIT LOGIC ---
  void submitVisit() async {
    // Validate basic fields
    if (patientEmailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Patient Email is required')));
      return;
    }

    setState(() { isSaving = true; });

    // 1. Map the dynamic controllers into a JSON-friendly list
    List<Map<String, String>> medicinesPayload = medicines.map((med) {
      return {
        "name": med['name']!.text.trim(),
        "timing": med['timing']!.text.trim(),
        "schedule": med['schedule']!.text.trim()
      };
    }).where((med) => med['name']!.isNotEmpty).toList(); // Ignore empty medicine rows

    // 2. Prepare the full payload
    Map<String, dynamic> visitData = {
      "patientEmail": patientEmailController.text.trim(),
      "notes": notesController.text.trim(),
      "medicines": medicinesPayload
    };

    // 3. Call the API (Uncomment when ApiService is imported)
    /*
    try {
      bool success = await ApiService().createVisit(visitData);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Visit saved successfully!')));

        // Reset the form
        patientEmailController.clear();
        notesController.clear();
        setState(() {
          // Clear old medicines and start fresh with 1 empty block
          for (var med in medicines) {
            med['name']?.dispose();
            med['timing']?.dispose();
            med['schedule']?.dispose();
          }
          medicines.clear();
          addMedicine();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to save visit.')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
    */

    setState(() { isSaving = false; });
  }

  @override
  Widget build(BuildContext context) {
    final customBorder = OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0)
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Doctor Dashboard"),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Create New Visit", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            TextField(
              controller: patientEmailController,
              decoration: InputDecoration(labelText: 'Patient Email', enabledBorder: customBorder, focusedBorder: customBorder),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 15),

            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: InputDecoration(labelText: 'Doctor Notes / Diagnosis', enabledBorder: customBorder, focusedBorder: customBorder),
            ),

            const Padding(
              padding: EdgeInsets.only(top: 30, bottom: 10),
              child: Text("Prescriptions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),

            // --- DYNAMIC MEDICINE LIST BUILDER ---
            ListView.builder(
              shrinkWrap: true, // Needed inside SingleChildScrollView
              physics: const NeverScrollableScrollPhysics(), // Disables inner scrolling
              itemCount: medicines.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 15),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Remove Button (Only show if there's more than 1 medicine)
                        if (medicines.length > 1)
                          InkWell(
                            onTap: () => removeMedicine(index),
                            child: const Icon(Icons.cancel, color: Colors.red),
                          ),

                        TextField(
                          controller: medicines[index]['name'],
                          decoration: InputDecoration(labelText: 'Medicine Name', isDense: true, enabledBorder: customBorder, focusedBorder: customBorder),
                        ),
                        const SizedBox(height: 10),

                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: medicines[index]['timing'],
                                decoration: InputDecoration(labelText: 'Timing (e.g. After Food)', isDense: true, enabledBorder: customBorder, focusedBorder: customBorder),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: medicines[index]['schedule'],
                                decoration: InputDecoration(labelText: 'Schedule (e.g. 1-0-1)', isDense: true, enabledBorder: customBorder, focusedBorder: customBorder),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // ADD MEDICINE BUTTON
            TextButton.icon(
              onPressed: addMedicine,
              icon: const Icon(Icons.add, color: Colors.blue),
              label: const Text("Add Another Medicine", style: TextStyle(color: Colors.blue)),
            ),

            const SizedBox(height: 30),

            isSaving
                ? const Center(child: CircularProgressIndicator())
                : SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: submitVisit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
                child: const Text('Save Visit Record', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}