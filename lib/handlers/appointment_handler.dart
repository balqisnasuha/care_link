import 'package:flutter/material.dart';
import 'package:care_link/screens/booking_sessions.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

// Define Doctor class if not already defined
class Doctor {
  final String name;
  final int id;
  final String about;

  Doctor({required this.name, required this.id, required this.about});
}

class AppointmentHandlerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appointment Handler'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('doctors').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(); // Loading indicator while fetching data
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              Doctor doctor = Doctor(
                name: data['name'],
                id: data['id'],
                about: data['about'],
              ); // Create Doctor object from Firestore data
              return ListTile(
                title: Text(doctor.name),
                subtitle: Text('${doctor.id}\n${doctor.about}'),
                trailing: ElevatedButton(
                  onPressed: () {
                    // Navigate to BookingSessionPage with the selected doctor's information
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              BookingSessionPage(doctor: doctor)),
                    );
                  },
                  child: Text('Make Appointment'),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
