import 'dart:math' show cos, sqrt, asin;
import 'package:flutter/cupertino.dart';

bool isMoving(currentLoc, previousLoc) {
  //get current loc

  var p = 0.017453292519943295;
  var c = cos;
  var a = 0.5 -
      c((currentLoc.latitude - previousLoc.latitude) * p) / 2 +
      c(previousLoc.latitude * p) *
          c(currentLoc.latitude * p) *
          (1 - c((currentLoc.longitude - previousLoc.longitude) * p)) /
          2;
  var distance = 12742 * asin(sqrt(a));
  if (distance < 0) {
    return true;
  }
  return false;
}

class SizeConfig {
  static MediaQueryData _mediaQueryData;
  static double screenWidth;
  static double screenHeight;
  static double blockSizeHorizontal;
  static double blockSizeVertical;

  static double _safeAreaHorizontal;
  static double _safeAreaVertical;
  static double safeBlockHorizontal;
  static double safeBlockVertical;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;

    _safeAreaHorizontal =
        _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    _safeAreaVertical =
        _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;
    safeBlockHorizontal = (screenWidth - _safeAreaHorizontal) / 100;
    safeBlockVertical = (screenHeight - _safeAreaVertical) / 100;
  }
}
