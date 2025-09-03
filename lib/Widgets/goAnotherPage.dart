import 'package:flutter/material.dart';

goAnotherPage({required context, required Widget page, required bool isRoute}) {
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (context) => page),
    (route) => isRoute,
  );
}
