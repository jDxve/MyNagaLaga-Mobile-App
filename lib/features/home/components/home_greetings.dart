import 'package:flutter/material.dart';
import 'package:mynagalaga_mobile_app/common/resources/dimensions.dart';
import 'package:mynagalaga_mobile_app/common/resources/strings.dart';

Widget greetingText({String userName = ''}) {
  final hour = DateTime.now().hour;
  final greeting = hour < 12 ? AppString.aga : AppString.bangi;

  String displayName = '';
  if (userName.isNotEmpty) {
    final nameParts = userName.trim().split(' ');
    if (nameParts.length >= 2) {
      displayName = '${nameParts[0]} ${nameParts[1]}';
    } else {
      displayName = nameParts[0];
    }
  }
  
  return Text(
    '$greeting,\n$displayName !'.trim(),
    style: TextStyle(
      fontFamily: 'Segoe UI',
      fontSize: D.textXXL,
      fontWeight: D.extraBold,
    ),
  );
}