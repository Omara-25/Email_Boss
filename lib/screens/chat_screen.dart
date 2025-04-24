import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../models/chat_message.dart'; 
import '../providers/theme_provider.dart';
import '../widgets/chat_message_widget.dart';
import '../widgets/voice_input_button.dart';
import '../widgets/live_voice_chat.dart';
import '../widgets/text_input_field.dart';
import '../widgets/footer_widget.dart';
import 'history_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  


  @override
  void initState() {
    super.initState();
    // Add a welcome message from Mai when the chat screen is initialized
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    // Access the ChatProvider and add a welcome message
    final chatProvider = context.read<ChatProvider>();
    chatProvider.addMessage(
      ChatMessage(
        text: "Hello, I'm Email Boss. How can I assist you today?",
        isUser: false, // This message is from Email Boss, not the user
        timestamp: DateTime.now(),
      ),
    );
  }
  

  void _showChatHistory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HistoryScreen()),
    );
  }
 
  
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
    leading: Row(
      children: [
        IconButton(
          icon: const Icon(Icons.history),
          tooltip: 'Chat history',
          onPressed: () => _showChatHistory(context),
        ),
      ],
    ),
        title: const Text('Email Boss'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Start new chat',
            onPressed: () => context.read<ChatProvider>().startNewChat(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset current chat',
            onPressed: () => context.read<ChatProvider>().resetCurrentChat(),
          ),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return PopupMenuButton<ThemeMode>(
                icon: const Icon(Icons.brightness_6),
                onSelected: (ThemeMode selectedMode) => 
                  themeProvider.setThemeMode(selectedMode),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: ThemeMode.light,
                    child: Text('Light Mode'),
                  ),
                  const PopupMenuItem(
                    value: ThemeMode.dark,
                    child: Text('Dark Mode'),
                  ),
                  const PopupMenuItem(
                    value: ThemeMode.system,
                    child: Text('System Mode'),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                return ListView.builder(
                  itemCount: chatProvider.messages.length + 
                      (chatProvider.isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == chatProvider.messages.length && 
                        chatProvider.isTyping) {
                      return const TypingIndicator();
                    }
                    final message = chatProvider.messages[index];
                    return ChatMessageWidget(message: message);
                  },
                );
              },
            ),
          ),
          const FooterWidget(),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextInputField(
                    onSubmitted: (text) {
                      context.read<ChatProvider>().sendMessage(text);
                    },
                  ),
                ),
                const VoiceInputButton(),
                const LiveVoiceChatWidget(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TypingIndicator extends StatelessWidget {
  const TypingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          Text('Email Boss is typing', 
            style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color)),
          const SizedBox(width: 8),
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ],
      ),
    );
  }
}