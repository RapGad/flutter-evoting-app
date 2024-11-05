import 'package:finalapp/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PasswordCreatePage extends StatefulWidget {
  const PasswordCreatePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PasswordCreatePageState createState() => _PasswordCreatePageState();
}

class _PasswordCreatePageState extends State<PasswordCreatePage> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  Future<String> resetPassword() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    String value = "";

    if (user != null) {
      if (passwordController.text.isEmpty ||
          confirmPasswordController.text.isEmpty)
        return value = "Password is empty";
      if (passwordController.text != confirmPasswordController.text)
        return "Password does not match";

      try {
        await user.updatePassword(passwordController.text);
        // Navigate to the login page or show a success message
        Navigator.pushReplacement(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
        return value = "Password set successful";
      } catch (error) {
        // Handle error
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: Unexpected error Occured')),
        );
        return value;
      }
    }

    return value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Password')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: confirmPasswordController,
              decoration: const InputDecoration(labelText: 'Confirm Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String value = await resetPassword();
                if (!mounted) return;

                value.isNotEmpty
                    // ignore: use_build_context_synchronously
                    ? ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(value)),
                      )
                    // ignore: use_build_context_synchronously
                    : ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(value)),
                      );
              },
              child: const Text('Set New Password'),
            ),
          ],
        ),
      ),
    );
  }
}
