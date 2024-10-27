import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String message;
  final String senderId;
  final String senderName;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.message,
    required this.senderId,
    required this.senderName,
    required this.timestamp,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] ?? '',
      message: map['message'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'message': message,
      'senderId': senderId,
      'senderName': senderName,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
