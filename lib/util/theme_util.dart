
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ThemeUtil{

  static ThemeUtil instance = ThemeUtil._internal();
  ThemeUtil._internal();
  factory ThemeUtil(){
    return instance;
  }

  static const Color dividerColor = Color.fromRGBO(203,211,220,1);
  static const Color backgroundColor = Color.fromRGBO(242, 245, 250, 1);
  static const Color foregroundColor = Color.fromRGBO(78, 89, 105, 1);
  static const Color dialogueColor = Color.fromRGBO(0x95, 0xEC, 0x69, 1);
  static const Color buttonColor = Color.fromRGBO(0x4, 0xb6, 0xdd, 1);
  static const AssetImage defaultUserHeadProvider = AssetImage('images/chat/default_avatar.jpg');
  static Widget defaultUserHead = Image.asset('images/chat/default_avatar.jpg', width: double.infinity, height: double.infinity, fit: BoxFit.fill,);
  static const AssetImage defaultGroupAvatarProvider = AssetImage('images/freego_216.png');
  static Widget defaultGroupAvatar = Image.asset('images/freego_216.png');
  static Widget defaultCover = Image.asset('images/bg.png', width: double.infinity, height: double.infinity, fit: BoxFit.cover,);
  static Widget anonymousUserHead = Image.asset('images/anonymous.png', width: double.infinity, height: double.infinity, fit: BoxFit.fill,);

  static const SystemUiOverlayStyle statusBarThemeDark = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarBrightness: Brightness.light,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark
  );
  static const SystemUiOverlayStyle statusBarThemeLight = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarBrightness: Brightness.dark,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.light
  );

  static void setStatusBarStyle(SystemUiOverlayStyle style){
    SystemChrome.setSystemUIOverlayStyle(style);
  }
  static void setStatusBarLight(){
    SystemChrome.setSystemUIOverlayStyle(statusBarThemeLight);
  }
  static void setStatusBarDark(){
    SystemChrome.setSystemUIOverlayStyle(statusBarThemeDark);
  }
  static double getStatusBarHeight(BuildContext context){
    return MediaQuery.of(context).viewPadding.top;
  }
}
