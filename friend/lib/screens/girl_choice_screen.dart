


import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:universal_io/io.dart';
import 'girl_text_screen.dart';
import 'girl_video_screen.dart';

class GirlChoiceScreen extends StatefulWidget {
  const GirlChoiceScreen({super.key});

  @override
  State<GirlChoiceScreen> createState() => _GirlChoiceScreenState();
}

class _GirlChoiceScreenState extends State<GirlChoiceScreen> {
  late FlutterTts _flutterTts;

  @override
  void initState() {
    super.initState();
    _flutterTts = FlutterTts();
    _setVoiceBasedOnPlatform();
  }


  void _setVoiceBasedOnPlatform() async {
    List<dynamic> voices = await _flutterTts.getVoices;

    for (var voice in voices) {
      print('Voice: ${voice['name']} - Locale: ${voice['locale']}');
    }

    bool voiceSet = false;

    for (var voice in voices) {
      if (Platform.isAndroid && voice['name'] == 'Google UK English Female') {
        print('Setting Android voice: Google UK English Female');
        await _flutterTts.setVoice({"name": voice['name'], "locale": "en-GB"});
        voiceSet = true;

      } else if (Platform.isIOS && voice['name'] == 'Siri') {
        print('Setting iOS voice: Siri');
        await _flutterTts.setVoice({"name": voice['name'], "locale": "en-US"});
        voiceSet = true;

      } else if (Platform.isWindows &&
          voice['name'] == 'Microsoft Zira - English (United States)') {
        print('Setting Windows voice: Microsoft Zira');
        await _flutterTts.setVoice({"name": voice['name'], "locale": "en-US"});
        voiceSet = true;

      }
      else if (Platform.isMacOS && voice['name'] == 'Siri') {
        print('Setting macOS voice: Siri');
        await _flutterTts.setVoice({"name": voice['name'], "locale": "en-US"});
        voiceSet = true;
        break;
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
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      backgroundColor: Colors.blueGrey,
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Container(
            height: screenHeight / 3,
            width: screenWidth,
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.only(bottomRight: Radius.circular(70)),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.qr_code_scanner,
                  color: Colors.white,
                  size: 80,
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "ABC",
                  style: TextStyle(
                      fontSize: 25,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),

          SizedBox(
            height: 40,
            child: Center(
              child: Text(
                "WHAT DO YOU WANT TO DO??",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.5,

                ),
              ),
            ),
          ),

          SizedBox(
            height: 50,
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GirlTextScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "TEXT",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          SizedBox(
            height: 50,
            child: Center(
              child: ElevatedButton(
                onPressed: () {

                  _setVoiceBasedOnPlatform();

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GirlVideoScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "VIDEO CALL",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          const Spacer(),

          const SizedBox(
            height: 30,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.copyright,
                    size: 18,
                    color: Colors.black,
                  ),
                  SizedBox(width: 5),
                  Text(
                    "SHANKY",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
