import 'package:flutter/material.dart';
import 'package:internship/screens/login_screen.dart';
import 'package:provider/provider.dart';
import '../auth_provider.dart';
import '../api_service.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
class PatientDashboard extends StatefulWidget {
  const PatientDashboard({super.key});

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {

  late Future<List<dynamic>> patientHistory;
  void syncPatientNotifications(List<dynamic> patientVisits) {
    for (var visit in patientVisits) {
      if (visit['nextVisitDate'] != null) {
        DateTime appointmentDate = DateTime.parse(visit['nextVisitDate']);
        DateTime alarmTime = appointmentDate.subtract(const Duration(days: 1));

        if (alarmTime.isAfter(DateTime.now())) {
          AwesomeNotifications().createNotification(
            content: NotificationContent(
              id: appointmentDate.millisecondsSinceEpoch.remainder(100000),
              channelKey: 'appointment_channel',
              title: 'Doctor Appointment Tomorrow! 🩺',
              body: 'Reminder: You have an appointment scheduled for tomorrow.',
            ),
            schedule: NotificationCalendar.fromDate(date: alarmTime),
          );
        }
      }
    }
  }
  void initState(){
    super.initState();

    final authProvider=Provider.of<AuthProvider>(context,listen: false);
    final String patientId=authProvider.userId!;
    patientHistory=ApiService().getPatientHistory(patientId);
    patientHistory.then((visits) {
      syncPatientNotifications(visits);
    }).catchError((error) {
      print("Error syncing notifications: $error");
    });
  }

  String formatDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      return "${date.day}/${date.month}/${date.year}";
    } catch (e) {
      return dateString;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('My Medical History',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
        backgroundColor: Color.fromRGBO(44, 162, 158, 1.0),
        elevation: 0,
        actions: [
          IconButton(onPressed: (){
            Provider.of<AuthProvider>(context,listen: false).logout();
            Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)=>LoginScreen()));
          }, icon: Icon(Icons.logout,color: Colors.white,)),
          IconButton(
              onPressed: () {
                AwesomeNotifications().createNotification(
                  content: NotificationContent(
                    id: 999,
                    channelKey: 'appointment_channel',
                    title: 'Test Notification!',
                    body: 'Test Appointment',
                    notificationLayout: NotificationLayout.Default,
                  ),
                );
              },
              icon: const Icon(Icons.notifications_active, color: Colors.amber)
          ),
        ],
      ),

      body:FutureBuilder(future: patientHistory, builder: (context,snapshot){
        if(snapshot.connectionState==ConnectionState.waiting){
          return Center(
            child: CircularProgressIndicator(),
          );
        }else if(snapshot.hasError){
          return Center(
            child: Text('Error:${snapshot.error}'),
          );
        }
        else if(!snapshot.hasData || snapshot.data!.isEmpty){
          return Center(
            child: Text("You don't have any medical history yet.",style: TextStyle(fontSize: 18,color:Colors.grey),),
          );
        }

        final history=snapshot.data!;

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: history.length,
          itemBuilder: (context,index){
            final visit=history[index];
            final doctorName = visit['doctorId']?['name'] ?? 'Unknown Doctor';
            List<dynamic> medicines;
            if (visit['medicines'] != null) {
              medicines = visit['medicines'] as List<dynamic>;
            } else {
              medicines = [];
            }

            return Card(
              elevation: 3,
              margin: EdgeInsets.only(bottom: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            formatDate(visit['createdAt'] ?? ''),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color.fromRGBO(44, 162, 158, 1.0)),
                          ),
                          Text(
                            doctorName,
                            style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.black,fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      Divider(height: 30,thickness: 1),
                      if (visit['notes'] != null && visit['notes'].toString().isNotEmpty) ...[
                        const Text("Diagnosis / Notes:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16,color: Color.fromRGBO(44, 162, 158, 1.0))),
                        const SizedBox(height: 5),
                        Text(visit['notes'], style: TextStyle(color: Colors.grey[800],fontSize: 16)),
                        const SizedBox(height: 20),
                      ],

                      const Text("Prescriptions:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16,color: Color.fromRGBO(44, 162, 158, 1.0))),
                      const SizedBox(height: 10),

                      if (medicines.isEmpty)
                        const Text("No medicines prescribed.")
                      else
                        ...medicines.map((med) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.blue.shade100)
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.medication, color: Color.fromRGBO(44, 162, 158, 1.0)),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(med['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      const SizedBox(height: 4),
                                      Text("${med['schedule']}  •  ${med['timing']}", style: TextStyle(color: Colors.grey[700], fontSize: 16)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      SizedBox(height:20),
                      Row(
                        children: [
                          Text('Next Visit : ',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16,color: Color.fromRGBO(44, 162, 158, 1.0))),
                          Text(formatDate(visit['nextVisitDate'] ?? 'Not Applicable'),
                          style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: Color.fromRGBO(44, 162, 158, 1.0)),)
                        ],
                      ),
                    ],
                  ),
              ),
            );
          }
        );
      })
    );
  }
}
