import 'package:flutter/material.dart';

class Textfields extends StatelessWidget {
  final TextEditingController textEditingController;
  final bool isPass;
  final String hintText;
  final IconData icon;
  const Textfields(
      {super.key,
      required this.textEditingController,
      this.isPass = false,
      required this.hintText,
      required this.icon});

  @override 
  Widget build(BuildContext context) {
    return TextField(
        obscureText:
            isPass, //The obscureText property in a TextField widget in Flutter is used to hide the text input, making it suitable for password fields or any sensitive information.
        controller: textEditingController,
        decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
            prefixIcon: Icon(
              icon,
              color: const Color.fromARGB(255, 0, 0, 0),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(100),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.blue,
              ),
              borderRadius: BorderRadius.circular(40),
            )));
  }
}
