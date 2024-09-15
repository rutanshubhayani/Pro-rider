import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'internet.dart';

class HttpHandler {
  final BuildContext ctx;

  HttpHandler({required this.ctx});

  Future<bool> netconnection(bool showMessage) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      if (showMessage) {
        Navigator.of(ctx).push(
          MaterialPageRoute(builder: (context) => OnInternet()),
        );
      }
    }
    return false;
  }
}
