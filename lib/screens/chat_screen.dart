import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mitcampus/models/chat_message.dart';
import '../blocs/chat_bloc.dart';
import '../blocs/auth_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  late AuthState _authState;

  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(LoadMessagesEvent());
    _authState = context.read<AuthBloc>().state;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthSuccess) {
          return const Center(child: Text('Please login to access chat'));
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Chat',
                style: TextStyle(color: Colors.white)),
            backgroundColor: const Color(0xFF2563EB),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: BlocBuilder<ChatBloc, ChatState>(
            builder: (context, state) {
              if (state is ChatLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ChatLoaded) {
                return Column(
                  children: [
                    Expanded(
                      child: state.messages.isEmpty
                          ? const Center(child: Text('No messages yet'))
                          : ListView.builder(
                              reverse: true,
                              itemCount: state.messages.length,
                              itemBuilder: (context, index) {
                                final message = state.messages[index];
                                final isMe = message.senderId == _authState.user.uid;

                                return _buildMessageBubble(message, isMe);
                              },
                            ),
                    ),
                    _buildMessageInput(_authState.user.uid),
                  ],
                );
              } else if (state is ChatError) {
                return Center(child: Text('Error: ${state.error}'));
              }
              return const Center(child: Text('No messages'));
            },
          ),
        );
      },
    );
  }

  Widget _buildMessageInput(String userId) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: InputBorder.none,
              ),
              onSubmitted: (text) => _sendMessage(userId),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            color: const Color(0xFF2563EB),
            onPressed: () => _sendMessage(userId),
          ),
        ],
      ),
    );
  }

  void _sendMessage(String userId) {
    if (_messageController.text.isNotEmpty) {
      if (_authState is AuthSuccess) {
        final authState = _authState as AuthSuccess;
        context.read<ChatBloc>().add(
              SendMessageEvent(
                message: _messageController.text,
                senderId: userId,
                senderName: authState.user.displayName ?? 'Anonymous',
                timestamp: DateTime.now(),
              ),
            );
        _messageController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You must be logged in to send messages'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $urlString');
    }
  }

  Widget _buildMessageBubble(ChatMessage message, bool isMe) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isMe)
            Padding(
              padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
              child: Text(
                message.senderName,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            decoration: BoxDecoration(
              color: isMe ? const Color(0xFF2563EB) : Colors.grey[300],
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Text(
              message.message,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
