import 'dart:async';
import 'dart:ui';
import 'package:active_ecommerce_flutter/data_model/Banner.dart';
import 'package:active_ecommerce_flutter/data_model/doctors.dart';
import 'package:active_ecommerce_flutter/repositories/category_repository.dart';
import 'package:active_ecommerce_flutter/repositories/sliders_repository.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';

import '../app_config.dart';
import '../my_theme.dart';
import 'category_products.dart';

class HomeCopy extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<HomeCopy> {
  var _carouselImageList = [];
  var _featuredCategoryList = [];
  int _current_slider = 0;
  var _featuredProductList = [];
  bool _isProductInitial = true;
  bool _isCategoryInitial = true;
  bool _isCarouselInitial = true;
  int _totalProductData = 0;
  int _productPage = 1;
  bool _showProductLoadingContainer = false;
  TextEditingController _search = TextEditingController();
  List<doctor> _searchResult = [];
  List<doctor> doctorlist = [];
  List<Add> banner = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPermission();

    fetchFeaturedCategories();
    fetchCarouselImages();
  }


  fetchCarouselImages() async {
    var carouselResponse = await SlidersRepository().getSliders();
    carouselResponse.sliders.forEach((slider) {
      _carouselImageList.add(slider.photo);
    });
    _isCarouselInitial = false;
    setState(() {});
  }


  buildHomeCarouselSlider(context) {
    if (_isCarouselInitial && _carouselImageList.length == 0) {
      return Padding(
        padding: const EdgeInsets.only(left: 5.0, right: 5.0),
        child: Shimmer.fromColors(
          baseColor: MyTheme.shimmer_base,
          highlightColor: MyTheme.shimmer_highlighted,
          child: Container(
            height: 120,
            width: double.infinity,
            color: Colors.white,
          ),
        ),
      );
    } else if (_carouselImageList.length > 0) {
      return CarouselSlider(
        options: CarouselOptions(
            aspectRatio: 2.67,
            viewportFraction: 1,
            initialPage: 0,
            enableInfiniteScroll: true,
            reverse: false,
            autoPlay: true,
            autoPlayInterval: Duration(seconds: 5),
            autoPlayAnimationDuration: Duration(milliseconds: 1000),
            autoPlayCurve: Curves.easeInCubic,
            enlargeCenterPage: true,
            scrollDirection: Axis.horizontal,
            onPageChanged: (index, reason) {
              setState(() {
                _current_slider = index;
              });
            }),
        items: _carouselImageList.map((i) {
          return Builder(
            builder: (BuildContext context) {
              return Stack(
                children: <Widget>[
                  Container(
                      width: double.infinity,
                      margin: EdgeInsets.symmetric(horizontal: 5.0),
                      child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          child: FadeInImage.assetNetwork(
                            placeholder: 'assets/placeholder_rectangle.png',
                            image: AppConfig.BASE_PATH + i,
                            fit: BoxFit.fill,
                          ))),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _carouselImageList.map((url) {
                        int index = _carouselImageList.indexOf(url);
                        return Container(
                          width: 7.0,
                          height: 7.0,
                          margin: EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 4.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _current_slider == index
                                ? MyTheme.white
                                : Color.fromRGBO(112, 112, 112, .3),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              );
            },
          );
        }).toList(),
      );
    } else if (!_isCarouselInitial && _carouselImageList.length == 0) {
      return Container(
          height: 100,
          child: Center(
              child: Text('',
                //AppLocalizations.of(context).home_screen_no_carousel_image_found,
                style: TextStyle(color: MyTheme.font_grey),
              )));
    } else {
      // should not be happening
      return Container(
        height: 100,
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    double width;
    double height;

    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    return WillPopScope(
      //onWillPop: onWillPop,
      child: Scaffold(
        appBar: AppBar(

          actions: [
                    Container(
                      alignment: Alignment.center,
                      width: width-20,
                      //margin: EdgeInsets.only(left: width * 0.05, right: width * 0.05, top: height * 0.01),
                      child: Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Container(
                          //width: width * 1,
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                          child: TextField(
                            textCapitalization: TextCapitalization.words,
                            onChanged: onSearchTextChanged,
                            decoration: InputDecoration(
                              //hintText: getTranslated(context, home_searchDoctor).toString(),
                              hintText: 'Search',
                              hintStyle: TextStyle(
                                fontSize: width * 0.04,
                                color: Colors.blue,
                              ),
                              suffixIcon: Padding(
                                padding: const EdgeInsets.all(12),
                                child: SvgPicture.asset(
                                  'assets/icons/SearchIcon.svg',
                                  height: 15,
                                  width: 15,
                                ),
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                    ),
          ],
          backgroundColor: Colors.white,
        ),
        // PreferredSize(
        //   preferredSize: Size(width, 70),
        //   child:

          // SafeArea(
          //   top: true,
          //   child: Container(
          //     child: Column(
          //       children: [
          //
          //         Container(
          //           margin: EdgeInsets.only(left: width * 0.05, right: width * 0.05, top: height * 0.01),
          //           child: Card(
          //             color: Colors.white,
          //             shape: RoundedRectangleBorder(
          //               borderRadius: BorderRadius.circular(50),
          //             ),
          //             child: Container(
          //               width: width * 1,
          //               padding: EdgeInsets.symmetric(horizontal: 20, vertical: 2),
          //               child: TextField(
          //                 textCapitalization: TextCapitalization.words,
          //                 onChanged: onSearchTextChanged,
          //                 decoration: InputDecoration(
          //                   //hintText: getTranslated(context, home_searchDoctor).toString(),
          //                   hintText: 'Search',
          //                   hintStyle: TextStyle(
          //                     fontSize: width * 0.04,
          //                     color: Colors.blue,
          //                   ),
          //                   suffixIcon: Padding(
          //                     padding: const EdgeInsets.all(12),
          //                     child: SvgPicture.asset(
          //                       'assets/icons/SearchIcon.svg',
          //                       height: 15,
          //                       width: 15,
          //                     ),
          //                   ),
          //                   border: InputBorder.none,
          //                 ),
          //               ),
          //             ),
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
        //),

        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          //child: SingleChildScrollView(
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      8.0,
                      0.0,
                      8.0,
                      0.0,
                    ),
                    child: buildHomeCarouselSlider(context),
                  ),
                  SizedBox(height: 20,),
                  //  top view //
                  Row(
                    children: [
                      new Flexible(
                        child:GestureDetector(
                          onTap: (){
                            for(var i = 0; i< _featuredCategoryList.length; i++) {
                              if(_featuredCategoryList[i].name == 'Medicine'){
                                Navigator.push(context, MaterialPageRoute(builder: (context) {
                                  return CategoryProducts(
                                    category_id: _featuredCategoryList[i].id,
                                    category_name: _featuredCategoryList[i].name,
                                  );
                                }));
                                break;
                              }
                            }


                            //Navigator.pushNamed(context, 'Medicine');
                          },
                          child: new Card(
                            margin: EdgeInsets.all(10),
                            color: Colors.white,
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                                side: BorderSide(
                                    width: 1,
                                    color: Colors.green
                                )

                            ),


                            child:Container(
                              height: 120,
                              margin: EdgeInsets.only(
                                left: width * 0.05,
                                top: width * 0.00,
                                right: width * 0.05,
                              ),

                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Image.asset('assets/medicine.png',height: 40,width: 40,),
                                    Center(
                                      child: Text("Medicine",style: TextStyle(
                                        fontSize: 20.0,
                                        color: Colors.green,
                                      ),),
                                    ),
                                  ],
                                ),
                              ),



                            ),

                          ),
                        ),
                        flex: 1,),
                      new Flexible(
                        child:GestureDetector(
                          onTap: (){
                            for(var i = 0; i< _featuredCategoryList.length; i++) {
                              if(_featuredCategoryList[i].name == 'Medicine'){
                                Navigator.push(context, MaterialPageRoute(builder: (context) {
                                  return CategoryProducts(
                                    category_id: _featuredCategoryList[i].id,
                                    category_name: _featuredCategoryList[i].name,
                                  );
                                }));
                                break;
                              }
                            }
                          },
                          child: new Card(
                            margin: EdgeInsets.all(10),
                            color: Colors.white,
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                                side: BorderSide(
                                    width: 2,
                                    color: Colors.blue
                                )
                            ),


                            child:Container(
                              height: 120,
                              margin: EdgeInsets.only(
                                left: width * 0.05,
                                top: width * 0.00,
                                right: width * 0.05,
                              ),

                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Image.asset('assets/doctor.png',height: 40,width: 40,),
                                    Center(
                                      child: Text("Doctor",style: TextStyle(
                                        fontSize: 20.0,
                                        color: Colors.blue,
                                      ),),
                                    ),
                                  ],
                                ),
                              ),



                            ),

                          ),
                        ),
                        flex: 1,)
                    ],
                  ),
                  Row(
                    children: [
                      new Flexible(
                        child:GestureDetector(
                          onTap: (){
                            for(var i = 0; i< _featuredCategoryList.length; i++) {
                              if(_featuredCategoryList[i].name == 'Medicine'){
                                Navigator.push(context, MaterialPageRoute(builder: (context) {
                                  return CategoryProducts(
                                    category_id: _featuredCategoryList[i].id,
                                    category_name: _featuredCategoryList[i].name,
                                  );
                                }));
                                break;
                              }
                            }
                          },
                          child: Card(
                            margin: EdgeInsets.all(10),
                            color: Colors.white,
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                                side: BorderSide(
                                    width: 2,
                                    color: Colors.deepPurple
                                )
                            ),
                            child:Container(
                              height: 120,
                              margin: EdgeInsets.only(
                                left: width * 0.05,
                                top: width * 0.00,
                                right: width * 0.05,
                              ),

                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Image.asset('assets/test.png',height: 40,width: 40,),
                                    Center(
                                      child: Text("Diagnostic",style: TextStyle(
                                        fontSize: 20.0,
                                        color: Colors.blueGrey,
                                      ),),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        flex: 1,),
                      new Flexible(
                        child:GestureDetector(
                          onTap: (){
                            for(var i = 0; i< _featuredCategoryList.length; i++) {
                              if(_featuredCategoryList[i].name == 'Accessories'){
                                Navigator.push(context, MaterialPageRoute(builder: (context) {
                                  return CategoryProducts(
                                    category_id: _featuredCategoryList[i].id,
                                    category_name: _featuredCategoryList[i].name,
                                  );
                                }));
                                break;
                              }
                            }
                          },
                          child: new Card(
                            margin: EdgeInsets.all(10),
                            color: Colors.white,
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                                side: BorderSide(
                                    width: 2,
                                    color: Colors.orange
                                )
                            ),
                            child:Container(
                              height: 120,
                              margin: EdgeInsets.only(
                                left: width * 0.05,
                                top: width * 0.00,
                                right: width * 0.05,
                              ),

                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Image.asset('assets/firstaid.png',height: 40,width: 40,),
                                    Center(
                                      child: Text("Accessories",textAlign: TextAlign.center,style: TextStyle(fontSize: 20.0, color: Colors.orangeAccent,),
                                      ),
                                    ),
                                  ],
                                ),
                              ),



                            ),
                          ),
                        ),

                        flex: 1,)
                    ],
                  ),
                  Row(
                    children: [
                      new Flexible(
                        child:GestureDetector(
                          onTap: (){
                            //Navigator.pushNamed(context, 'Physiotherapylist');
                            setState(
                                  () {
                                // Fluttertoast.showToast(
                                //   msg: getTranslated(context, coming_soon_toast)
                                //       .toString(),
                                //   toastLength: Toast.LENGTH_SHORT,
                                //   gravity: ToastGravity.BOTTOM,
                                //   backgroundColor: Palette.blue,
                                //   textColor: Palette.white,
                                // );
                              },
                            );
                          },
                          child: new Card(
                            margin: EdgeInsets.only(left: 10,right: 10,bottom: 50),
                            color: Colors.white,
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                                side: BorderSide(
                                    width: 2,
                                    color: Colors.brown
                                )
                            ),
                            child:Container(
                              height: 120,
                              margin: EdgeInsets.only(
                                left: width * 0.05,
                                top: width * 0.00,
                                right: width * 0.05,
                              ),

                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Image.asset('assets/physiotherapy.png',height: 40,width: 40,),
                                    Center(
                                      child: Text("Physiotherapy",style: TextStyle(
                                        fontSize: 20.0,
                                        color: Colors.brown,
                                      ),),
                                    ),
                                  ],
                                ),
                              ),



                            ),
                          ),
                        ),
                        flex: 1,),
                      new Flexible(
                        child:GestureDetector(
                          onTap: (){
                            //Navigator.pushNamed(context, 'Nursinglist');
                            setState(
                                  () {
                                // Fluttertoast.showToast(
                                //   msg: getTranslated(context, coming_soon_toast)
                                //       .toString(),
                                //   toastLength: Toast.LENGTH_SHORT,
                                //   gravity: ToastGravity.BOTTOM,
                                //   backgroundColor: Palette.blue,
                                //   textColor: Palette.white,
                                // );
                              },
                            );
                          },

                          child: new Card(
                            margin: EdgeInsets.only(left: 10,right: 10,bottom: 50),
                            color: Colors.white,
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                                side: BorderSide(
                                    width: 2,
                                    color: Colors.purple
                                )
                            ),
                            child:Container(
                              height: 120,
                              margin: EdgeInsets.only(
                                left: width * 0.05,
                                top: width * 0.00,
                                right: width * 0.05,
                              ),

                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Image.asset('assets/nursing.png',height: 40,width: 40,),
                                    Center(
                                      child: Text("Home Nursing",style: TextStyle(
                                        fontSize: 20.0,
                                        color: Colors.purple,
                                      ),),
                                    ),
                                  ],
                                ),
                              ),

                            ),
                          ),
                        ),

                        flex: 1,)
                    ],
                  ),


                ],
              ),
            ),
          //),
        ),
      ),
    );



    /*
    return WillPopScope(
      onWillPop: onWillPop,
      child: ModalProgressHUD(
        inAsyncCall: _loadding,
        opacity: 0.5,
        progressIndicator: SpinKitFadingCircle(
          color: Palette.blue,
          size: 50.0,
        ),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: Scaffold(
            key: _scaffoldKey,

            // Drawer //
            drawer: Drawer(
              child: Column(
                children: [
                  SharedPreferenceHelper.getBoolean(Preferences.is_logged_in) == true
                      ? Expanded(
                          flex: 3,
                          child: DrawerHeader(
                            child: Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width: 60,
                                    height: 80,
                                    alignment: AlignmentDirectional.center,
                                    decoration: new BoxDecoration(
                                      shape: BoxShape.circle, // BoxShape.circle or BoxShape.retangle
                                      boxShadow: [
                                        new BoxShadow(
                                          color: Palette.blue,
                                          blurRadius: 1.0,
                                        ),
                                      ],
                                    ),
                                    child: CachedNetworkImage(
                                      alignment: Alignment.center,
                                      imageUrl: image!,
                                      imageBuilder: (context, imageProvider) => CircleAvatar(
                                        radius: 50,
                                        backgroundColor: Palette.white,
                                        child: CircleAvatar(
                                          radius: 30,
                                          backgroundImage: imageProvider,
                                        ),
                                      ),
                                      placeholder: (context, url) => SpinKitFadingCircle(color: Palette.blue),
                                      errorWidget: (context, url, error) => Image.asset("assets/images/no_image.jpg"),
                                    ),
                                  ),
                                  Container(
                                    width: 150,
                                    height: 55,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 5),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Container(
                                            alignment: AlignmentDirectional.topStart,
                                            child: Text(
                                              '$name',
                                              style: TextStyle(
                                                fontSize: width * 0.05,
                                                color: Palette.dark_blue,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Container(
                                            alignment: AlignmentDirectional.topStart,
                                            child: Text(
                                              '$email',
                                              style: TextStyle(
                                                fontSize: width * 0.035,
                                                color: Palette.grey,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Container(
                                            alignment: AlignmentDirectional.topStart,
                                            child: Text(
                                              '$phone_no',
                                              style: TextStyle(
                                                fontSize: width * 0.035,
                                                color: Palette.grey,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    alignment: AlignmentDirectional.center,
                                    margin: EdgeInsets.only(top: 20),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.pushNamed(context, 'profile');
                                        },
                                        child: SvgPicture.asset(
                                          'assets/icons/edit.svg',
                                          height: 20,
                                          width: 20,
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        )
                      : Expanded(
                          flex: 3,
                          child: DrawerHeader(
                            child: Container(
                              alignment: AlignmentDirectional.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(context, 'SignIn');
                                    },
                                    child: Container(
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(width * 0.06),
                                        ),
                                        color: Palette.white,
                                        shadowColor: Palette.grey,
                                        elevation: 5,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                          child: Text(
                                            getTranslated(context, home_signIn_button).toString(),
                                            style: TextStyle(fontSize: width * 0.04, color: Palette.dark_blue),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(context, 'signup');
                                    },
                                    child: Container(
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(width * 0.06),
                                        ),
                                        color: Palette.white,
                                        shadowColor: Palette.grey,
                                        elevation: 5,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                          child: Text(
                                            getTranslated(context, home_signUp_button).toString(),
                                            style: TextStyle(
                                              fontSize: width * 0.04,
                                              color: Palette.dark_blue,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                  Expanded(
                    flex: 12,
                    child: Container(
                      margin: EdgeInsets.only(left: 20, right: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ListTile(
                            onTap: () {
                              Navigator.popAndPushNamed(context, 'Specialist');
                            },
                            title: Text(
                              getTranslated(context, home_book_appointment).toString(),
                              style: TextStyle(
                                fontSize: width * 0.04,
                                color: Palette.dark_blue,
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                            child: Column(
                              children: [
                                DottedLine(
                                  direction: Axis.horizontal,
                                  lineLength: double.infinity,
                                  lineThickness: 1.0,
                                  dashLength: 3.0,
                                  dashColor: Palette.dash_line,
                                  dashRadius: 0.0,
                                  dashGapLength: 1.0,
                                  dashGapColor: Palette.transparent,
                                  dashGapRadius: 0.0,
                                )
                              ],
                            ),
                          ),
                          ListTile(
                            onTap: () {
                              SharedPreferenceHelper.getBoolean(Preferences.is_logged_in) == true
                                  ? Navigator.popAndPushNamed(context, 'Appointment')
                                  : FormHelper.showMessage(
                                context,
                                getTranslated(context, home_medicineOrder_alert_title).toString(),
                                getTranslated(context, home_medicineOrder_alert_text).toString(),
                                getTranslated(context, cancel).toString(),
                                    () {
                                  Navigator.of(context).pop();
                                },
                                buttonText2: getTranslated(context, login).toString(),
                                isConfirmationDialog: true,
                                onPressed2: () {
                                  Navigator.pushNamed(context, 'SignIn');
                                },
                              );
                            },
                            title: Text(
                              getTranslated(context, home_appointments).toString(),
                              style: TextStyle(
                                fontSize: width * 0.04,
                                color: Palette.dark_blue,
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                            child: Column(
                              children: [
                                DottedLine(
                                  direction: Axis.horizontal,
                                  lineLength: double.infinity,
                                  lineThickness: 1.0,
                                  dashLength: 3.0,
                                  dashColor: Palette.dash_line,
                                  dashRadius: 0.0,
                                  dashGapLength: 1.0,
                                  dashGapColor: Palette.transparent,
                                  dashGapRadius: 0.0,
                                )
                              ],
                            ),
                          ),
                          ListTile(
                            onTap: () {
                              SharedPreferenceHelper.getBoolean(Preferences.is_logged_in) == true
                                  ? Navigator.popAndPushNamed(context, 'Favoritedoctor')
                                  : FormHelper.showMessage(
                                context,
                                getTranslated(context, home_favoriteDoctor_alert_title).toString(),
                                getTranslated(context, home_favoriteDoctor_alert_text).toString(),
                                getTranslated(context, cancel).toString(),
                                    () {
                                  Navigator.of(context).pop();
                                },
                                buttonText2: getTranslated(context, login).toString(),
                                isConfirmationDialog: true,
                                onPressed2: () {
                                  Navigator.pushNamed(context, 'SignIn');
                                },
                              );
                            },
                            title: Text(
                              getTranslated(context, home_favoritesDoctor).toString(),
                              style: TextStyle(
                                fontSize: width * 0.04,
                                color: Palette.dark_blue,
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                            child: Column(
                              children: [
                                DottedLine(
                                  direction: Axis.horizontal,
                                  lineLength: double.infinity,
                                  lineThickness: 1.0,
                                  dashLength: 3.0,
                                  dashColor: Palette.dash_line,
                                  dashRadius: 0.0,
                                  dashGapLength: 1.0,
                                  dashGapColor: Palette.transparent,
                                  dashGapRadius: 0.0,
                                )
                              ],
                            ),
                          ),
                          ListTile(
                            onTap: () {
                              Navigator.popAndPushNamed(context, 'Medicine');
                            },
                            title: Text(
                              getTranslated(context, home_medicineBuy).toString(),
                              style: TextStyle(
                                fontSize: width * 0.04,
                                color: Palette.dark_blue,
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                            child: Column(
                              children: [
                                DottedLine(
                                  direction: Axis.horizontal,
                                  lineLength: double.infinity,
                                  lineThickness: 1.0,
                                  dashLength: 3.0,
                                  dashColor: Palette.dash_line,
                                  dashRadius: 0.0,
                                  dashGapLength: 1.0,
                                  dashGapColor: Palette.transparent,
                                  dashGapRadius: 0.0,
                                )
                              ],
                            ),
                          ),
                          ListTile(
                            onTap: () {
                              SharedPreferenceHelper.getBoolean(Preferences.is_logged_in) == true
                                  ? Navigator.popAndPushNamed(context, 'MedicineOrder')
                                  : FormHelper.showMessage(
                                context,
                                getTranslated(context, home_medicineBuy_alert_title).toString(),
                                getTranslated(context, home_medicineBuy_alert_text).toString(),
                                getTranslated(context, cancel).toString(),
                                    () {
                                  Navigator.of(context).pop();
                                },
                                buttonText2: getTranslated(context, login).toString(),
                                isConfirmationDialog: true,
                                onPressed2: () {
                                  Navigator.pushNamed(context, 'SignIn');
                                },
                              );
                            },
                            title: Text(
                              getTranslated(context, home_orderHistory).toString(),
                              style: TextStyle(
                                fontSize: width * 0.04,
                                color: Palette.dark_blue,
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                            child: Column(
                              children: [
                                DottedLine(
                                  direction: Axis.horizontal,
                                  lineLength: double.infinity,
                                  lineThickness: 1.0,
                                  dashLength: 3.0,
                                  dashColor: Palette.dash_line,
                                  dashRadius: 0.0,
                                  dashGapLength: 1.0,
                                  dashGapColor: Palette.transparent,
                                  dashGapRadius: 0.0,
                                )
                              ],
                            ),
                          ),
                          ListTile(
                            onTap: () {
                              Navigator.popAndPushNamed(context, 'HealthTips');
                            },
                            title: Text(
                              getTranslated(context, home_healthTips).toString(),
                              style: TextStyle(
                                fontSize: width * 0.04,
                                color: Palette.dark_blue,
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                            child: Column(
                              children: [
                                DottedLine(
                                  direction: Axis.horizontal,
                                  lineLength: double.infinity,
                                  lineThickness: 1.0,
                                  dashLength: 3.0,
                                  dashColor: Palette.dash_line,
                                  dashRadius: 0.0,
                                  dashGapLength: 1.0,
                                  dashGapColor: Palette.transparent,
                                  dashGapRadius: 0.0,
                                )
                              ],
                            ),
                          ),
                          ListTile(
                            onTap: () {
                              Navigator.popAndPushNamed(context, 'Offer');
                            },
                            title: Text(
                              getTranslated(context, home_offers).toString(),
                              style: TextStyle(
                                fontSize: width * 0.04,
                                color: Palette.dark_blue,
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                            child: Column(
                              children: [
                                DottedLine(
                                  direction: Axis.horizontal,
                                  lineLength: double.infinity,
                                  lineThickness: 1.0,
                                  dashLength: 3.0,
                                  dashColor: Palette.dash_line,
                                  dashRadius: 0.0,
                                  dashGapLength: 1.0,
                                  dashGapColor: Palette.transparent,
                                  dashGapRadius: 0.0,
                                )
                              ],
                            ),
                          ),
                          ListTile(
                            onTap: () {
                              SharedPreferenceHelper.getBoolean(Preferences.is_logged_in) == true
                                  ? Navigator.popAndPushNamed(context, 'notifications')
                                  : FormHelper.showMessage(
                                context,
                                getTranslated(context, home_notification_alert_title).toString(),
                                getTranslated(context, home_notification_alert_text).toString(),
                                getTranslated(context, cancel).toString(),
                                    () {
                                  Navigator.of(context).pop();
                                },
                                buttonText2: getTranslated(context, login).toString(),
                                isConfirmationDialog: true,
                                onPressed2: () {
                                  Navigator.pushNamed(context, 'SignIn');
                                },
                              );
                            },
                            title: Text(
                              getTranslated(context, home_notification).toString(),
                              style: TextStyle(
                                fontSize: width * 0.04,
                                color: Palette.dark_blue,
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                            child: Column(
                              children: [
                                DottedLine(
                                  direction: Axis.horizontal,
                                  lineLength: double.infinity,
                                  lineThickness: 1.0,
                                  dashLength: 3.0,
                                  dashColor: Palette.dash_line,
                                  dashRadius: 0.0,
                                  dashGapLength: 1.0,
                                  dashGapColor: Palette.transparent,
                                  dashGapRadius: 0.0,
                                )
                              ],
                            ),
                          ),
                          ListTile(
                            onTap: () {
                              Navigator.popAndPushNamed(context, 'Setting');
                            },
                            title: Text(
                              getTranslated(context, home_settings).toString(),
                              style: TextStyle(
                                fontSize: width * 0.04,
                                color: Palette.dark_blue,
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                            child: Column(
                              children: [
                                DottedLine(
                                  direction: Axis.horizontal,
                                  lineLength: double.infinity,
                                  lineThickness: 1.0,
                                  dashLength: 2.0,
                                  dashColor: Palette.dash_line,
                                  dashRadius: 0.0,
                                  dashGapLength: 1.0,
                                  dashGapColor: Palette.transparent,
                                  dashGapRadius: 0.0,
                                )
                              ],
                            ),
                          ),
                          ListTile(
                            title: SharedPreferenceHelper.getBoolean(Preferences.is_logged_in) == true
                                ? GestureDetector(
                              onTap: () {
                                FormHelper.showMessage(
                                  context,
                                  getTranslated(context, home_logout_alert_title).toString(),
                                  getTranslated(context, home_logout_alert_text).toString(),
                                  getTranslated(context, cancel).toString(),
                                      () {
                                    Navigator.of(context).pop();
                                  },
                                  buttonText2: getTranslated(context, home_logout_alert_title).toString(),
                                  isConfirmationDialog: true,
                                  onPressed2: () {
                                    Preferences.checkNetwork().then((value) => value == true ? logoutUser() : print('No int'));
                                  },
                                );
                              },
                              child: Text(
                                getTranslated(context, home_logout).toString(),
                                style: TextStyle(
                                  fontSize: width * 0.04,
                                  color: Palette.dark_blue,
                                ),
                              ),
                            )
                                : Text(
                              '',
                              style: TextStyle(
                                fontSize: width * 0.04,
                                color: Palette.dark_blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  )
                ],
              ),
            ),
            appBar: PreferredSize(
              preferredSize: Size(width, 130),
              child: SafeArea(
                top: true,
                child: Container(
                  child: Column(
                    children: [
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                _passIsWhere();
                                SharedPreferenceHelper.getBoolean(Preferences.is_logged_in) == true
                                    ? Navigator.pushNamed(context, 'ShowLocation')
                                    : SharedPreferenceHelper.getBoolean(Preferences.is_logged_in) == true
                                        ? Navigator.popAndPushNamed(context, 'MedicineOrder')
                                        : FormHelper.showMessage(
                                            context,
                                            getTranslated(context, home_selectAddress_alert_title).toString(),
                                            getTranslated(context, home_selectAddress_alert_text).toString(),
                                            getTranslated(context, cancel).toString(),
                                            () {
                                              Navigator.of(context).pop();
                                            },
                                            buttonText2: getTranslated(context, login).toString(),
                                            isConfirmationDialog: true,
                                            onPressed2: () {
                                              Navigator.pushNamed(context, 'SignIn');
                                            },
                                          );
                              },
                              child: Row(
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(top: height * 0.01, left: width * 0.03, right: width * 0.03),
                                    height: 25,
                                    width: 20,
                                    child: SvgPicture.asset(
                                      'assets/icons/location.svg',
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        width: 120,
                                        padding: EdgeInsets.only(top: height * 0.01, left: width * 0.03, right: width * 0.03),
                                        child: _Address == null || _Address == ""
                                            ? Text(
                                                getTranslated(context, home_selectAddress).toString(),
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: width * 0.035,
                                                  fontWeight: FontWeight.bold,
                                                  color: Palette.dark_blue,
                                                ),
                                              )
                                            : Text(
                                                '$_Address',
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: width * 0.04,
                                                  fontWeight: FontWeight.bold,
                                                  color: Palette.dark_blue,
                                                ),
                                              ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(top: width * 0.02),
                                        height: 15,
                                        width: 15,
                                        child: SvgPicture.asset(
                                          'assets/icons/down.svg',
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(right: 10, left: 10),
                              child: IconButton(
                                onPressed: () {
                                  _scaffoldKey.currentState!.openDrawer();
                                },
                                icon: SvgPicture.asset(
                                  'assets/icons/menu.svg',
                                  height: 15,
                                  width: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: width * 0.05, right: width * 0.05, top: height * 0.01),
                        child: Card(
                          color: Palette.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Container(
                            width: width * 1,
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                            child: TextField(
                              textCapitalization: TextCapitalization.words,
                              onChanged: onSearchTextChanged,
                              decoration: InputDecoration(
                                hintText: getTranslated(context, home_searchDoctor).toString(),
                                hintStyle: TextStyle(
                                  fontSize: width * 0.04,
                                  color: Palette.dark_blue,
                                ),
                                suffixIcon: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: SvgPicture.asset(
                                    'assets/icons/SearchIcon.svg',
                                    height: 15,
                                    width: 15,
                                  ),
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            body: GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(new FocusNode());
              },
              child: SingleChildScrollView(
                child: Center(
                  child: Column(
                    children: [

                      //  top view //
                      Row(
                        children: [
                          new Flexible(
                            child:GestureDetector(
                              onTap: (){
                                Navigator.pushNamed(context, 'Medicine');
                              },
                              child: new Card(
                                color: Colors.white,
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                    side: BorderSide(
                                        width: 2,
                                        color: Colors.green
                                    )

                                ),


                                child:Container(
                                  height: 120,
                                  margin: EdgeInsets.only(
                                    left: width * 0.05,
                                    top: width * 0.00,
                                    right: width * 0.05,
                                  ),

                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Image.asset('assets/icons/medicine.png',height: 40,width: 40,),
                                        Center(
                                          child: Text("Medicine",style: TextStyle(
                                            fontSize: 20.0,
                                            color: Colors.green,
                                          ),),
                                        ),
                                      ],
                                    ),
                                  ),



                                ),

                              ),
                            ),
                            flex: 1,),
                          new Flexible(
                            child:GestureDetector(
                              onTap: (){
                                Navigator.pushNamed(context, 'Specialist');
                              },
                              child: new Card(
                                color: Colors.white,
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                    side: BorderSide(
                                        width: 2,
                                        color: Colors.blue
                                    )
                                ),


                                child:Container(
                                  height: 120,
                                  margin: EdgeInsets.only(
                                    left: width * 0.05,
                                    top: width * 0.00,
                                    right: width * 0.05,
                                  ),

                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Image.asset('assets/icons/doctor.png',height: 40,width: 40,),
                                        Center(
                                          child: Text("Doctor",style: TextStyle(
                                            fontSize: 20.0,
                                            color: Colors.blue,
                                          ),),
                                        ),
                                      ],
                                    ),
                                  ),



                                ),

                              ),
                            ),
                             flex: 1,)
                        ],
                      ),
                      Row(
                        children: [
                          new Flexible(
                            child:GestureDetector(
                              onTap: (){
                                //Navigator.pushNamed(context, 'Diagonisticslist');
                                setState(
                                      () {
                                    Fluttertoast.showToast(
                                      msg: getTranslated(context, coming_soon_toast)
                                          .toString(),
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      backgroundColor: Palette.blue,
                                      textColor: Palette.white,
                                    );
                                  },
                                );
                              },
                            child: Card(
                              color: Colors.white,
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                                  side: BorderSide(
                                      width: 2,
                                      color: Colors.deepPurple
                                  )
                              ),
                              child:Container(
                                height: 120,
                                margin: EdgeInsets.only(
                                  left: width * 0.05,
                                  top: width * 0.00,
                                  right: width * 0.05,
                                ),

                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Image.asset('assets/icons/test.png',height: 40,width: 40,),
                                      Center(
                                        child: Text("Diagnostic",style: TextStyle(
                                          fontSize: 20.0,
                                          color: Colors.blueGrey,
                                        ),),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            ),

                            flex: 1,),
                          new Flexible(
                            child:GestureDetector(
                              onTap: (){
                                Navigator.pushNamed(context, 'Product');
                              },
                              child: new Card(
                                color: Colors.white,
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                    side: BorderSide(
                                        width: 2,
                                        color: Colors.orange
                                    )
                                ),
                                child:Container(
                                  height: 120,
                                  margin: EdgeInsets.only(
                                    left: width * 0.05,
                                    top: width * 0.00,
                                    right: width * 0.05,
                                  ),

                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Image.asset('assets/icons/firstaid.png',height: 40,width: 40,),
                                        Center(
                                          child: Text("Accessories",textAlign: TextAlign.center,style: TextStyle(fontSize: 20.0, color: Colors.orangeAccent,),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),



                                ),
                              ),
                            ),

                             flex: 1,)
                        ],
                      ),
                      Row(
                        children: [
                          new Flexible(
                            child:GestureDetector(
                              onTap: (){
                                Navigator.pushNamed(context, 'Physiotherapylist');
                              },
                              child: new Card(
                                color: Colors.white,
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                    side: BorderSide(
                                        width: 2,
                                        color: Colors.brown
                                    )
                                ),
                                child:Container(
                                  height: 120,
                                  margin: EdgeInsets.only(
                                    left: width * 0.05,
                                    top: width * 0.00,
                                    right: width * 0.05,
                                  ),

                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Image.asset('assets/icons/physiotherapy.png',height: 40,width: 40,),
                                        Center(
                                          child: Text("Physiotherapy",style: TextStyle(
                                            fontSize: 20.0,
                                            color: Colors.brown,
                                          ),),
                                        ),
                                      ],
                                    ),
                                  ),



                                ),
                              ),
                            ),
                             flex: 1,),
                          new Flexible(
                            child:GestureDetector(
                              onTap: (){
                                Navigator.pushNamed(context, 'Nursinglist');
                              },

                              child: new Card(
                                color: Colors.white,
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                    side: BorderSide(
                                        width: 2,
                                        color: Colors.purple
                                    )
                                ),
                                child:Container(
                                  height: 120,
                                  margin: EdgeInsets.only(
                                    left: width * 0.05,
                                    top: width * 0.00,
                                    right: width * 0.05,
                                  ),

                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Image.asset('assets/icons/nursing.png',height: 40,width: 40,),
                                        Center(
                                          child: Text("Home Nursing",style: TextStyle(
                                            fontSize: 20.0,
                                            color: Colors.purple,
                                          ),),
                                        ),
                                      ],
                                    ),
                                  ),

                                ),
                              ),
                            ),

                             flex: 1,)
                        ],
                      ),

                      // Upcoming Appointment //
                      upcomingAppointment.length != 0
                          ? Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(top: 20, left: 20, right: 20),
                                      alignment: AlignmentDirectional.topStart,
                                      child: Column(
                                        children: [
                                          Text(
                                            getTranslated(context, home_upcomingAppointment).toString(),
                                            style: TextStyle(fontSize: width * 0.04, color: Palette.dark_blue),
                                          )
                                        ],
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.pushNamed(context, 'Appointment');
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(top: 15, left: 20, right: 20),
                                        alignment: AlignmentDirectional.topStart,
                                        child: Column(
                                          children: [
                                            Text(
                                              getTranslated(context, home_viewAll).toString(),
                                              style: TextStyle(fontSize: width * 0.035, color: Palette.blue),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  height: 220,
                                  width: width * 1,
                                  margin: EdgeInsets.symmetric(vertical: 5),
                                  child: ListView(
                                    scrollDirection: Axis.horizontal,
                                    children: [
                                      Container(
                                        child: ListView.builder(
                                          physics: NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          scrollDirection: Axis.horizontal,
                                          itemCount: 5 <= upcomingAppointment.length ? 5 : upcomingAppointment.length,
                                          itemBuilder: (context, index) {
                                            var statusColor = Palette.green.withOpacity(0.5);
                                            if (upcomingAppointment[index].appointmentStatus!.toUpperCase() ==
                                                getTranslated(context, home_pending).toString()) {
                                              statusColor = Palette.dark_blue;
                                            } else if (upcomingAppointment[index].appointmentStatus!.toUpperCase() ==
                                                getTranslated(context, home_cancel).toString()) {
                                              statusColor = Palette.red;
                                            } else if (upcomingAppointment[index].appointmentStatus!.toUpperCase() ==
                                                getTranslated(context, home_approve).toString()) {
                                              statusColor = Palette.green.withOpacity(0.5);
                                            }
                                            return Column(
                                              children: [
                                                Container(
                                                  margin: EdgeInsets.all(10),
                                                  width: width * 0.95,
                                                  child: Card(
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(10.0),
                                                    ),
                                                    elevation: 10,
                                                    color: index % 2 == 0 ? Palette.light_blue : Palette.white,
                                                    child: Column(
                                                      children: [
                                                        Container(
                                                          margin: EdgeInsets.only(top: 10, left: 12, right: 12),
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Row(
                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                children: [
                                                                  Container(
                                                                    child: Text(
                                                                      getTranslated(context, home_bookingId).toString(),
                                                                      style: TextStyle(
                                                                          fontSize: 14,
                                                                          color: index % 2 == 0 ? Palette.white : Palette.blue,
                                                                          fontWeight: FontWeight.bold),
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    upcomingAppointment[index].appointmentId!,
                                                                    style: TextStyle(
                                                                        fontSize: 14, color: Palette.black, fontWeight: FontWeight.bold),
                                                                  ),
                                                                ],
                                                              ),
                                                              Container(
                                                                child: Text(
                                                                  upcomingAppointment[index].appointmentStatus!.toUpperCase(),
                                                                  style: TextStyle(
                                                                      fontSize: 14, color: statusColor, fontWeight: FontWeight.bold),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Container(
                                                          margin: EdgeInsets.only(
                                                            top: 10,
                                                          ),
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Container(
                                                                width: width * 0.15,
                                                                child: Column(
                                                                  children: [
                                                                    Container(
                                                                      width: 40,
                                                                      height: 40,
                                                                      decoration: new BoxDecoration(shape: BoxShape.circle, boxShadow: [
                                                                        new BoxShadow(
                                                                          color: Palette.blue,
                                                                          blurRadius: 1.0,
                                                                        ),
                                                                      ]),
                                                                      child: CachedNetworkImage(
                                                                        alignment: Alignment.center,
                                                                        imageUrl: upcomingAppointment[index].doctor!.fullImage!,
                                                                        imageBuilder: (context, imageProvider) => CircleAvatar(
                                                                          radius: 50,
                                                                          backgroundColor: Palette.white,
                                                                          child: CircleAvatar(
                                                                            radius: 18,
                                                                            backgroundImage: imageProvider,
                                                                          ),
                                                                        ),
                                                                        placeholder: (context, url) =>
                                                                            SpinKitFadingCircle(color: Palette.blue),
                                                                        errorWidget: (context, url, error) =>
                                                                            Image.asset("assets/images/no_image.jpg"),
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                              Container(
                                                                width: width * 0.75,
                                                                // color: Colors.red,
                                                                child: Column(
                                                                  children: [
                                                                    Container(
                                                                      alignment: AlignmentDirectional.topStart,
                                                                      child: Column(
                                                                        children: [
                                                                          Text(
                                                                            upcomingAppointment[index].doctor!.name!,
                                                                            style: TextStyle(
                                                                              fontSize: 16,
                                                                              color: index % 2 == 0 ? Palette.white : Palette.dark_blue,
                                                                            ),
                                                                            overflow: TextOverflow.ellipsis,
                                                                          )
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    Container(
                                                                      alignment: AlignmentDirectional.topStart,
                                                                      margin: EdgeInsets.only(top: 3),
                                                                      child: Column(
                                                                        children: [
                                                                          Text(
                                                                            upcomingAppointment[index].doctor!.treatment!.name!,
                                                                            style: TextStyle(
                                                                                fontSize: 12,
                                                                                color: index % 2 == 0 ? Palette.white : Palette.grey),
                                                                            overflow: TextOverflow.ellipsis,
                                                                          )
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    Container(
                                                                      alignment: AlignmentDirectional.topStart,
                                                                      margin: EdgeInsets.only(top: 3),
                                                                      child: Column(
                                                                        children: [
                                                                          Text(
                                                                            upcomingAppointment[index].doctor!.hospital!.address!,
                                                                            style: TextStyle(
                                                                                fontSize: 12,
                                                                                color: index % 2 == 0 ? Palette.white : Palette.grey),
                                                                            overflow: TextOverflow.ellipsis,
                                                                          )
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Container(
                                                          margin: EdgeInsets.only(top: 10),
                                                          child: Column(
                                                            children: [
                                                              Divider(
                                                                height: 2,
                                                                color: index % 2 == 0 ? Palette.white : Palette.dark_grey,
                                                                thickness: width * 0.001,
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                        Container(
                                                          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                                          child: Column(
                                                            children: [
                                                              Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  Container(
                                                                    child: Text(
                                                                      getTranslated(context, home_dateTime).toString(),
                                                                      style: TextStyle(
                                                                        fontSize: 12,
                                                                        color: index % 2 == 0 ? Palette.white : Palette.grey,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    child: Text(
                                                                      getTranslated(context, home_patientName).toString(),
                                                                      style: TextStyle(
                                                                        fontSize: 12,
                                                                        color: index == 0
                                                                            ? Palette.white
                                                                            : index % 2 == 0
                                                                                ? Palette.white
                                                                                : Palette.grey,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  Container(
                                                                    child: Text(
                                                                      upcomingAppointment[index].date! +
                                                                          '  ' +
                                                                          upcomingAppointment[index].time!,
                                                                      style: TextStyle(fontSize: 12, color: Palette.dark_blue),
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    child: Text(
                                                                      upcomingAppointment[index].patientName!,
                                                                      style: TextStyle(fontSize: 12, color: Palette.dark_blue),
                                                                      overflow: TextOverflow.ellipsis,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : SizedBox(),




                      // Treatments  //
                    Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child:Column(
                        children: [
                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(
                                    left: width * 0.05,
                                    top: width * 0.05,
                                    right: width * 0.05,
                                  ),
                                  alignment: AlignmentDirectional.topStart,
                                  child: Row(
                                    children: [
                                      Text(
                                        getTranslated(context, home_treatments).toString(),
                                        style: TextStyle(
                                          fontSize: width * 0.05,
                                          color: Palette.dark_blue,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(context, 'Treatment');
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(
                                      right: width * 0.05,
                                      top: width * 0.06,
                                      left: width * 0.05,
                                    ),
                                    alignment: AlignmentDirectional.topEnd,
                                    child: Row(
                                      children: [
                                        Text(
                                          getTranslated(context, home_viewAll).toString(),
                                          style: TextStyle(fontSize: width * 0.035, color: Palette.blue),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 220,
                            width: width,
                            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                ListView.builder(
                                  itemCount: 4 <= treatmentList.length ? 4 : treatmentList.length,
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => TreatmentSpecialist(
                                              treatmentList[index].id,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        // color: Colors.teal,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              height: 100,
                                              alignment: AlignmentDirectional.center,
                                              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                                              child: CachedNetworkImage(
                                                alignment: Alignment.center,
                                                imageUrl: treatmentList[index].fullImage!,
                                                fit: BoxFit.fill,
                                                placeholder: (context, url) =>
                                                // CircularProgressIndicator(),
                                                SpinKitFadingCircle(
                                                  color: Palette.blue,
                                                ),
                                                errorWidget: (context, url, error) => Image.asset("assets/images/no_image.jpg"),
                                              ),
                                            ),
                                            Container(
                                              //width: 70,
                                              //height: 35,
                                              margin: EdgeInsets.symmetric(horizontal: 0, vertical: 5),
                                              child: Text(
                                                treatmentList[index].name!,
                                                style: TextStyle(
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.bold,
                                                  color: Palette.dark_blue,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                            Container(
                                              //width: 70,
                                              //height: 35,
                                              margin: EdgeInsets.symmetric(horizontal: 0, vertical: 5),
                                              child: Text(
                                                treatmentList[index].name!,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Palette.dark_blue,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                      // Doctor Specialist List //
                      Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Column(
                          children: [
                            Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(left: width * 0.05, right: width * 0.05),
                                    alignment: AlignmentDirectional.topStart,
                                    child: Row(
                                      children: [
                                        Text(
                                          getTranslated(context, home_specialist).toString(),
                                          style: TextStyle(fontSize: width * 0.05, color: Palette.dark_blue),
                                        )
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(context, 'Specialist');
                                    },
                                    child: Container(
                                      margin: EdgeInsets.only(right: width * 0.05, left: width * 0.05),
                                      child: Row(
                                        children: [
                                          Text(
                                            getTranslated(context, home_viewAll).toString(),
                                            style: TextStyle(fontSize: width * 0.035, color: Palette.blue),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: height * 0.24,
                              width: width * 1,
                              margin: EdgeInsets.symmetric(vertical: width * 0.04, horizontal: width * 0.03),
                              child: _searchResult.length > 0 || _search.text.isNotEmpty
                                  ? ListView(
                                scrollDirection: Axis.horizontal,
                                children: [
                                  ListView.builder(
                                    physics: NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: _searchResult.length,
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (context, index) {
                                      favoriteDoctor.clear();
                                      for (int i = 0; i < _searchResult.length; i++) {
                                        _searchResult[i].isFaviroute == false ? favoriteDoctor.add(false) : favoriteDoctor.add(true);
                                      }
                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => Doctordetail(
                                                _searchResult[index].id,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          width: width * 0.4,
                                          child: Card(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10.0),
                                            ),
                                            child: Column(
                                              children: [
                                                Column(
                                                  children: [
                                                    Stack(
                                                      children: [
                                                        Container(
                                                          margin: EdgeInsets.all(width * 0.02),
                                                          width: width * 0.35,
                                                          height: height * 0.15,
                                                          child: ClipRRect(
                                                            borderRadius: BorderRadius.all(
                                                              Radius.circular(10),
                                                            ),
                                                            child: CachedNetworkImage(
                                                              alignment: Alignment.center,
                                                              imageUrl: _searchResult[index].fullImage!,
                                                              fit: BoxFit.fitHeight,
                                                              placeholder: (context, url) => SpinKitFadingCircle(color: Palette.blue),
                                                              errorWidget: (context, url, error) =>
                                                                  Image.asset("assets/images/no_image.jpg"),
                                                            ),
                                                          ),
                                                        ),
                                                        Positioned(
                                                          top: 5,
                                                          right: 0,
                                                          child: Container(
                                                            child: SharedPreferenceHelper.getBoolean(Preferences.is_logged_in) == true
                                                                ? IconButton(
                                                              onPressed: () {
                                                                setState(
                                                                      () {
                                                                    favoriteDoctor[index] == false
                                                                        ? favoriteDoctor[index] = true
                                                                        : favoriteDoctor[index] = false;
                                                                    doctorID = _searchResult[index].id;
                                                                    CallApiFavoriteDoctor();
                                                                  },
                                                                );
                                                              },
                                                              icon: Icon(
                                                                Icons.favorite_outlined,
                                                                size: 25,
                                                                color:
                                                                favoriteDoctor[index] == false ? Palette.white : Palette.red,
                                                              ),
                                                            )
                                                                : IconButton(
                                                              onPressed: () {
                                                                setState(
                                                                      () {
                                                                    Fluttertoast.showToast(
                                                                      msg: getTranslated(context, home_pleaseLogin_toast)
                                                                          .toString(),
                                                                      toastLength: Toast.LENGTH_SHORT,
                                                                      gravity: ToastGravity.BOTTOM,
                                                                      backgroundColor: Palette.blue,
                                                                      textColor: Palette.white,
                                                                    );
                                                                  },
                                                                );
                                                              },
                                                              icon: Icon(
                                                                Icons.favorite_outlined,
                                                                size: 25,
                                                                color:
                                                                favoriteDoctor[index] == false ? Palette.white : Palette.red,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                Container(
                                                  width: width * 0.4,
                                                  margin: EdgeInsets.only(top: width * 0.02),
                                                  child: Column(
                                                    children: [
                                                      Text(
                                                        _searchResult[index].name!,
                                                        style: TextStyle(
                                                            fontSize: width * 0.04,
                                                            color: Palette.dark_blue,
                                                            fontWeight: FontWeight.bold),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  width: width * 0.4,
                                                  child: Column(
                                                    children: [
                                                      _searchResult[index].treatment != null
                                                          ? Text(
                                                        _searchResult[index].treatment!.name.toString(),
                                                        style: TextStyle(fontSize: width * 0.035, color: Palette.grey),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      )
                                                          : Text(
                                                        getTranslated(context, home_notAvailable).toString(),
                                                        style: TextStyle(fontSize: width * 0.035, color: Palette.grey),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                ],
                              )
                                  : doctorlist.length > 0
                                  ? ListView(
                                scrollDirection: Axis.horizontal,
                                children: [
                                  ListView.builder(
                                    physics: NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: 3 <= doctorlist.length ? 3 : doctorlist.length,
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (context, index) {
                                      favoriteDoctor.clear();
                                      for (int i = 0; i < doctorlist.length; i++) {
                                        doctorlist[i].isFaviroute == false ? favoriteDoctor.add(false) : favoriteDoctor.add(true);
                                      }

                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => Doctordetail(
                                                doctorlist[index].id,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          width: width * 0.4,
                                          child: Card(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10.0),
                                            ),
                                            child: Column(
                                              children: [
                                                Column(
                                                  children: [
                                                    Stack(
                                                      children: [
                                                        Container(
                                                          margin: EdgeInsets.all(width * 0.02),
                                                          width: width * 0.35,
                                                          height: height * 0.15,
                                                          child: ClipRRect(
                                                            borderRadius: BorderRadius.all(Radius.circular(10)),
                                                            child: CachedNetworkImage(
                                                              alignment: Alignment.center,
                                                              imageUrl: doctorlist[index].fullImage!,
                                                              fit: BoxFit.fitHeight,
                                                              placeholder: (context, url) =>
                                                                  SpinKitFadingCircle(color: Palette.blue),
                                                              errorWidget: (context, url, error) =>
                                                                  Image.asset("assets/images/no_image.jpg"),
                                                            ),
                                                          ),
                                                        ),
                                                        Positioned(
                                                          top: 5,
                                                          right: 0,
                                                          child: Container(
                                                            child:
                                                            SharedPreferenceHelper.getBoolean(Preferences.is_logged_in) == true
                                                                ? IconButton(
                                                              onPressed: () {
                                                                setState(
                                                                      () {
                                                                    favoriteDoctor[index] == false
                                                                        ? favoriteDoctor[index] = true
                                                                        : favoriteDoctor[index] = false;
                                                                    doctorID = doctorlist[index].id;
                                                                    CallApiFavoriteDoctor();
                                                                  },
                                                                );
                                                              },
                                                              icon: Icon(
                                                                Icons.favorite_outlined,
                                                                size: 25,
                                                                color: favoriteDoctor[index] == false
                                                                    ? Palette.white
                                                                    : Palette.red,
                                                              ),
                                                            )
                                                                : IconButton(
                                                              onPressed: () {
                                                                setState(
                                                                      () {
                                                                    Fluttertoast.showToast(
                                                                      msg: getTranslated(context, home_pleaseLogin_toast)
                                                                          .toString(),
                                                                      toastLength: Toast.LENGTH_SHORT,
                                                                      gravity: ToastGravity.BOTTOM,
                                                                      backgroundColor: Palette.blue,
                                                                      textColor: Palette.white,
                                                                    );
                                                                  },
                                                                );
                                                              },
                                                              icon: Icon(
                                                                Icons.favorite_outlined,
                                                                size: 25,
                                                                color: favoriteDoctor[index] == false
                                                                    ? Palette.white
                                                                    : Palette.red,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                Container(
                                                  width: width * 0.4,
                                                  margin: EdgeInsets.only(top: width * 0.02),
                                                  child: Column(
                                                    children: [
                                                      Text(
                                                        doctorlist[index].name!,
                                                        style: TextStyle(
                                                            fontSize: width * 0.04,
                                                            color: Palette.dark_blue,
                                                            fontWeight: FontWeight.bold),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  width: width * 0.4,
                                                  child: Column(
                                                    children: [
                                                      doctorlist[index].treatment != null
                                                          ? Text(
                                                        doctorlist[index].treatment!.name.toString(),
                                                        style: TextStyle(fontSize: width * 0.035, color: Palette.grey),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      )
                                                          : Text(
                                                        getTranslated(context, home_notAvailable).toString(),
                                                        style: TextStyle(fontSize: width * 0.035, color: Palette.grey),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                ],
                              )
                                  : Center(
                                child: Container(
                                  child: Text(
                                    getTranslated(context, home_notAvailable).toString(),
                                    style: TextStyle(fontSize: width * 0.05, color: Palette.grey, fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),


                      // Offer //
                      offerList.length != 0
                          ? Column(
                              children: [
                                Container(
                                  alignment: AlignmentDirectional.topStart,
                                  margin: EdgeInsets.only(left: width * 0.05, top: width * 0.05, right: width * 0.05),
                                  child: Column(
                                    children: [
                                      Text(
                                        getTranslated(context, home_offers).toString(),
                                        style: TextStyle(fontSize: width * 0.05, color: Palette.dark_blue),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  height: 180,
                                  width: width * 1,
                                  child: ListView.builder(
                                    itemCount: offerList.length,
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (context, index) {
                                      return Container(
                                        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                        child: Container(
                                          height: 160,
                                          width: 175,
                                          child: Card(
                                            color:
                                                index % 2 == 0 ? Palette.light_blue.withOpacity(0.9) : Palette.offer_card.withOpacity(0.9),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10.0),
                                            ),
                                            child: Column(
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                                                  child: Container(
                                                    height: 40,
                                                    margin: EdgeInsets.symmetric(vertical: 5),
                                                    child: Center(
                                                      child: Text(
                                                        offerList[index].name!,
                                                        style:
                                                            TextStyle(fontSize: 16, color: Palette.dark_blue, fontWeight: FontWeight.bold),
                                                        textAlign: TextAlign.center,
                                                        overflow: TextOverflow.ellipsis,
                                                        maxLines: 2,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  margin: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                                                  child: Column(
                                                    children: [
                                                      DottedLine(
                                                        direction: Axis.horizontal,
                                                        lineLength: double.infinity,
                                                        lineThickness: 1.0,
                                                        dashLength: 3.0,
                                                        dashColor: index % 2 == 0
                                                            ? Palette.light_blue.withOpacity(0.9)
                                                            : Palette.offer_card.withOpacity(0.9),
                                                        dashRadius: 0.0,
                                                        dashGapLength: 1.0,
                                                        dashGapColor: Palette.transparent,
                                                        dashGapRadius: 0.0,
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                if (offerList[index].discountType == "amount" && offerList[index].isFlat == 0)
                                                  Container(
                                                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                                    child: Text(
                                                      getTranslated(context, home_flat).toString() +
                                                          ' ' +
                                                          SharedPreferenceHelper.getString(Preferences.currency_symbol).toString() +
                                                          offerList[index].discount.toString(),
                                                      style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight: FontWeight.bold,
                                                        color: Palette.dark_blue,
                                                      ),
                                                    ),
                                                  ),
                                                if (offerList[index].discountType == "percentage" && offerList[index].isFlat == 0)
                                                  Container(
                                                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                                    // alignment: Alignment.topLeft,
                                                    child: Text(
                                                      offerList[index].discount.toString() +
                                                          getTranslated(context, home_discount).toString(),
                                                      style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight: FontWeight.bold,
                                                        color: Palette.dark_blue,
                                                      ),
                                                    ),
                                                  ),
                                                if (offerList[index].discountType == "amount" && offerList[index].isFlat == 1)
                                                  Container(
                                                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                                    child: Text(
                                                      getTranslated(context, home_flat).toString() +
                                                          SharedPreferenceHelper.getString(Preferences.currency_symbol).toString() +
                                                          offerList[index].flatDiscount.toString(),
                                                      style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight: FontWeight.bold,
                                                        color: Palette.dark_blue,
                                                      ),
                                                    ),
                                                  ),
                                                Container(
                                                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                  decoration: BoxDecoration(color: Palette.white, borderRadius: BorderRadius.circular(10)),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8),
                                                    child: SelectableText(
                                                      offerList[index].offerCode!,
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        // fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            )
                          : Container(),

                      // looking For //
                      Column(
                        children: [
                          Container(
                            alignment: AlignmentDirectional.topStart,
                            margin: EdgeInsets.only(left: 20, right: 20, top: 10),
                            child: Column(
                              children: [
                                Text(
                                  getTranslated(context, home_lookingFor).toString(),
                                  style: TextStyle(fontSize: width * 0.04, color: Palette.dark_blue),
                                ),
                              ],
                            ),
                          ),
                          //banners
                          Container(
                            //height: 210,
                            margin: EdgeInsets.symmetric(vertical: 0, horizontal: 5),
                            child: Card(
                              color: Palette.white,
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                                alignment: Alignment.center,
                                //height: 200,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20),
                                  ),
                                  color: Palette.white,
                                ),
                                child: Stack(
                                  children: <Widget>[
                                    CarouselSlider(
                                      options: CarouselOptions(
                                        height: 200,
                                        viewportFraction: 1.0,
                                        autoPlay: true,
                                        onPageChanged: (index, index1) {
                                          setState(
                                            () {
                                              _current = index;
                                            },
                                          );
                                        },
                                      ),
                                      items: banner.map((bannerData) {
                                        return Builder(
                                          builder: (BuildContext context) {
                                            return InkWell(
                                              onTap: () async {
                                                await launch(bannerData.link!);
                                              },
                                              child: Column(
                                                children: [
                                                  Row(
                                                    children: [
                                                      Container(
                                                        alignment: Alignment.topLeft,
                                                        child: Stack(
                                                          children: <Widget>[
                                                            Material(
                                                              color: Palette.white,
                                                              borderRadius: BorderRadius.circular(15.0),
                                                              elevation: 2.0,
                                                              clipBehavior: Clip.antiAliasWithSaveLayer,
                                                              type: MaterialType.transparency,
                                                              child: CachedNetworkImage(
                                                                imageUrl: bannerData.fullImage!,
                                                                fit: BoxFit.fill,
                                                                //height: height * 0.12,
                                                                width: width*0.92,
                                                                placeholder: (context, url) => SpinKitFadingCircle(color: Palette.blue),
                                                                errorWidget: (context, url, error) => Image.asset("images/no_image.png"),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),

                                                    ],
                                                  ),

                                                ],
                                              ),
                                            );
                                          },
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    */
  }

  onSearchTextChanged(String text) async {
    _searchResult.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    doctorlist.forEach((appointmentData) {
      if (appointmentData.name.toLowerCase().contains(text.toLowerCase())) _searchResult.add(appointmentData);
    });

    setState(() {});
  }

  fetchFeaturedCategories() async {
    var categoryResponse = await CategoryRepository().getFeturedCategories();
    _featuredCategoryList.addAll(categoryResponse.categories);
    _isCategoryInitial = false;
    setState(() {});
  }

  getPermission() async {
    if (await Permission.location.isRestricted) {
      Permission.location.request();
      if (await Permission.location.isRestricted || await Permission.location.isDenied) {
        Permission.location.request();
      }
    }
    if (await Permission.storage.isDenied) {
      Permission.storage.request();
      if (await Permission.storage.isDenied || await Permission.storage.isDenied) {
        Permission.storage.request();
      }
    }
  }

}
