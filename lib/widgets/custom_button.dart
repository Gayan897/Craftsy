import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  // ignore: non_constant_identifier_names
  final String ButtonName;
  final Color buttonColor;
  const CustomButton(
      {super.key, required this.ButtonName, required this.buttonColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      height:
          MediaQuery.of(context).size.height * 0.06, //set the height to button
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: buttonColor,
      ),
      child: Center(
        child: Text(
          ButtonName,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
