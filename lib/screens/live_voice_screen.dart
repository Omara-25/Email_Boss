import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../providers/chat_provider.dart';

class LiveVoiceScreen extends StatefulWidget {
  const LiveVoiceScreen({super.key});

  @override
  State<LiveVoiceScreen> createState() => _LiveVoiceScreenState();
}

class _LiveVoiceScreenState extends State<LiveVoiceScreen> {
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  bool _isListening = false;
  bool _isSpeaking = false;
  int _step = 0; // 0: idle, 1: loading, 2: speaking
  Timer? _speechTimer;
  String _currentText = '';

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
    await _flutterTts.setSharedInstance(true);
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.4);
    await _flutterTts.setSpeechRate(0.7);

    _flutterTts.setStartHandler(() {
      setState(() {
        _step = 2;
        _isSpeaking = true;
      });
    });

    _flutterTts.setCompletionHandler(() {
      setState(() {
        _step = 0;
        _isSpeaking = false;
        _currentText = '';
      });
    });

    _flutterTts.setErrorHandler((msg) {
      setState(() {
        _step = 0;
        _isSpeaking = false;
      });
    });
  }

  void _toggleListening() {
    if (_isListening) {
      _stopListening();
    } else {
      _startListening();
    }
  }

  void _startListening() async {
    if (await _speechToText.initialize()) {
      setState(() {
        _isListening = true;
        _step = 0;
      });
      _speechToText.listen(
        onResult: (result) => _handleSpeechResult(result),
        listenFor: const Duration(minutes: 1),
        partialResults: false,
        cancelOnError: true,
      );
    }
  }

  void _stopListening() {
    _speechToText.stop();
    setState(() => _isListening = false);
  }

  void _handleSpeechResult(result) {
    final text = result.recognizedWords.trim();
    if (text.isNotEmpty) {
      _processVoiceInput(text);
    }
  }

  Future<void> _processVoiceInput(String text) async {
    final chatProvider = context.read<ChatProvider>();
    setState(() => _step = 1);
    
    try {
      await chatProvider.sendMessage(text);
      final response = chatProvider.messages.last.text;
      _currentText = response;
      await _speakResponse(response);
    } catch (e) {
      await _speakResponse("Sorry, I encountered an error");
      setState(() => _step = 0);
    }
  }

  Future<void> _speakResponse(String text) async {
    await _flutterTts.speak(text);
  }

  void _cancelInteraction() async {
    await _flutterTts.stop();
    _stopListening();
    setState(() {
      _step = 0;
      _isSpeaking = false;
      _currentText = '';
    });
  }

  @override
  void dispose() {
    _speechTimer?.cancel();
    _speechToText.stop();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        title: Text('Email Boss - Live Voice Assistant', 
          style: TextStyle(color: theme.colorScheme.onSurface)),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline, color: theme.colorScheme.onSurface),
            onPressed: () {/* Add info dialog */},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: size.width * 0.8,
                  maxHeight: size.height * 0.7,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Center(
                        child: _buildVisualFeedback(theme),
                      ),
                    ),
                    if (_currentText.isNotEmpty && _step == 2)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          _currentText,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(top: 24.0, bottom: 100.0),
                      child: _buildStatusText(theme),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(bottom: 40.0),
            child: _buildVoiceControls(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildVisualFeedback(ThemeData theme) {
    if (_step == 1) {
      return Center(
        child: Lottie.asset(
          'assets/loading.json',
          width: 200,
          height: 200,
          fit: BoxFit.contain,
        ),
      );
    }
    
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _step == 2 
          ? _buildSoundBars(70.0, theme)
          : Hero(
              tag: 'Email Boss-avatar',
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                  image: const DecorationImage(
                    image: AssetImage('assets/Email_Boss.jpg'),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: _isListening
                  ? Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.colorScheme.primary.withOpacity(0.3),
                      ),
                    )
                  : null,
              ),
            ),
    );
  }

  Widget _buildSoundBars(double baseHeight, ThemeData theme) {
    return Container(
      width: 250,
      height: 250,
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(4, (index) {
          final heights = [baseHeight * 1.1, baseHeight * 1.3, 
                          baseHeight * 1.5, baseHeight * 1.2];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: heights[index],
              width: 20,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStatusText(ThemeData theme) {
    String text;
    if (_step == 1) {
      text = "Processing...";
    } else if (_isListening) {
      text = "Listening...";
    } else if (_step == 2) {
      text = "Speaking...";
    } else {
      text = "Tap to start";
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        text,
        style: TextStyle(
          color: theme.colorScheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildVoiceControls(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildControlButton(
            icon: _isListening ? Icons.mic_off : Icons.mic,
            color: theme.colorScheme.primary,
            onPressed: _toggleListening,
          ),
          _buildControlButton(
            icon: Icons.close,
            color: theme.colorScheme.error,
            onPressed: _cancelInteraction,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
    bool isSquare = false,
  }) {
    return FloatingActionButton(
      backgroundColor: color,
      onPressed: onPressed,
      shape: isSquare 
          ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
          : const CircleBorder(),
      child: Icon(icon, size: 30, color: Colors.white),
    );
  }
}