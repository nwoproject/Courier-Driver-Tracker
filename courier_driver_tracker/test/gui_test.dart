import 'package:courier_driver_tracker/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:courier_driver_tracker/routing.dart';
import 'package:mockito/mockito.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {

    testWidgets('LoginPage defualt route and input widgets and button is present',
      (WidgetTester tester) async {
    final mockObserver = MockNavigatorObserver();
    await tester.pumpWidget(
      MaterialApp(
      initialRoute: '/',
      onGenerateRoute: Router.generateRoute,
        navigatorObservers: [mockObserver],
      ),
    );

    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);

  });

  
  testWidgets('Login button triggers navigation to home when tapped',
      (WidgetTester tester) async {
    final mockObserver = MockNavigatorObserver();
    await tester.pumpWidget(
      MaterialApp(
      initialRoute: '/',
      onGenerateRoute: Router.generateRoute,
        navigatorObservers: [mockObserver],
      ),
    );

  
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    verify(mockObserver.didPush(any, any));

    expect(find.byType(HomePage), findsOneWidget);
  });
}


