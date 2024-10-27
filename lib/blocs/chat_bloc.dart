import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import '../models/chat_message.dart';

// Events
abstract class ChatEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SendMessageEvent extends ChatEvent {
  final String message;
  final String senderId;
  final String senderName;
  final DateTime timestamp;

  SendMessageEvent({
    required this.message,
    required this.senderId,
    required this.senderName,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [message, senderId, senderName, timestamp];
}

class LoadMessagesEvent extends ChatEvent {}

// States
abstract class ChatState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<ChatMessage> messages;

  ChatLoaded({required this.messages});

  @override
  List<Object?> get props => [messages];
}

class ChatError extends ChatState {
  final String error;

  ChatError({required this.error});

  @override
  List<Object?> get props => [error];
}

// Bloc
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ChatBloc() : super(ChatInitial()) {
    on<LoadMessagesEvent>(_onLoadMessages);
    on<SendMessageEvent>(_onSendMessage);
  }

  Future<void> _onLoadMessages(LoadMessagesEvent event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    try {
      final messagesStream = _firestore
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots();

      await emit.forEach(messagesStream, onData: (QuerySnapshot snapshot) {
        final messages = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return ChatMessage.fromMap(data);
        }).toList();
        return ChatLoaded(messages: messages);
      });
    } catch (e) {
      emit(ChatError(error: e.toString()));
    }
  }

  Future<void> _onSendMessage(SendMessageEvent event, Emitter<ChatState> emit) async {
    try {
      final messageDoc = _firestore.collection('messages').doc();
      await messageDoc.set({
        'id': messageDoc.id,
        'message': event.message,
        'senderId': event.senderId,
        'senderName': event.senderName,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      emit(ChatError(error: e.toString()));
    }
  }
}
