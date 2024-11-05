import 'package:finalapp/pages/password_reset.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Add Firestore if you are using it

class OtpVerificationPage extends StatefulWidget {
  final String phoneNumber;
  const OtpVerificationPage({required this.phoneNumber, super.key});

  @override
  // ignore: library_private_types_in_public_api
  _OtpVerificationPageState createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final TextEditingController otpController = TextEditingController();
  String verificationId = '';

  @override
  void initState() {
    super.initState();
    checkPhoneNumberAndVerify();
  }

  Future<void> checkPhoneNumberAndVerify() async {
    bool isPhoneNumberLinked =
        await isPhoneNumberLinkedToAccount(widget.phoneNumber);

    if (isPhoneNumberLinked) {
      verifyPhoneNumber();
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Phone number is not linked to any account')),
      );
      // ignore: use_build_context_synchronously
      Navigator.pop(context); // Go back to the previous screen
    }
  }

  Future<bool> isPhoneNumberLinkedToAccount(String phoneNumber) async {
    try {
      // Check if the phone number is linked to any user
      // ignore: deprecated_member_use
      List<String> methods =
          // ignore: deprecated_member_use
          await FirebaseAuth.instance.fetchSignInMethodsForEmail(phoneNumber);
      return methods.isNotEmpty;
    } catch (e) {
      print('Error checking phone number: $e');
      return false;
    }
  }

  Future<void> verifyPhoneNumber() async {
    FirebaseAuth auth = FirebaseAuth.instance;

    await auth.verifyPhoneNumber(
      phoneNumber: widget.phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-resolve if the verification code is sent to the device
        await auth.signInWithCredential(credential);
        navigateToPasswordReset();
      },
      verificationFailed: (FirebaseAuthException e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification failed. Reason: ${e.message}')),
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          this.verificationId = verificationId;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification code sent')),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(() {
          this.verificationId = verificationId;
        });
      },
    );
  }

  Future<void> verifyOtp() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    String smsCode = otpController.text.trim();

    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    if (otpController.text.isEmpty) {
      try {
        await auth.signInWithCredential(credential);
        navigateToPasswordReset();
      } catch (e) {
        // ignore: use_build_context_synchronously
        //ScaffoldMessenger.of(context).showSnackBar(
        //SnackBar(content: Text('Failed to sign in. Reason: $e')),
        //);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Input is Empty')),
      );
    }
  }

  void navigateToPasswordReset() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) =>
              PasswordResetPage(phoneNumber: widget.phoneNumber)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: otpController,
              decoration: const InputDecoration(labelText: 'Enter OTP'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: verifyOtp,
              child: const Text('Verify OTP'),
            ),
          ],
        ),
      ),
    );
  }
}
