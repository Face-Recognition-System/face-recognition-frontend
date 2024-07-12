import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'capture_provider.dart';
import 'backend_service.dart';

class RegisterForm extends StatefulWidget {
  final Uint8List imageBytes;

  RegisterForm({required this.imageBytes});

  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _levelController = TextEditingController();
  final _matriculeController = TextEditingController();
  final _courseController = TextEditingController();
  final _departmentController = TextEditingController();

  Future<void> _registerStudent() async {
    if (_formKey.currentState!.validate()) {
      bool success = await BackendService.registerStudent(
        name: _nameController.text,
        level: _levelController.text,
        matricule: _matriculeController.text,
        course: _courseController.text,
        department: _departmentController.text,
        imageBytes: widget.imageBytes,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Student registered successfully')),
        );
        _formKey.currentState?.reset();
        Provider.of<CaptureProvider>(context, listen: false).clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to register student')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Name'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a name';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _levelController,
            decoration: InputDecoration(labelText: 'Level'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a level';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _matriculeController,
            decoration: InputDecoration(labelText: 'Matricule'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a matricule';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _courseController,
            decoration: InputDecoration(labelText: 'Course'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a course';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _departmentController,
            decoration: InputDecoration(labelText: 'Department'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a department';
              }
              return null;
            },
          ),
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: _registerStudent,
            child: Text('Register Student'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
            ),
          ),
        ],
      ),
    );
  }
}