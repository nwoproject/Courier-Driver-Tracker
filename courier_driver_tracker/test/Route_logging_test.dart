import 'package:courier_driver_tracker/services/location/route_logging.dart';
import 'package:flutter_test/flutter_test.dart';
void main() {
  group('PathProvider', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    RouteLogging logger = RouteLogging();

    test('Local path should contain the path.', () async{
      bool created = false;
      String path = await logger.localPath.toString();
      if (path.length > 0)
        {
          created = true;
        }
      else
        created = false;
      expect(created, true);
    });

    test('Local file should contain the file.', () async*{
      bool created = false;
      String file = logger.locationFile.toString();
      if (file.length > 0)
      {
        created = true;
      }
      else
        created = false;
      expect(created, true);
    });
  });
}

