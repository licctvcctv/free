
enum ProductType{
  guide,
  hotel,
  video,
  restaurant,
  scenic,
  travel,
  circle,
  circleQuestionAnswer,
  productQuestion,
  productQuestionAnswer,
  productComment,
  productCommentSub
}

extension ProductTypeExt on ProductType{
  int getNum(){
    switch(this){
      case ProductType.guide:
        return 1;
      case ProductType.hotel:
        return 2;
      case ProductType.video:
        return 3;
      case ProductType.restaurant:
        return 4;
      case ProductType.scenic:
        return 5;
      case ProductType.travel:
        return 6;
      case ProductType.circle:
        return 7;
      case ProductType.circleQuestionAnswer:
        return 8;
      case ProductType.productQuestion:
        return 21;
      case ProductType.productQuestionAnswer:
        return 22;
      case ProductType.productComment:
        return 23;
      case ProductType.productCommentSub:
        return 24;
    }
  }

  String getVal(){
    switch(this){
      case ProductType.guide:
        return 'guide';
      case ProductType.hotel:
        return 'hotel';
      case ProductType.video:
        return 'video';
      case ProductType.restaurant:
        return 'restaurant';
      case ProductType.scenic:
        return 'scenic';
      case ProductType.travel:
        return 'travel';
      case ProductType.circle:
        return 'circle';
      case ProductType.circleQuestionAnswer:
        return 'circleQuestionAnswer';
      case ProductType.productQuestion:
        return 'productQuestion';
      case ProductType.productQuestionAnswer:
        return 'productQuestionAnswer';
      case ProductType.productComment:
        return 'productComment';
      case ProductType.productCommentSub:
        return 'productCommentSub';
    }
  }

  static ProductType? getType(int num){
    for(ProductType type in ProductType.values){
      if(type.getNum() == num){
        return type;
      }
    }
    return null;
  }

  static ProductType? getTypeByVal(String val){
    for(ProductType type in ProductType.values){
      if(type.getVal() == val){
        return type;
      }
    }
    return null;
  }

  T visit<T>(ProductTypeVisitor<T> visitor){
    return visitor.visit(this);
  }
}

abstract class ProductTypeVisitor<T>{

  T visit(ProductType type);
}

class ProductTypeNameVisitor extends ProductTypeVisitor<String?>{

  ProductTypeNameVisitor._internal();
  static final ProductTypeNameVisitor _instance = ProductTypeNameVisitor._internal();
  factory ProductTypeNameVisitor(){
    return _instance;
  }

  @override
  String? visit(ProductType type) {
    switch(type){
      case ProductType.guide:
        return '攻略';
      case ProductType.hotel:
        return '酒店';
      case ProductType.video:
        return '视频';
      case ProductType.restaurant:
        return '美食';
      case ProductType.scenic:
        return '景点';
      case ProductType.travel:
        return '旅行';
      case ProductType.circle:
        return '圈子';
      default:
        return null;
    }
  }
  
}
