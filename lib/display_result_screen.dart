import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'capture_provider.dart';

class DisplayResultScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final result = Provider.of<CaptureProvider>(context).result;

    return Scaffold(
      appBar: AppBar(title: Text('Recognition Result')),
      body: Center(
        child: result != null
            ? Text('Recognition Result: $result')
            : Text('No result available.'),
      ),
    );
  }
}