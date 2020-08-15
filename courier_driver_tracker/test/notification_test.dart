import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_local_notifications/src/platform_specifics/android/enums.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:platform/platform.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  group('android', () {
    const MethodChannel channel =
    MethodChannel('dexterous.com/flutter/local_notifications');
    List<MethodCall> log = <MethodCall>[];

    setUp(() {
      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin.private(
          FakePlatform(operatingSystem: 'android'));
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
        if (methodCall.method == 'pendingNotificationRequests') {
          return Future.value(List<Map<String, Object>>());
        } else if (methodCall.method == 'getNotificationAppLaunchDetails') {
          return Future.value(Map<String, Object>());
        }
      });
    });

    tearDown(() {
      log.clear();
    });

    test('The android notification plugin should initialize.', () async {
      const AndroidInitializationSettings androidInitializationSettings =
      AndroidInitializationSettings('app_icon');
      const InitializationSettings initializationSettings =
      InitializationSettings(androidInitializationSettings, null);
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);
      expect(log, <Matcher>[
        isMethodCall('initialize', arguments: <String, Object>{
          'defaultIcon': 'app_icon',
        })
      ]);
    });

    test('Notification should show with android specific details.', () async {
      const AndroidInitializationSettings androidInitializationSettings =
      AndroidInitializationSettings('app_icon');
      const InitializationSettings initializationSettings =
      InitializationSettings(androidInitializationSettings, null);
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);
      const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails(
          'channelId', 'channelName', 'channelDescription');

      await flutterLocalNotificationsPlugin.show(
          1,
          'notification title',
          'notification body',
          NotificationDetails(androidNotificationDetails, null));
      expect(
          log.last,
          isMethodCall('show', arguments: <String, Object>{
            'id': 1,
            'title': 'notification title',
            'body': 'notification body',
            'payload': '',
            'platformSpecifics': <String, Object>{
              'icon': null,
              'channelId': 'channelId',
              'channelName': 'channelName',
              'channelDescription': 'channelDescription',
              'channelShowBadge': true,
              'channelAction':
              AndroidNotificationChannelAction.CreateIfNotExists.index,
              'importance': Importance.Default.value,
              'priority': Priority.Default.value,
              'playSound': true,
              'enableVibration': true,
              'vibrationPattern': null,
              'groupKey': null,
              'setAsGroupSummary': null,
              'groupAlertBehavior': GroupAlertBehavior.All.index,
              'autoCancel': true,
              'ongoing': null,
              'colorAlpha': null,
              'colorRed': null,
              'colorGreen': null,
              'colorBlue': null,
              'onlyAlertOnce': null,
              'showWhen': true,
              'when': null,
              'showProgress': false,
              'maxProgress': 0,
              'progress': 0,
              'indeterminate': false,
              'enableLights': false,
              'ledColorAlpha': null,
              'ledColorRed': null,
              'ledColorGreen': null,
              'ledColorBlue': null,
              'ledOnMs': null,
              'ledOffMs': null,
              'ticker': null,
              'visibility': null,
              'timeoutAfter': null,
              'category': null,
              'additionalFlags': null,
              'style': AndroidNotificationStyle.Default.index,
              'styleInformation': <String, Object>{
                'htmlFormatContent': false,
                'htmlFormatTitle': false,
              },
            },
          }));
    });

    test('Notification should show without android specific details.', () async {
      const AndroidInitializationSettings androidInitializationSettings =
      AndroidInitializationSettings('app_icon');
      const InitializationSettings initializationSettings =
      InitializationSettings(androidInitializationSettings, null);
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);
      await flutterLocalNotificationsPlugin.show(
          1, 'notification title', 'notification body', null);
      expect(
          log.last,
          isMethodCall('show', arguments: <String, Object>{
            'id': 1,
            'title': 'notification title',
            'body': 'notification body',
            'payload': '',
            'platformSpecifics': null,
          }));
    });

    test('The notification channel should be deleted.', () async {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          .deleteNotificationChannel('channelId');
      expect(log, <Matcher>[
        isMethodCall('deleteNotificationChannel', arguments: 'channelId')
      ]);
    });

    test('The current notification should be cancelled.', () async {
      await flutterLocalNotificationsPlugin.cancel(1);
      expect(log, <Matcher>[isMethodCall('cancel', arguments: 1)]);
    });

  });

}