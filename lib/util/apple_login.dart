
import 'dart:io';

import 'package:freego_flutter/http/http_user.dart';
import 'package:freego_flutter/model/user.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AppleLogin{

  AppleLogin._internal();
  static final AppleLogin _instance = AppleLogin._internal();
  factory AppleLogin(){
    return _instance;
  }

  Future<bool> check() async{
    if(!Platform.isIOS){
      return false;
    }
    return await SignInWithApple.isAvailable();
  }

  Future<String?> getIdentityToken() async{
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName
      ]
    );
    return credential.identityToken;
  }

  Future<UserModel?> login() async{
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.fullName,
        AppleIDAuthorizationScopes.email,
      ]
    );
    String? identityToken = credential.identityToken;
    String? userName = (credential.familyName ?? '') + (credential.givenName ?? '');
    if(userName.isEmpty){
      userName = null;
    }
    String? email = credential.email;
    if(identityToken == null){
      return null;
    }
    UserModel? user = await HttpUser.loginByApple(identityToken: identityToken, userName: userName, email: email);
    return user;
  }
}
