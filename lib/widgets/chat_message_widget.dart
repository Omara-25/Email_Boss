import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart'; 
import '../models/chat_message.dart';

class ChatMessageWidget extends StatefulWidget {
  final ChatMessage message;

  const ChatMessageWidget({
    super.key,
    required this.message,
  });

  @override
  State<ChatMessageWidget> createState() => _ChatMessageWidgetState();
}

class _ChatMessageWidgetState extends State<ChatMessageWidget> {
  final FlutterTts _flutterTts = FlutterTts();
  bool isLiked = false;
  bool isDisliked = false;
  bool isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _initializeTts();
  }

  Future<void> _initializeTts() async {
    await _flutterTts.setLanguage("en-GB");
    await _flutterTts.setPitch(1.4);
    await _flutterTts.setSpeechRate(0.7);
    _flutterTts.setCompletionHandler(() {
      setState(() {
        isSpeaking = false;
      });
    });
  }

  Future<void> _toggleSpeak() async {
    if (isSpeaking) {
      await _flutterTts.stop();
      setState(() {
        isSpeaking = false;
      });
    } else {
      setState(() {
        isSpeaking = true;
      });
      await _flutterTts.speak(widget.message.text);
    }
  }

  // Helper function to format the timestamp
  String _formatTimestamp(DateTime timestamp) {
    return DateFormat('MMM d, yyyy hh:mm a').format(timestamp);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: widget.message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!widget.message.isUser) _buildAvatar(),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.message.text,
                    style: TextStyle(
                      color: widget.message.isUser 
                      ? Theme.of(context).textTheme.bodyLarge?.color
                      : Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 4), // Add spacing between message and timestamp
                  Text(
                    _formatTimestamp(widget.message.timestamp), // Display formatted timestamp
                    style: TextStyle(
                      fontSize: 12,
                      color: widget.message.isUser 
                      ? Theme.of(context).textTheme.bodyLarge?.color
                      : Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  if (!widget.message.isUser) _buildActionButtons(), // Add action buttons for Mai's messages
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (widget.message.isUser) _buildAvatar(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      backgroundColor: widget.message.isUser ? Colors.blue : Colors.grey,
      child: Text(
        widget.message.isUser ? 'A' : 'E',
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.copy, size: 20),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: widget.message.text));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Message copied to clipboard')),
            );
          },
        ),
        IconButton(
          icon: Icon(
            isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
            size: 20,
          ),
          onPressed: () {
            setState(() {
              isLiked = !isLiked;
              isDisliked = false;
            });
          },
        ),
        IconButton(
          icon: Icon(
            isDisliked ? Icons.thumb_down : Icons.thumb_down_outlined,
            size: 20,
          ),
          onPressed: () {
            setState(() {
              isDisliked = !isDisliked;
              isLiked = false;
            });
          },
        ),
        IconButton(
          icon: Icon(
            isSpeaking ? Icons.stop : Icons.volume_up,
            size: 20,
          ),
          onPressed: _toggleSpeak,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }
}