import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mitcampus/models/user.dart' as app_user;

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<app_user.User> getCurrentUser() async {
    final User? firebaseUser = _auth.currentUser;
    if (firebaseUser == null) {
      throw Exception('No authenticated user found');
    }

    final docSnapshot = await _firestore.collection('users').doc(firebaseUser.uid).get();
    if (!docSnapshot.exists) {
      // If the user document doesn't exist in Firestore, create it
      final newUser = app_user.User(
        id: firebaseUser.uid,
        email: firebaseUser.email!,
        isHOD: firebaseUser.email == 'hodece@mvit.edu.in',
      );
      await _firestore.collection('users').doc(firebaseUser.uid).set(newUser.toFirestore());
      return newUser;
    }

    return app_user.User.fromFirestore(docSnapshot);
  }

  Future<bool> isUserHOD() async {
    final currentUser = await getCurrentUser();
    return currentUser.isHOD;
  }

  Future<List<app_user.User>> getAllUsers() async {
    final querySnapshot = await _firestore.collection('users').get();
    return querySnapshot.docs.map((doc) => app_user.User.fromFirestore(doc)).toList();
  }

  Future<void> updateUser(app_user.User user) async {
    await _firestore.collection('users').doc(user.id).update(user.toFirestore());
  }
}

