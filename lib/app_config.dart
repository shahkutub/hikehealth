import 'package:flutter/material.dart';

var this_year = DateTime.now().year.toString();

class AppConfig {
  static String copyright_text = "@ Hike Health " + this_year; //this shows in the splash screen
  static String app_name = "Hike Health Ltd."; //this shows in the splash screen
  static String purchase_code = ""; //enter your purchase code for the app from codecanyon
  //static String purchase_code = ""; //enter your purchase code for the app from codecanyon

  //Default language config
  static String default_language ="en";
  static String mobile_app_code ="en";
  static bool app_language_rtl =false;

  //configure this
  static const bool HTTPS = true;
  //https://med.lulumart.a2hosted.com/
  //configure this
  // static const DOMAIN_PATH = "192.168.1.238/demo_ecommerce"; //localhost
  //static const DOMAIN_PATH = "lulumart.com.bd"; //inside a folder
  static const DOMAIN_PATH = "med.lulumart.a2hosted.com"; //inside a folder
  //static const DOMAIN_PATH = "mydomain.com"; // directly inside the public folder

  //do not configure these below
  static const String API_ENDPATH = "api/v2";
  static const String PUBLIC_FOLDER = "public";
  static const String PROTOCOL = HTTPS ? "https://" : "http://";
  static const String RAW_BASE_URL = "${PROTOCOL}${DOMAIN_PATH}";
  static const String BASE_URL = "${RAW_BASE_URL}/${API_ENDPATH}";

  //configure this if you are using amazon s3 like services
  //give direct link to file like https://[[bucketname]].s3.ap-southeast-1.amazonaws.com/
  //otherwise do not change anythink
  static const String BASE_PATH = "${RAW_BASE_URL}/${PUBLIC_FOLDER}/";
  //static const String BASE_PATH = "https://tosoviti.s3.ap-southeast-2.amazonaws.com/";
}
