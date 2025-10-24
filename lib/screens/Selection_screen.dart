import 'package:flutter/material.dart';
import 'employer_dashboard.dart';           
import 'item_selection_page.dart';
import '../Utils/selection_tools.dart';
import 'pdf_menu_page.dart';
import 'role_login_page.dart';              

class SelectScreen extends StatefulWidget {
  const SelectScreen({super.key});

  static const List<String> drinks = ['Water', 'CocaCola', 'Fanta', 'Sprite'];
  static const List<String> desserts = ['Brownie', 'Cheesecake', 'Ice Cream'];
  static const List<String> extras = ['Fries', 'Onion Rings', 'Breadsticks'];

  @override
  State<SelectScreen> createState() => _SelectScreenState();
}

class _SelectScreenState extends State<SelectScreen> {
  @override
  Widget build(BuildContext context) {
    final double bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Selection Page"),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: SafeArea(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 250,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ItemsSelectionPage(
                                title: 'Drinks',
                                items: SelectScreen.drinks,
                              ),
                            ),
                          );
                        },
                        child: const Text("Refills"),
                        key: const Key("Refills-button"),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 250,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ItemsSelectionPage(
                                title: 'Desserts',
                                items: SelectScreen.desserts,
                              ),
                            ),
                          );
                        },
                        child: const Text("Desserts"),
                        key: const Key("Desserts-button"),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 250,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ItemsSelectionPage(
                                title: 'Extras',
                                items: SelectScreen.extras,
                              ),
                            ),
                          );
                        },
                        child: const Text("Extras"),
                        key: const Key("Extras-button"),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 250,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () => PopupUtils.showServerOnTheWay(context),
                        child: const Text("Call Server"),
                        key: const Key("Call-server"),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 250,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PdfMenuPage(),
                            ),
                          );
                        },
                        child: const Text("View Menu"),
                        key: const Key("Menu-button"),
                      ),
                    ),
                    SizedBox(height: 24 + bottomInset),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 10 + bottomInset,
            right: 10,
            child: FloatingActionButton.extended(
              onPressed: () {
                // 👇 CHANGE: go to RoleLoginPage (Server or Manager)
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RoleLoginPage()),
                );
              },
              label: const Text(
                'Employer Login',
                style: TextStyle(fontSize: 12),
              ),
              icon: const Icon(Icons.lock),
              backgroundColor: const Color.fromARGB(221, 231, 230, 230),
            ),
          ),
        ],
      ),
    );
  }
}
