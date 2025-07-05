
import 'package:flutter/material.dart';
import 'package:freego_flutter/components/customer/customer_center.dart';
import 'package:freego_flutter/components/user/user_center.dart';
import 'package:freego_flutter/model/user.dart';
import 'package:freego_flutter/util/local_user.dart';

class UserHomeDirector{
  UserHomeDirector._internal();
  static final UserHomeDirector _instance = UserHomeDirector._internal();
  factory UserHomeDirector(){
    return _instance;
  }

  void goUserHome({required BuildContext context, required int userId}){
    UserModel? user = LocalUser.getUser();
    if(user != null && user.id == userId){
      Navigator.of(context).push(MaterialPageRoute(builder: (context){
        return const UserCenterPage();
      }));
    }
    else{
      Navigator.of(context).push(MaterialPageRoute(builder: (context){
        return CustomerCenterPage(userId);
      }));
    }
  }
}
