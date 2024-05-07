import 'package:flutter/material.dart';

class EditScheduleScreen extends StatefulWidget {
  final String schedule;

  const EditScheduleScreen({Key? key, required this.schedule})
      : super(key: key);

  @override
  _EditScheduleScreenState createState() => _EditScheduleScreenState();
}

class _EditScheduleScreenState extends State<EditScheduleScreen> {
  late TextEditingController _scheduleController;

  @override
  void initState() {
    super.initState();
    _scheduleController = TextEditingController(text: widget.schedule);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Schedule'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Edit the schedule below:',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _scheduleController,
              decoration: InputDecoration(
                labelText: 'Schedule',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _saveEditedSchedule();
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveEditedSchedule() {
    String editedSchedule = _scheduleController.text.trim();
    if (editedSchedule.isNotEmpty) {
      Navigator.pop(context, editedSchedule);
    } else {
      // Show an error message if the schedule is empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Schedule cannot be empty'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _scheduleController.dispose();
    super.dispose();
  }
}
