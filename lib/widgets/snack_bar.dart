import 'package:flutter/material.dart';

showSnackBar(BuildContext context, String text) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(text),
    ),
  );
  //The primary purpose of the showSnackBar function is to show a temporary message (SnackBar) at the bottom of the screen. This is useful for providing feedback to users, such as confirming an action or alerting them to an event.
}
