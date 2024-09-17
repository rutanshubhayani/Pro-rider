import 'dart:io';
import 'package:flutter/material.dart';

class License extends StatelessWidget {
  final File imageFile;

  const License({Key? key, required this.imageFile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Preview'),
      ),
      body: Center(
        child: Image.file(
          imageFile,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
