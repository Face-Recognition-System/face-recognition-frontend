import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';
import 'capture_provider.dart';
import 'backend_service.dart';
import 'register_form.dart';

class CaptureScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  CaptureScreen({required this.cameras});

  @override
  _CaptureScreenState createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  CameraController? controller;
  Uint8List? capturedImage;
  String? recognitionResult;
  bool showForm = false;
  bool noFaceDetected = false;
  Map<String, dynamic>? studentData;

  @override
  void initState() {
    super.initState();
    controller = CameraController(widget.cameras[0], ResolutionPreset.high);
    controller?.initialize().then((_) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Future<void> _captureImage() async {
    try {
      final image = await controller?.takePicture();
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          capturedImage = bytes;
          recognitionResult = null;
          showForm = false;
          noFaceDetected = false;
          studentData = null;
        });
      }
    } catch (e) {
      print('Error capturing image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error capturing image: $e')),
      );
    }
  }

  Future<void> _recognizeImage() async {
    if (capturedImage == null) return;
    try {
      var response = await BackendService.recognizeStudent(imageBytes: capturedImage!);
      setState(() {
        if (response['success']) {
          recognitionResult = response['data'] != null ? response['data']['result'] : 'Face recognized';
          studentData = response['data']['student'];
          noFaceDetected = false;
        } else {
          recognitionResult = response['message'];
          if (response['message'] == 'No face detected in the image') {
            noFaceDetected = true;
          }
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['success'] ? 'Recognition successful' : 'Error: ${response['message']}')),
      );
    } catch (e) {
      print('Error recognizing image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error recognizing image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.width, // Ensuring square aspect ratio
            child: controller != null && controller!.value.isInitialized
                ? AspectRatio(
                    aspectRatio: controller!.value.aspectRatio,
                    child: CameraPreview(controller!),
                  )
                : CircularProgressIndicator(),
          ),
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: _captureImage,
            child: Icon(Icons.camera_alt),
            style: ElevatedButton.styleFrom(
              shape: CircleBorder(),
              padding: EdgeInsets.all(24.0),
            ),
          ),
          if (capturedImage != null) ...[
            SizedBox(height: 16.0),
            Container(
              width: 200.0,
              height: 200.0,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 1.0),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.memory(
                  capturedImage!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _recognizeImage,
              child: Text('Recognize Image'),
            ),
            if (recognitionResult != null) ...[
              SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  recognitionResult!,
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
              ),
              if (studentData != null) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    'Name: ${studentData!['name']}',
                    style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    'Matricule: ${studentData!['matricule']}',
                    style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    'Level: ${studentData!['level']}',
                    style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
              if (!noFaceDetected) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        setState(() {
                          showForm = true;
                        });
                      },
                      child: Text('Register New Student'),
                    ),
                    SizedBox(width: 20),
                    OutlinedButton(
                      onPressed: _captureImage,
                      child: Text('Retake Image'),
                    ),
                  ],
                ),
                if (showForm) RegisterForm(imageBytes: capturedImage!),
              ],
            ],
          ],
        ],
      ),
    );
  }
}