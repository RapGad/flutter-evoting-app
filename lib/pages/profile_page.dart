import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset("assets/images/student_profile.jpeg"),
            const SizedBox(height: 10),
            const Text("Jeffrey Hayford",style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold
            ),
            ),
            const Text("Bsc Information Technology, L400",
            style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),
            const Text("Running Mate",
            style: TextStyle(color: Colors.grey),
            ),
            const Text("Kwadwo Hayford",style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold
            ),
            
            ),
            const Text("Bsc Computer Science, L300",
            style: TextStyle(),
            ),

          ],
        ),
      ),
    );
  }
}