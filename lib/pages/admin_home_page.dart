
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finalapp/main.dart';
import 'package:finalapp/pages/admin_creation_page.dart';
import 'package:finalapp/pages/delete_user.dart';
import 'package:finalapp/pages/login_page.dart';
import 'package:finalapp/pages/update.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DeleteUser(
          onDelete: (levelToDelete) async {
            // Perform the delete operation here
            try {
              await _deleteUsersAtLevel(levelToDelete);

              levelToDelete != 0
                  ?
                  // ignore: use_build_context_synchronously
                  scaffoldMessengerKey.currentState!.showSnackBar(
                      const SnackBar(
                        content: Text('Deletion Successful'),
                        duration: Duration(seconds: 2),
                      ),
                    )
                  : scaffoldMessengerKey.currentState!.showSnackBar(
                      const SnackBar(
                        content: Text('Deletion not Successful'),
                        duration: Duration(seconds: 2),
                      ),
                    );
            } catch (e) {
              // ignore: use_build_context_synchronously
              scaffoldMessengerKey.currentState!.showSnackBar(
                const SnackBar(
                  content: Text('Deletion not successful'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
        );
      },
    );
  }

  void _showUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return UpdateLevelDialog(
          onUpdate: (int from, int to) async {
            try {
              // Perform the update operation here
              await _updateUsersLevel(from, to);
              scaffoldMessengerKey.currentState!.showSnackBar(
                SnackBar(
                  content: Text('Users updated successfully'),
                  duration: Duration(seconds: 2),
                ),
              );
            } catch (e) {
              scaffoldMessengerKey.currentState!.showSnackBar(
                SnackBar(
                  content: Text('Users not Updated'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
        );
      },
    );
  }

  Future<void> _updateUsersLevel(int from, int to) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      // Query users with 'level' equal to 'from'

      QuerySnapshot usersSnapshot = await firestore
          .collection('elections')
          .doc('election2024')
          .collection('users')
          .where('level', isEqualTo: from.toString())
          .get();

      // Update each user found
      List<Future<void>> updateTasks = [];
      usersSnapshot.docs.forEach((userDoc) {
        updateTasks.add(userDoc.reference.update({
          'level': to.toString(),
        }));
      });

      // Execute all update tasks
      await Future.wait(updateTasks);

      ScaffoldMessenger(child: Text("Update successful"));
    } catch (e) {
      print('Failed to update users: $e');
    }
  }

  Future<void> _deleteUsersAtLevel(int levelToDelete) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    try {
      // Query users with 'level' equal to 'levelToDelete'
      QuerySnapshot usersSnapshot = await firestore
          .collection('elections')
          .doc('election2024')
          .collection('users')
          .where('level', isEqualTo: levelToDelete.toString())
          .get();

      // Print number of documents found
      print('Documents found to delete: ${usersSnapshot.docs.length}');

      // Print data of each document to be deleted
      usersSnapshot.docs.forEach((DocumentSnapshot document) {
        Map<String, dynamic> userData = document.data() as Map<String, dynamic>;
        print('Document ID: ${document.id}');
        print('Data: $userData');
      });

      // Delete each user found
      List<Future<void>> deleteTasks = [];

      usersSnapshot.docs.forEach((userDoc) {
        deleteTasks.add(userDoc.reference.delete());
      });

      // Execute all delete tasks
      await Future.wait(deleteTasks);

      print('Users deleted successfully');
    } catch (e) {
      print('Failed to delete users: $e');
    }
  }

  Future<void> _toggleResultAvailable() async {
    setState(() {
      _isLoading = true;
    });

    try {
      DocumentReference documentReference = FirebaseFirestore.instance
          .collection('elections')
          .doc('election2024');
      DocumentSnapshot documentSnapshot = await documentReference.get();

      print(documentSnapshot.data());

      if (documentSnapshot.exists) {
        bool currentResultAvailable = documentSnapshot.get('resultsAvailable');
        bool newResultAvailable = !currentResultAvailable;

        await documentReference
            .update({'resultsAvailable': newResultAvailable});
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "Results is ${newResultAvailable ? "released" : "withheld"}"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Document does not exist"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error updating result status: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Page"),
        actions: [
          TextButton.icon(
            onPressed: () async {
              await _auth.signOut();
              Navigator.pushAndRemoveUntil(
                // ignore: use_build_context_synchronously
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout),
            label: const Text("SignOut"),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AdminPage()));
              },
              child: const SizedBox(
                width: 250,
                height: 70,
                child: Card(
                  elevation: 7,
                  child: Center(
                    child: Text(
                      "Create Election",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                _showDeleteDialog(context);
              },
              child: const SizedBox(
                width: 250,
                height: 70,
                child: Card(
                  elevation: 7,
                  child: Center(
                    child: Text(
                      "Remove Delegates",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                _showUpdateDialog(context);
              },
              child: const SizedBox(
                width: 250,
                height: 70,
                child: Card(
                  elevation: 7,
                  child: Center(
                    child: Text(
                      "Update Delegates",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: _toggleResultAvailable,
              child: Container(
                margin: const EdgeInsets.all(10),
                width: 250,
                height: 70,
                child: Card(
                  elevation: 7,
                  child: Center(
                    child: _isLoading
                        ? const CircularProgressIndicator.adaptive()
                        : const Text(
                            "Release Results",
                            style: TextStyle(fontSize: 20),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
