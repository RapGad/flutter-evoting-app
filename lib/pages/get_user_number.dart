import 'package:finalapp/main.dart';
import 'package:finalapp/pages/verification_page.dart';
import 'package:flutter/material.dart';

class GetUserNumber extends StatefulWidget {
  const GetUserNumber({super.key});

  @override
  State<GetUserNumber> createState() => _GetUserNumberState();
}

class _GetUserNumberState extends State<GetUserNumber> {
  TextEditingController phoneNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: skyBlue,
      body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              elevation: 5,
              color: skyBlue,
              child: TextField(
                controller: phoneNumberController,
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                  hintText: "Enter your Phone number",
                  hintStyle: TextStyle(color: Colors.white),
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.phone, color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
                onPressed: () {
                  if (phoneNumberController.text.isEmpty) {
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
                          builder: (context) => OtpVerificationPage(
                                phoneNumber:
                                    '+233${phoneNumberController.text.trim().substring(1)}',
                              )),
                    );
                  }
                },
                child: const Text("Verify number"))
          ]),
    );
  }
}
