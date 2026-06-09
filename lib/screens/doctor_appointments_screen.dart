import 'package:flutter/material.dart';
import '../api_service.dart';

class DoctorAppointmentsScreen extends StatefulWidget {
  const DoctorAppointmentsScreen({super.key});

  @override
  State<DoctorAppointmentsScreen> createState() => _DoctorAppointmentsScreenState();
}

class _DoctorAppointmentsScreenState extends State<DoctorAppointmentsScreen> {
  List<dynamic> upcomingVisits = [];
  List<dynamic> pastVisits = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchVisits();
  }

  void fetchVisits() async {
    try {
      final visits = await ApiService().getDoctorVisits();
      final now = DateTime.now();

      setState(() {
        for (var visit in visits) {
          if (visit['nextVisitDate'] != null) {
            DateTime visitDate = DateTime.parse(visit['nextVisitDate']);
            if (visitDate.isAfter(now)) {
              upcomingVisits.add(visit);
            } else {
              pastVisits.add(visit);
            }
          } else {
            // If there's no next visit date, consider it a past record
            pastVisits.add(visit);
          }
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
  String getPatientName(dynamic visit) {
    if (visit['patientId'] != null && visit['patientId'] is Map) {
      return visit['patientId']['name'] ?? 'Unknown Name';
    }
    return 'Unknown Patient';
  }

  String formatDate(String? isoDate) {
    if (isoDate == null) return "No Date";
    DateTime date = DateTime.parse(isoDate);
    return "${date.day}/${date.month}/${date.year}";
  }

  Widget buildVisitList(List<dynamic> visits, bool isUpcoming) {
    if (visits.isEmpty) {
      return Center(
        child: Text(
          isUpcoming ? "No upcoming appointments." : "No past appointments.",
          style: const TextStyle(fontSize: 16, color: Color.fromRGBO(44, 162, 158, 1.0)),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: visits.length,
      itemBuilder: (context, index) {
        final visit = visits[index];
        return Card(
          elevation: 3,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: Colors.white.withOpacity(0.95),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: isUpcoming ? const Color.fromRGBO(44, 162, 158, 0.2) : Colors.grey.shade200,
              child: Icon(
                  isUpcoming ? Icons.calendar_month : Icons.history,
                  color: isUpcoming ? const Color.fromRGBO(44, 162, 158, 1.0) : Colors.grey.shade600
              ),
            ),
            title: Text(
              getPatientName(visit),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  "Date: ${formatDate(visit['nextVisitDate'])}",
                  style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  visit['notes'] ?? 'No notes available.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.black),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Appointments", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white)),
          backgroundColor: const Color.fromRGBO(44, 162, 158, 1.0),
          elevation: 0,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16,color: Colors.white),
            tabs: [
              Tab(text: "Upcoming"),
              Tab(text: "Past"),
            ],
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromRGBO(224, 242, 241, 1.0),
                Colors.white,
                Color.fromRGBO(227, 242, 253, 1.0),
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
            children: [
              buildVisitList(upcomingVisits, true),
              buildVisitList(pastVisits, false),
            ],
          ),
        ),
      ),
    );
  }
}