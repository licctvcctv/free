
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freego_flutter/model/user.dart';
import 'package:freego_flutter/model/user_fo.dart';

UserModel loginedUser = UserModel(0,'');
final userProvider = StateProvider<UserModel>((ref){
  return loginedUser;
});

UserFoModel loginedUserFo = UserFoModel(0);
final userFoProvider = StateProvider<UserFoModel>((ref) => loginedUserFo);
