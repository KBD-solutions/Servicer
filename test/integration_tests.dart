import 'package:flutter/material.dart';
import 'package:Hey_Server/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:Hey_Server/firebase_options.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  //set up fire base
  setUpAll(() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  });

  // Helper function to handle the login flow for every test
  Future<void> loginAsCustomer(WidgetTester tester) async {
    // Load the app
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Find Table Number and Password
    final tableField = find.widgetWithText(TextField, "Enter Table Number");
    final passField = find.widgetWithText(TextField, "Create or Enter Password");
    final loginBtn = find.widgetWithText(ElevatedButton, "Start / Join Session");

    //Enter Credentials
    await tester.enterText(tableField, "1");
    await tester.pumpAndSettle();
    
    await tester.enterText(passField, "123");
    await tester.pumpAndSettle();

    // Login
    await tester.tap(loginBtn);
    await tester.pumpAndSettle(const Duration(seconds: 2)); 
  }

  //Happy Paths

  group('Happy Paths', () {
    /*
      GIVEN I am logged in as Table 1
      WHEN I select 'Refills' -> Add Water -> Confirm
      THEN I should see a success message
    */
    testWidgets(
      "Select Refills and Confirm Order",
      (WidgetTester tester) async {
        // arrange & act (Login first)
        await loginAsCustomer(tester);

        // act - Select Refills category
        await tester.tap(find.byKey(const Key("Refills-button")));
        await tester.pumpAndSettle();

        // act - Add Water
        await tester.tap(find.byKey(const Key('add_Water')));
        await tester.pumpAndSettle();

        // act - Confirm
        await tester.tap(find.byKey(const Key("confirm-button")));
        await tester.pumpAndSettle();

        // assert - Check for the SnackBar success message defined in SelectScreen
        expect(find.text('Refills request sent: Water x1'), findsOneWidget);
      },
    );

    /*
      GIVEN I am logged in as Table 1
      WHEN I select 'Desserts' -> Add Brownie -> Confirm
      THEN I should see a success message
    */
    testWidgets(
      "Select Desserts and Confirm Order",
      (WidgetTester tester) async {
        // arrange & act
        await loginAsCustomer(tester);

        // act
        await tester.tap(find.byKey(const Key("Desserts-button")));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('add_Brownie')));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key("confirm-button")));
        await tester.pumpAndSettle();

        // assert
        expect(find.text('Desserts request sent: Brownie x1'), findsOneWidget);
      },
    );

    /*
      GIVEN I am logged in as Table 1
      WHEN I select 'Extras' -> Add Fries -> Confirm
      THEN I should see a success message
    */
    testWidgets(
      "Select Extras and Confirm Order",
      (WidgetTester tester) async {
        // arrange & act
        await loginAsCustomer(tester);

        // act
        await tester.tap(find.byKey(const Key("Extras-button")));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('add_Fries')));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key("confirm-button")));
        await tester.pumpAndSettle();

        // assert
        expect(find.text('Extras request sent: Fries x1'), findsOneWidget);
      },
    );
  });
  

  //sad paths


  group('Sad Paths', () {
    /*
      GIVEN I am logged in as Table 1
      WHEN I select 'Refills' -> Remove Water (Resulting in 0) -> Confirm
      THEN I should see "No items selected"
    */
    testWidgets(
      "Select Refills and attempt to Confirm Order with zero quantity",
      (WidgetTester tester) async {
        // arrange & act
        await loginAsCustomer(tester);

        // act
        await tester.tap(find.byKey(const Key("Refills-button")));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('remove_Water')));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key("confirm-button")));
        await tester.pumpAndSettle();

        expect(find.text('No items selected'), findsOneWidget);
      },
    );
  });
}