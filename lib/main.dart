import 'package:flutter/material.dart';
import 'src/init/init.dart';

void main() {
  runApp(OTStudio());
}

class OTStudio extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OTStudio',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: Init(),
    );
  }
}
