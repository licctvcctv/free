
import 'package:flutter/material.dart';

class FrameCallbackUtil{

  List<Function(Duration)> list = [];
  static final FrameCallbackUtil instance = FrameCallbackUtil._internal();

  factory FrameCallbackUtil(){
    return instance;
  }
  FrameCallbackUtil._internal(){
    WidgetsBinding.instance.addPersistentFrameCallback((timeStamp) {
      for(Function(Duration) func in list){
        func(timeStamp);
      }
    });
  }

  bool addFrameCallback(Function(Duration) callback){
    if(list.contains(callback)){
      return false;
    }
    list.add(callback);
    return true;
  }
  bool removeFrameCallback(Function(Duration) callback){
    return list.remove(callback);
  }
}
