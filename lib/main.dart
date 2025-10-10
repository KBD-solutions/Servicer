import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SelectScreen(),      
    );
  }
}


class SelectScreen extends StatefulWidget {
  const SelectScreen({super.key});

  @override
  State<SelectScreen> createState() => _SelectScreenState();
}

class _SelectScreenState extends State<SelectScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child:
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 250,
                height: 60,
                child: ElevatedButton(onPressed: 
                () {},
                child: Text("Refills")
                )),
                SizedBox(
                width: 250,
                height: 60,
                child: ElevatedButton(onPressed: 
                () {},
                child: Text("Desserts")
                )),
                SizedBox(
                width: 250,
                height: 60,
                child: ElevatedButton(onPressed: 
                () {},
                child: Text("Extras")
                )),
                SizedBox(
                width: 250,
                height: 60,
                child: ElevatedButton(onPressed: 
                () {},
                child: Text("Call Server")
                )),
            ]
          ),
      ),
    );
  }
}