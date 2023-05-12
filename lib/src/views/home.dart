// ignore_for_file: unused_element, unused_local_variable

import 'dart:convert';
import 'dart:math' show cos, sqrt, asin;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vendue_vendor/src/global/global.dart';
import 'package:vendue_vendor/src/models/User_model.dart';
import 'package:vendue_vendor/src/models/product_model.dart';
import 'package:vendue_vendor/src/models/signin_model.dart';
import 'package:vendue_vendor/src/sharedpref/preferencesKey.dart';
import 'package:vendue_vendor/src/views/create_store.dart';
import 'package:vendue_vendor/src/views/edit_store.dart';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:vendue_vendor/src/views/tabbar.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ProductModel productModel;
  SigninModel signinModel;
  Position currentLocation;
  bool likePressed = false;

  Map<String, dynamic> dic;
  bool notLoader = true;

  @override
  void initState() {
    getUserCurrentLocation();
    getUserDataFromPrefs();

    super.initState();
  }

  Future getUserDataFromPrefs() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    String userDataStr =
        preferences.getString(SharedPreferencesKey.LOGGED_IN_USERRDATA);
    Map<String, dynamic> userData = json.decode(userDataStr);
    signinModel = SigninModel.fromJson(userData);

    setState(() {
      userID = signinModel.userId;
      print(userID);
    });
    _badgeCount();
    _getProducts();
    _getUSer();
  }

  refresh() {
    _getProducts();
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  Future getUserCurrentLocation() async {
    if (mounted)
      await Geolocator.getCurrentPosition().then((position) {
        if (mounted)
          setState(() {
            currentLocation = position;
            print("<><><><><><><" + currentLocation.latitude.toString());
            print("<><><><><><><" + currentLocation.longitude.toString());
          });
      });
  }

  Future<void> _pullRefresh() async {
    await Future.delayed(Duration(milliseconds: 1000));
    setState(() {
      _getProducts();
    });
  }

  _getProducts() async {
    var uri = Uri.parse('${baseUrl()}/get_v_res');
    var request = new http.MultipartRequest("POST", uri);
    Map<String, String> headers = {
      "Accept": "application/json",
    };
    request.headers.addAll(headers);
    request.fields.addAll({'vid': userID});
    // request.fields['user_id'] = userID;
    var response = await request.send();
    print(response.statusCode);
    String responseData = await response.stream.transform(utf8.decoder).join();
    var userData = json.decode(responseData);

    if (mounted)
      setState(() {
        productModel = ProductModel.fromJson(userData);
      });
  }

  _getUSer() async {
    UserModel userModel;

    var uri = Uri.parse('${baseUrl()}/vendor_data');
    var request = new http.MultipartRequest("POST", uri);
    Map<String, String> headers = {
      "Accept": "application/json",
    };
    request.headers.addAll(headers);
    request.fields['vid'] = userID;
    var response = await request.send();
    print(response.statusCode);
    String responseData = await response.stream.transform(utf8.decoder).join();
    var userData = json.decode(responseData);
    if (mounted)
      setState(() {
        userModel = UserModel.fromJson(userData);
      });
    if (userModel != null) {
      userEmail = userModel.user.email;
      userName = userModel.user.uname;
      userGender = userModel.user.gender;
      userDob = userModel.user.dateOfBirth;
      userImg = userModel.user.profileImage;
      userMobile = userModel.user.mobile.toString();
    }
  }

  _getRequests() async {
    _badgeCount();
  }

  _badgeCount() async {
    setState(() {
      notLoader = true;
    });
    try {
      var uri = Uri.parse('${baseUrl()}/vendor_notification_read_count');
      var request = new http.MultipartRequest("POST", uri);

      Map<String, String> headers = {
        "Accept": "application/json",
      };
      request.headers.addAll(headers);
      request.fields.addAll({'v_id': userID});

      var response = await request.send();
      if (response.statusCode == 200) {
        String responseData =
            await response.stream.transform(utf8.decoder).join();
        dic = json.decode(responseData);
        if (dic['response_code'] == '1') {
          print('notification count???????????????');
          print(dic['count']);
        }
        debugPrint('Success Response of notification count : $dic');
      } else {
        debugPrint('Server Not responding properly in notification count');
      }
      setState(() {
        notLoader = false;
      });

      // print(response.statusCode);
      // String responseData =
      //     await response.stream.transform(utf8.decoder).join();
      // var userData = json.decode(responseData);

      // print("+++++++++");
      // print(responseData);
      // print("+++++++++");
    } on Exception {
      setState(() {
        notLoader = false;
      });
      throw Exception('No Internet connection');
    }
  }

  @override
  Widget build(BuildContext context) {
    // _width = MediaQuery.of(context).size.width;

    return Scaffold(
      extendBody: false,
      backgroundColor: Colors.white,
      // appBar: AppBar(
      //   elevation: 0,
      //   backgroundColor: Colors.white,
      //   leading: Padding(
      //     padding: const EdgeInsets.all(8.0),
      //     child: Image.asset(
      //       "assets/images/shield.jpg",
      //       height: 30,
      //     ),
      //   ),
      //   title: Text(
      //     "Store",
      //     style: TextStyle(
      //       fontSize: 18,
      //       color: Colors.black,
      //       fontWeight: FontWeight.bold,
      //     ),
      //   ),
      //   centerTitle: true,
      //   automaticallyImplyLeading: false,
      //   actions: [
      //     Padding(
      //       padding: const EdgeInsets.only(top: 4),
      //       child: Stack(
      //         children: [
      //           IconButton(
      //               icon: Icon(CupertinoIcons.bell, size: 32),
      //               onPressed: () {
      //                 Navigator.of(context)
      //                     .push(new MaterialPageRoute(
      //                         builder: (_) => new Notifications()))
      //                     .then((val) => val ? _getRequests() : null);
      //               }),
      //           notLoader != true
      //               ? dic['count'] != '0'
      //                   ? new Positioned(
      //                       right: 9,
      //                       top: 3,
      //                       child: new Container(
      //                         padding: EdgeInsets.all(2),
      //                         decoration: new BoxDecoration(
      //                           color: appColorGreen,
      //                           borderRadius: BorderRadius.circular(6),
      //                         ),
      //                         constraints: BoxConstraints(
      //                           minWidth: 15,
      //                           minHeight: 15,
      //                         ),
      //                         child: Center(
      //                           child: Text(
      //                             '${dic['count']}',
      //                             style: TextStyle(
      //                               color: Colors.white,
      //                               fontSize: 10,
      //                             ),
      //                             textAlign: TextAlign.center,
      //                           ),
      //                         ),
      //                       ),
      //                     )
      //                   : new Container()
      //               : new Positioned(
      //                   right: 9,
      //                   top: 3,
      //                   child: new Container(
      //                       padding: EdgeInsets.all(2),
      //                       decoration: new BoxDecoration(
      //                         color: appColorGreen,
      //                         borderRadius: BorderRadius.circular(6),
      //                       ),
      //                       constraints: BoxConstraints(
      //                         minWidth: 15,
      //                         minHeight: 15,
      //                       ),
      //                       child: Container(
      //                           height: 9,
      //                           width: 9,
      //                           child: CircularProgressIndicator(
      //                               color: appColorWhite, strokeWidth: 1))),
      //                 )
      //         ],
      //       ),
      //     ),
      //     IconButton(
      //         icon: Icon(CupertinoIcons.add_circled, size: 32),
      //         onPressed: () {
      //           Navigator.push(
      //             context,
      //             MaterialPageRoute(builder: (context) => StepperDemo()),
      //           );
      //         })
      //   ],
      // ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: SafeArea(
          child: Stack(
            children: <Widget>[
              RefreshIndicator(
                onRefresh: _pullRefresh,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 21, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Image.asset(
                            'assets/images/UrbanService.png',
                            width: 100,
                          ),
                          Row(
                            children: [
                              Stack(
                                children: [
                                  // IconButton(
                                  //     icon: Icon(CupertinoIcons.bell, size: 32),
                                  //     onPressed: () {
                                  //       Navigator.of(context)
                                  //           .push(new MaterialPageRoute(
                                  //               builder: (_) => new Notifications()))
                                  //           .then((val) => val ? _getRequests() : null);
                                  //     }),
                                  Image.asset(
                                    'assets/images/Notification.png',
                                    height: 25,
                                    width: 25,
                                  ),
                                  notLoader != true
                                      ? dic['count'] != '0'
                                          ? new Positioned(
                                              right: 1,
                                              top: 0,
                                              child: new Container(
                                                padding: EdgeInsets.all(2),
                                                decoration: new BoxDecoration(
                                                  color: Colors.black,
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                constraints: BoxConstraints(
                                                  minWidth: 15,
                                                  minHeight: 15,
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    '${dic['count']}',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                            )
                                          : new Container()
                                      : new Positioned(
                                          right: 1,
                                          top: 0,
                                          child: new Container(
                                              padding: EdgeInsets.all(2),
                                              decoration: new BoxDecoration(
                                                color: Colors.black,
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              constraints: BoxConstraints(
                                                minWidth: 15,
                                                minHeight: 15,
                                              ),
                                              child: Container(
                                                  height: 9,
                                                  width: 9,
                                                  child:
                                                      CircularProgressIndicator(
                                                          color: appColorWhite,
                                                          strokeWidth: 1))),
                                        )
                                ],
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => StepperDemo()),
                                  );
                                },
                                child: Image.asset(
                                  'assets/images/plus-circle.png',
                                  height: 25,
                                  width: 25,
                                ),
                              ),
                            ],
                          )
                          // IconButton(
                          //     icon: Icon(CupertinoIcons.add_circled, size: 32),
                          //     onPressed: () {
                          //       Navigator.push(
                          //         context,
                          //         MaterialPageRoute(
                          //             builder: (context) => StepperDemo()),
                          //       );
                          //     }),
                        ],
                      ),
                    ),
                    productModel != null && currentLocation != null
                        ? _homeList()
                        : Container(
                            height: 200,
                            child: Center(
                              child: CircularProgressIndicator(
                                valueColor: new AlwaysStoppedAnimation<Color>(
                                    appColorYellow),
                              ),
                            ),
                          ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _homeList() {
    double _height, _width, _fixedPadding;
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    _fixedPadding = _height * 0.015;
    return AnimationLimiter(
        child: Column(
      children: [
        Container(
          color: Colors.grey[200],
          height: MediaQuery.of(context).size.height * 0.16,
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => TabbarScreen(currentTab: 3)));
                  },
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Total\nBookings',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyText1.copyWith(
                              color: Colors.black45,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          productModel.bookingCount,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.headline4.copyWith(
                              color: appColorYellow,
                              fontFamily: 'harabaraBold',
                              letterSpacing: 2,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(width: 1, color: Colors.black45),
              Expanded(
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => TabbarScreen(
                              currentTab: 2,
                            )));
                  },
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Total\nProducts',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyText1.copyWith(
                              color: Colors.black45,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          productModel.productsCount,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.headline4.copyWith(
                              color: appColorYellow,
                              fontFamily: 'harabaraBold',
                              letterSpacing: 2,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(width: 1, color: Colors.black45),
              Expanded(
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => TabbarScreen(currentTab: 1)));
                  },
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Total\nServices',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyText1.copyWith(
                              color: Colors.black45,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          productModel.servicesCount,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.headline4.copyWith(
                              color: appColorYellow,
                              fontFamily: 'harabaraBold',
                              letterSpacing: 2,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        productModel.restaurants.length > 0
            ? Column(
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Text(
                          "Your Stores",
                          style: Theme.of(context).textTheme.bodyText1.copyWith(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: productModel.restaurants.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                            margin: EdgeInsets.symmetric(horizontal: 5),
                            child: _nearByitemCard(
                                context, productModel.restaurants[index]));
                      },
                    ),
                  )
                ],
              )
            : Center(
                child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 70),
                  Container(
                    height: 200,
                    width: 200,
                    child: Image.asset(
                      "assets/images/nostores.png",
                      fit: BoxFit.fill,
                    ),
                  ),
                  Text(
                    "Store list empty!",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ],
              ))
      ],
    ) //Widget,

        );
  }

  Widget _nearByitemCard(BuildContext context, Restaurants product) {
    double _height, _width, _fixedPadding;
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    _fixedPadding = _height * 0.015;

    return InkWell(
      onTap: () {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //       builder: (context) => BidDetailWidget(
        //             productID: product.resId,
        //           )),
        // );
      },
      child: Padding(
        padding: EdgeInsets.all(_fixedPadding),
        child: Container(
          height: _height * 3 / 10,
          child: Stack(
            children: <Widget>[
              Container(
                height: _height * 3 / 10,
                width: _width,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(0.0),
                  child: FittedBox(
                    child: CachedNetworkImage(
                      imageUrl: product.allImage[0],
                      placeholder: (context, url) => Center(
                        child: Container(
                          margin: EdgeInsets.all(100.0),
                          child: CupertinoActivityIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 5,
                        width: 5,
                        child: Icon(
                          Icons.error,
                          color: Colors.red,
                        ),
                      ),
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: _width,
                    height: _height * 1.6 / 10,
                    color: Colors.white.withOpacity(0.8),
                    padding: EdgeInsets.all(_fixedPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(product.resName,
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: TextStyle(
                                          fontFamily: 'harabaraBold',
                                          fontSize: _width * 0.035,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black)),
                                  SizedBox(
                                    height: _height * 0.010,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(CupertinoIcons.location),
                                      SizedBox(
                                        width: _width * 0.010,
                                      ),
                                      Flexible(
                                        child: Column(
                                          children: [
                                            Text(product.resAddress,
                                                textAlign: TextAlign.start,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                                style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    color: Colors.black)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                // mainAxisAlignment:
                                //     MainAxisAlignment.start,
                                // crossAxisAlignment:
                                //     CrossAxisAlignment.end,
                                children: [
                                  new Container(
                                    height: _height * 0.030,
                                    width: _width * 1.2 / 10,
                                    decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(5)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.star,
                                            color: Colors.amber,
                                            size: _width * 0.025,
                                          ),
                                          SizedBox(
                                            width: _width * 0.010,
                                          ),
                                          Flexible(
                                            child: Text(
                                              product.resRatings != ""
                                                  ? product.resRatings
                                                  : "0.0",
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              softWrap: false,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: appColorWhite,
                                                fontSize: _width * 0.025,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: _width * 0.025,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            currentLocation != null &&
                                    product.lat != '' &&
                                    product.lon != ''
                                ? Container(
                                    child: Flexible(
                                      child: Column(
                                        children: [
                                          Text(
                                            calculateDistance(
                                                  currentLocation.latitude,
                                                  currentLocation.longitude,
                                                  double.parse(product.lat),
                                                  double.parse(product.lon),
                                                ).toStringAsFixed(0) +
                                                "km",
                                            style: TextStyle(
                                                fontFamily: 'harabaraBold',
                                                fontSize: _width * 0.030),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : Container(),
                            Row(
                              children: [
                                SizedBox(
                                  width: _width * 2 / 10,
                                  height: _height * 0.35 / 10,
                                  child: ElevatedButton(
                                    child: Text(
                                      'Edit',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'harabaraBold'),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      primary: Colors.black,
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => EditProduct(
                                                productId: product.resId,
                                                refresh: refresh)),
                                      );
                                      print('Pressed');
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: _width * 0.025,
                                ),
                                SizedBox(
                                  height: _height * 0.35 / 10,
                                  width: _width * 2.2 / 10,
                                  child: OutlinedButton(
                                    onPressed: null,
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                          width: 1.0, color: Colors.black),
                                    ),
                                    child: const Text(
                                      "Review",
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
