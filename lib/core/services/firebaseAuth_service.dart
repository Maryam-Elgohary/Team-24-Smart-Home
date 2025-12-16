import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:updated_smart_home/core/errors/execptions.dart';

class FirebaseAuthService {
  // Add your Firebase authentication methods here
  Future<User> createUserWithEmailAndPassword(
    String emailAddress,
    String password,
  ) async {
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailAddress,
            password: password,
          );
      return credential.user!;
    } on FirebaseAuthException catch (e) {
      log(e.toString());
      if (e.code == 'weak-password') {
        throw CustomException(message: 'The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        throw CustomException(
          message: 'The account already exists for that email.',
        );
      } else {
        log(e.code);
        throw CustomException(message: "something went wrong");
      }
    } catch (e) {
      log(e.toString());
      throw CustomException(message: "Something went wrong");
    }
  }

  Future<User> signInWithEmailAndPassword(
    String emailAddress,
    String password,
  ) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );
      //    log(credential.user.toString());
      return credential.user!;
    } on FirebaseAuthException catch (e) {
      log(e.toString());

      if (e.code == 'user-not-found') {
        throw CustomException(message: 'No user found for that email.');
      } else if (e.code == 'wrong-password') {
        throw CustomException(
          message: 'Wrong password provided for that user.',
        );
      } else {
        log(e.code);
        throw CustomException(message: "something went wrong");
      }
    } catch (e) {
      log(e.toString());
      throw CustomException(message: "Something went wrong");
    }
  }

  Future deleteUser() async {
    await FirebaseAuth.instance.currentUser!.delete();
  }

  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'no-current-user') {
        throw CustomException(message: 'No user is currently signed in.');
      } else {
        throw CustomException(
          message: 'Something went wrong, please try again.',
        );
      }
    }
  }
}
