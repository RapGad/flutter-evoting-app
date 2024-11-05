import 'package:finalapp/pages/password_create.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PhoneVerificationPage extends StatefulWidget {
  final String phoneNumber;

  const PhoneVerificationPage({super.key, required this.phoneNumber});

  @override
  // ignore: library_private_types_in_public_api
  _PhoneVerificationPageState createState() => _PhoneVerificationPageState();
}

class _PhoneVerificationPageState extends State<PhoneVerificationPage> {
  final TextEditingController codeController = TextEditingController();
  String? verificationId;

  @override
  void initState() {
    super.initState();
    verifyPhoneNumber();
  }

  Future<void> verifyPhoneNumber() async {
    FirebaseAuth auth = FirebaseAuth.instance;

    await auth.verifyPhoneNumber(
      phoneNumber: widget.phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Automatically sign in the user and update the phone number
        await auth.currentUser?.updatePhoneNumber(credential);
        // ignore: use_build_context_synchronously
        Navigator.pop(context); // Go back to the previous screen
      },
      verificationFailed: (FirebaseAuthException e) {
        if (e.code == 'invalid-phone-number') {
          print('The provided phone number is not valid.');
        }
        print('Error: $e');
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          this.verificationId = verificationId;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(() {
          this.verificationId = verificationId;
        });
      },
    );
  }

  Future<void> signInWithPhoneNumber() async {
    FirebaseAuth auth = FirebaseAuth.instance;

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId!,
        smsCode: codeController.text,
      );

      // Link the credential with the existing user
      await auth.currentUser?.linkWithCredential(credential);

      // Navigate to a success page or show a success message
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Phone number verified and linked successfully.'),
            backgroundColor: Colors.green),
      );
      //Navigator.pop(context); // Go back to the previous screen
      Navigator.push(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (context) => const PasswordCreatePage()),
      );
    } catch (e) {
      print('Error: $e');
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Invalid code. Please try again.'),
            backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Phone Number')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Verification code sent to ${widget.phoneNumber}'),
            TextField(
              controller: codeController,
              decoration: const InputDecoration(labelText: 'Verification Code'),
            ),
            ElevatedButton(
              onPressed: signInWithPhoneNumber,
              child: const Text('Verify Code'),
            ),
          ],
        ),
      ),
    );
  }
}
