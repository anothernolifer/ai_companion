import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:friend/provider/girl_video_provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:http/http.dart' as http;
import 'package:universal_io/io.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:friend/constants/constants.dart';

class GirlVideoScreen extends ConsumerStatefulWidget {
  @override
  _GirlVideoScreenState createState() => _GirlVideoScreenState();
}

class _GirlVideoScreenState extends ConsumerState<GirlVideoScreen>
    with SingleTickerProviderStateMixin {
  late stt.SpeechToText _speechToText;
  bool _isListening = false;
  late VideoPlayerController _videoController;
  late FlutterTts _flutterTts;
  late TextEditingController _textController;

  bool _hasReceivedResponse = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _speechToText = stt.SpeechToText();
    _initializeSpeechRecognition();

    _videoController = VideoPlayerController.asset('assets/girl_video.mp4')
      ..initialize().then((_) {
        setState(() {});
      });

    _flutterTts = FlutterTts();
    _setVoiceBasedOnPlatform();
  }

  void _initializeSpeechRecognition() async {
    bool available = await _speechToText.initialize();
    if (available) {
      setState(() {
        _isListening = false;
      });
    } else {
      print('Speech recognition not available');
    }
  }

  void _startListening() async {
    await _speechToText.listen(onResult: (result) {
      ref.read(textInputProvider.notifier).state = result.recognizedWords;
    });
    setState(() {
      _isListening = true;
    });
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {
      _isListening = false;
    });
  }

  Future<void> _sendTextToHuggingFace(String text) async {
    if (text.isEmpty) return;

    ref.read(huggingFaceResponseProvider.notifier).state = 'Opening mic...';

    try {
      final response = await http.post(
        Uri.parse(AppConstants.huggingFaceApiUrl4),
        headers: {
          'Authorization': 'Bearer ${AppConstants.huggingFaceApiKey4}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'inputs': text}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        ref.read(huggingFaceResponseProvider.notifier).state = data.isNotEmpty
            ? data[0]['generated_text'] ?? 'No response'
            : 'No response';

        _playVideoBasedOnResponse(ref.read(huggingFaceResponseProvider));
        _speakHuggingFaceResponse(ref.read(huggingFaceResponseProvider));

        setState(() {
          _hasReceivedResponse = true;
        });
      } else {
        ref.read(huggingFaceResponseProvider.notifier).state =
            'Error: ${response.statusCode}';
      }
    } catch (e) {
      ref.read(huggingFaceResponseProvider.notifier).state = 'Error: $e';
    }
  }

  void _playVideoBasedOnResponse(String response) {
    if (!_videoController.value.isInitialized) {
      _videoController.initialize().then((_) {
        setState(() {
          _videoController.play();
        });
      });
    } else {
      if (_videoController.value.isPlaying) {
        _videoController.seekTo(Duration.zero);
      } else {
        _videoController.play();
      }
    }
  }

  void _speakHuggingFaceResponse(String response) async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(response);
  }

  void _setVoiceBasedOnPlatform() async {
    List<dynamic> voices = await _flutterTts.getVoices;

    for (var voice in voices) {
      print('Voice: ${voice['name']} - Locale: ${voice['locale']}');
    }

    bool voiceSet = false;

    for (var voice in voices) {
      if (Platform.isAndroid && voice['name'] == 'Google UK English Female') {
        await _flutterTts.setVoice({"name": voice['name'], "locale": "en-GB"});
        voiceSet = true;
      } else if (Platform.isIOS && voice['name'] == 'Siri') {
        await _flutterTts.setVoice({"name": voice['name'], "locale": "en-US"});
        voiceSet = true;
      } else if (Platform.isWindows &&
          voice['name'] == 'Microsoft Zira - English (United States)') {
        await _flutterTts.setVoice({"name": voice['name'], "locale": "en-US"});
        voiceSet = true;
      } else if (Platform.isMacOS && voice['name'] == 'Siri') {
        await _flutterTts.setVoice({"name": voice['name'], "locale": "en-US"});
        voiceSet = true;
      }
    }

    if (!voiceSet) {
      print('Desired voice not found. Using default voice.');
    } else {
      print('Voice set successfully.');
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _videoController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textInput = ref.watch(textInputProvider);
    final huggingFaceResponse = ref.watch(huggingFaceResponseProvider);

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
      body: Column(
        children: [
          if (!_hasReceivedResponse)
            Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blueAccent, width: 2),
              ),
              child: Center(
                child: Image.asset(
                  'assets/girl_image.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          if (_hasReceivedResponse)
            Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blueAccent, width: 2),
              ),
              child: Center(
                child: _videoController.value.isInitialized
                    ? AspectRatio(
                        aspectRatio: _videoController.value.aspectRatio,
                        child: VideoPlayer(_videoController),
                      )
                    : CircularProgressIndicator(),
              ),
            ),
          SizedBox(height: 20),
          if (huggingFaceResponse.isNotEmpty)
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Girlfriend: $huggingFaceResponse',
                style: TextStyle(fontSize: 16, color: Colors.black),
                textAlign: TextAlign.center,
              ),
            ),
          ElevatedButton(
            onPressed: _isListening ? _stopListening : _startListening,
            child: Icon(
              _isListening ? Icons.stop : Icons.mic,
              size: 30,
            ),
            style: ElevatedButton.styleFrom(
              shape: CircleBorder(),
              padding: EdgeInsets.all(20),
              backgroundColor: _isListening ? Colors.red : Colors.green,
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                suffixIcon: IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    setState(() {
                      _handleSendButtonPressed();
                    });
                  },
                ),
              ),
              onChanged: (text) =>
                  ref.read(textInputProvider.notifier).state = text,
            ),
          ),
        ],
      ),
    );
  }

  void _handleSendButtonPressed() {
    final textInput = ref.read(textInputProvider);

    if (textInput.isNotEmpty) {
      _sendTextToHuggingFace(textInput);
      setState(() {
        _textController.clear();
        ref.read(textInputProvider.notifier).state = '';
      });
    }
  }
}
