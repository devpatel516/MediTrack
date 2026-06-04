import 'package:flutter/material.dart';
import 'package:internship/screens/login_screen.dart';
import 'package:provider/provider.dart';
import '../auth_provider.dart';
import '../api_service.dart';

class PatientDashboard extends StatefulWidget {
  const PatientDashboard({super.key});

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {

  late Future<List<dynamic>> patientHistory;

  void initState(){
    super.initState();

    final authProvider=Provider.of<AuthProvider>(context,listen: false);
    final String patientId=authProvider.userId!;
    patientHistory=ApiService().getPatientHistory(patientId);
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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('My Medical History'),
        backgroundColor: Colors.blue,
        elevation: 0,
        actions: [
          IconButton(onPressed: (){
            Provider.of<AuthProvider>(context,listen: false).logout();
            Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)=>LoginScreen()));
          }, icon: Icon(Icons.logout))
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
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                          ),
                          Text(
                            doctorName,
                            style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.grey),
                          ),
                        ],
                      ),
                      Divider(height: 30,thickness: 1),
                      if (visit['notes'] != null && visit['notes'].toString().isNotEmpty) ...[
                        const Text("Diagnosis / Notes:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 5),
                        Text(visit['notes'], style: TextStyle(color: Colors.grey[800])),
                        const SizedBox(height: 20),
                      ],

                      const Text("Prescriptions:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                                const Icon(Icons.medication, color: Colors.blue),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(med['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      const SizedBox(height: 4),
                                      Text("${med['schedule']}  •  ${med['timing']}", style: TextStyle(color: Colors.grey[700], fontSize: 14)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
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
