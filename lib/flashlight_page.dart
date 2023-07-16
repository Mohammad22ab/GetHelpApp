import 'dart:async';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class FlashlightPage extends StatefulWidget {
  const FlashlightPage({Key? key}) : super(key: key);

  @override
  _FlashlightPageState createState() => _FlashlightPageState();
}

class _FlashlightPageState extends State<FlashlightPage> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  bool isSOSActive = false;

  @override
  void initState() {
    super.initState();
    _initializeControllerFuture = initializeCamera();
  }

  Future<void> initializeCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.first;

    _controller = CameraController(camera, ResolutionPreset.low);
    await _controller.initialize();
  }

  void activateSOS() async {
    if (!isSOSActive) {
      isSOSActive = true;
      bool stopSOS = false;

      // Start a timer for 120 seconds
      Timer(const Duration(seconds: 120), () {
        stopSOS = true;
      });

      while (!stopSOS) {
        await _controller.setFlashMode(FlashMode.torch);
        await Future.delayed(const Duration(milliseconds: 500));
        await _controller.setFlashMode(FlashMode.off);
        await Future.delayed(const Duration(milliseconds: 500));

        if (!isSOSActive) {
          break;
        }
      }

      if (isSOSActive) {
        await _controller.setFlashMode(FlashMode.off);
      }

      isSOSActive = false;
    } else {
      // Turn off SOS flashlight if already active
      isSOSActive = false;
      await _controller.setFlashMode(FlashMode.off);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashlight SOS'),
        backgroundColor: Colors.green,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'images/bg2.png'), // Replace with your background image path
            fit: BoxFit.cover,
          ),
        ),
        child: FutureBuilder<void>(
          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '                   Activate SOS flashlight                            ',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 60),
                  ElevatedButton(
                    onPressed: activateSOS,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.all(35),
                      shape: const CircleBorder(),
                    ),
                    child: const Icon(
                      Icons.power_settings_new,
                      size: 36,
                      color: Colors.white,
                    ),
                  ),
                ],
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}
