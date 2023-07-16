// ignore_for_file: deprecated_member_use, unused_element

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gethelp11/auth.dart';
import 'package:gethelp11/beep.dart';
import 'package:gethelp11/contacts_page.dart';
import 'package:gethelp11/faq_page.dart';
import 'package:gethelp11/flashlight_page.dart';
import 'package:gethelp11/profile_page.dart';
import 'location_page.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  final String firstName;
  final String lastName;
  HomePage(
      {super.key,
      required List contacts,
      required String googleURL,
      required this.firstName,
      required this.lastName});

  final User? user = Auth().currentUser;

  Future<void> signOut() async {
    await Auth().signOut();
  }

  Widget _userUid() {
    return Text(user?.email ?? 'User Email');
  }

  Widget _signOutButton() {
    return ElevatedButton(onPressed: signOut, child: const Text('Sign Out'));
  }

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> contacts = [];
  bool isDarkModeEnabled = false;
  ColorScheme lightColorScheme = const ColorScheme.light();
  ColorScheme darkColorScheme = const ColorScheme.dark();
  late ThemeProvider themeProvider;
  // ignore: unused_field
  late Map<String, dynamic> _userData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    themeProvider = Provider.of<ThemeProvider>(context);
  }

  @override
  void initState() {
    super.initState();
    _userData = {
      'firstName': '',
      'lastName': '',
      'profileImage': null,
    }; // Initialize with default values or null
  }

  // final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    isDarkModeEnabled = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Get Help',
          style: TextStyle(
            color: isDarkModeEnabled ? Colors.white : Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isDarkModeEnabled ? Colors.black : Colors.green,
        actions: [
          Switch(
            value: themeProvider.isDarkModeEnabled,
            onChanged: (value) {
              setState(() {
                themeProvider.toggleDarkMode(value);
              });
            },
          ),
        ],
      ),
      body: Builder(builder: (BuildContext context) {
        bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
        Color backgroundColor = isDarkMode ? Colors.black : Colors.green;

        return Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            image: isDarkMode
                ? null
                : const DecorationImage(
                    image: AssetImage(
                        'images/bg4.jpg'), // Replace with your image path
                    fit:
                        BoxFit.cover, // Adjust the image fit property as needed
                  ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Press here to ACTIVATE:',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                Material(
                  elevation: 15,
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: SizedBox(
                    width: 200,
                    height: 200,
                    child: InkWell(
                      onTap: () {
                        // Button action
                        sendSMS();
                      },
                      child: Ink.image(
                        image: const AssetImage('images/sos.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    return DropdownButton<String>(
                      value: selectedCountry,
                      onChanged: (String? newValue) {
                        setState(() {
                          if (newValue != null) {
                            selectedCountry = newValue;
                          }
                        });
                      },
                      items: countries.map((Country country) {
                        return DropdownMenuItem<String>(
                          value: country.name,
                          child: Text(country.name),
                        );
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    final selectedEmergencyNumber = countries
                        .firstWhere(
                            (country) => country.name == selectedCountry)
                        .emergencyNumber;
                    callEmergency(selectedEmergencyNumber);
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red, // Background color
                    elevation: 10, // Shadow or elevation effect
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(20), // Rounded corners
                    ),
                  ),
                  child: const Text('Call Emergency'),
                ),
              ],
            ),
          ),
        );
      }),
      backgroundColor: themeProvider.isDarkModeEnabled ? Colors.black : null,
      drawer: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: isDarkModeEnabled ? Colors.black : Colors.green.shade300,
        ),
        child: Drawer(
          child: Container(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade900
                : Colors.green.shade300,
            child: ListView(
              children: <Widget>[
                UserAccountsDrawerHeader(
                  accountName: Text(
                    '${widget.firstName} ${widget.lastName}',
                  ),
                  accountEmail: null,
                  // currentAccountPicture: const CircleAvatar(
                  //   backgroundImage: NetworkImage(
                  //     'https://www.kindpng.com/picc/m/544-5440949_se-logo-final-rev3-icon-need-help-icon.png',
                  //   ),
                  // ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.black
                        : Colors.green,
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text('Home'),
                  onTap: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => HomePage(
                        contacts: const [],
                        googleURL: '',
                        firstName: '',
                        lastName: '',
                      ),
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Profile'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ProfilePage(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.contacts),
                  title: const Text('Contacts'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ContactsPage(contacts: contacts),
                      ),
                    ).then((updatedContacts) {
                      if (updatedContacts != null) {
                        setState(() {
                          contacts = updatedContacts;
                        });
                      }
                    });
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.surround_sound),
                  title: const Text('Beep Sound Button'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const BeepButton(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.lightbulb),
                  title: const Text('SOS flashlight'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const FlashlightPage(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.location_on),
                  title: const Text('Location'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const LocationPage(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.question_answer),
                  title: const Text('FAQ'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => HelpSupportPage(),
                      ),
                    );
                  },
                ),
                const Spacer(),
                ListTile(
                  leading: const Icon(Icons.exit_to_app),
                  title: const Text('Sign Out'),
                  onTap: widget.signOut,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void sendSMS() async {
    String message = 'Help me please!\n';
    PermissionStatus permissionStatus = await Permission.location.request();

    if (permissionStatus.isGranted) {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      double latitude = position.latitude;
      double longitude = position.longitude;

      String googleURL = 'https://maps.google.com/?q=$latitude,$longitude';

      String messageWithLocation = '$message $googleURL';

      List<String> recipients = contacts;

      String smsUri =
          'sms:${recipients.join(',')}?body=${Uri.encodeComponent(messageWithLocation)}';

      if (await canLaunch(smsUri)) {
        await launch(smsUri);
      } else {
        if (kDebugMode) {
          print('Could not launch SMS app');
        }
      }
    }
  }

  void callEmergency(String emergencyNumber) async {
    final url = 'tel:$emergencyNumber';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

class Country {
  String name;
  String emergencyNumber;

  Country({required this.name, required this.emergencyNumber});
}

List<Country> countries = [
  Country(name: 'Turkiye', emergencyNumber: '153'),
];

String selectedCountry = 'Turkiye';
final selectedCountryController = TextEditingController();

Future<String> getCurrentCountry() async {
  final position = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );

  final placemarks = await placemarkFromCoordinates(
    position.latitude,
    position.longitude,
  );

  return placemarks.first.country ?? 'Unknown';
}

class _SignOutButton extends StatelessWidget {
  final VoidCallback onSignOut;

  const _SignOutButton({required this.onSignOut});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.exit_to_app),
      title: const Text('Sign Out'),
      onTap: onSignOut,
    );
  }
}
