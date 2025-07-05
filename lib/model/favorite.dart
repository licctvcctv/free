
import 'package:intl/intl.dart';

class Favorite{
  late int id;
  int? userId;
  int? pid;
  String? name;
  String? pic;
  int? productId;
  int? productType;
  DateTime? createTime;
  List<Favorite>? children;
  Favorite(this.id);
  Favorite.fromJson(dynamic json){
    id = json['id'];
    userId = json['userId'];
    pid = json['pid'];
    name = json['name'];
    pic = json['pic'];
    productId = json['productId'];
    productType = json['productType'];
    createTime = DateTime.tryParse(json['createTime']);
  }
  Map<String, Object?> toJson(){
    Map<String, Object?> map = {};
    map['id'] = id;
    map['userId'] = userId;
    map['pid'] = pid;
    map['name'] = name;
    map['pic'] = pic;
    map['productId'] = productId;
    map['productTpye'] = productType;
    if(createTime != null){
      map['createTime'] = DateFormat('yyyy-MM-dd HH:mm:ss').format(createTime!);
    }
    return map;
  }
}

enum FavoriteType{
  dir,
  guide,
  hotel,
  video,
  restaurant,
  spot,
  travel,
  circle
}

extension FavoriteTypeExt on FavoriteType{
  int getNum(){
    switch(this){
      case FavoriteType.dir:
        return 0;
      case FavoriteType.guide:
        return 1;
      case FavoriteType.hotel:
        return 2;
      case FavoriteType.video:
        return 3;
      case FavoriteType.restaurant:
        return 4;
      case FavoriteType.spot:
        return 5;
      case FavoriteType.travel:
        return 6;
      case FavoriteType.circle:
        return 7;
    }
  }
  static FavoriteType? getType(int num){
    for(FavoriteType type in FavoriteType.values){
      if(type.getNum() == num){
        return type;
      }
    }
    return null;
  }
}

extension FavoriteListExt on List<Favorite>{

  void sortById(){
    sort((f1, f2){
      if(f1.id < f2.id){
        return -1;
      }
      else if(f1.id > f2.id){
        return 1;
      }
      else{
        return 0;
      }
    });
  }
}
