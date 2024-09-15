// ignore_for_file: empty_catches

import 'dart:math';
import 'package:flutter/material.dart';

extension SizeExtension on num {
  double get kp => FontHandel.setSp(this);
}

class FontHandel {
  static double screenWidth = 0;
  static double screenHeight = 0;
  MediaQueryData? _mediaQueryData;
  static Orientation? orientation;
  BuildContext? context;
  static Size _uiSize = Size(360, 690);
  void initContext(BuildContext context) {
    this.context = context;
    try {
      this._mediaQueryData = MediaQuery.of(context);
    } catch (e) {}
    if (_mediaQueryData != null) {
      FontHandel.screenWidth = _mediaQueryData!.size.width;
      FontHandel.screenHeight = _mediaQueryData!.size.height;
      FontHandel.orientation = _mediaQueryData!.orientation;
      FontHandel._uiSize = _mediaQueryData!.size;
    }
  }

  static double get scaleWidth => screenWidth / _uiSize.width;

  static double get scaleHeight => max(screenHeight, 700) / _uiSize.height;

  static double get scaleText => min(scaleWidth, scaleHeight);

  static void init() {
    screenWidth = _uiSize.width;
    screenHeight = _uiSize.height;
  }

  static double setSp(num fontSize) {
    init();
    return fontSize * scaleText;
  }
}

class KSize {
  MediaQueryData? _mediaQueryData;
  double screenWidth = 0;
  double screenHeight = 0;
  double defaultSize = 0;
  double topPadding = 0;
  double toolbarSize = 0;
  Orientation? orientation;
  FontHandel? fh;
  late Size _uiSize;
  List<double> wd = [];
  List<double> hd = [];

  KSize(BuildContext context, double toolbarSize, {isToppading = false}) {
    try {
      _mediaQueryData = MediaQuery.of(context);
    } catch (e) {}
    if (_mediaQueryData != null) {
      screenWidth = _mediaQueryData!.size.width;
      screenHeight = _mediaQueryData!.size.height;
      orientation = _mediaQueryData!.orientation;
      if (isToppading == true) {
        topPadding = _mediaQueryData!.padding.top;
      } else {
        topPadding = 0;
      }
      toolbarSize = toolbarSize;
      _uiSize = _mediaQueryData!.size;
    }

    for (var i = 1; i <= 15; i++) {
      wd.add(w(double.parse("$i")));
      hd.add(h(double.parse("$i")));
    }

    fh = FontHandel();
    fh!.initContext(context);
  }

  double get scaleWidth => screenWidth / _uiSize.width;

  double get scaleHeight => max(screenHeight, 700) / _uiSize.height;

  double get scaleText => min(scaleWidth, scaleHeight);

  double setSp(num fontSize) {
    return fontSize * scaleText;
  }

  double w(double value) {
    double? screenWidth = this.screenWidth;
    return (screenWidth * value) / 100;
  }

  double h(double value) {
    double? screenWidtht = screenHeight - topPadding - toolbarSize;
    return (screenWidtht * value) / 100;
  }
}
