import 'package:finalapp/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController studentIdController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  String? selectedLevel;

  List<String> levels = ['100', '200', '300', '400'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          "Sign Up",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildTextField(
                controller: emailController,
                labelText: "Student ID",
                prefixIcon: Icons.mail,
              ),
              const SizedBox(height: 20),
              _buildPhoneNumberField(
                controller: phoneNumberController,
                labelText: "Phone Number",
                prefixIcon: Icons.phone,
              ),
              const SizedBox(height: 20),
              _buildDropdownField(
                labelText: "Level",
                icon: Icons.school,
                value: selectedLevel,
                onChanged: (value) {
                  setState(() {
                    selectedLevel = value as String?;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  // Implement your sign-up logic here
                  AuthService().register('${emailController.text}@uenr.com',
                      phoneNumberController.text, selectedLevel!, context);
                },
                child: const Text("Sign Up"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
  }) {
    return Card(
      elevation: 5,
      color: Colors.blue,
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: const TextStyle(color: Colors.white),
          prefixIcon: Icon(prefixIcon, color: Colors.white),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildPhoneNumberField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
  }) {
    return Card(
      elevation: 5,
      color: Colors.blue,
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        keyboardType: TextInputType.phone,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: const TextStyle(color: Colors.white),
          prefixIcon: Icon(prefixIcon, color: Colors.white),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String labelText,
    required IconData icon,
    required String? value,
    required ValueChanged? onChanged,
  }) {
    return Card(
      elevation: 5,
      color: Colors.blue,
      child: DropdownButtonFormField(
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: const TextStyle(color: Colors.white),
          prefixIcon: Icon(icon, color: Colors.white),
          border: InputBorder.none,
        ),
        value: value,
        items: levels.map((String level) {
          return DropdownMenuItem(
            value: level,
            child: Text(
              level,
              style: const TextStyle(color: Colors.white),
            ),
          );
        }).toList(),
        onChanged: onChanged as void Function(String?)?,
        dropdownColor: Colors.blue,
        style: const TextStyle(color: Colors.white),
        iconEnabledColor: Colors.white,
        iconSize: 30,
      ),
    );
  }
}
