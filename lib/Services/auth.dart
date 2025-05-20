import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  //for storing data in firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  //for Authentication
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //for sign up
  Future<String> signUpUser({
    required String email,
    required String password,
    required String name,
  }) async //crucial for maintaining a responsive user interface. This allows the function to return a Future, which represents a value that will be available at some point in the future.
  {
    String res = "Some error occured";
    try {
      if (email.isNotEmpty && password.isNotEmpty && name.isNotEmpty) {
        UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        //for storing users data in firestore
        await _firestore.collection("users").doc(result.user!.uid).set({
          "name": name,
          "email": email,
          "uid": result.user!.uid,
        });
        res = "Success";
      } else {
        res = "Please enter all fields";
      }
    } catch (e) {
      res = e.toString();
      print(e.toString());
    }
    return res;
  }

  // For Login
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = "Some error occurred";
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        res = "success";
      } else {
        res = "Please enter email and password";
      }
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  //for logout
  Future<void> logoutUser() async {
    await _auth.signOut(); //sign out from firebase
  }

  //for password reset
  Future<String> resetPassword(String email) async {
    String res = "Some error occured";
    try {
      if (email.isNotEmpty) {
        await _auth.sendPasswordResetEmail(email: email);
        res = "Password reset link sent to $email";
      } else {
        res = "Please enter your email";
      }
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  //for fetching user profile
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    DocumentSnapshot snapshot = await _firestore
        .collection("users")
        .doc(uid)
        .get(); //fetching data from firestore
    return snapshot.data() as Map<String, dynamic>?;
  }

  // For Updating User Profile
  Future<String> updateUserProfile(
      String uid, String name, String email) async {
    String res = "Some error occurred";
    try {
      await _firestore.collection("users").doc(uid).update({
        "name": name,
        "email": email,
      });
      res = "Profile updated successfully";
    } catch (e) {
      res = e.toString();
    }
    return res;
  }
}
