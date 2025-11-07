//material packages because we worked with widgets
import 'package:flutter/material.dart';
import 'package:Hey_Server/main.dart';

//testing packages
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main(){
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets("Testing refills button in homepage ", (WidgetTester tester) async{

    await tester.pumpWidget(const MyApp());

    final refillsButton = find.byKey(Key("Refills-button"));

    await tester.tap( refillsButton );

    await tester.pumpAndSettle();

    expect (find.text("Choose your item"), findsOneWidget);
  });
  //testing Desserts button 
  testWidgets("Testing Desserts button in homepage ", (WidgetTester tester) async{

    await tester.pumpWidget(const MyApp());

    final dessertsButton = find.byKey(Key("Desserts-button"));

    await tester.tap( dessertsButton );

    await tester.pumpAndSettle();

    expect (find.text("Choose your item"), findsOneWidget);
  });

  testWidgets("Testing Extras button in homepage ", (WidgetTester tester) async{

    await tester.pumpWidget(const MyApp());

    final extrasButton = find.byKey(Key("Extras-button"));

    await tester.tap( extrasButton );

    await tester.pumpAndSettle();

    expect (find.text("Choose your item"), findsOneWidget);
  });
  
}