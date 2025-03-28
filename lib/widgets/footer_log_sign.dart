import 'package:flutter/material.dart';

class FooterLogSign extends StatefulWidget {
  final String imageUrl;
  final Function()? onTap;

  const FooterLogSign({super.key, required this.imageUrl, this.onTap});

  @override
  State<FooterLogSign> createState() => _FooterLogSignState();
}

class _FooterLogSignState extends State<FooterLogSign> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(150),
          ),
          child: ClipRRect(child: Image.asset(widget.imageUrl)),
        ),
      ],
    );
  }
}
