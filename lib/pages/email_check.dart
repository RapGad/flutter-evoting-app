import 'package:finalapp/pages/phone_verfication.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmailCheckPage extends StatefulWidget {
  const EmailCheckPage({super.key});

  @override
  _EmailCheckPageState createState() => _EmailCheckPageState();
}

class _EmailCheckPageState extends State<EmailCheckPage> {
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;
  String errorMessage = '';

  Future<void> checkEmail() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final email = "${emailController.text}@uenr.com";
      // ignore: deprecated_member_use
      final user =
          await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      print(user);

      if (user.isNotEmpty) {
        final phoneNumber = await getUserPhoneNumber(email);
        if (phoneNumber != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  PhoneVerificationPage(phoneNumber: phoneNumber),
            ),
          );
        } else {
          setState(() {
            errorMessage = 'No phone number associated with this email.';
          });
        }
      } else {
        setState(() {
          errorMessage = 'No user found with this email.';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error checking email: $e';
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<String?> getUserPhoneNumber(String email) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        return user.phoneNumber;
      }
    } catch (e) {
      print('Error fetching phone number: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Check Email')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : checkEmail,
              child:
                  isLoading ? CircularProgressIndicator() : Text('Check Email'),
            ),
            if (errorMessage.isNotEmpty) ...[
              SizedBox(height: 20),
              Text(errorMessage, style: TextStyle(color: Colors.red)),
            ],
          ],
        ),
      ),
    );
  }
}
