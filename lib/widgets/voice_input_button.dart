import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../providers/chat_provider.dart';

class VoiceInputButton extends StatefulWidget {
  const VoiceInputButton({super.key});

  @override
  VoiceInputButtonState createState() => VoiceInputButtonState();
}

class VoiceInputButtonState extends State<VoiceInputButton> {
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
    _initializeTts();
  }

  void _initializeSpeech() async {
    await _speechToText.initialize();
  }

  void _initializeTts() async {
    await _flutterTts.setLanguage("en-GB");
    await _flutterTts.setPitch(1.4); // Higher pitch for a more feminine voice
    await _flutterTts.setSpeechRate(0.7);

    // Get available voices
    var voices = await _flutterTts.getVoices;
    print("Available voices: $voices"); // Debug print

    // List of female voice names to try (add more if needed)
    List<String> femaleVoices = [
      'en-us-x-sfg#female_1-local',
      'en-us-x-sfg#female_2-local',
      'en-gb-x-gba-network',
      'en-au-x-aua-network',
      'samantha',
      'victoria',
    ];

    // Try to set a specific female voice
    for (var voiceName in femaleVoices) {
      try {
        await _flutterTts.setVoice({"name": voiceName, "locale": "en-GB"});
        print("Set voice to: $voiceName"); // Debug print
        break;
      } catch (e) {
        print("Failed to set voice $voiceName: $e"); // Debug print
      }
    }

    // Test the voice
    await _flutterTts.speak("Hello, I'm Email Boss , How can I assist you today.");
  }

  void _startListening() async {
    if (!_isListening) {
      bool available = await _speechToText.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speechToText.listen(
          onResult: (result) async {
            if (result.finalResult) {
              setState(() => _isListening = false);
              final text = result.recognizedWords;
              if (text.isNotEmpty) {
                await context.read<ChatProvider>().sendMessage(text);
                // Speak the assistant's response
                final lastMessage = context.read<ChatProvider>().messages.last;
                if (!lastMessage.isUser) {
                  await _flutterTts.speak(lastMessage.text);
                }
              }
            }
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speechToText.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: FloatingActionButton(
        onPressed: _startListening,
        child: Icon(_isListening ? Icons.mic : Icons.mic_none),
      ),
    );
  }

  @override
  void dispose() {
    _speechToText.stop();
    _flutterTts.stop();
    super.dispose();
  }
}