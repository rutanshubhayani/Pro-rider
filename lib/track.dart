import 'package:flutter/material.dart';

class track extends StatelessWidget {
  const track({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Track screen'),
        backgroundColor: Color(0xFF51737A),
      ),
      body: Center(
    child: Text('Track Screen')),
    );

  }
}
