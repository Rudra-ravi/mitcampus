import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String email;
  final bool isHOD;

  User({
    required this.id,
    required this.email,
    required this.isHOD,
  });

  factory User.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return User(
      id: doc.id,
      email: data['email'],
      isHOD: data['email'] == 'hodece@mvit.edu.in',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'isHOD': isHOD,
    };
  }
}
