import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class BeepButton extends StatefulWidget {
  const BeepButton({Key? key}) : super(key: key);

  @override
  _BeepButtonState createState() => _BeepButtonState();
}

class _BeepButtonState extends State<BeepButton> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
  }

  Future<void> _playSound() async {
    if (_isPlaying) {
      await _audioPlayer.stop();
      setState(() {
        _isPlaying = false;
      });
    } else {
      await _audioPlayer.play(AssetSource('alarm.mp3'));
      setState(() {
        _isPlaying = true;
      });
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Beep Button'),
          backgroundColor: Colors.green,
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image:
                  AssetImage('images/bg2.png'), // Replace with your image path
              fit: BoxFit.cover, // Adjust the image fit property as needed
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                ' Press to activate Emergency sound: ',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 30),
              Material(
                elevation: 15,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: SizedBox(
                  width: 275,
                  height: 200,
                  child: InkWell(
                    onTap: _playSound,
                    child: Ink.image(
                      image: const AssetImage('images/bell1.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
