
import 'package:freego_flutter/components/product_neo/product_common.dart';

class LabelUtil{

  static String getProductName(ProductType type){
    switch(type){
      case ProductType.guide:
        return '攻略';
      case ProductType.hotel:
        return '酒店';
      case ProductType.video:
        return '视频';
      case ProductType.restaurant:
        return '饭店';
      case ProductType.scenic:
        return '景点';
      case ProductType.travel:
        return '旅行';
      case ProductType.circle:
        return '圈子';
      case ProductType.circleQuestionAnswer:
        return '回答';
      case ProductType.productQuestion:
        return '提问';
      case ProductType.productQuestionAnswer:
        return '回答';
      case ProductType.productComment:
        return '评论';
      case ProductType.productCommentSub:
        return '回复';
    }
  }
}
