import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vendue_vendor/src/models/signin_model.dart';
import 'package:vendue_vendor/src/views/home.dart';
import 'package:vendue_vendor/src/views/productList.dart';
import 'package:vendue_vendor/src/views/profile.dart';
import 'package:vendue_vendor/src/views/serviceList.dart';

// ignore: must_be_immutable
class TabbarScreen extends StatefulWidget {
  int currentTab;
  Widget currentPage = HomeScreen();
  TabbarScreen({Key key, this.currentTab}) : super(key: key) {
    currentTab = currentTab != (null) ? currentTab : 0;
  }

  @override
  _TabbarScreenState createState() => _TabbarScreenState();
}

class _TabbarScreenState extends State<TabbarScreen> {
  // int _currentIndex = 0;
  SigninModel signinModel;

  // List<dynamic> _handlePages = [
  //   HomeScreen(),
  //   ServiceList(),
  //   ProductList(),
  //   BookingList(),
  //   // FireChatList(),
  //   ProfileScreen(),
  // ];

  // ignore: unused_field

  initState() {
    request();
    super.initState();
    _selectTab(widget.currentTab);
  }

  bool isLoading = false;

  void _selectTab(int tabItem) {
    setState(() {
      widget.currentTab = tabItem;
      switch (tabItem) {
        case 0:
          widget.currentPage = HomeScreen();
          break;
        case 1:
          widget.currentPage = ServiceList();
          break;
        case 2:
          widget.currentPage = ProductList();
          break;

        case 3:
          widget.currentPage = ProfileScreen();
          break;
      }
    });
  }

  request() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.storage,
      Permission.notification,
      Permission.camera,
    ].request();
    print(statuses[Permission.location]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: false,
      body: widget.currentPage,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10), topRight: Radius.circular(10)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black45,
              blurRadius: 5,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10), topRight: Radius.circular(10)),
          child: BottomNavigationBar(
            // iconSize: 28,
            backgroundColor: Colors.white,
            type: BottomNavigationBarType.fixed,
            selectedFontSize: 0,
            unselectedFontSize: 0,

            selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
            // unselectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
            currentIndex: widget.currentTab,
            onTap: (int i) {
              _selectTab(i);
            },

            items: <BottomNavigationBarItem>[
              widget.currentTab == 0
                  ? BottomNavigationBarItem(
                      icon: Image.asset(
                        'assets/images/home_fill.png',
                        height: 25,
                      ),
                      label: "")
                  : BottomNavigationBarItem(
                      icon: Image.asset(
                        'assets/images/home_outline.png',
                        height: 25,
                      ),
                      label: ""),
              widget.currentTab == 1
                  ? BottomNavigationBarItem(
                      icon: Image.asset(
                        'assets/images/service_fill.png',
                        height: 25,
                      ),
                      label: "")
                  : BottomNavigationBarItem(
                      icon: Image.asset(
                        'assets/images/service_outline.png',
                        height: 25,
                      ),
                      label: ""),
              widget.currentTab == 2
                  ? BottomNavigationBarItem(
                      icon: Image.asset(
                        'assets/images/Product.png',
                        height: 25,
                      ),
                      label: "")
                  : BottomNavigationBarItem(
                      icon:
                          Image.asset('assets/images/package.png', height: 25),
                      label: ""),
              widget.currentTab == 3
                  ? BottomNavigationBarItem(
                      icon: Image.asset(
                        'assets/images/pro_fill.png',
                        height: 25,
                      ),
                      label: "")
                  : BottomNavigationBarItem(
                      icon: Image.asset(
                        'assets/images/pro_outline.png',
                        height: 25,
                      ),
                      label: ""),
            ],
          ),
        ),
      ),
    );
  }
}
