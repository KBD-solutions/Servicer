//material packages because we worked with widgets
import 'package:flutter/material.dart';
import 'package:Hey_Server/main.dart';

//testing packages
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main(){
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Happy Paths', (){
    
  
    /*
      GIVEN I am at the selection screen AND press the 'Refills' button
      WHEN I press the '+' symbol for an item AND press the 'Confirm' button
      THEN I should be able to confirm an order
    */
    testWidgets("Select Refills and Confirm Order", (WidgetTester tester) async {
      //arrange
      await tester.pumpWidget(const MyApp());

      //act
      await tester.tap(find.byKey(const Key("Refills-button")));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('add_Water')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("confirm-button")));
      await tester.pumpAndSettle();

      //assert
      expect(find.text('👋 Hey Waiter!'), findsOneWidget);
    });

    /*
      GIVEN I am at the selection screen AND press the 'Desserts' button
      WHEN I press the '+' symbol for an item AND press the 'Confirm' button
      THEN I should be able to confirm an order
    */
    testWidgets("Select Desserts and Confirm Order", (WidgetTester tester) async {
      //arrange
      await tester.pumpWidget(const MyApp());

      //act
      await tester.tap(find.byKey(const Key("Desserts-button")));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('add_Brownie')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("confirm-button")));
      await tester.pumpAndSettle();

      //assert
      expect(find.text('Desserts request sent: Brownie x1'), findsOneWidget);
    });
    /*
      GIVEN I am at the selection screen AND press the 'Extras' button
      WHEN I press the '+' symbol for an item AND press the 'Confirm' button
      THEN I should be able to confirm an order
    */
    testWidgets("Select Extras and Confirm Order", (WidgetTester tester) async {
      //arrange
      await tester.pumpWidget(const MyApp());

      //act
      await tester.tap(find.byKey(const Key("Extras-button")));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('add_Fries')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("confirm-button")));
      await tester.pumpAndSettle();

      //assert
      expect(find.text('Extras request sent: Fries x1'), findsOneWidget);
    });

  });
  
  group('sad paths', (){
    /*
      GIVEN I am at the selection screen AND press the 'Refills' button
      WHEN I press the '-' symbol for an item AND press the 'Confirm' button
      THEN I should NOT be able to confirm an order
    */
    testWidgets("Select Refills and attempt to Confirm Order with negative quantity", (WidgetTester tester) async {
      //arrange
      await tester.pumpWidget(const MyApp());

      //act
      await tester.tap(find.byKey(const Key("Refills-button")));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('remove_Water')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("confirm-button")));
      await tester.pumpAndSettle();

      //assert
      expect(find.text('👋 Hey Waiter!'), findsOneWidget);
    });
  });
} 