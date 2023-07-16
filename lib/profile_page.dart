// ignore_for_file: library_private_types_in_public_api, unused_field

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gethelp11/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _bloodTypeController;
  late TextEditingController _allergiesController;
  late TextEditingController _weightController;
  late TextEditingController _heightController;
  late DateTime _selectedDate;
  String? _selectedGender;
  File? _image;

  bool _isEditing = false;

  String? _firstName;
  String? _lastName;

  List<String> bloodTypes = ['O+', 'O-', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-'];
  String? _selectedBloodType;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _bloodTypeController = TextEditingController();
    _allergiesController = TextEditingController();
    _weightController = TextEditingController();
    _heightController = TextEditingController();
    _selectedDate = DateTime.now();
    _selectedGender = '';
    _loadProfileData();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _bloodTypeController.dispose();
    _allergiesController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? profileData = prefs.getString('profile');
    if (profileData != null) {
      Map<String, dynamic> profile = jsonDecode(profileData);
      setState(() {
        _firstNameController.text = profile['firstName'];
        _lastNameController.text = profile['lastName'];
        _bloodTypeController.text = profile['bloodType'] ?? '';
        _allergiesController.text = profile['allergies'] ?? '';
        _weightController.text = profile['weight'] ?? '';
        _heightController.text = profile['height'] ?? '';
        _selectedDate = DateTime.parse(profile['birthday']);
        _selectedGender = profile['gender'];
        _firstName = profile['firstName'];
        _lastName = profile['lastName'];
        _selectedBloodType = profile['bloodType'];
      });
    }
  }

  Future<void> _saveProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> profile = {
      'firstName': _firstNameController.text,
      'lastName': _lastNameController.text,
      'bloodType': _selectedBloodType,
      'allergies': _allergiesController.text,
      'weight': _weightController.text,
      'height': _heightController.text,
      'birthday': _selectedDate.toIso8601String(),
      'gender': _selectedGender,
    };
    String profileData = jsonEncode(profile);
    await prefs.setString('profile', profileData);

    // Save profile data to Firestore
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    String userId =
        'n2jxiZSW5q2OvyLVzHCd'; // Replace with the user ID of the logged-in user

    firestore.collection('users').doc(userId).set(profile);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _selectImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _editProfile() {
    setState(() {
      _isEditing = true;
    });
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      _saveProfileData();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(
            firstName: _firstNameController.text,
            lastName: _lastNameController.text,
            contacts: [],
            googleURL: '',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            onPressed: _editProfile,
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/bg2.png'), // Replace with your image path
            fit: BoxFit.cover, // Adjust the image fit property as needed
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                GestureDetector(
                  onTap: _isEditing ? _selectImage : null,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: _image != null ? FileImage(_image!) : null,
                    child: _image == null
                        ? Icon(Icons.person, size: 60, color: Colors.green[500])
                        : null,
                  ),
                ),
                const SizedBox(height: 16.0),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100], // Background color
                    borderRadius: BorderRadius.circular(20), // Rounded corners
                  ),
                  child: TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(labelText: 'First Name'),
                    enabled: _isEditing,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your first name';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16.0),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200], // Background color
                    borderRadius: BorderRadius.circular(20), // Rounded corners
                  ),
                  child: TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(labelText: 'Last Name'),
                    enabled: _isEditing,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your last name';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16.0),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200], // Background color
                    borderRadius: BorderRadius.circular(20), // Rounded corners
                  ),
                  child: DropdownButtonFormField<String>(
                    value: _selectedBloodType,
                    items: bloodTypes.map((bloodType) {
                      return DropdownMenuItem<String>(
                        value: bloodType,
                        child: Text(bloodType),
                      );
                    }).toList(),
                    decoration: const InputDecoration(labelText: 'Blood Type'),
                    onChanged: _isEditing
                        ? (String? value) {
                            setState(() {
                              _selectedBloodType = value;
                            });
                          }
                        : null,
                  ),
                ),
                const SizedBox(height: 16.0),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200], // Background color
                    borderRadius: BorderRadius.circular(20), // Rounded corners
                  ),
                  child: TextFormField(
                    controller: _allergiesController,
                    decoration: const InputDecoration(labelText: 'Allergies'),
                    enabled: _isEditing,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your allergies';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16.0),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200], // Background color
                    borderRadius: BorderRadius.circular(20), // Rounded corners
                  ),
                  child: TextFormField(
                    controller: _weightController,
                    decoration: const InputDecoration(labelText: 'Weight'),
                    enabled: _isEditing,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your weight';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16.0),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200], // Background color
                    borderRadius: BorderRadius.circular(20), // Rounded corners
                  ),
                  child: TextFormField(
                    controller: _heightController,
                    decoration: const InputDecoration(labelText: 'Height'),
                    enabled: _isEditing,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your height';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16.0),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200], // Background color
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                  ),
                  child: GestureDetector(
                    onTap: _isEditing ? () => _selectDate(context) : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12.0, horizontal: 16.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Text(
                        'Selected Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}',
                        style: const TextStyle(fontSize: 16.0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200], // Background color
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                  ),
                  child: Column(
                    children: <Widget>[
                      ListTile(
                        title: const Text('Male'),
                        leading: Radio<String>(
                          value: 'Male',
                          groupValue: _selectedGender,
                          onChanged: _isEditing
                              ? (String? value) {
                                  setState(() {
                                    _selectedGender = value;
                                  });
                                }
                              : null,
                        ),
                      ),
                      ListTile(
                        title: const Text('Female'),
                        leading: Radio<String>(
                          value: 'Female',
                          groupValue: _selectedGender,
                          onChanged: _isEditing
                              ? (String? value) {
                                  setState(() {
                                    _selectedGender = value;
                                  });
                                }
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16.0),
                if (_isEditing)
                  ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, // Background color
                      elevation: 10, // Shadow or elevation effect
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(20), // Rounded corners
                      ),
                    ),
                    child: const Text('Save'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
