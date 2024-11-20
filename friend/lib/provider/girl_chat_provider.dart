import 'package:flutter_riverpod/flutter_riverpod.dart';


class ChatMessage {
  final String role;
  final String text;

  ChatMessage({required this.role, required this.text});
}


class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  ChatNotifier() : super([]);

  void addMessage(String role, String text) {
    state = [...state, ChatMessage(role: role, text: text)];
  }
}

final chatMessagesProvider =
StateNotifierProvider<ChatNotifier, List<ChatMessage>>((ref) {
  return ChatNotifier();
});


final textInputProvider = StateProvider<String>((ref) {
  return '';
});
