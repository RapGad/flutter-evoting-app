import 'package:finalapp/helper/election_provider.dart';
import 'package:finalapp/pages/admin_home_page.dart';
import 'package:finalapp/pages/candidates_page.dart';
import 'package:finalapp/pages/categories_page.dart';
import 'package:finalapp/pages/home_page.dart';
import 'package:finalapp/pages/login_page.dart';
import 'package:finalapp/pages/splash_screen.dart';
import 'package:finalapp/services/auth_services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

const Color skyBlue = Color(0xFF006994);
const Color white = Colors.white;
const Color accentBlue = Color(0xFF4682B4);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyANaSQ1kXr6KSCEgaP7a3wGYCSDFtsZqQI",
          authDomain: "finalapp-7d8c2.firebaseapp.com",
          projectId: "finalapp-7d8c2",
          storageBucket: "finalapp-7d8c2.appspot.com",
          messagingSenderId: "510821241795",
          appId: "1:510821241795:web:d6308263b5c0668cb62376"),
    );
  } else {
    await Firebase.initializeApp();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ElectionProvider()),
      ],
      child: MaterialApp(
        initialRoute: '/',
        onGenerateRoute: (settings) {
          final args = settings.arguments as Map<String, dynamic>?;

          switch (settings.name) {
            case '/categories':
              return MaterialPageRoute(
                builder: (context) => CategoriesPage(
                  analytics: args?['analytics'] ?? false,
                  showVoteButton: args?['showVoteButton'] ?? false,
                  showResults: args?['showResults'] ?? false,
                ),
              );
            case '/candidates':
              return MaterialPageRoute(
                builder: (context) => CandidatesPage(
                  category: args?['category'] ?? '',
                  showResults: args?['showResults'] ?? false,
                  showVoteButton: args?['showVoteButton'] ?? false,
                ),
              );
            case '/login':
              return MaterialPageRoute(builder: (context) => const LoginPage());
            default:
              return MaterialPageRoute(builder: (context) => HomePage());
          }
        },
        debugShowCheckedModeBanner: false,
        scaffoldMessengerKey: scaffoldMessengerKey,
        home: StreamBuilder(
          stream: AuthService().firebaseAuth.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasData) {
              return FutureBuilder<bool>(
                future: _checkAdminStatus(snapshot.data!.email),
                builder: (context, adminSnapshot) {
                  if (adminSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(
                        child: SizedBox(
                          height: 50,
                          width: 50,
                          child: CircularProgressIndicator.adaptive(),
                        ),
                      ),
                    );
                  } else if (adminSnapshot.hasData &&
                      adminSnapshot.data == true) {
                    return const AdminHomePage();
                  } else {
                    return HomePage();
                  }
                },
              );
            } else
              // ignore: curly_braces_in_flow_control_structures
              return const SplashScreen();
          },
        ),
      ),
    );
  }
}

Future<bool> _checkAdminStatus(String? email) async {
  if (email == null) return false;
  return await AuthService().isUserAdmin(email);
}
