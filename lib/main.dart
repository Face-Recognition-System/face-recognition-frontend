import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'capture_provider.dart';
import 'capture_screen.dart'; // Ensure this import is correct
import 'register_form.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  runApp(MyApp(cameras: cameras));
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;

  MyApp({required this.cameras});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CaptureProvider()),
      ],
      child: MaterialApp(
        title: 'Face Recognition App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: HomeScreen(cameras: cameras),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  HomeScreen({required this.cameras});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Face Recognition App'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CaptureScreen(cameras: widget.cameras), // Ensure CaptureScreen is correctly imported and used
            Consumer<CaptureProvider>(
              builder: (context, captureProvider, child) {
                if (captureProvider.capturedImage != null) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 24.0),
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
                            captureProvider.capturedImage!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(height: 16.0),
                      Text(
                        captureProvider.result ?? '',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () => captureProvider.clear(),
                            child: Text('Take New Picture'),
                          ),
                          SizedBox(width: 20),
                          ElevatedButton(
                            onPressed: () => captureProvider.showRegisterForm(),
                            child: Text('Register New Student'),
                          ),
                        ],
                      ),
                      if (captureProvider.showForm)
                        RegisterForm(imageBytes: captureProvider.capturedImage!),
                    ],
                  );
                } else {
                  return Text('');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}