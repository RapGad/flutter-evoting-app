import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finalapp/pages/sign_up_phone_verification.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUserRecord(String email, String level) async {
    FirebaseFirestore.instance
        .collection('elections')
        .doc("election2024")
        .collection("users")
        .add({
      'email': email,
      'level': level,
      'isAdmin':
          false, // Set this to true for admin users manually or based on your logic
    });
  }

  Future<User?> register(String email, String phoneNumber, String level,
      BuildContext context) async {
    try {
      // Check if the user already exists by attempting to sign in
      UserCredential? userCredential;

      try {
        userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: '12345678', // No need to provide password
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          // User does not exist, display an error message
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('User does not exist.'),
                backgroundColor: Colors.red),
          );
        } else {
          // Other errors
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(e.message.toString()),
                backgroundColor: Colors.red),
          );
        }
      }

      if (phoneNumber.length < 10) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Phone number is invalid"),
              backgroundColor: Colors.red),
        );

        return null;
      }

      if (userCredential?.user != null) {
        QuerySnapshot querySnapshot = await _firestore
            .collection('elections')
            .doc('election2024')
            .collection('users')
            .where('email', isEqualTo: email)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Index number is in use"),
                backgroundColor: Colors.red),
          );
          return null;
        }
        createUserRecord(email, level);
        Navigator.push(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(
              builder: (context) => PhoneVerificationPage(
                  phoneNumber: "+233${phoneNumber.substring(1)}")),
        );
      }

      return userCredential?.user;
    } on FirebaseAuthException catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(e.message.toString()), backgroundColor: Colors.red),
      );
    } catch (e) {
      print(e);
    }

    return null;
  }

  Future<bool> isUserAdmin(String? email) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('elections')
        .doc('election2024')
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Assuming email is unique and there's only one document
      DocumentSnapshot userDoc = querySnapshot.docs.first;

      if (userDoc.exists && userDoc['isAdmin'] == true) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  Future<User?> login(
      String email, String password, BuildContext context) async {
    try {
      UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.message.toString()),
        backgroundColor: Colors.red,
      ));
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Unexpected error Occured"),
        backgroundColor: Colors.red,
      ));
    }
    return null;
  }

  Future<void> createUserWithEmailAndPassword(
      String email, String password, String phoneNumber) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Once the user is created, you can add the phone number
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await userCredential.user?.linkWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          if (e.code == 'invalid-phone-number') {
            print('The provided phone number is not valid.');
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          // Store the verificationId and resendToken for later use
          // e.g., prompting the user to enter the SMS code
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Handle timeout
        },
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
  }
}
