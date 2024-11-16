import 'dart:async';
import 'dart:io';
import 'dart:convert'; // For Base64 encoding
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late CameraController _controller;
  bool _isCameraInitialized = false;
  late List<CameraDescription> cameras;

  bool _isRecording = false;
  NoiseReading? _latestReading;
  StreamSubscription<NoiseReading>? _noiseSubscription;
  NoiseMeter? noiseMeter;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    // Initialize the first available camera
    _controller = CameraController(
      cameras[0], // Select the first camera
      ResolutionPreset.high,
    );
    await _controller.initialize();
    if (!mounted) return;
    setState(() {
      _isCameraInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Center(
            child: Text('Home Screen'),
          ),
          SizedBox(
            height: 20,
          ),
          CircularProgressIndicator(),
          _isCameraInitialized
              ? Stack(
                  children: [
                    CameraPreview(_controller),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ElevatedButton(
                          onPressed: _capturePhoto,
                          child: Text('Capture Photo'),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            textStyle: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                    Center(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                          Container(
                              margin: EdgeInsets.all(25),
                              child: Column(children: [
                                Container(
                                  child: Text(
                                      _isRecording ? "Mic: ON" : "Mic: OFF",
                                      style: TextStyle(
                                          fontSize: 25, color: Colors.blue)),
                                  margin: EdgeInsets.only(top: 20),
                                ),
                                Container(
                                  child: Text(
                                    'Noise: ${_latestReading?.meanDecibel.toStringAsFixed(2)} dB',
                                  ),
                                  margin: EdgeInsets.only(top: 20),
                                ),
                                Container(
                                  child: Text(
                                    'Max: ${_latestReading?.maxDecibel.toStringAsFixed(2)} dB',
                                  ),
                                )
                              ])),
                        ])),
                    FloatingActionButton(
                      backgroundColor: _isRecording ? Colors.red : Colors.green,
                      child: _isRecording ? Icon(Icons.stop) : Icon(Icons.mic),
                      onPressed: _isRecording ? stop : start,
                    ),
                  ],
                )
              : Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Future<void> _capturePhoto() async {
    if (!_controller.value.isInitialized) return;

    try {
      final image = await _controller.takePicture();
      print('Photo captured: ${image.path}');

      // Read the file and convert to Base64
      final bytes = await File(image.path).readAsBytes();
      final base64String = base64Encode(bytes);
      print('Base64 String: $base64String');

      // Display a dialog with the captured image
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.file(File(image.path)),
              Text('Photo saved at: ${image.path}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      print('Error capturing photo: $e');
    }
  }

  void onData(NoiseReading noiseReading) {
    print('noiseReading');
    print(noiseReading);
    setState(() => _latestReading = noiseReading);
    if (noiseReading.meanDecibel > 70) {
      print('Ejecutamos el metodo enviar foto');
    }
  }

  void onError(Object error) {
    print(error);
    stop();
  }

  /// Check if microphone permission is granted.
  Future<bool> checkPermission() async => await Permission.microphone.isGranted;

  /// Request the microphone permission.
  Future<void> requestPermission() async =>
      await Permission.microphone.request();

  /// Start noise sampling.
  Future<void> start() async {
    // Create a noise meter, if not already done.
    noiseMeter ??= NoiseMeter();

    // Check permission to use the microphone.
    //
    // Remember to update the AndroidManifest file (Android) and the
    // Info.plist and pod files (iOS).
    if (!(await checkPermission())) await requestPermission();

    // Listen to the noise stream.
    _noiseSubscription = noiseMeter?.noise.listen(onData, onError: onError);
    setState(() => _isRecording = true);
  }

  /// Stop sampling.
  void stop() {
    _noiseSubscription?.cancel();
    setState(() => _isRecording = false);
  }

  @override
  void dispose() {
    super.dispose();
    _noiseSubscription?.cancel();
  }
}
