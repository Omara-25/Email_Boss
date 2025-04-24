import 'dart:io';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final File? attachment;
  final bool? isVoice; // Add this field

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.attachment,
    this.isVoice,
  });

  Map<String, dynamic> toJson() => {
    'text': text,
    'isUser': isUser,
    'timestamp': timestamp.toIso8601String(),
    'attachment': attachment?.path,
    'isVoice': isVoice,
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    text: json['text'],
    isUser: json['isUser'],
    timestamp: DateTime.parse(json['timestamp']),
    attachment: json['attachment'] != null ? File(json['attachment']) : null,
    isVoice: json['isVoice'],
  );
}

