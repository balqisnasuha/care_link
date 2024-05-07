import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chart_sparkline/chart_sparkline.dart';
import 'dart:math';

class HealthStatusPage extends StatefulWidget {
  final String patientId;

  const HealthStatusPage({Key? key, required this.patientId}) : super(key: key);

  @override
  _HealthStatusPageState createState() => _HealthStatusPageState();
}

class _HealthStatusPageState extends State<HealthStatusPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late List<double> _bloodPressureData;
  late List<double> _sugarLevelData;
  late List<double> _heartRateData;

  @override
  void initState() {
    super.initState();
    _fetchHealthData();
  }

  void _fetchHealthData() async {
    try {
      final querySnapshot = await _firestore
          .collection('patients')
          .doc(widget.patientId)
          .collection('healthData')
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
    } catch (e) {
      print('Error fetching health data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Health Status'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildChartItem(_bloodPressureData, Colors.red, 'Blood Pressure'),
            SizedBox(height: 30.0),
            _buildChartItem(_sugarLevelData, Colors.blue, 'Sugar Level'),
            SizedBox(height: 30.0),
            _buildChartItem(_heartRateData, Colors.green, 'Heart Rate'),
          ],
        ),
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
}
