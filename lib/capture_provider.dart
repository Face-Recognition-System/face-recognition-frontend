import 'dart:typed_data';
import 'package:flutter/material.dart';

class CaptureProvider with ChangeNotifier {
  Uint8List? _capturedImage;
  String? _result;
  bool _showForm = false;

  Uint8List? get capturedImage => _capturedImage;
  String? get result => _result;
  bool get showForm => _showForm;

  void setCapturedImage(Uint8List image, String result) {
    _capturedImage = image;
    _result = result;
    _showForm = false;
    notifyListeners();
  }

  void clear() {
    _capturedImage = null;
    _result = null;
    _showForm = false;
    notifyListeners();
  }

  void showRegisterForm() {
    _showForm = true;
    notifyListeners();
  }
}