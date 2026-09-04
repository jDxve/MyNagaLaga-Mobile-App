import 'package:flutter/material.dart';
import 'package:mynagalaga_mobile_app/common/resources/dimensions.dart';

class ServicesHeader extends StatelessWidget {
  const ServicesHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Services',
      style: TextStyle(
        fontFamily: 'Segoe UI',
        fontSize: D.textXXL,
        fontWeight: D.bold,
        color: Colors.black,
      ),
    );
  }
}