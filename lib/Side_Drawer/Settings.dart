import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: Container(
        alignment: Alignment.center,
        child: Text(
          "Work In progress",
          style: TextStyle(
            fontSize: 30,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}
