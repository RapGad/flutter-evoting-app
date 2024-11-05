import 'package:finalapp/main.dart';
import 'package:finalapp/pages/verification_page.dart';
import 'package:flutter/material.dart';

class PhoneVerificationPage extends StatefulWidget {
  const PhoneVerificationPage({super.key, required String phoneNumber});

  @override
  _PhoneVerificationPageState createState() => _PhoneVerificationPageState();
}

class _PhoneVerificationPageState extends State<PhoneVerificationPage> {
  final TextEditingController phoneController = TextEditingController();

  void sendOtp() {
    if (phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Input is empty'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              OtpVerificationPage(phoneNumber: phoneController.text),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: skyBlue,
      appBar: AppBar(title: const Text('Forgot Password')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: phoneController,
              decoration:
                  const InputDecoration(labelText: 'Enter your phone number'),
            ),
            ElevatedButton(
              onPressed: sendOtp,
              child: const Text('Send OTP'),
            ),
          ],
        ),
      ),
    );
  }
}
