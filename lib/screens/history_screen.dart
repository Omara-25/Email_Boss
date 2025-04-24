import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              Provider.of<ChatProvider>(context, listen: false).clearChatHistory();
            },
          ),
        ],
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          return ListView.builder(
            itemCount: chatProvider.chatHistory.length,
            itemBuilder: (context, index) {
              final chat = chatProvider.chatHistory[index];
              return ListTile(
                title: Text(chat.title),
                subtitle: Text(chat.lastMessage),
                onTap: () {
                  chatProvider.loadChat(chat.id);
                  Navigator.pop(context);
                },
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'delete')  {
                      chatProvider.archiveChat(chat.id);
                    } else if (value == 'rename') {
                      showDialog(
                        context: context,
                        builder: (context) {
                          TextEditingController controller = TextEditingController(text: chat.title);
                          return AlertDialog(
                            title: const Text('Rename Chat'),
                            content: TextField(
                              controller: controller,
                              decoration: const InputDecoration(hintText: 'Enter new chat name'),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  chatProvider.renameChat(chat.id, controller.text);
                                  Navigator.pop(context);
                                },
                                child: const Text('Rename'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'rename',
                      child: Text('Rename'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
