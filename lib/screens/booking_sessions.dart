import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:care_link/handlers/appointment_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Import FirebaseAuth

class BookingSessionPage extends StatelessWidget {
  final Doctor doctor;

  BookingSessionPage({required this.doctor});

  Future<void> _bookAppointment(
      BuildContext context, String userId, DateTime selectedTime) async {
    try {
      // Implement your booking logic, such as adding a document to Firestore
      // For example, adding appointment details under the doctor's collection

      await FirebaseFirestore.instance
          .collection('doctors')
          .doc(doctor.id.toString())
          .collection('appointments')
          .add({
        'patient_id': userId,
        'appointment_time': Timestamp.fromDate(
            selectedTime), // Save the selected appointment time
      });

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Appointment booked successfully!'),
          duration: Duration(seconds: 2),
        ),
      );

      // Navigate back to the appointment handler page
      Navigator.pop(context);
    } catch (error) {
      // Show an error message if booking fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to book appointment: $error'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the current user ID from FirebaseAuth
    String userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text('Booking Session'),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('doctors')
            .doc(doctor.id.toString())
            .collection('appointments')
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else {
            // Retrieve existing appointment times
            List<DateTime> bookedTimes = [];
            snapshot.data!.docs.forEach((doc) {
              bookedTimes.add((doc['appointment_time'] as Timestamp).toDate());
            });

            // Generate available time slots
            List<DateTime> availableTimes = [];
            DateTime now = DateTime.now();
            for (int i = 0; i < 7; i++) {
              DateTime nextTime = now.add(Duration(days: i));
              if (nextTime.weekday >= 1 && nextTime.weekday <= 5) {
                // Only consider weekdays for appointments
                DateTime time8AM =
                    DateTime(nextTime.year, nextTime.month, nextTime.day, 8);
                if (!bookedTimes.contains(time8AM)) {
                  availableTimes.add(time8AM);
                }
                // Add more time slots as needed
                // Example: time10AM, time12PM, time2PM, time4PM, etc.
              }
            }

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Choose an available time for your appointment:',
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: availableTimes.length,
                    itemBuilder: (context, index) {
                      return // Display available appointment times in the UI
                          ListTile(
                        title: Text(
                            '${DateFormat('EEEE, MMM d, y, HH:mm').format(availableTimes[index])}'), // Format date and time
                        onTap: () {
                          _bookAppointment(
                              context,
                              userId,
                              availableTimes[
                                  index]); // Pass the selected appointment time
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
