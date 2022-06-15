import 'package:ballot_box/constants.dart';
import 'package:flutter/material.dart';

import 'create_poll_candidates_screen.dart';
import 'find_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  PageController pageController = PageController();

  static const List<Widget> _widgetOptions = <Widget>[
    Text(
      'Create A Poll',
    ),
    Text(
      'Find A Poll',
    ),
  ];

  static const List<Widget> _pages = <Widget>[CreatePage(), FindPage()];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    pageController.animateToPage(
      index,
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _widgetOptions[_currentIndex],
        centerTitle: true,
      ),
      body: PageView(
        controller: pageController,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.edit), label: "Create"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Find"),
        ],
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class CreatePage extends StatelessWidget {
  const CreatePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          WidgetContainer(
            height: 70,
            child: ElevatedButton(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const <Widget>[
                  Icon(Icons.add),
                  SizedBox(width: 10),
                  Text('New Poll'),
                ],
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreatePollScreen(),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
