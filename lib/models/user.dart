import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String email;
  final bool isHOD;
  final String displayName;

  User({
    required this.id,
    required this.email,
    required this.isHOD,
    String? displayName,
  }) : displayName = displayName ?? email.split('@')[0];

  factory User.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return User(
      id: doc.id,
      email: data['email'],
      isHOD: data['email'] == 'hodece@mvit.edu.in',
      displayName: data['displayName'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'isHOD': isHOD,
      'displayName': displayName,
    };
  }
}
