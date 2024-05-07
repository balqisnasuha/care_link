//patient key in health data
import "package:flutter/material.dart";
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chart_sparkline/chart_sparkline.dart';
import 'dart:math';

class AxesPainter extends CustomPainter {
  final List<double> data;

  AxesPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 0.5;

    // Draw horizontal line (x-axis)
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );

    // Draw vertical line (y-axis)
    canvas.drawLine(
      Offset(0, size.height),
      Offset(0, 0),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class HealthDataApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health Data Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HealthDataScreen(),
    );
  }
}

class HealthDataScreen extends StatefulWidget {
  @override
  _HealthDataScreenState createState() => _HealthDataScreenState();
}

class _HealthDataScreenState extends State<HealthDataScreen> {
  List<double> _bloodPressureData = [];
  List<double> _sugarLevelData = [];
  List<double> _heartRateData = [];
  TextEditingController _bloodPressureController = TextEditingController();
  TextEditingController _sugarLevelController = TextEditingController();
  TextEditingController _heartRateController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  double _calculateAverage(List<double> data) {
    if (data.isEmpty) {
      return 0.0;
    }
    double sum = 0.0;
    for (var value in data) {
      sum += value;
    }
    return sum / data.length;
  }

  @override
  void initState() {
    super.initState();
    _fetchHealthData();
  }

  // void _fetchHealthData() async {
  //   try {
  //     final User? user = _auth.currentUser;
  //     if (user != null) {
  //       final userId = user.uid;
  //       final querySnapshot = await _firestore
  //           .collection('healthData')
  //           .doc(userId)
  //           .collection('dailyData')
  //           .orderBy('timestamp', descending: true)
  //           .limit(7)
  //           .get();
  //       setState(() {
  //         _bloodPressureData = querySnapshot.docs
  //             .map((doc) => doc['bloodPressure'] as double)
  //             .toList();
  //         _sugarLevelData = querySnapshot.docs
  //             .map((doc) => doc['sugarLevel'] as double)
  //             .toList();
  //         _heartRateData = querySnapshot.docs
  //             .map((doc) => doc['heartRate'] as double)
  //             .toList();
  //       });
  //       _updateChart(); // Update the chart after fetching data
  //     }
  //   } catch (e) {
  //     print('Error fetching data: $e');
  //   }
  // }

