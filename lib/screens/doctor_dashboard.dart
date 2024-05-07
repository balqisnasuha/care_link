import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'health_status.dart'; // Import health status page

class DoctorDashboard extends StatefulWidget {
  @override
  _DoctorDashboardState createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late List<Map<String, dynamic>> _patients = []; // Initialize as list of maps

  @override
  void initState() {
    super.initState();
    _fetchPatients(); // Fetch list of patients when the widget initializes
  }

  // void _fetchPatients() async {
  //   try {
  //     final querySnapshot = await _firestore.collection('patients').get();
  //     setState(() {
  //       _patients = querySnapshot.docs.map((doc) => doc.id).toList();
  //     });
  //     print('Patients fetched: $_patients');
  //   } catch (e) {
  //     print('Error fetching patients: $e');
  //   }
  // }

  void _fetchPatients() async {
    try {
      final querySnapshot = await _firestore.collection('patients').get();
      setState(() {
        _patients = querySnapshot.docs.map((doc) {
          final name = doc['name'];
          final id = doc.id;
          return {'id': id, 'name': name};
        }).toList();
      });
      print('Patients fetched: $_patients');
    } catch (e) {
      print('Error fetching patients: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('LIST OF PATIENT'),
      ),
      body: ListView.builder(
        itemCount: _patients.length,
        itemBuilder: (context, index) {
          final patient = _patients[index];
          return ListTile(
            title: Text('Name: ${patient['name']}'),
            trailing: IconButton(
              icon: Icon(Icons.assignment_rounded),
              tooltip: 'View Health Status',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        HealthStatusPage(patientId: patient['id']),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
