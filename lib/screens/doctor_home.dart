import 'package:care_link/pages/login_page.dart';
import 'package:care_link/screens/doctor_dashboard.dart';
import 'package:care_link/screens/edit_schedule.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Import date formatting

// class DoctorHome extends StatefulWidget {
//   const DoctorHome({Key? key}) : super(key: key);

//   @override
//   _DoctorHomeState createState() => _DoctorHomeState();
// }

// List<Map> navigationBarItems = [
//   {'icon': Icons.local_hospital, 'index': 0},
//   {'icon': Icons.calendar_today, 'index': 1},
// ];

// class _DoctorHomeState extends State<DoctorHome> {
//   int _selectedIndex = 0;
//   void goToSchedule() {
//     setState(() {
//       _selectedIndex = 1;
//     });
//   }

//   //sign user out method
//   void signUserOut() {
//     FirebaseAuth.instance.signOut();
//   }

//   @override
//   Widget build(BuildContext context) {
//     List<Widget> screens = [
//       DoctorHomeTab(
//         onPressedScheduleCard: goToSchedule,
//       ),
//       ScheduleTab(),
//     ];

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Color(MyColors.primary),
//         elevation: 0,
//         toolbarHeight: 0,
//       ),
//       body: SafeArea(
//         child: screens[_selectedIndex],
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         selectedFontSize: 0,
//         selectedItemColor: Color(MyColors.primary),
//         showSelectedLabels: false,
//         showUnselectedLabels: false,
//         items: [
//           for (var navigationBarItem in navigationBarItems)
//             BottomNavigationBarItem(
//               icon: Container(
//                 height: 55,
//                 decoration: BoxDecoration(
//                   border: Border(
//                     top: _selectedIndex == navigationBarItem['index']
//                         ? BorderSide(color: Color(MyColors.bg01), width: 5)
//                         : BorderSide.none,
//                   ),
//                 ),
//                 child: Icon(
//                   navigationBarItem['icon'],
//                   color: _selectedIndex == 0
//                       ? Color(MyColors.bg01)
//                       : Color(MyColors.bg02),
//                 ),
//               ),
//               label: '',
//             ),
//         ],
//         currentIndex: _selectedIndex,
//         onTap: (value) => setState(() {
//           _selectedIndex = value;
//         }),
//       ),
//     );
//   }
// }

class DoctorHome extends StatefulWidget {
  const DoctorHome({Key? key}) : super(key: key);

  @override
  _DoctorHomeState createState() => _DoctorHomeState();
}

class _DoctorHomeState extends State<DoctorHome> {
  int _selectedIndex = 0;
  late CollectionReference<Map<String, dynamic>> doctorsCollection;
  late DateTime selectedDateTime = DateTime.now();
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(); // Create a GlobalKey for the Scaffold

  @override
  void initState() {
    super.initState();
    // Initialize Firestore collection reference
    doctorsCollection = FirebaseFirestore.instance.collection('doctors');
  }

  Future<void> addBookingSchedule() async {
    try {
      // Get the current user from Firebase Authentication
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        // Handle the case where the user is not authenticated
        print('User is not authenticated');
        return;
      }

      // Get the current user ID
      String userId = currentUser.uid;

      // Check if the document already exists
      bool docExists =
          await doctorsCollection.doc(userId).get().then((doc) => doc.exists);

      // If the document doesn't exist, create it
      if (!docExists) {
        await doctorsCollection.doc(userId).set({
          'schedules': [], // Initialize with an empty array of schedules
        });
      }

      // Format selected date time
      String formattedDateTime =
          DateFormat('yyyy-MM-dd - kk:mm').format(selectedDateTime);

      // Add the formatted date time to Firestore
      await doctorsCollection.doc(userId).update({
        'schedules': FieldValue.arrayUnion([formattedDateTime]),
      });

      // Show a success message using SnackBar
      _showSnackBar('Schedule added successfully');
    } catch (error) {
      // Show an error message using SnackBar
      _showSnackBar('Error adding schedule: $error');
    }
  }

  Future<void> signUserOut(BuildContext context) async {
    CircularProgressIndicator();
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(),
      ),
    );
  }

  // Method to show a SnackBar with the provided message
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 5),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selectedDateTime),
      );

      if (pickedTime != null) {
        setState(() {
          selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });

        // Call method to add booking schedule
        addBookingSchedule();
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Assign the GlobalKey to the Scaffold
      appBar: AppBar(
        title: Text('Doctor Home'),
        actions: <Widget>[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              'Logout',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),

          IconButton(
            onPressed: () {
              signUserOut(context);
            },
            icon: Icon(
              Icons.logout,
            ),
          ),

          // IconButton(
          //   icon: Icon(Icons.add),
          //   onPressed: () {
          //     _selectDateTime(context); // Call method to add booking schedule
          //   },
          // ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Drawer Header'),
            ),
            ListTile(
              title: Text('Appointment Requests'),
              onTap: () {
                // Navigate to a screen where appointment requests are managed
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //       builder: (context) => AppointmentRequestsScreen()),
                // );
              },
            ),
            ListTile(
              title: Text('List of Patients'),
              onTap: () {
                // Navigate to a screen where patient health status is displayed
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DoctorDashboard()),
                );
              },
            ),
            // Add more list tiles as needed
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            IconButton(
              onPressed: () {
                _selectDateTime(context); // Call method to add booking schedule
              },
              icon: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add),
                  SizedBox(
                      width: 8), // Add some space between the icon and the text
                  Text('Add New Schedule'),
                ],
              ),
            ),

            SizedBox(
                height:
                    20), // Add some space between the add button and the schedule list
            Expanded(
              child: _selectedIndex == 0
                  ? _buildScheduleList() // Display schedule list
                  : Container(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Business',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildScheduleList() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return Center(
        child: Text('User not authenticated'),
      );
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: doctorsCollection.doc(currentUser.uid).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        List<String> schedules =
            List<String>.from(snapshot.data!.get('schedules'));

        return ListView.builder(
          itemCount: schedules.length,
          itemBuilder: (context, index) {
            String schedule = schedules[index];
            return ListTile(
              title: Text(schedule),
              trailing: IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  _editSchedule(schedule);
                },
              ),
            );
          },
        );
      },
    );
  }

  void _editSchedule(String schedule) {
    // Navigate to a new screen where the user can edit the schedule
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditScheduleScreen(schedule: schedule),
      ),
    ).then((editedSchedule) {
      if (editedSchedule != null) {
        // Update the edited schedule in Firestore
        _updateSchedule(schedule, editedSchedule);
      }
    });
  }

  void _updateSchedule(String oldSchedule, String newSchedule) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      // Handle the case where the user is not authenticated
      return;
    }

    try {
      // Get the current user ID
      String userId = currentUser.uid;

      // Get the document reference for the doctor's schedules
      DocumentReference<Map<String, dynamic>> doctorDocRef =
          doctorsCollection.doc(userId);

      // Get the current list of schedules
      List<String> schedules = List<String>.from(
          (await doctorDocRef.get()).data()!['schedules'] ?? []);

      // Find and update the old schedule with the new one
      int index = schedules.indexOf(oldSchedule);
      if (index != -1) {
        schedules[index] = newSchedule;

        // Update the schedules in Firestore
        await doctorDocRef.update({'schedules': schedules});

        // Show a success message using SnackBar
        _showSnackBar('Schedule updated successfully');
      } else {
        // Show an error message if the old schedule was not found
        _showSnackBar('Error updating schedule: Schedule not found');
      }
    } catch (error) {
      // Show an error message using SnackBar
      _showSnackBar('Error updating schedule: $error');
    }
  }
}
