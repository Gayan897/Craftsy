import 'package:flutter/material.dart';

class FrontPage extends StatelessWidget {
  const FrontPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          "Assets/craftsy-main.png",
          width: 200,
          fit: BoxFit.cover,
        ),
        Center(
          child: Text("Craftsy",
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 219, 158, 27),
              )),
        )
      ],
    );
  }
}
