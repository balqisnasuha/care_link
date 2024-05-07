import 'package:flutter/material.dart';
import 'package:care_link/screens/doctor_detail.dart';
import 'package:care_link/screens/home.dart';

Map<String, Widget Function(BuildContext)> routes = {
  '/': (context) => Home(),
  '/detail': (context) => SliverDoctorDetail(),
};
