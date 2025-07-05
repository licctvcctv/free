
import 'package:flutter/material.dart';
import 'package:freego_flutter/http/http.dart';

class CommonWidget{

  static Widget getHeadWidget({String? url, double size = 48}){
    if(url != null){
      url = getFullUrl(url);
    }
    return ClipOval(
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        width: size,
        height: size,
        child: url == null ?
        Image.asset('images/default_head.png', fit: BoxFit.cover, width: double.infinity, height: double.infinity,) :
        Image.network(url, fit: BoxFit.cover, width: double.infinity, height: double.infinity,)
      ),
    );
  }
}
