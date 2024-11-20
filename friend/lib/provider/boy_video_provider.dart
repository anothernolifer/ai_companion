import 'package:flutter_riverpod/flutter_riverpod.dart';


final textInputProvider = StateProvider<String>((ref) => '');


final huggingFaceResponseProvider = StateProvider<String>((ref) => '');


final videoPlayingProvider = StateProvider<bool>((ref) => false);
