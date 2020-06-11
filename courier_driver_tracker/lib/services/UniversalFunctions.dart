import 'dart:math' show cos, sqrt, asin;

bool isMoving(currentLoc, previousLoc){

  //get current loc

  var p = 0.017453292519943295;
  var c = cos;
  var a = 0.5 - c((currentLoc.latitude - previousLoc.latitude) * p)/2 +
      c(previousLoc.latitude * p) * c(currentLoc.latitude * p) *
          (1 - c((currentLoc.longitude - previousLoc.longitude) * p))/2;
  var distance = 12742 * asin(sqrt(a));

  return true;

}