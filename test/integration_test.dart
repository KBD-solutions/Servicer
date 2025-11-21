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
      GIVEN I am in the selection screen
      WHEN i press the 'Menu' button
      THEN I should see the Restraunt Menu
    */
    testWidgets("View Menu PDF", (WidgetTester tester) async {
      //arrange
      await tester.pumpWidget(const MyApp());

      //act
      final menuButton = find.byKey(const Key("Menu-button"));
      await tester.tap(menuButton);
      await tester.pumpAndSettle();

      //assert
      expect(find.text('Menu'), findsOneWidget);
    },skip: true);
  });
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
      expect(find.text('Selection Page'), findsOneWidget);
    });
}