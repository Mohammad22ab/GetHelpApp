import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gethelp11/theme_provider.dart';
// import 'package:gethelp11/home_page.dart';
import 'package:gethelp11/widget_tree.dart';
import 'package:provider/provider.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_sms/flutter_sms.dart';
// import 'package:gethelp11/contacts_page.dart';
// import 'package:flutter/foundation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        // Add other providers if needed...
      ],
      child: MyApp(),
    ),
  );
}

// ignore: must_be_immutable
class MyApp extends StatelessWidget {
  MyApp({super.key});
  bool isDarkModeEnabled = false;
  ColorScheme lightColorScheme = const ColorScheme.light();
  ColorScheme darkColorScheme = const ColorScheme.dark(
    primary: Colors.grey,
    secondary: Colors.blueGrey,
    background: Colors.black,
    surface: Color.fromARGB(255, 37, 37, 37),
    onBackground: Colors.white,
    onSurface: Colors.white,
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: Provider.of<ThemeProvider>(context).isDarkModeEnabled
          ? ThemeData.dark()
          : ThemeData.light(),

      title: 'Get Help App',
      // theme: ThemeData(
      //   primarySwatch: Colors.blue,
      // ),
      home: const WidgetTree(),
    );
  }
}
