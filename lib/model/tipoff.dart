
class Tipoff{

  int id;
  int? userId;
  int? targetId;
  int? targetType;
  String? reason;
  String? descrip;
  String? pics;
  DateTime? createTime;

  Tipoff(this.id);

  Map<String, Object?> toJson(){
    Map<String, Object?> map = {};
    map['id'] = id;
    map['userId'] = userId;
    map['targetId'] = targetId;
    map['targetType'] = targetType;
    map['reason'] = reason;
    map['descrip'] = descrip;
    map['pics'] = pics;
    map['createTime'] = createTime?.millisecondsSinceEpoch;
    return map;
  }
}


const TIPOFFABLE_TYPE_GUIDE = 1;
const TIPOFFABLE_TYPE_HOTEL = 2;
const TIPOFFABLE_TYPE_VIDEO = 3;
const TIPOFFABLE_TYPE_RESTAURAT = 4;
const TIPOFFABLE_TYPE_SPOT = 5;
const TIPOFFABLE_TYPE_TRAVEL = 6;
const TIPOFFABLE_TYPE_CIRCLE = 7;
const TIPOFFABLE_TYPE_PRODUCT_ANSWER = 21;
const TIPOFFABLE_TYPE_CIRCLE_ANSWER = 22;
const TIPOFFABLE_TYPE_PRODUCT_COMMENT = 23;
const TIPOFFABLE_TYPE_PRODUCT_COMMENT_SUB = 24;

enum TipoffableType{
  guide,
  hotel,
  video,
  restaurant,
  spot,
  travle,
  circle,
  productAnswer,
  circleAnswer,
  productComment,
  productCommentSub
}

extension TipoffableTypeExt on TipoffableType{
  int getNum(){
    switch(this){
      case TipoffableType.guide:
        return TIPOFFABLE_TYPE_GUIDE;
      case TipoffableType.hotel:
        return TIPOFFABLE_TYPE_HOTEL;
      case TipoffableType.video:
        return TIPOFFABLE_TYPE_VIDEO;
      case TipoffableType.restaurant:
        return TIPOFFABLE_TYPE_RESTAURAT;
      case TipoffableType.spot:
        return TIPOFFABLE_TYPE_SPOT;
      case TipoffableType.travle:
        return TIPOFFABLE_TYPE_TRAVEL;
      case TipoffableType.circle:
        return TIPOFFABLE_TYPE_CIRCLE;
      case TipoffableType.productAnswer:
        return TIPOFFABLE_TYPE_PRODUCT_ANSWER;
      case TipoffableType.circleAnswer:
        return TIPOFFABLE_TYPE_CIRCLE_ANSWER;
      case TipoffableType.productComment:
        return TIPOFFABLE_TYPE_PRODUCT_COMMENT;
      case TipoffableType.productCommentSub:
        return TIPOFFABLE_TYPE_PRODUCT_COMMENT_SUB;
    }
  }
  static TipoffableType? getType(int num){
    for(TipoffableType type in TipoffableType.values){
      if(type.getNum() == num){
        return type;
      }
    }
    return null;
  }
}
