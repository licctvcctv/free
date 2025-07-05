
import 'package:flutter/material.dart';

class RouteObserverUtil{

  static RouteObserverUtil instance = RouteObserverUtil._internal();
  RouteObserverUtil._internal();
  factory RouteObserverUtil(){
    return instance;
  }

  final RouteObserver<PageRoute> routeObserver = RouteObserver();
}
