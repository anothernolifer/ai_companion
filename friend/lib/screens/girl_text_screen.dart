
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:friend/provider/girl_chat_provider.dart';
import 'package:friend/constants/constants.dart';
import 'package:http/http.dart' as http;

class GirlTextScreen extends ConsumerWidget {
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(chatMessagesProvider);
    final textInput = ref.watch(textInputProvider);

    Future<String> _getHuggingFaceResponse(String text) async {
      final url = Uri.parse(AppConstants.huggingFaceApiUrl3);
      final headers = {
        'Authorization': 'Bearer ${AppConstants.huggingFaceApiKey3}',
        'Content-Type': 'application/json',
      };
      final body = jsonEncode({
        'inputs': text,
      });

      try {
        final response = await http.post(url, headers: headers, body: body);
        if (response.statusCode == 200) {
          final List<dynamic> data = jsonDecode(response.body);
          return data.isNotEmpty
              ? data[0]['generated_text'] ?? 'No response'
              : 'No response';
        } else {
          return 'Error: ${response.statusCode} ${response.body}';
        }
      } catch (e) {
        return 'Error: $e';
      }
    }


    Future<void> _sendMessage() async {
      if (textInput.isEmpty) return;

      ref.read(chatMessagesProvider.notifier).addMessage('user', textInput);

      String response = await _getHuggingFaceResponse(textInput);

      ref.read(chatMessagesProvider.notifier).addMessage('bot', response);

      _textController.clear();
      ref.read(textInputProvider.notifier).state = '';
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/girl_image.png',
              width: 30,
              height: 30,
            ),
            SizedBox(width: 8),
            Text('Girlfriend'),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  final isUser = message.role == 'user';
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: isUser
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: [
                        Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                          decoration: BoxDecoration(
                            color: isUser ? Colors.blueAccent : Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            message.text,
                            style: TextStyle(
                                color: isUser ? Colors.white : Colors.black),
                            overflow: TextOverflow.visible,
                            softWrap: true,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),


            TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ),
              onChanged: (text) {
                ref.read(textInputProvider.notifier).state = text;
              },
              onSubmitted: (_) => _sendMessage(),
            ),
          ],
        ),
      ),
    );
  }
}
