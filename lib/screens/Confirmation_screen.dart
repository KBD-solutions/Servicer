import 'package:flutter/material.dart';


class ConfirmationScreen extends StatefulWidget {
  const ConfirmationScreen({super.key});

  @override
  State<ConfirmationScreen> createState() => _ConfirmationscreenState();
}

class _ConfirmationscreenState extends State<ConfirmationScreen> {
  int amount = 0;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Choose your item"),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Sprite", 
                style: TextStyle(
                  fontSize: 20,
                  backgroundColor: Colors.blue,
                  ),
                ),
                //this Icon removes
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: amount > 0 ? () {
                    setState(() {
                      amount--;
                    });
                  }
                  : null,
                ),
                
                //this icon adds items 
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    setState(() {
                      amount++;
                    });
                  },
                ),

                //container for the amount of items added or removed
                Container(
                  width:60,
                  height:40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text("$amount"),
                ),
              ],
            ),
            //fanta option
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Fanta", 
                style: TextStyle(
                  fontSize: 20,
                  backgroundColor: Colors.blue,
                  ),
                ),
                //this Icon removes
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: amount > 0 ? () {
                    setState(() {
                      amount--;
                    });
                  }
                  : null,
                ),
                
                //this icon adds items 
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    setState(() {
                      amount++;
                    });
                  },
                ),

                //container for the amount of items added or removed
                Container(
                  width:60,
                  height:40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text("$amount"),
                ),
              ],
            ),

            //Coke option
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("CocaCola", 
                style: TextStyle(
                  fontSize: 20,
                  backgroundColor: Colors.blue,
                  ),
                ),
                //this Icon removes
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: amount > 0 ? () {
                    setState(() {
                      amount--;
                    });
                  }
                  : null,
                ),
                
                //this icon adds items 
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    setState(() {
                      amount++;
                    });
                  },
                ),

                //container for the amount of items added or removed
                Container(
                  width:60,
                  height:40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text("$amount"),
                ),
              ],
            ),
          ],
        )
      ),
    );
  }
}