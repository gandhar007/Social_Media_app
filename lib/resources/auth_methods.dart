import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:instagram_clone/resources/storage_methods.dart';
import 'package:instagram_clone/models/user.dart' as model;

class AuthMethods
{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<model.User> getUserDetails() async {
    User currentUser = _auth.currentUser!;

    DocumentSnapshot snap = await _firestore.collection('users').doc(currentUser.uid).get();
    return model.User.fromSnap(snap);
  }

  // Sign up user
  Future<String> signUpUser({
    required String email,
    required String password,
    required String username,
    required String bio,
    required Uint8List file
  }) async {
    String res = "Some error occurred";
    try{
      if(email.isNotEmpty && password.isNotEmpty && username.isNotEmpty && bio.isNotEmpty && file != null) {
        // Register User
        UserCredential cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);

        String photoUrl = await StorageMethods().uploadImageToStorage('profilePics', file, false);

        model.User user = model.User(
            username: username,
            uid: cred.user!.uid,
            email: email,
            bio: bio,
            followers: [],
            following: [],
            photoUrl: photoUrl
        );

        // Add user to database (Specifying document id to be same as uid)
        await _firestore.collection('users').doc(cred.user!.uid).set(user.toJson());

        // Alternate method to add a user data to database (Document id is generated by firebase and is different from uid)
        /*await _firestore.collection('users').add({
          'username': username,
          'uid': cred.user!.uid,
          'email': email,
          'bio': bio,
          'followers': [],
          'following': []
        });*/

        res = 'success';
      }
    } on FirebaseAuthException catch(err) {
      if(err.code == 'invalid-email') {
        res = 'The email is badly formatted';
      } else if(err.code == 'weak-password') {
        res = 'Password should be at least 6 characters';
      }
    }
    catch(e) {
      res = e.toString();
    }
    return res;
  }

  // Log in user
Future<String> loginUser({
    required String email,
    required String password
  }) async {
    String res = "Some error occurred";
    try {
      if(email.isNotEmpty && password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(email: email, password: password);
        res = "success";
      } else {
        res = "Please enter all the fields";
      }
    } on FirebaseAuthException catch(err) {
      if(err.code == 'user-not-found') {
        return res = 'User does not exist';
      } else if(err.code == 'wrong-password') {
        return res = 'Please enter correct password';
      }
    }
    catch(e) {
      res = e.toString();
    }
    return res;
  }
}