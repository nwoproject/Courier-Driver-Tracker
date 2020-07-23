import 'package:courier_driver_tracker/services/abnormality/abnormality_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';

void main(){

  Position start = new Position(
    latitude: 25.0,
    longitude: 25.0,
    speed: 120.0
  );

  Position middel = new Position(
      latitude: 26.0,
      longitude: 26.0,
      speed: 120.0
  );

  Position end = new Position(
      latitude: 27.0,
      longitude: 27.0,
      speed: 0.0
  );
  AbnormalityService abnormalityService = AbnormalityService();

  test("Positions should be set",(){
    abnormalityService.setCurrentLocation(start);
    bool isSet = abnormalityService.getCurrentLocation() != null && abnormalityService.getLastLocation() != null;
    expect(isSet, true);
  });

  test("Stopped moving abnormality should return true",(){

    bool stopped;
    abnormalityService.setCurrentLocation(start);
    abnormalityService.setMaxStopCount(1);
    abnormalityService.stoppingTooLong();
    stopped = abnormalityService.stoppingTooLong();

    expect(stopped, true);

  });

  test("Stopped moving abnormality should return false",(){
    for(int each = 0; each > 99; each++){
      abnormalityService.setCurrentLocation(start);
    }
    abnormalityService.setCurrentLocation(middel);
    abnormalityService.setCurrentLocation(end);

    bool stopped = abnormalityService.stoppingTooLong();
    expect(stopped, false);
  });

  test("Sudden stop abnormality should return true",(){
    abnormalityService.setCurrentLocation(end);
    abnormalityService.setLastLocation(start);

    bool stopped = abnormalityService.suddenStop();
    expect(stopped, true);
  });

  test("Sudden stop abnormality should return false",(){
    abnormalityService.setCurrentLocation(start);
    abnormalityService.setLastLocation(middel);

    bool stopped = abnormalityService.suddenStop();
    expect(stopped, false);
  });

}

