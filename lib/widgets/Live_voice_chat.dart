import 'package:flutter/material.dart';

class LiveVoiceChatWidget extends StatelessWidget {
  const LiveVoiceChatWidget({Key? key}) : super(key: key);

  void _openLiveVoiceScreen(BuildContext context) {
    Navigator.pushNamed(context, '/live_voice_screen'); 
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.record_voice_over),
      onPressed: () => _openLiveVoiceScreen(context),
    );
  }
}