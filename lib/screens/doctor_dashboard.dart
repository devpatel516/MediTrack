import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../auth_provider.dart';
import '../api_service.dart';
import 'login_screen.dart';
import 'doctor_appointments_screen.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({super.key});

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  final patientEmailController = TextEditingController();
  final notesController = TextEditingController();
  late Future<List<dynamic>> notes;
  List<Map<String, TextEditingController>> medicines = [];
  DateTime? selectedDate;
  bool isSaving = false;

  late stt.SpeechToText speech;
  bool isListening = false;
  String voiceTranscript = "";
  bool speechAvailable = false;
  String previousWords = "";
  bool extracting = false;

  @override
  void initState() {
    super.initState();
    addMedicine();
    initSpeech();
  }

  void initSpeech() async {
    speech = stt.SpeechToText();
    try {
      speechAvailable = await speech.initialize(
        onStatus: (status) {
          print('Speech Status: $status');
          if (status == 'done' || status == 'notListening') {
            setState(() {
              isListening = false;
            });
          }
        },
        onError: (errorNotification) => print('Speech Error: $errorNotification'),
      );
      setState(() {});
    } catch (e) {
      print("Speech initialization failed: $e");
    }
  }

  void listen() async {
    if (!isListening && speechAvailable) {
      setState(() {
        isListening = true;
        previousWords = voiceTranscript;
      });

      speech.listen(
        onResult: (result) {
          setState(() {
            if (previousWords.isEmpty) {
              voiceTranscript = result.recognizedWords;
            } else {
              voiceTranscript = "$previousWords ${result.recognizedWords}";
            }
          });
        },
        listenOptions: stt.SpeechListenOptions(
          listenFor: const Duration(minutes: 5),
          pauseFor: const Duration(seconds: 15),
          listenMode: stt.ListenMode.dictation,
          cancelOnError: false,
          partialResults: true,
        ),
      );
    } else {
      setState(() => isListening = false);
      speech.stop();
    }
  }

  @override
  void dispose() {
    patientEmailController.dispose();
    notesController.dispose();
    for (var med in medicines) {
      med['name']?.dispose();
      med['timing']?.dispose();
      med['schedule']?.dispose();
    }
    super.dispose();
  }

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
      medicines[index]['name']?.dispose();
      medicines[index]['timing']?.dispose();
      medicines[index]['schedule']?.dispose();
      medicines.removeAt(index);
    });
  }

  void extract() async {
    if (voiceTranscript.trim().isEmpty) return;
    setState(() {
      extracting = true;
    });
    try {
      final Map<String, dynamic> result = await ApiService().aiService(voiceTranscript);
      setState(() {
        String diagnosis = result['diagnosis'] ?? 'No diagnosis found';
        String notes = result['notes'] ?? '';
        notesController.text = "Diagnosis: $diagnosis\n\nNotes: $notes".trim();
        extracting = false;
      });
      print('here in dd');
    } catch (e) {
      setState(() {
        extracting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void submitVisit() async {
    if (patientEmailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Patient Email is required')));
      return;
    }
    setState(() {
      isSaving = true;
    });

    List<Map<String, String>> medicinesPayload = medicines.map((med) {
      return {
        "name": med['name']!.text.trim(),
        "timing": med['timing']!.text.trim(),
        "schedule": med['schedule']!.text.trim()
      };
    }).where((med) => med['name']!.isNotEmpty).toList();

    Map<String, dynamic> visitData = {
      "patientEmail": patientEmailController.text.trim(),
      "notes": notesController.text.trim(),
      "medicines": medicinesPayload,
      "nextVisitDate": selectedDate?.toIso8601String(),
    };

    try {
      bool success = await ApiService().createVisit(visitData);
      if (success) {
        if (selectedDate != null) {
          DateTime alarmTime = selectedDate!.subtract(const Duration(days: 1));
          if (alarmTime.isAfter(DateTime.now())) {
            AwesomeNotifications().createNotification(
              content: NotificationContent(
                id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
                channelKey: 'appointment_channel',
                title: 'Appointment Reminder 🩺',
                body: 'You have a patient visit scheduled for tomorrow!',
              ),
              schedule: NotificationCalendar.fromDate(date: alarmTime),
            );
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Visit saved successfully!')));

        patientEmailController.clear();
        notesController.clear();
        setState(() {
          for (var med in medicines) {
            med['name']?.dispose();
            med['timing']?.dispose();
            med['schedule']?.dispose();
          }
          medicines.clear();
          addMedicine();
          selectedDate = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to save visit.')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }

    setState(() {
      isSaving = false;
    });
  }

  String formatDate(DateTime date) {
    try {
      return "${date.day}/${date.month}/${date.year}";
    } catch (e) {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final customBorder = OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0)
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Doctor Dashboard",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromRGBO(44, 162, 158, 1.0),
        actions: [
          IconButton(
            color: Colors.white,
            icon: const Icon(Icons.list_alt),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DoctorAppointmentsScreen()),
              );
            },
          ),
          IconButton(
            color: Colors.white,
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
            const Text(
              "Create New Visit",
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(45, 161, 155, 1.0)),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: patientEmailController,
              decoration: InputDecoration(
                  labelText: 'Patient Email',
                  labelStyle: const TextStyle(
                      color: Color.fromRGBO(45, 161, 155, 1.0),
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic),
                  enabledBorder: customBorder,
                  focusedBorder: customBorder),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 15),
            Card(
              color: isListening ? Colors.red.shade50 : Colors.blue.shade50,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Voice Extractor',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromRGBO(44, 162, 158, 1.0)),
                              ),
                              Text(
                                isListening ? "Listening... Speak now" : "Tap mic to start dictating",
                                style: TextStyle(
                                    color: isListening ? Colors.red : Colors.grey.shade700,
                                    fontSize: 13),
                              ),
                            ],
                          ),
                          FloatingActionButton(
                            onPressed: listen,
                            mini: true,
                            backgroundColor: isListening ? Colors.red : const Color.fromRGBO(44, 162, 158, 1.0),
                            child: Icon(isListening ? Icons.mic : Icons.mic_none, color: Colors.white),
                          ),
                          FloatingActionButton(
                            onPressed: () {
                              setState(() {
                                previousWords = "";
                                voiceTranscript = "";
                              });
                            },
                            mini: true,
                            backgroundColor: Colors.white,
                            child: const Icon(Icons.cancel, color: Color.fromRGBO(44, 162, 158, 1.0)),
                          )
                        ],
                      ),
                      if (voiceTranscript.isNotEmpty) ...[
                        const SizedBox(height: 15),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue.shade100)),
                          child: Text(
                            voiceTranscript,
                            style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      extracting
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton.icon(
                        onPressed: isListening ? null : () {
                          extract();
                        },
                        icon: const Icon(Icons.auto_awesome),
                        label: const Text("Extract Notes"),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromRGBO(44, 162, 158, 1.0),
                            foregroundColor: Colors.white),
                      )
                    ],
                  )),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: InputDecoration(
                  labelText: 'Doctor Notes / Diagnosis',
                  labelStyle: const TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Color.fromRGBO(45, 161, 155, 1.0),
                      fontWeight: FontWeight.w500),
                  enabledBorder: customBorder,
                  focusedBorder: customBorder),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 30, bottom: 10),
              child: Text(
                "Prescriptions",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(44, 162, 158, 1.0)),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
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
                        if (medicines.length > 1)
                          InkWell(
                            onTap: () => removeMedicine(index),
                            child: const Icon(Icons.cancel, color: Colors.red),
                          ),
                        TextField(
                          controller: medicines[index]['name'],
                          decoration: InputDecoration(
                              labelText: 'Medicine Name',
                              labelStyle: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Color.fromRGBO(45, 161, 155, 1.0),
                                  fontWeight: FontWeight.w500),
                              isDense: true,
                              enabledBorder: customBorder,
                              focusedBorder: customBorder),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: medicines[index]['timing'],
                                decoration: InputDecoration(
                                    labelText: 'Timing (e.g. After Food)',
                                    labelStyle: const TextStyle(
                                        fontStyle: FontStyle.italic,
                                        color: Color.fromRGBO(45, 161, 155, 1.0),
                                        fontWeight: FontWeight.w500),
                                    isDense: true,
                                    enabledBorder: customBorder,
                                    focusedBorder: customBorder),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: medicines[index]['schedule'],
                                decoration: InputDecoration(
                                    labelText: 'Schedule',
                                    labelStyle: const TextStyle(
                                        fontStyle: FontStyle.italic,
                                        color: Color.fromRGBO(45, 161, 155, 1.0),
                                        fontWeight: FontWeight.w500),
                                    isDense: true,
                                    enabledBorder: customBorder,
                                    focusedBorder: customBorder),
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
            TextButton.icon(
              onPressed: addMedicine,
              icon: const Icon(Icons.add, color: Color.fromRGBO(44, 162, 158, 1.0)),
              label: const Text(
                "Add Another Medicine",
                style: TextStyle(color: Color.fromRGBO(44, 162, 158, 1.0)),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    final DateTime? picked = await showDatePicker(
                        context: context,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                        initialDate: DateTime.now());
                    if (picked != null) {
                      setState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                  icon: const Icon(
                    Icons.calendar_today,
                    color: Color.fromRGBO(44, 162, 158, 1.0),
                  ),
                  label: const Text(
                    'Pick Follow-up Date',
                    style: TextStyle(color: Color.fromRGBO(44, 162, 158, 1.0)),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  selectedDate == null ? 'No date selected' : formatDate(selectedDate!),
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color.fromRGBO(45, 161, 155, 1.0)),
                )
              ],
            ),
            const SizedBox(height: 30),
            isSaving
                ? const Center(child: CircularProgressIndicator())
                : SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: submitVisit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(44, 162, 158, 1.0),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
                child: const Text('Save Visit Record',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}