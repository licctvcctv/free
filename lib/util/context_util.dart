
import 'package:flutter/material.dart';

class ContextUtil {

  static late GlobalKey<NavigatorState> _navigatorKey;

  static init(GlobalKey<NavigatorState> key){
    _navigatorKey = key;
  }

  static BuildContext? getContext(){
    return _navigatorKey.currentContext;
  }
}
