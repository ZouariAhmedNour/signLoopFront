import 'package:flutter/material.dart';

class CustomTextForm extends StatelessWidget {
  final  String hinttext;
  final TextEditingController mycontroller;
  const CustomTextForm({super.key, required this.hinttext, required this.mycontroller});

  @override
  Widget build(BuildContext context) {
    return  TextFormField(
      controller: mycontroller,
  decoration : InputDecoration(
    hintText: hinttext,
    hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    filled: true,
    fillColor: Colors.grey[200],
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(
        color: Colors.grey,
      ),
    ),
  ),
);
  }
}

