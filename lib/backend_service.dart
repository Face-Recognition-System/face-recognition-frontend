import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class BackendService {
  static const String baseUrl = 'http://192.168.43.68:8000';

  static Future<bool> registerStudent({
    required String name,
    required String level,
    required String matricule,
    required String course,
    required String department,
    required Uint8List imageBytes,
  }) async {
    var uri = Uri.parse('$baseUrl/register/');

    try {
      var request = http.MultipartRequest('POST', uri);
      request.fields['name'] = name;
      request.fields['level'] = level;
      request.fields['matricule'] = matricule;
      request.fields['course'] = course;
      request.fields['department'] = department;

      // Use MultipartFile.fromBytes
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        imageBytes,
        filename: 'image.png',
        contentType: MediaType('image', 'png'),
      ));

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        print('Student registered successfully: $responseBody');
        return true;
      } else {
        print('Failed to register student: ${response.statusCode}');
        print('Response body: ${await response.stream.bytesToString()}');
        return false;
      }
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>> recognizeStudent({
    required Uint8List imageBytes,
  }) async {
    var uri = Uri.parse('$baseUrl/recognize/');

    try {
      var request = http.MultipartRequest('POST', uri);
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        imageBytes,
        filename: 'image.png',
        contentType: MediaType('image', 'png'),
      ));

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        var responseData = jsonDecode(responseBody);
        return {'success': true, 'data': responseData};
      } else if (response.statusCode == 400) {
        var responseBody = await response.stream.bytesToString();
        print('No face detected in the image: $responseBody');
        return {'success': false, 'message': 'No face detected in the image'};
      } else {
        print('Failed to recognize student: ${response.statusCode}');
        print('Response body: ${await response.stream.bytesToString()}');
        return {'success': false, 'message': 'Recognition failed: ${response.statusCode}'};
      }
    } catch (e) {
      print('Error: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}