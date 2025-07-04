# 📧 Email Boss

<div align="center">

  ![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
  ![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
  ![AI](https://img.shields.io/badge/AI-Powered-%23FF6F00.svg?style=for-the-badge&logo=ai&logoColor=white)

  <h3>A smart voice assistant for managing your emails</h3>

</div>

## 📝 Overview

Email Boss is a Flutter-based voice assistant application designed to help manage emails through integration with Flowise AI. It provides an intuitive interface for interacting with your emails using both voice commands and text input.

## ✨ Features

- 🎤 **Voice Interaction** - Communicate with the assistant using voice commands
- 💬 **Text Chat** - Type messages to interact with the assistant
- 📜 **Chat History** - View and manage previous conversations
- 🌓 **Theme Options** - Switch between light, dark, and system themes
- 🔊 **Live Voice Mode** - Dedicated screen for continuous voice interaction

## 🏗️ Project Structure

```
adam_email_assistant/
├── assets/                  # Contains images, animations, and other assets
├── lib/                     # Main source code directory
│   ├── models/              # Data models
│   │   └── chat_message.dart
│   ├── providers/           # State management
│   │   ├── chat_provider.dart
│   │   └── theme_provider.dart
│   ├── screens/             # UI screens
│   │   ├── chat_screen.dart
│   │   ├── history_screen.dart
│   │   └── live_voice_screen.dart
│   ├── widgets/             # Reusable UI components
│   │   ├── chat_message_widget.dart
│   │   ├── footer_widget.dart
│   │   ├── live_voice_chat.dart
│   │   ├── text_input_field.dart
│   │   └── voice_input_button.dart
│   └── main.dart            # Application entry point
├── test/                    # Test files
├── .env                     # Environment variables (API keys)
└── pubspec.yaml             # Project dependencies and configuration
```

## 🛠️ Technologies Used

- 📱 **Flutter** - Cross-platform UI framework
- 🔄 **Provider** - State management
- 🔊 **Flutter TTS** - Text-to-speech functionality
- 🎙️ **Speech to Text** - Voice recognition
- 🌐 **HTTP** - API communication
- 💾 **Shared Preferences** - Local storage
- 🧠 **Flowise AI** - Backend AI integration

## 🚀 Setup and Configuration

1. Clone the repository
   ```bash
   git clone https://github.com/Omara-25/Email_Bossgit
   ```

2. Create a `.env` file in the root directory with:
   ```
   FLOWISE_API_KEY=your_api_key_here
   ```

3. Install dependencies
   ```bash
   flutter pub get
   ```

4. Run the app
   ```bash
   flutter run
   ```

## 📱 Platform Support

- 📱 Android
- 📱 iOS
- 🌐 Web
- 🖥️ Windows
- 🖥️ macOS
- 🐧 Linux

## 🔌 API Integration

The app must be connected to a Flowise AI backend hosted server like `https://flowise.com` for processing natural language requests related to email management.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👥 Contributors

- Mohamed Omara - Initial work

---

<div align="center">
  Made with ❤️ by Critical Future Team
</div>