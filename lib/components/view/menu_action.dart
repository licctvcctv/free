import 'package:flutter/material.dart';

enum CommonMenuAction{
  showMenu,
  hideMenu
}

class CommonMenuController extends ChangeNotifier{

  CommonMenuAction? action;
  void showMenu(){
    action = CommonMenuAction.showMenu;
    notifyListeners();
  }
  void hideMenu(){
    action = CommonMenuAction.hideMenu;
    notifyListeners();
  }
}
