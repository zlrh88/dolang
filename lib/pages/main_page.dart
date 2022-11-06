import 'dart:math';

import 'package:calendar_appbar/calendar_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:uangkoo/models/database.dart';
import 'package:uangkoo/pages/category_page.dart';
import 'package:uangkoo/pages/home_page.dart';
import 'package:uangkoo/pages/transaction_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late DateTime selectedDate;
  late List<Widget> _children;
  late int currentIndex;

  final database = AppDb();

  TextEditingController categoryNameController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    selectedDate =
        DateTime.parse(DateFormat('yyyy-MM-dd').format(DateTime.now()));
    currentIndex = 0;
    _children = [
      HomePage(
        selectedDate: selectedDate,
      ),
      CategoryPage()
    ];
    super.initState();
  }

  Future<List<Category>> getAllCategory() {
    return database.select(database.categories).get();
  }

  void showAwe() async {
    List<Category> al = await getAllCategory();
    print('PANJANG : ' + al.length.toString());
  }

  void onTabTapped(int index) {
    setState(() {
      selectedDate =
          DateTime.parse(DateFormat('yyyy-MM-dd').format(DateTime.now()));
      currentIndex = index;
      _children = [
        HomePage(
          selectedDate: selectedDate,
        ),
        CategoryPage()
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: Visibility(
          visible: (currentIndex == 0) ? true : false,
          child: FloatingActionButton(
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(
                      builder: (context) => TransactionPage(),
                    ))
                    .then((value) {});
                currentIndex = 0;
                _children = [
                  HomePage(
                    selectedDate: selectedDate,
                  ),
                  CategoryPage()
                ];
                setState(() {});
              },
              backgroundColor: Colors.green,
              child: Icon(Icons.add)),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
                onPressed: () {
                  onTabTapped(0);
                },
                icon: Icon(Icons.home)),
            SizedBox(
              width: 20,
            ),
            IconButton(
                onPressed: () {
                  onTabTapped(1);
                },
                icon: Icon(Icons.list))
          ],
        )),
        body: _children[currentIndex],
        appBar: (currentIndex == 1)
            ? PreferredSize(
                preferredSize: const Size.fromHeight(100),
                child: Container(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 36, horizontal: 16),
                    child: Text(
                      "Categories",
                      style: GoogleFonts.montserrat(fontSize: 20),
                    ),
                  ),
                ),
              )
            : CalendarAppBar(
                fullCalendar: true,
                backButton: false,
                accent: Colors.green,
                locale: 'en',
                onDateChanged: (value) {
                  setState(() {
                    selectedDate = value;
                    currentIndex = 0;
                    _children = [
                      HomePage(
                        selectedDate: DateTime.parse(
                            DateFormat('yyyy-MM-dd').format(selectedDate)),
                      ),
                      CategoryPage()
                    ];
                  });
                },
                lastDate: DateTime.now()));
  }
}
