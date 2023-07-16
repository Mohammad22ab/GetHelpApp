// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactsPage extends StatefulWidget {
  final List<String> contacts;

  const ContactsPage({Key? key, required this.contacts}) : super(key: key);

  @override
  _ContactsPageState createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  final TextEditingController _phoneNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadContacts();
    _checkPermissionStatus();
  }

  Future<void> _loadContacts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedContacts = prefs.getStringList('contacts');
    if (savedContacts != null) {
      setState(() {
        widget.contacts.clear();
        widget.contacts.addAll(savedContacts);
      });
    }
  }

  Future<void> _saveContacts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('contacts', widget.contacts);
  }

  void addContact(String phoneNumber) {
    setState(() {
      if (widget.contacts.length < 5) {
        widget.contacts.add(phoneNumber);
        _saveContacts();
      }
    });
  }

  void deleteContact(int index) {
    setState(() {
      widget.contacts.removeAt(index);
      _saveContacts();
    });
  }

  void editContact(int index, String newPhoneNumber) {
    setState(() {
      widget.contacts[index] = newPhoneNumber;
      _saveContacts();
    });
  }

  Future<void> _importContacts() async {
    PermissionStatus status = await Permission.contacts.request();

    if (status.isGranted) {
      final Iterable<Contact> contacts = await ContactsService.getContacts();
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Import Contacts'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: contacts
                    .map(
                      (contact) => ListTile(
                        title: Text(
                          contact.displayName ?? '',
                        ),
                        subtitle: Text(
                          contact.phones?.isNotEmpty == true
                              ? contact.phones!.first.value ?? ''
                              : '',
                        ),
                        onTap: () {
                          if (widget.contacts.length < 5) {
                            addContact(
                              contact.phones?.isNotEmpty == true
                                  ? contact.phones!.first.value ?? ''
                                  : '',
                            );
                          }
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Permission Required'),
            content: const Text('Please grant permission to access contacts.'),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void _addPhoneNumberManually() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Phone Number'),
          content: TextFormField(
            controller: _phoneNumberController,
            decoration: const InputDecoration(
              hintText: 'Enter Phone Number',
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter a phone number';
              }
              return null;
            },
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                String phoneNumber = _phoneNumberController.text;
                addContact(phoneNumber);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _checkPermissionStatus() async {
    PermissionStatus status = await Permission.contacts.status;
    if (status.isGranted) {
      // Permission already granted, proceed with your logic
    } else if (status.isDenied) {
      // Permission denied, handle accordingly
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
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
          itemCount: widget.contacts.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(widget.contacts[index]),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      // ignore: unused_local_variable
                      String currentPhoneNumber = widget.contacts[index];
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Edit Contact'),
                            content: TextFormField(
                              controller: _phoneNumberController,
                              decoration: const InputDecoration(
                                hintText: 'Enter Phone Number',
                              ),
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please enter a phone number';
                                }
                                return null;
                              },
                            ),
                            actions: <Widget>[
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  String newPhoneNumber =
                                      _phoneNumberController.text;
                                  editContact(index, newPhoneNumber);
                                  Navigator.of(context).pop();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),
                                child: const Text('Save'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      deleteContact(index);
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _importContacts,
            backgroundColor: Colors.green,
            child: const Icon(
              Icons.import_contacts,
              size: 30,
            ),
          ),
          const SizedBox(height: 10),
          Hero(
            tag: 'myTag',
            child: FloatingActionButton(
              heroTag: null,
              onPressed: _addPhoneNumberManually,
              backgroundColor: Colors.green,
              child: const Icon(
                Icons.add,
                size: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