  void _fetchHealthData() async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        final userId = user.uid;
        final querySnapshot = await _firestore
            .collection('patients') // Use 'patients' as the main collection
            .doc(userId) // Use patient's ID as document ID
            .collection('healthData') // Use 'healthData' as the subcollection
            .orderBy('timestamp', descending: true)
            .limit(7)
            .get();
        setState(() {
          _bloodPressureData = querySnapshot.docs
              .map((doc) => doc['bloodPressure'] as double)
              .toList();
          _sugarLevelData = querySnapshot.docs
              .map((doc) => doc['sugarLevel'] as double)
              .toList();
          _heartRateData = querySnapshot.docs
              .map((doc) => doc['heartRate'] as double)
              .toList();
        });
        _updateChart(); // Update the chart after fetching data
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }
  // void _addData() async {
  //   try {
  //     final User? user = _auth.currentUser;
  //     if (user != null) {
  //       final userId = user.uid;
  //       await _firestore
  //           .collection('healthData')
  //           .doc(userId)
  //           .collection('dailyData')
  //           .add({
  //         'bloodPressure': double.parse(_bloodPressureController.text),
  //         'sugarLevel': double.parse(_sugarLevelController.text),
  //         'heartRate': double.parse(_heartRateController.text),
  //         'timestamp': DateTime.now(),
  //       });

  //       // Fetch updated data after adding new data
  //       _fetchHealthData();

  //       // Clear text fields after adding data
  //       _bloodPressureController.clear();
  //       _sugarLevelController.clear();
  //       _heartRateController.clear();
  //     }
  //   } catch (e) {
  //     print('Error adding data: $e');
  //   }
  // }

  void _addData() async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        final userId = user.uid;

        // Validate entered data
        double bloodPressure =
            double.tryParse(_bloodPressureController.text) ?? 0.0;
        double sugarLevel = double.tryParse(_sugarLevelController.text) ?? 0.0;
        double heartRate = double.tryParse(_heartRateController.text) ?? 0.0;

        if (!_isValidReading(bloodPressure, sugarLevel, heartRate)) {
          // Show error message for invalid data entry
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Invalid Data Entry'),
                content: Text(
                    'Please enter valid readings for blood pressure, sugar level, and heart rate.'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
          return;
        }

        // Add validated data to Firestore
        await _firestore
            .collection('patients')
            .doc(userId)
            .collection('healthData')
            .add({
          'bloodPressure': bloodPressure,
          'sugarLevel': sugarLevel,
          'heartRate': heartRate,
          'timestamp': DateTime.now(),
        });

        // Fetch updated data after adding new data
        _fetchHealthData();

        // Clear text fields after adding data
        _bloodPressureController.clear();
        _sugarLevelController.clear();
        _heartRateController.clear();
      }
    } catch (e) {
      print('Error adding data: $e');
    }
  }

  bool _isValidReading(
      double bloodPressure, double sugarLevel, double heartRate) {
    // Define reasonable ranges for each type of reading
    const double minBloodPressure = 50.0;
    const double maxBloodPressure = 250.0;
    const double minSugarLevel = 50.0;
    const double maxSugarLevel = 400.0;
    const double minHeartRate = 30.0;
    const double maxHeartRate = 200.0;

    // Check if readings fall within reasonable ranges
    return bloodPressure >= minBloodPressure &&
        bloodPressure <= maxBloodPressure &&
        sugarLevel >= minSugarLevel &&
        sugarLevel <= maxSugarLevel &&
        heartRate >= minHeartRate &&
        heartRate <= maxHeartRate;
  }

  void _updateChart() {
    setState(() {
      // Update the chart with the latest data
      // You may need to customize this based on your chart library
      // For example, if you're using flutter_sparkline, you'd update _bloodPressureData, _sugarLevelData, and _heartRateData.
      _bloodPressureData = _bloodPressureData;
      _sugarLevelData = _sugarLevelData;
      _heartRateData = _heartRateData;
    });
  }

  bool _shouldConsultDoctor(List<double> data, double threshold) {
    if (data.length < 3) return false; // Ensure at least 3 data entries
    return data.any((reading) => reading > threshold);
  }

  String _generateHealthReport() {
    String report = '';

    if (_shouldConsultDoctor(_bloodPressureData, 140.0)) {
      report += 'High blood pressure detected. ';
    }

    if (_shouldConsultDoctor(_sugarLevelData, 180.0)) {
      report += 'High sugar level detected. ';
    }

    if (_shouldConsultDoctor(_heartRateData, 100.0)) {
      report += 'High heart rate detected. ';
    }

    if (report.isEmpty) {
      report = 'No significant health issues detected.';
    }

    return report;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Health Data Tracker'),
      ),
      body: SingleChildScrollView(
        // Wrap your Column with SingleChildScrollView
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextField(
                controller: _bloodPressureController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Blood Pressure (mmHg)',
                ),
              ),
              TextField(
                controller: _sugarLevelController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Sugar Level (mg/dL)',
                ),
              ),
              TextField(
                controller: _heartRateController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Heart Rate (bpm)',
                ),
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: _addData,
                child: Text('Add Data'),
              ),
              SizedBox(height: 20.0),
              Text(
                _generateHealthReport(),
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.red, // Customize the color as needed
                ),
              ),
              SizedBox(height: 20.0),
              _buildChart(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChart() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _buildChartItem(_bloodPressureData, Colors.red, 'Blood Pressure'),
          SizedBox(
              height: 30.0), // Add space between blood pressure and sugar level
          _buildChartItem(_sugarLevelData, Colors.blue, 'Sugar Level'),
          SizedBox(
              height: 30.0), // Add space between blood pressure and sugar level
          _buildChartItem(_heartRateData, Colors.green, 'Heart Rate'),
        ],
      ),
    );
  }

  Widget _buildChartItem(List<double> data, Color color, String label) {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                label,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    // Clear data from local state
                    data.clear();
                  });

                  // Remove data from Firestore
                  _removeChartDataFromFirestore(label);
                },
                child: Text('Clear'),
              ),
            ],
          ),
          SizedBox(height: 8.0),
          Stack(
            children: <Widget>[
              Sparkline(
                data: data,
                lineColor: color,
                pointsMode: PointsMode.all,
                pointSize: 8.0,
              ),
              Positioned.fill(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: data.map((value) {
                    int index = data.indexOf(value);
                    return Align(
                      alignment: Alignment(
                        (index + 0.5) / data.length * 2 - 1,
                        -1 +
                            (value - data.reduce(min)) /
                                (data.reduce(max) - data.reduce(min)) *
                                2,
                      ),
                      child: Text(
                        value.toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 10.0,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Today',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '1d',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Current: ${data.isNotEmpty ? data.first.toStringAsFixed(1) : "-"}',
                style: TextStyle(
                  color: color,
                ),
              ),
              Text(
                'Avg: ${_calculateAverage(data).toStringAsFixed(1)}',
                style: TextStyle(
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // void _removeChartDataFromFirestore(String label) async {
  //   try {
  //     final User? user = _auth.currentUser;
  //     if (user != null) {
  //       final userId = user.uid;
  //       final collectionReference = _firestore
  //           .collection('healthData')
  //           .doc(userId)
  //           .collection('dailyData');

  //       // Remove the corresponding data from Firestore based on the label
  //       QuerySnapshot querySnapshot =
  //           await collectionReference.where(label, isNotEqualTo: null).get();
  //       querySnapshot.docs.forEach((doc) {
  //         doc.reference.delete();
  //       });
  //     }
  //   } catch (e) {
  //     print('Error removing data from Firestore: $e');
  //   }
  // }

  void _removeChartDataFromFirestore(String label) async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        final userId = user.uid;
        final collectionReference = _firestore
            .collection('patients') // Use 'patients' as the main collection
            .doc(userId) // Use patient's ID as document ID
            .collection('healthData'); // Use 'healthData' as the subcollection

        // Remove the corresponding data from Firestore based on the label
        QuerySnapshot querySnapshot =
            await collectionReference.where(label, isNotEqualTo: null).get();
        querySnapshot.docs.forEach((doc) {
          doc.reference.delete();
        });
      }
    } catch (e) {
      print('Error removing data from Firestore: $e');
    }
  }
}
