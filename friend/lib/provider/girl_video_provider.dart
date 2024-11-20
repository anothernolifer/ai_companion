import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider for text input state
final textInputProvider = StateProvider<String>((ref) => '');

// Provider for Hugging Face response
final huggingFaceResponseProvider = StateProvider<String>((ref) => '');

// Provider for video playing state
final videoPlayingProvider = StateProvider<bool>((ref) => false);
