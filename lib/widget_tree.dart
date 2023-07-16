import 'package:gethelp11/auth.dart';
import 'package:gethelp11/home_page.dart';
import 'package:gethelp11/login_register_page.dart';
import 'package:flutter/material.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Auth().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return HomePage(
            contacts: const [],
            googleURL: '',
            firstName: '',
            lastName: '',
          );
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
