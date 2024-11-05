import 'package:flutter/material.dart';


class ResultPage extends StatelessWidget {
  const ResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Results"),
        centerTitle: true,
      ),
      body: const Padding(
        padding: EdgeInsets.symmetric(vertical: 12,horizontal: 20),
        child: Column(
          children: [
            ListTile(
              title: Text("Presidential",
              style: TextStyle(fontSize: 20),),
              subtitle: Text("Candidates"),
              trailing: Icon(Icons.chevron_right_rounded),
            ),
            ListTile(
              title: Text("Presidential",
              style: TextStyle(fontSize: 20),),
              subtitle: Text("Candidates"),
              trailing: Icon(Icons.chevron_right_rounded),
            ),
            ListTile(
              title: Text("Presidential",
              style: TextStyle(fontSize: 20),),
              subtitle: Text("Candidates"),
              trailing: Icon(Icons.chevron_right_rounded),
            ),
            ListTile(
              title: Text("Presidential",
              style: TextStyle(fontSize: 20),),
              subtitle: Text("Candidates"),
              trailing: Icon(Icons.chevron_right_rounded),
            ),
            ListTile(
              title: Text("Presidential",
              style: TextStyle(fontSize: 20),),
              subtitle: Text("Candidates"),
              trailing: Icon(Icons.chevron_right_rounded),
            ),
            ListTile(
              title: Text("Presidential",
              style: TextStyle(fontSize: 20),),
              subtitle: Text("Candidates"),
              trailing: Icon(Icons.chevron_right_rounded),
            ),
        
          ],
        ),
      ),
    );
  }
}