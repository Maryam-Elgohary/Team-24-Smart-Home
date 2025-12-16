import 'package:flutter/material.dart';

void BuildSnackBar(BuildContext context, String messege) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      duration: Duration(seconds: 1),
      content: Text(messege),
    ),
  );
}
