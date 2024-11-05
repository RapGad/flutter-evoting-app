import 'package:finalapp/main.dart';
import 'package:finalapp/pages/admin_home_page.dart';
import 'package:finalapp/pages/get_user_number.dart';
import 'package:finalapp/pages/home_page.dart';
import 'package:finalapp/pages/sign_up_page.dart';
import 'package:finalapp/services/auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController studentIdController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  bool _showPassword = false;
  bool _isBiometricSupported = false;
  bool _useBiometrics = false;

  final secureStorage = const FlutterSecureStorage();
  final localAuth = LocalAuthentication();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkBiometricSupport();
  }

  @override
  void dispose() {
    // Dispose of controllers to prevent memory leaks
    studentIdController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkBiometricSupport() async {
    // final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    bool isSupported = false;

    try {
      if (Theme.of(context).platform == TargetPlatform.iOS ||
          Theme.of(context).platform == TargetPlatform.android) {
        isSupported = await localAuth.canCheckBiometrics ||
            await localAuth.isDeviceSupported();
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() {
      _isBiometricSupported = isSupported;
    });
  }

  Future<void> _authenticateWithBiometrics() async {
    bool authenticated = false;

    try {
      authenticated = await localAuth.authenticate(
        localizedReason: 'Use your fingerprint to authenticate',
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error during biometric authentication: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }

    if (authenticated) {
      // Load credentials from secure storage
      await _loadCredentials();
      _login();
    }
  }

  Future<void> _saveCredentials(String studentId, String password) async {
    await secureStorage.write(key: 'email', value: studentId);
    await secureStorage.write(key: 'password', value: password);
  }

  Future<void> _loadCredentials() async {
    String? email = await secureStorage.read(key: 'email');
    String? password = await secureStorage.read(key: 'password');

    if (email != null && password != null) {
      setState(() {
        studentIdController.text = email;
        passwordController.text = password;
      });
    }
  }

  void _login() async {
    setState(() {
      isLoading = true;
    });

    try {
      if (studentIdController.text.isEmpty || passwordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("All fields are required"),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        User? result = await AuthService().login(
          '${studentIdController.text}@uenr.com',
          passwordController.text,
          context,
        );
        bool isAdmin = await AuthService()
            .isUserAdmin('${studentIdController.text}@uenr.com');
        if (result != null && !isAdmin) {
          _saveCredentials(studentIdController.text, passwordController.text);
          Navigator.pushAndRemoveUntil(
            // ignore: use_build_context_synchronously
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
            (route) => false,
          );
        }
        if (result != null && isAdmin) {
          Navigator.pushAndRemoveUntil(
            // ignore: use_build_context_synchronously
            context,
            MaterialPageRoute(builder: (context) => const AdminHomePage()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error logging in: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: skyBlue,
      appBar: AppBar(
        backgroundColor: skyBlue,
        title: const Text(
          "Sign in",
          style: TextStyle(
            color: white,
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
            children: [
              Container(
                alignment: Alignment.centerLeft,
                child: const Text(
                  "Student Id",
                  style: TextStyle(
                    color: white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Card(
                elevation: 5,
                color: skyBlue,
                child: TextField(
                  controller: studentIdController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: "Enter your Student Id",
                    hintStyle: TextStyle(color: Colors.white),
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.mail, color: white),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Container(
                alignment: Alignment.centerLeft,
                child: const Text(
                  "Password",
                  style: TextStyle(
                    fontSize: 18,
                    color: white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Card(
                elevation: 5,
                color: skyBlue,
                child: TextField(
                  controller: passwordController,
                  obscureText: !_showPassword,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Enter your Password",
                    hintStyle: const TextStyle(color: Colors.white),
                    border: InputBorder.none,
                    prefixIcon: const Icon(Icons.lock, color: white),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showPassword ? Icons.visibility : Icons.visibility_off,
                        color: white,
                      ),
                      onPressed: () {
                        setState(() {
                          _showPassword = !_showPassword;
                        });
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const GetUserNumber()),
                    );
                  },
                  child: const Text(
                    "Forgot Password",
                    style: TextStyle(fontSize: 12, color: white),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _login,
                      style: const ButtonStyle(
                        minimumSize: WidgetStatePropertyAll(Size(300, 50)),
                      ),
                      child: const Text(
                        "LOGIN",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: skyBlue,
                        ),
                      ),
                    ),
              const SizedBox(height: 20),
              if (_isBiometricSupported)
                Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _useBiometrics = !_useBiometrics;
                        });
                      },
                      icon: const Icon(Icons.fingerprint),
                      label: Text(
                        _useBiometrics
                            ? "Disable Biometrics"
                            : "Enable Biometrics",
                      ),
                    ),
                    if (_useBiometrics)
                      ElevatedButton.icon(
                        onPressed: _authenticateWithBiometrics,
                        icon: const Icon(Icons.fingerprint),
                        label: const Text("Login with Biometrics"),
                      ),
                  ],
                ),
              const SizedBox(height: 20),
              RichText(
                text: TextSpan(
                  text: "Don't have an account? ",
                  style: const TextStyle(color: Colors.white),
                  children: [
                    TextSpan(
                      text: "Sign Up",
                      style: const TextStyle(
                        color: Colors.white,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignUpPage()),
                          );
                        },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
