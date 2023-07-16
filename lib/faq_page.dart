import 'package:flutter/material.dart';

class HelpSupportPage extends StatelessWidget {
  final List<FaqItem> faqItems = [
    FaqItem(
      question: 'How do I add contacts?',
      answer:
          'To add contacts, go to the Contacts page and tap on the Add button. Enter the name and phone number of the contact, then tap Save.',
    ),
    FaqItem(
      question: 'How do I turn on location services?',
      answer:
          'To turn on location services, go to the Settings app on your device. Find the Location settings and make sure it is enabled.',
    ),
    FaqItem(
      question: 'How do I activate the app and send the emergency?',
      answer:
          'In order to send the emergency message, 4 steps must be done:\n1- Add contacts in the contacts apge.\n2- Turn on location permission.\n3- Press on SOS button in the home page.\n4- Just send the message filled in the messages app.',
    ),
    FaqItem(
        question: 'In which platforms does this app works?',
        answer:
            'For now this app works only on Android platform, later on it will be available on IOS.'),
    // Add more FAQ items as needed
  ];

  HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FAQ'),
        backgroundColor: Colors.green,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/bg2.png'),
            fit: BoxFit.cover, // Adjust the image fit property as needed
          ),
        ),
        child: ListView.builder(
          itemCount: faqItems.length,
          itemBuilder: (BuildContext context, int index) {
            return ExpansionTile(
              title: Text(faqItems[index].question),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(faqItems[index].answer),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class FaqItem {
  final String question;
  final String answer;

  FaqItem({
    required this.question,
    required this.answer,
  });
}
