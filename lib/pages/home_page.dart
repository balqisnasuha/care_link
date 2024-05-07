import 'package:flutter/material.dart';
import 'package:care_link/routes/router.dart';
import 'package:care_link/utils/textscale.dart';
import 'package:care_link/screens/home.dart';
import 'package:care_link/screens/doctor_home.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       actions: [
  //         IconButton(
  //           onPressed: signUserOut,
  //           icon: Icon(Icons.logout),
  //         )
  //       ],
  //     ),
  //     body: Center(
  //       child: Text(
  //         "Logged in as: " + user.email!,
  //         style: TextStyle(fontSize: 20),
  //       ),
  //     ),
  //   );
  // }

  // @override
  // Widget build(BuildContext context) {
  //   return MaterialApp(
  //     builder: fixTextScale,
  //     debugShowCheckedModeBanner: false,
  //     initialRoute: '/',
  //     routes: routes,
  //     // home: Scaffold(
  //     //   appBar: AppBar(
  //     //     actions: [
  //     //       IconButton(
  //     //         onPressed: signUserOut,
  //     //         icon: Icon(Icons.logout),
  //     //       )
  //     //     ],
  //     //),
  //     // body: Center(
  //     //   child: Text(
  //     //     "Logged in as: ${user.email!}",
  //     //     style: TextStyle(fontSize: 20),
  //     //   ),
  //     // ),
  //     //),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: fixTextScale,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: routes,
    );
  }
}
