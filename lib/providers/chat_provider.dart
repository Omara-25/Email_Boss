import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_message.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class ChatProvider with ChangeNotifier {
  List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => _messages;
  final bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool _isTyping = false;
  bool get isTyping => _isTyping;
  
  final String _apiHost = "https://adam.criticalfutureglobal.com";
  final String _chatflowId = "5abf0443-4269-4127-93ba-cbd53e4285b5";
  final String _apiKey = dotenv.env['FLOWISE_API_KEY'] ?? 'DEFAULT_VALUE';

  List<ChatHistory> _chatHistory = [];
  final List<ChatHistory> _archivedChats = [];
  List<ChatHistory> get chatHistory => _chatHistory;

  ChatProvider() {
    _loadChatHistory();
    _loadMessages();
  }

  void clearMessages() {
  _messages.clear();
  notifyListeners();
}

Future<void> sendVoiceMessage(String text) async {
  if (text.isEmpty) return;

  _messages.add(ChatMessage(
    text: text,
    isUser: true,
    timestamp: DateTime.now(),
  ));
  notifyListeners();

  _isTyping = true;
  notifyListeners();

  try {
    final response = await http.post(
      Uri.parse('$_apiHost/api/v1/prediction/$_chatflowId'),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'question': text}),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final aiResponse = responseData['text'] ?? 'No response';
      _messages.add(ChatMessage(
        text: aiResponse,
        isUser: false,
        timestamp: DateTime.now(),
      ));
    } else {
      _messages.add(ChatMessage(
        text: 'Error: Server returned ${response.statusCode}',
        isUser: false,
        timestamp: DateTime.now(),
      ));
    }
  } catch (e) {
    _messages.add(ChatMessage(
      text: 'Error: $e',
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  _isTyping = false;
  notifyListeners();
  _saveMessages();
}



  // resetCurrentChat  
  void resetCurrentChat() {
   messages.clear();
   notifyListeners();
    }
  Future<void> _loadChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList('chat_history') ?? [];
    _chatHistory = historyJson
        .map((json) => ChatHistory.fromJson(jsonDecode(json)))
        .toList();
    notifyListeners();
  }

  Future<void> _saveChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = _chatHistory
        .map((chat) => jsonEncode(chat.toJson()))
        .toList();
    await prefs.setStringList('chat_history', historyJson);
  }

  Future<void> _loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final messagesJson = prefs.getString('messages');
    if (messagesJson != null) {
      final List<dynamic> decodedMessages = jsonDecode(messagesJson);
      _messages = decodedMessages.map((m) => ChatMessage.fromJson(m)).toList();
      notifyListeners();
    }
  }

  Future<void> _saveMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final messagesJson = jsonEncode(_messages.map((m) => m.toJson()).toList());
    await prefs.setString('messages', messagesJson);
  }

  void startNewChat() {
    if (_messages.isNotEmpty) {
      // Check if a chat with the same title (first message) already exists
      final existingChatIndex = _chatHistory.indexWhere(
        (chat) => chat.title == _messages.first.text,
      );

      if (existingChatIndex != -1) {
        // Update the existing chat with the latest messages
        _chatHistory[existingChatIndex] = ChatHistory(
          id: _chatHistory[existingChatIndex].id, // Keep the same ID
          title: _messages.first.text, // Update the title (if needed)
          lastMessage: _messages.last.text, // Update the last message
          timestamp: DateTime.now(), // Update the timestamp
          messages: List.from(_messages), // Update the messages
        );
      } else {
        // If no existing chat is found, create a new one
        final chatHistory = ChatHistory(
          id: DateTime.now().toString(),
          title: _messages.first.text,
          lastMessage: _messages.last.text,
          timestamp: DateTime.now(),
          messages: List.from(_messages),
        );
        _chatHistory.insert(0, chatHistory); // Add the new chat to the top of the history
      }

      // Save the updated chat history
      _saveChatHistory();
    }

    // Clear current chat
    _messages = [];
    notifyListeners();
  }

  void deleteChat(String chatId) {
    _chatHistory.removeWhere((chat) => chat.id == chatId);
    _saveChatHistory();
    notifyListeners();
  }

  void archiveChat(String chatId) {
    final chatIndex = _chatHistory.indexWhere((chat) => chat.id == chatId);
    if (chatIndex != -1) {
      final archivedChat = _chatHistory.removeAt(chatIndex);
      _archivedChats.insert(0, archivedChat);
      _saveChatHistory();
      notifyListeners();
    }
  }

  void clearChatHistory() {
    _chatHistory.clear();
    _saveChatHistory();
    notifyListeners();
  }

  void renameChat(String chatId, String newTitle) {
    final chatIndex = _chatHistory.indexWhere((chat) => chat.id == chatId);
    if (chatIndex != -1) {
      _chatHistory[chatIndex] = ChatHistory(
        id: _chatHistory[chatIndex].id,
        title: newTitle,
        lastMessage: _chatHistory[chatIndex].lastMessage,
        timestamp: _chatHistory[chatIndex].timestamp,
        messages: _chatHistory[chatIndex].messages,
      );
      _saveChatHistory();
      notifyListeners();
    }
  }

  void addMessage(ChatMessage message) {
  _messages.add(message);
  notifyListeners();
   }
  Future<void> sendMessage(String message, {File? attachment}) async {
    if (message.trim().isEmpty && attachment == null) return;

    _messages.add(ChatMessage(
      text: message,
      isUser: true,
      timestamp: DateTime.now(),
      attachment: attachment,
    ));
    notifyListeners();

    _isTyping = true;
    notifyListeners();

    try {
      var request = http.MultipartRequest('POST', Uri.parse('$_apiHost/api/v1/prediction/$_chatflowId'));
      request.headers.addAll({
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'multipart/form-data',
      });

      request.fields['question'] = message;

      if (attachment != null) {
        request.files.add(await http.MultipartFile.fromPath('file', attachment.path));
      }

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final responseData = json.decode(responseBody);
        final aiResponse = responseData['text'] ?? 'No response';
        _messages.add(ChatMessage(
          text: aiResponse,
          isUser: false,
          timestamp: DateTime.now(),
        ));
      } else {
        print('Error response: $responseBody');
        _messages.add(ChatMessage(
          text: 'Error: Server returned ${response.statusCode}',
          isUser: false,
          timestamp: DateTime.now(),
        ));
      }
    } catch (e) {
      print('Exception details: $e');
      _messages.add(ChatMessage(
        text: 'Error: $e',
        isUser: false,
        timestamp: DateTime.now(),
      ));
    }

    _isTyping = false;
    notifyListeners();
    
    _saveMessages();
  }

  Future<void> loadChat(String chatId) async {
    final chat = _chatHistory.firstWhere((chat) => chat.id == chatId);
    _messages = List.from(chat.messages);
    notifyListeners();
  }
}

class ChatHistory {
  final String id;
  final String title;
  final String lastMessage;
  final DateTime timestamp;
  final List<ChatMessage> messages;

  ChatHistory({
    required this.id,
    required this.title,
    required this.lastMessage,
    required this.timestamp,
    required this.messages,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'lastMessage': lastMessage,
    'timestamp': timestamp.toIso8601String(),
    'messages': messages.map((m) => m.toJson()).toList(),
  };

  factory ChatHistory.fromJson(Map<String, dynamic> json) => ChatHistory(
    id: json['id'],
    title: json['title'],
    lastMessage: json['lastMessage'],
    timestamp: DateTime.parse(json['timestamp']),
    messages: (json['messages'] as List)
        .map((m) => ChatMessage.fromJson(m))
        .toList(),
  );
}