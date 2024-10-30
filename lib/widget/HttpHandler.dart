import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'internet.dart';

class HttpHandler {
  final BuildContext contx;

  HttpHandler({required this.contx});

  Future<bool> InternetConnection(bool showMessage) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      if (showMessage) {
        Navigator.of(contx).push(
          MaterialPageRoute(builder: (context) => Internet()),
        );
      }
    }
    return false;
  }
}
